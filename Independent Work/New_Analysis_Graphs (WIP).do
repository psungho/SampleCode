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

* Generate locals for labels and colours
loc labGI	"Trade, Accomm., Food"
loc labG	"Trade"
loc labI	"Accomm., Food"
loc labFL	"Construction/RE"
loc labF	"Construction"
loc labL	"Real estate"
loc labC	"Manufacturing"
loc labBC	"Manuf., Mining"
loc labA	"Agriculture"
loc labHH	"Households"
loc colGI	"$color1"
loc colG	"$color1"
loc colI	"$color1"
loc colFL	"$color2"
loc colF	"$color2"
loc colL	"$color3"
loc colC	"$color6"
loc colBC	"$color6"
loc colB	"$color5"
loc colA	"$color7"
loc colHH	"$color4"
glo areaopts "lwidth(none) color(gs14%50)"
glo lineopts "yaxis(1) legend(off)"
glo labopts  "yaxis(2) ms(i) ytitle("", axis(2)) yscale(lc(none) axis(2))"

* Set Scheme
set scheme modern
* Basic options
glo areaopts "lwidth(none) color(gs14%50)"
glo lineopts "yaxis(1) legend(off)"
glo labopts  "yaxis(2) ms(i) ytitle("", axis(2)) yscale(lc(none) axis(2))"
* Sectors of interest:
** EAST ASIAN CRISIS
replace  HH_mortgage = HH_other if country_name== "Philippines" & HH_mortgage == .
* encode(country3d), gen(country_id)
tsset country_id year
   * Index to 1990
   foreach i in  HH T NT BC FL GI{
      gen temp_gdp_`i' =gdp_`i' if year == 1990
      bysort country3d: egen scale_`i' = max(temp_gdp_`i')
      gen index_`i' =  100 * (gdp_`i'/scale)
      drop temp_gdp_`i' scale_`i'
   }
   * gen byte baseyear = 1 if year == 1990
   *foreach i of global tradable {
   *   bysort country_id (baseyear):   replace index_`i' = 100*gdp_`i'/gdp_`i'[1]
   *   }
   *   bysort country_id (baseyear):   replace index_HH = 100*gdp_HH/gdp_HH[1]

   gen cdate = 750 if year>=1998 & year<=1997
twoway (area cdate year, $areaopts) (line C_GDP F_GDP L_GDP GI_GDP HH_GDP year, $lineopts lcolor(`colC' `colF' `colL' `colGI' `colHH') subtitle("{bf:Credit to GDP}" "Index (1999=100)", pos(11)) ylab(100(100)750)) (scatteri 100 2014 "" 100 2014 "", $labopts ylabel(`posC_GDP' "`labC'" `posHH_GDP' "`labHH'" `posL_GDP' "`labL'" `posGI_GDP' "`labGI'", labsize(medsmall) axis(2))),  xtitle("") xlabel(1995(5)2015) yscale(range(50 750) axis(1)) yscale(range(50 750) axis(2)) text(242 2011.3 "- Construction", size(medsmall))
   * egen NT =  rowtotal(F G H J K L D E)
   * egen T   = rowtotal(A B C)
   * replace NT= . if (NT == 0)
   * replace T= . if (T == 0)


*Regression Obsevation
   ivreghdfe crisis d1_HH_3  d1_NT_3 d1_T_3 if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
   ivreghdfe crisis d1_HH_3    if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
   ivreghdfe crisis   d1_NT_3  if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
   ivreghdfe crisis d1_T_3 if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
* Graphs
glo asia MYS KOR THA PHL JPN SGP HKG IDN TWN
glo var_initial index_HH index_T index_NT
glo var_secondary index_HH  index_BC   index_FL  index_GI
glo thick_first medthick medthick medthick medthick
foreach a of glo asia {
    preserve
    drop if country3d!="`a'"
    keep if year>=1985
    foreach b in  HH T NT BC FL GI{
      gen temp=`var' if year==1985
      bysort country_id: egen scale=max(temp)
      replace `var' = 100 * (`var'/scale)
      drop temp scale
   }
  foreach svar in HH T NT BC FL GI {
    cap sum index_`var' if year==2000
    cap loc pos`var'_VA = r(mean)
    qui sum `var'_GDP if year==2000
    loc pos`var'_GDP = r(mean)
 }
 gen cdate = 750 if year>=1997 & year<=1998

restore
    }
