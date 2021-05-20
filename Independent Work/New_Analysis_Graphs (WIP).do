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
   foreach i in A HH T NT BC FL GI{
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

foreach var in A BC FL GI HH NT T{
   	qui sum index_`var' if year==2000
   	loc pos`var'_GDP = r(mean)
   }

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
* Index to 1900
foreach i in  HH T NT BC FL GI{
   gen temp_gdp_`i' =gdp_`i' if year == 1990
   bysort country3d: egen scale_`i' = max(temp_gdp_`i')
   gen index_`i' =  100 * (gdp_`i'/scale_`i')
   drop temp_gdp_`i' scale_`i'
}

foreach i in  HH T NT BC FL GI{
   gen temp_gdp_`i'_85 =gdp_`i' if year == 1985
   bysort country3d: egen scale_`i'_85 = max(temp_gdp_`i')
   gen index_`i'_85 =  100 * (gdp_`i'/scale_`i'_85)
   drop temp_gdp_`i'_85 scale_`i'_85
}

foreach i in  HH T NT BC FL GI{
   gen temp_gdp_`i'_00 =gdp_`i' if year == 2000
   bysort country3d: egen scale_`i'_00 = max(temp_gdp_`i')
   gen index_`i'_00 =  100 * (gdp_`i'/scale_`i'_00)
   drop temp_gdp_`i'_00 scale_`i'_00
}



tsset country_id year
glo asia MYS KOR THA PHL JPN SGP HKG IDN TWN
glo var_initial index_HH index_T index_NT
glo var_secondary index_HH  index_BC   index_FL  index_GI
glo thick_first medthick medthick medthick medthick
levelsof country3d, loc(clevels)
foreach var in HH  BC   FL  GI A T NT{
      foreach l of local clevels {
          qui sum index_`var'_85 if year==2000 &  country3d=="`l'"
          loc pos_`var'_`l'_85= r(mean)
      }
}
foreach i of glo asia{
 tsline  $var_initial if year <=2000 & year>=1985 & country3d=="`i'", ///
 lwidth($thick_first) ///
 xtitle(Years, size(vsmall)) ///
 legend(label(1 "Households") label(2 "Tradables") ///
 label(3 "Non-Tradables") size(vsmall)) ///
 title("`i': Indexed Credit to GDP (in %) (1990=100)", size(small)) ///
 legend(region(style(none))  style(zyx2)  size(vsmall) ring(1) pos(6)) ///
 xsize(10) ysize(10) ///
 xline(1997.5, lwidth(5.5) lc(gs14%55) lpattern(solid)) legend(size(tiny)) ///
 xline(1997 1998, lcolor(gs14%55) lpattern(solid)) legend(off) graphregion(margin(r+2)) ///
 text(`pos_HH_`i''  2000 "Households", size(vsmall)) text(`pos_T_`i''  2000 "Tradables", size(vsmall)) text(`pos_NT_`i''  2000 "Non-Tradables", size(vsmall))
 graph export "$user/Documents/GitHub/SampleCode/Independent Work/`i'_AFC_HHTNT.png", replace
 tsline $var_secondary      if year <=2000 & year>=1985 & country3d=="`i'", ///
  lwidth($thick_first) xtitle(Years, size(vsmall))  ///
  legend(label(1 "Households") label(2 "Manufacturing") ///
  label(3 "Construction/RE") label(4 "Trade, Accomm., Food") size(vsmall)) ///
  xline(1997.5, lwidth(5.5) lc(gs15%55) lpattern(solid)) legend(region(style(none))) ///
  legend(off) graphregion(margin(r+2)) ///
  title("`i': Indexed Credit to GDP (in %) (1990=100)", size(small)) ///
   text(`pos_HH_`i''  2000 "Households", size(vsmall)) text(`pos_BC_`i''  2000 "Manufacturing", size(vsmall)) text(`pos_FL_`i''  2000 "Construction/RE", size(vsmall)) ///
   text(`pos_GI_`i''  2000 "Trade, Accomm., Food", size(vsmall))  ///
  xsize(10) ysize(10) ///
  xline(1997 1998, lcolor(gs14%55) lpattern(solid))
  graph export "$user/Documents/GitHub/SampleCode/Independent Work/`i'_AFC_MCT.png", replace
}
