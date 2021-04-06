***SET UP
* Clear workspace
	ssc install ietoolkit, replace
	ssc install ritest, replace
	clear
	clear frames
  macro drop _all
  set more off
* Define the user name depending on operating system
  if c(os) == "Windows" global user "C:/Users/`c(username)'"
  if c(os) == "MacOSX"  global user "/Users/`c(username)'"
  display "User name: $user"
* Path to folder
  global myfolder = "$user/Desktop/RA_Wantchekon"
* Output to folder
  global output = "$myfolder"
* set globals
  glo covariates female Employed Farmers Monogamous Polygamist  Single Widowed   Divorced ethn_Yoruba ethn_Yorma ethn_Other ethn_Fulani ethn_Ditamari ethn_Dendi ethn_Bariba age Languages_Knwn FormalEduc LevelEduc
	glo cov_demographics 	female Employed Farmers Monogamous Polygamist  Single Widowed   Divorced  age Languages_Knwn FormalEduc LevelEduc
	glo cov_ethnic  ethn_Yoruba ethn_Yorma ethn_Other ethn_Fulani ethn_Ditamari ethn_Dendi ethn_Bariba
	global votevar q26 q28


** load Dataset (Individual)
frame rename default Individual
use  "$myfolder/Individual_Dataset.dta", replace
** load Dataset (Village)
frame create Village
frame change Village
use "$myfolder/Village_Dataset.dta", replace
replace turnout = turnout/100
replace turnout = 1 if turnout>1
** Create shareinfo variables
frame change Individual
decode(q26), gen(q26_s)
decode(q28), gen(q28_s)

foreach v of glo votevar {
  gen `v'_d = 1 if `v'_s=="yes"
  replace `v'_d = 0 if `v'_s=="not"
}

gen shareinfo_alt = q26_d + q28_d
gen shareinfo = shareinfo_alt
replace shareinfo = 1 if shareinfo > 1 & shareinfo!=.
collapse (mean) shareinfo_alt shareinfo, by(village_excel q1_4)

** link shareinfo variables

frame change Village
frlink m:1 q1_4 village_excel, frame(Individual)
frget shareinfo_alt shareinfo, from(Individual)
** Generate Balance Table for Covariates
iebaltab $covariates, grpvar(treat_vil) ///
savetex("$myfolder\balancetable.tex") ///
replace onenrow ftest rowvarlabel

** Calculate AIE and Output Results
loc k
eststo: qui reg turnout treat_vil
foreach i of glo covariates {
	loc k `k' `i'
	eststo:  qui reg turnout treat_vil `k', noomitted

}

esttab * using AIE.tex, replace noobs nonum noomit
eststo clear
qui reg turnout treat_vil $covariates
qui gen AIE =  _b[treat_vil]
	* Calculate By Demographic
	qui eststo: reg turnout treat_vil, noomitted
	estadd local aie_cov "None"
	qui eststo: reg turnout treat_vil $cov_demographics, noomitted
	estadd local aie_cov "Demographics"
	qui eststo: reg turnout treat_vil $cov_ethnic, noomitted
	estadd local aie_cov "Ethnic"
	qui eststo: reg turnout treat_vil $covariates, noomitted
	estadd local aie_cov "All"
	esttab * using AIE_comp.tex, replace noobs nonum noomit scalars("aie_cov")
	eststo clear


** Calculate AED/AED_alt and Output Results
loc j
eststo: qui reg shareinfo treat_vil
foreach i of glo covariates {
	loc j `j' `i'
	eststo: qui reg shareinfo treat_vil `j', noomitted
}

esttab * using AED.tex, replace noobs nonum noomit
eststo clear
eststo: qui reg shareinfo_alt treat_vil
foreach i of glo covariates {
	loc p `p' `i'
	eststo: qui reg shareinfo_alt treat_vil `p', noomitted
}
esttab *  using AED_alt.tex, replace noobs nonum noomit
eststo clear
qui reg shareinfo treat_vil $covariates
qui gen AED =  _b[treat_vil]
qui reg shareinfo_alt treat_vil $covariates
qui gen AED_alt =  _b[treat_vil]
	* Calculate By Demographic
	qui eststo: reg shareinfo treat_vil, noomitted
	estadd local aed_cov "None"
	qui eststo: reg shareinfo treat_vil $cov_demographics, noomitted
	estadd local aed_cov "Demographic"
	qui eststo: reg shareinfo treat_vil $cov_ethnic, noomitted
	estadd local aed_cov "Ethnic"
	qui eststo: reg shareinfo treat_vil $covariates, noomitted
	estadd local aed_cov "All"
	esttab * using AED_comp.tex, replace noobs nonum noomit scalars("aed_cov")
	eststo clear
	qui eststo: reg shareinfo_alt treat_vil, noomitted
	estadd local aed_cov2 "All"
	qui eststo: reg shareinfo_alt treat_vil $cov_demographics, noomitted
	estadd local aed_cov2 "Demographics"
	qui eststo: reg shareinfo_alt treat_vil $cov_ethnic, noomitted
	estadd local aed_cov2 "Ethnic"
	qui eststo: reg shareinfo_alt treat_vil $covariates, noomitted
	estadd local aed_cov2 "All"
	esttab * using AED_alt_comp.tex, replace noobs nonum noomit scalars("aed_cov2")
	eststo clear
** Calculate APE and Output Results
loc z
eststo: qui ivreg2 turnout (shareinfo = treat_vil)
foreach i of glo covariates {
	loc z `z' `i'
	eststo: qui ivreg2 turnout (shareinfo = treat_vil) `z', noomitted
}
esttab *  using APE.tex, replace noobs nonum noomit
eststo clear

loc a
eststo: qui ivreg2 turnout (shareinfo_alt = treat_vil)
foreach i of glo covariates {
	loc `a' `i'
	eststo: qui ivreg2 turnout (shareinfo_alt = treat_vil) `a', noomitted
}
esttab *  using APE_alt.tex, replace noobs nonum noomit
eststo clear

qui gen APE = AIE/AED
qui gen APE_alt = AIE/AED_alt
	* Calculate By Demographic
	qui eststo: ivreg2 turnout (shareinfo = treat_vil), noomitted
	estadd local ape_cov "None"
	qui eststo: ivreg2 turnout (shareinfo = treat_vil)  $cov_demographics, noomitted
	estadd local ape_cov "Demographics"
	qui eststo: ivreg2 turnout (shareinfo = treat_vil)  $cov_ethnic, noomitted
	estadd local ape_cov "Ethnic"
	qui eststo: ivreg2 turnout (shareinfo = treat_vil)  $covariates, noomitted
	estadd local ape_cov "All"
	esttab * using APE_comp.tex, replace noobs nonum noomit scalars("ape_cov")
	eststo clear
	qui eststo: ivreg2 turnout (shareinfo_alt = treat_vil), noomitted
	estadd local ape_cov2 "None"
	qui eststo: ivreg2 turnout (shareinfo_alt = treat_vil)  $cov_demographics, noomitted
	estadd local ape_cov2 "Demographics"
	qui eststo: ivreg2 turnout (shareinfo_alt = treat_vil)  $cov_ethnic, noomitted
	estadd local ape_cov2 "Ethnic"
	qui eststo: ivreg2 turnout (shareinfo_alt = treat_vil)  $covariates, noomitted
	estadd local ape_cov2 "All"
	esttab * using APE_alt_comp.tex, replace noobs nonum noomit scalars("ape_cov2")
	eststo clear
** Output  APE/AED/AIE/AED

estpost sum AIE AED APE
esttab using output.tex, cells("count mean") noobs replace

estpost sum AIE AED_alt APE_alt
esttab using output_alt.tex, cells("count mean") noobs replace
