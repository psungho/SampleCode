	clear
	clear frames
  macro drop _all
  set more off
  if c(os) == "Windows" global user "C:/Users/`c(username)'"
  if c(os) == "MacOSX"  global user "/Users/`c(username)'"
  display "User name: $user"
  global myfolder = "$user/Documents/GitHub/SampleCode/Independent Work"
  global output = "$myfolder"
	use  "/Users/sunghopark/Dropbox/For Sungho/SectoralCredit_Full_Feb20.dta"
  * Crisis, Non-tradable and Tradable Prep
	gen crisis = bcrisis_bvx
	replace crisis = bcrisis_lv if crisis == .

	global sectors Corp NFC A A1_2 A1 A2  ///
	   A3 BC B B5 B6 B7 B8_9 C C10_11 C10_12 ///
	   C10 C11_12 C11 C12 C13_15 C13 C14_15 ///
	   C14 C15 C16 C16_18 C17_18 C17 C18 C19 ///
	   C19_21 C19_22 C19_23 C20_21 C21 C20_22 ///
	   C22 C23 C24_25 C24_28 C24 C25_28 C25_30 ///
	   C25 C26_27 C26_28 C26_30 C26 C27 C28 C29_30 ///
	   C29 C30 C31 C32 DEHJ DE D E FL F GI G G45 G46 G47 ///
	   HJ H H49_52 H49 H50 H51 H53 J I I55 I56 KLMN KL K ///
	   K64 K65 K66 LMNPQRS LMN L MN MNOPQRS MNPQRS M N OPQRS O PQRS ///
	   PQ P Q RS R Z HH HH_consumer Mortgage_all HH_mortgage ///
	   HH_CreditCards HH_Car HH_other LMNOPQRS HH_nonmortgage
	qui{
	egen New_GI =  rowtotal(G I)
	egen New_FL = rowtotal(F L)
	egen New_HJ = rowtotal(H J)
	egen New_DE = rowtotal(D E)
	egen New_BC = rowtotal(B C)
	foreach x in GI FL HJ DE BC{
	   replace New_`x'= . if (New_`x' == 0)
	   replace New_`x'= `x' if New_`x' < `x' & `x'!=.
	   replace `x' = New_`x' if `x'==.
	}
}
	egen T = rowtotal(A BC)
	egen NT = rowtotal(DE HJ FL GI)
	foreach x in T NT{
	   replace `x' = . if `x' == 0
	}
	encode(country3d), gen(country_id)
	tsset country_id year
	foreach i of global sectors {
	   gen gdp_`i' = `i'/GDP
	   }
	foreach x in  T NT {
	   gen gdp_`x' = `x'/GDP
	}

	* Debt Changes
	forval j=2/6{
	foreach i of global sectors {
		 local J = `j'-1
		  cap gen d2_`i'_`J' = (l.gdp_`i' - l`j'.gdp_`i')
		 }
	}
	forval j=2/6{
	foreach i of global sectors {
	local J = `j'-1
	cap gen d1_`i'_`J' = (l.`i' - l`j'.`i')/l`j'.GDP
	}
}
forval j=2/6{
foreach i in T NT{
	 local J = `j'-1
	 cap gen d2_`i'_`J' = (l.gdp_`i' - l`j'.gdp_`i')
	 }
}
forval j=2/6{
foreach i in T NT{
local J = `j'-1
cap gen d1_`i'_`J' = (l.`i' - l`j'.`i')/l`j'.GDP
}
}


	* Summary stats
	eststo summary: estpost sum  T NT d1_T_3 d1_HH_3 d1_NT_3
esttab summary using summary.tex, ///
cell("count(label(Count)) mean(label(Mean)) sd(label(Std. Deviation)) min(label(Minimum)) max(label(Maximum))") ///
label nonumber nomtitle replace
 eststo clear


***HAMILTON FILER
gen lnrGDP=ln(rGDP)
global hamilvars lnrGDP Total_GDP  gdp_NT gdp_HH gdp_T
levelsof country_id, local(country)
preserve
keep country_id country year $hamilvars
local h = 4

foreach var in $hamilvars {
	qui gen v_`var' = .  // Hamilton-filtered cyclical component
	qui gen y_`var' = .  // trend component
	qui gen y_hpred = .
	qui gen v_h     = .
	foreach c in `country' {

		qui sum `var' if country_id==`c'
		if r(N)>=20 {

			qui reg F`h'.`var' `var' L1.`var' L2.`var' L3.`var' if country_id==`c', robust
			qui predict temp, xb
			qui replace y_hpred=temp           if country_id==`c'
			qui replace v_h=F`h'.`var'-y_hpred if country_id==`c'
			qui replace v_`var'=L`h'.v_h       if country_id==`c'
			qui replace y_`var'=`var' - v_`var'
			drop temp

		}
	}
	drop v_h y_hpred
}
xtset country_id year

save "hamilton_filtered.dta", replace

foreach x of varlist $hamilvars {

	by id: egen sd   = sd(v_`x')

	*** (1) "Booms #1": Simple. First year that threshold is crossed
	gen E1 = (v_`x'>sd*1.00)  if v_`x'~=.
	bysort id (year): gen change = E1 != E1[_n-1] if E1[_n-1]~=.
	by id: gen spell = sum(change)
	bysort id spell (year): gen yaE = cond(E1, _n, 0)
	* first year threshold crossed (among successive years beyond threshold)
	gen     E1_start = 0 if v_`x'~=.
	replace E1_start = 1 if yaE==1 & v_`x'~=.
	* peak of boom
	bysort id spell: egen max_v_`x' = max(v_`x') if E1==1 & v_`x'~=.
	gen E1_peak = (max_v_`x'==v_`x') if v_`x'~=.
	drop spell yaE change max_v_`x'
	* set start to 0 if there is a start a couple years earlier that is part of same boom event
	xtset id year
	global psi = 0.5
	replace E1_start = 0 if E1_start==1 & L2.E1_start==1 & L.v_`x'> ${psi}*sd

	* "start" of boom, capped at 5 years before identifying boom
	gen start_thr = . // distance from start to when threshold crossed
	global phi =0.5   // start threshold
	gen     E1_start_0 = 0 if v_`x'~=.
	replace start_thr = 1  if F.E1_start==1 & (v_`x'< ${phi}*sd)
	replace E1_start_0 = 1 if F.E1_start==1 & (v_`x'< ${phi}*sd)
	replace start_thr = 2  if F2.E1_start==1 & F1.E1_start_0==0 & (v_`x'< ${phi}*sd)
	replace E1_start_0 = 1 if F2.E1_start==1 & F1.E1_start_0==0 & (v_`x'< ${phi}*sd)
	replace start_thr  = 3 if F3.E1_start==1 & F2.E1_start_0==0 & F1.E1_start_0==0 & (v_`x'< ${phi}*sd)
	replace E1_start_0 = 1 if F3.E1_start==1 & F2.E1_start_0==0 & F1.E1_start_0==0 & (v_`x'< ${phi}*sd)
	replace start_thr  = 4 if F4.E1_start==1 & F3.E1_start_0==0 & F2.E1_start_0==0 & F1.E1_start_0==0 & (v_`x'< ${phi}*sd)
	replace E1_start_0 = 1 if F4.E1_start==1 & F3.E1_start_0==0 & F2.E1_start_0==0 & F1.E1_start_0==0 & (v_`x'< ${phi}*sd)
	replace start_thr  = 5 if F5.E1_start==1 & F4.E1_start_0==0 & F3.E1_start_0==0 & F2.E1_start_0==0 & F1.E1_start_0==0
	replace E1_start_0 = 1 if F5.E1_start==1 & F4.E1_start_0==0 & F3.E1_start_0==0 & F2.E1_start_0==0 & F1.E1_start_0==0

	* start to peak of boom, capped at five years
	gen     start_peak = . // distance from start to peak
	replace start_peak = 1  if E1_peak==1   & (L.v_`x'< ${phi}*sd)
	replace start_peak = 2  if E1_peak==1   & start_peak~=1 & (L2.v_`x'< ${phi}*sd)
	replace start_peak = 3  if E1_peak==1   & start_peak~=1 & start_peak~=2 & (L3.v_`x'< ${phi}*sd)
	replace start_peak = 4  if E1_peak==1   & start_peak~=1 & start_peak~=2 & start_peak~=3 & (L4.v_`x'< ${phi}*sd)
	replace start_peak = 5  if E1_peak==1   & start_peak~=1 & start_peak~=2 & start_peak~=3 & start_peak~=4


	ren E1 E1_`x'
	ren E1_start E1_start_`x'
	ren E1_start_0 E1_start_0_`x'
	ren E1_peak E1_peak_`x'
	ren start_thr start_thr_`x'
	ren start_peak start_peak_`x'


	*** (2) "Booms #2": Find years threshold is crossed. Then include nearby years above a less stringent threshold
	gen E_tmp = (v_`x'>sd*1.00)  if v_`x'~=.
		* if near a boom, then set to boom if above less strict threshold
		global phi=0.7 // less strict threshold
		xtset id year
		gen     E2 = E_tmp
		replace E2 = 1 if F.E_tmp==1  & (v_`x'> ${phi}*sd) & v_`x'~=.
		replace E2 = 1 if L.E_tmp==1  & (v_`x'> ${phi}*sd) & v_`x'~=.
		replace E2 = 1 if F2.E_tmp==1 & F1.E2==1 & (v_`x'> ${phi}*sd) & v_`x'~=.
		replace E2 = 1 if L2.E_tmp==1 & L1.E2==1 & (v_`x'> ${phi}*sd) & v_`x'~=.
		replace E2 = 1 if F3.E_tmp==1 & F2.E2==1 & F1.E2==1 & (v_`x'> ${phi}*sd) & v_`x'~=.
		replace E2 = 1 if L3.E_tmp==1 & L2.E2==1 & L1.E2==1 & (v_`x'> ${phi}*sd) & v_`x'~=.
		replace E2 = 1 if F4.E_tmp==1 & F3.E2==1 & F2.E2==1 & F1.E2==1 & (v_`x'> ${phi}*sd) & v_`x'~=.
		replace E2 = 1 if L4.E_tmp==1 & L3.E2==1 & L2.E2==1 & L1.E2==1 & (v_`x'> ${phi}*sd) & v_`x'~=.

	bysort id (year): gen change = E2 != E2[_n-1] if E2[_n-1]~=.
	by id: gen spell = sum(change)
	bysort id spell (year): gen yaE = cond(E2, _n, 0)
	gen     E2_start = 0 if v_`x'~=.
	replace E2_start = 1 if yaE==1 & v_`x'~=.
	drop spell yaE change E_tmp

	ren E2 E2_`x'
	ren E2_start E2_start_`x'
	drop sd
}

xtset id year

use "hamilton_filtered.dta", clear
merge 1:1 id year using "hamilton_filtered.dta", nogen

gen s_NT_HH = (gdp_HH + gdp_NT)/(gdp_HH + gdp_NT + gdp_T)

	foreach var of varlist s_NT_HH Total_GDP {
		gen D`var' = .
		forv i=1/5 {
			gen D`i'`var' = `var' - L`i'.`var'
		replace D`var'    = D`i'`var'   if E1_peak_Total_GDP==1 & start_peak_Total_GDP==`i'
		}
		replace D`var'    = D5`var'   if E1_peak_Total_GDP==0 & (crisis==1)
	}

xtset id year
gen Event = E1_start_Total_GDP
keep country_id id year Event  lnrGDP gdp_NT gdp_T gdp_HH v_Total_GDP
gen s_NT_HH = (gdp_NT + gdp_HH)/(gdp_NT + gdp_HH + gdp_T)

keep country_id year E1_peak_Total_GDP crisis Ds_NT_HH DTotal_GDP
keep if E1_peak_Total_GDP==1  | crisis==1
local W = 5
gen D`W's_NT_HH = s_NT_HH - L`W'.s_NT_HH
sum D`W's_NT_HH
gen Pos_NT_HH = (D`W's_NT_HH>0) if D`W's_NT_HH~=.
tab Pos_NT_HH if Event==1
 	egen N_v_Total_GDP = count(v_Total_GDP), by(id)
	drop if N_v_Total_GDP==0
   gen Ex1 = Event*Pos_NT_HH
   gen Ex0 = Event*(1-Pos_NT_HH)

export excel using "Case_study_events.xls", replace
