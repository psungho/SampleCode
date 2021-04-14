
* East Asian Financial Crisis
 tsset country_id year
glo asia MYS KOR THA PHL JPN SGP HKG IDN TWN
glo var_initial index_HH index_T index_NT
glo var_secondary index_HH  index_BC   index_FL  index_GI
glo thick_first medthick medthick medthick medthick
foreach i of glo asia {
 tsline  $var_initial if year <=2000 & year>=1985 & country3d=="`i'", ///
 lwidth($thick_first) ///
 xtitle(Years, size(vsmall)) ///
 legend(label(1 "Households") label(2 "Tradables") ///
 label(3 "Non-Tradables") size(vsmall)) ///
 title("`i': Indexed Credit to GDP (in %) (1990=100)", size(small)) ///
 legend(region(style(none))  style(zyx2)  size(vsmall) ring(1) pos(6)) ///
 xsize(10) ysize(10) ///
 xline(1997.5, lwidth(5.5) lc(gs14%55) lpattern(solid)) legend(size(tiny)) ///
 xline(1997 1998, lcolor(gs14%55) lpattern(solid))
 graph export "/Users/sunghopark/Desktop/Asian Graphs/`i'_AFC_HHTNT.png", replace
 tsline $var_secondary      if year <=2000 & year>=1985 & country3d=="`i'", ///
  lwidth($thick_first) xtitle(Years, size(vsmall)) ytitle(Indexed Credit/Nominal GDP, size(vsmall)) ///
  legend(label(1 "Households") label(2 "Manufacturing") ///
  label(3 "Construction/RE") label(4 "Trade, Accomm., Food") size(vsmall)) ///
  xline(1997.5, lwidth(7) lc(gs15%55) lpattern(solid)) legend(size(tiny)) ///
  xline(1997 1998, lcolor(gs15%55) lpattern(solid)) ///
  title("`i': Indexed Credit to GDP (in %) (1990=100)", size(small)) ///
  legend(region(style(none))  style(zyx2)  size(vsmall) ring(1) pos(6)) ///
  xsize(10) ysize(10) ///
  xline(1997.5, lwidth(5.5) lc(gs14%55) lpattern(solid)) legend(size(tiny)) ///
  xline(1997 1998, lcolor(gs14%55) lpattern(solid))
  graph export "/Users/sunghopark/Desktop/Asian Graphs/`i'_AFC_MCT.png", replace
}


foreach i of glo asia {
 tsline  $var_initial if year <=2000 & year>=1985 & country3d=="IDN", ///
 lwidth(medthick medthick medthick medthick) ///
 xtitle(Years, size(vsmall)) ///
 legend(label(1 "Households") label(2 "Tradables") ///
 label(3 "Non-Tradables") size(vsmall)) ///
 title("Indonesia: Indexed Credit to GDP (in %) (1990=100)", size(small)) ///
 legend(region(style(none))  style(zyx2)  size(vsmall) ring(1) pos(6)) ///
 xsize(10) ysize(10) ///
 xline(1997.5, lwidth(5.5) lc(gs14%55) lpattern(solid)) legend(size(tiny)) ///
 xline(1997 1998, lcolor(gs14%55) lpattern(solid))
 graph export "/Users/sunghopark/Desktop/Asian Graphs/IDN_AFC_HHTNT.png", replace
}

foreach i of glo asia {
 tsline  $var_initial if year <=2000 & year>=1985 & country3d=="IDN", ///
 lwidth(medthick medthick medthick medthick) ///
 xtitle(Years, size(vsmall)) ///
 legend(label(1 "Households") label(2 "Tradables") ///
 label(3 "Non-Tradables") size(vsmall)) ///
 title("Indonesia: Indexed Credit to GDP (in %) (1990=100)", size(small)) ///
 legend(region(style(none))  style(zyx2)  size(vsmall) ring(1) pos(6)) ///
 xsize(10) ysize(10) ///
 xline(1997.5, lwidth(5.5) lc(gs14%55) lpattern(solid)) legend(size(tiny)) ///
 xline(1997 1998, lcolor(gs14%55) lpattern(solid))
 graph export "/Users/sunghopark/Desktop/Asian Graphs/IDN_AFC_HHTNT.png", replace
}
* Eurozone Crisis
gen byte baseyear_Euro = 1 if year == 1999
foreach i of global tnt {
 bysort country_id (baseyear_Euro) : gen index_Euro_`i' = 100* gdp_`i'/gdp_`i'[1]
  }
tsset country_id year
** Spain
tsline index_Euro_HH  index_Euro_BC   index_Euro_FL  index_Euro_GI      if year <=2015 & year>=1995 & country3d=="ESP", ///
       lwidth(medthick medthick medthick medthick) xtitle(Years, size(vsmall)) ytitle(Indexed Credit/Nominal GDP, size(vsmall)) ///
       legend(region(style(none)) ring(0) pos(2) label(1 "Households") label(2 "Manufacturing") ///
       label(3 "Construction/RE") label(4 "Trade, Accomm., Food") size(vsmall)) ///
       xline(2010, lwidth(20) lc(gs15%55) lpattern(solid)) legend(size(tiny)) ///
       xline(2008 2012, lcolor(gs15%55) lpattern(solid))  ///
       title("Spain: Indexed Credit to GDP (in %) (1999=100)", size(small))

tsline index_Euro_HH index_Euro_T index_Euro_NT   if year <=2015 & year>=1995 & country3d=="ESP", ///
 lwidth(medthick medthick medthick)  xtitle(Years, size(vsmall)) ytitle(Indexed Credit/Nominal GDP, size(vsmall)) ///
  legend(region(style(none)) ring(0) pos(2) label(1 "Households") label(2 "Tradables") ///
  label(3 "Non-Tradables") size(vsmall)) ///
  xline(2010, lwidth(20) lc(gs15%55) lpattern(solid)) legend(size(tiny)) ///
  xline(2008 2012, lcolor(gs15%55) lpattern(solid)) ///
  title("Portugal: Indexed Credit to GDP (in %) (1990=100)", size(small))

** Portugal
tsline index_Euro_HH  index_Euro_BC  index_Euro_FL  index_Euro_GI      if year <=2015 & year>=1995 & country3d=="PRT", ///
     xtitle(Years, size(vsmall)) ytitle(Indexed Credit/Nominal GDP, size(vsmall)) ///
     lwidth(medthick medthick medthick medthick) legend(region(style(none)) ring(0) pos(10) ///
     label(1 "Households") label(2 "Manufacturing") ///
     label(3 "Construction/RE") label(4 "Trade, Accomm., Food") size(vsmall)) ///
     xline(2010, lwidth(16) lc(gs15%55) lpattern(solid)) legend(size(tiny)) ///
     xline(2008 2012, lcolor(gs15%55) lpattern(solid)) ///
     title("Portugal: Indexed Credit to GDP (in %) (1999=100)", size(small)) ///
     xsize(10) ysize(10)
tsline index_Euro_HH index_Euro_T index_Euro_NT   if year <=2015 & year>=1995 & country3d=="PRT", ///
     lwidth(medthick medthick medthick) xtitle(Years, size(vsmall)) ///
     ytitle(Indexed Credit/Nominal GDP, size(vsmall)) ///
     legend(region(style(none)) ring(0) pos(10) ///
     label(1 "Households") label(2 "Tradables") ///
     label(3 "Non-Tradables") size(vsmall)) ///
     xline(2010, lwidth(16) lc(gs15%55) lpattern(solid)) legend(size(tiny)) ///
     xline(2008 2012, lcolor(gs15%55) lpattern(solid)) ///
     title("Portugal: Indexed Credit to GDP (in %) (1999=100)", size(small)) ///
     xsize(10) ysize(10)

     ivreghdfe crisis d1_HH_3  d1_NT_3 d1_T_3 if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
     ivreghdfe crisis d1_HH_3    if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
     ivreghdfe crisis   d1_NT_3  if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)
     ivreghdfe crisis d1_T_3 if year<=2010& year>=1945 & population>=3.1 & (d1_HH_3!=0 &  d1_NT_3!=0 & d1_T_3 !=0), absorb(country_id year) cluster(country_id year)

gen severity_index = 0
replace severity_index= 39.8 if country3d=="ARG" & year==1980
replace severity_index= 17.2  if country3d=="BRA" & year==1990
replace severity_index= 26.9  if country3d=="CHL" & year==1980
replace severity_index= 26.9  if country3d=="CHL" & year==1980
replace severity_index= 8.7 if country3d=="MYS" & year==1985
replace severity_index= 31.1 if country3d=="MEX" & year==1981
replace severity_index = 57.0 if country3d=="PER" & year==1983
replace severity_index = 39.8 if country3d=="PHL" & year==1981
replace severity_index = 19.8 if country3d=="FIN" & year==1991
replace severity_index = 3.6 if country3d=="FIN" & year==1987
replace severity_index = 11.2 if country3d=="SWE" & year==1991
replace severity_index = 12.0 if country3d=="COL" & year==1998
replace severity_index = 2.1 if country3d=="JPN" & year==1992
replace severity_index = 10.7 if country3d=="MEX" & year==1994
replace severity_index = 7.2 if country3d=="RUS" & year==1998
replace severity_index = 38.2 if country3d=="VEN" & year==1994
replace severity_index = 23.1 if country3d=="IDN" & year==1998
replace severity_index = 8.7 if country3d=="JPN" & year==1997
replace severity_index = 8.4 if country3d=="KOR" & year==1997
replace severity_index = 15.8 if country3d=="MYS" & year==1997
replace severity_index = 5.7 if country3d=="PHL" & year==1997
replace severity_index = 19.6 if country3d=="THA" & year==1997
replace severity_index = 9.7 if country3d=="HKG" & year==1998
replace severity_index = 29.9 if country3d=="ARG" & year==2001
replace severity_index = 12.3 if country3d=="TUR" & year==2001
replace severity_index = 26.9 if country3d=="URY" & year==2002
replace severity_index = 9 if country3d=="FRA" & year==2008
replace severity_index = 3.0 if country3d=="DEU" & year==2008
replace severity_index = 36.0 if country3d=="USA" & year==2007
replace severity_index = 23.2 if country3d=="ISL" & year==2007
replace severity_index = 23.3 if country3d=="ITA" & year==2008
replace severity_index = 15.8 if country3d=="NLD" & year==2008
replace severity_index = 19.2 if country3d=="PRT" & year==2008
replace severity_index = 20.4 if country3d=="ESP" & year==2008
replace severity_index = 22.4 if country3d=="UKR" & year==2008
replace severity_index = 18.1 if country3d=="GBR" & year==2007
