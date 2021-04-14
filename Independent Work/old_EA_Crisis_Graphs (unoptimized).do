
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

tsline

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

