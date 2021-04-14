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
* Data preprocessing

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
* Index to 1990
foreach var in  {
   gen temp `i' if year == 1990
   bysort country_id: egen scale = max(temp)
   replace `var' = 100 * (`var'/scale)
   }
   * gen byte baseyear = 1 if year == 1990
   *foreach i of global tradable {
   *   bysort country_id (baseyear):   replace index_`i' = 100*gdp_`i'/gdp_`i'[1]
   *   }
   *   bysort country_id (baseyear):   replace index_HH = 100*gdp_HH/gdp_HH[1]
foreach var in  {
   	qui sum `var' if year==2000
   	loc pos`var'_GDP = r(mean)
}

replace  HH_mortgage = HH_other if country_name== "Philippines" & HH_mortgage == .
egen NT =  rowtotal(F G H J K L D E)
egen T   = rowtotal(A B C)
replace NT= . if (NT == 0)
replace T= . if (T == 0)


*Regression Obsevation
ivreghdfe crisis d1_HH_3  d1_NT_3 d1_T_3 if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
ivreghdfe crisis d1_HH_3    if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
ivreghdfe crisis   d1_NT_3  if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
ivreghdfe crisis d1_T_3 if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
