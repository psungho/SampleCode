clear all
macro drop _all
egen NT_Piton =  rowtotal(D R G O F E P Q L)
egen T_Piton   = rowtotal(B  C I  A H N  M J  K)
replace NT_Piton= . if (NT_Piton == 0)
replace T_Piton= . if (T_Piton == 0)
egen NT_Muller = rowtotal(DE  FL  GI  HJ)
egen T_Muller   = rowtotal(A  BC)
replace  NT_Muller= . if (NT_Muller == 0)
replace T_Muller= . if (T_Muller == 0)
egen NT =  rowtotal(F G H J K L D E)
egen T   = rowtotal(A B C)
replace NT_Kala= . if (NT_Kala == 0)
replace T_Kala= . if (T_Kala == 0)
egen New_GI =  rowtotal(G I)
egen New_FL = rowtotal(F L)
egen New_HJ = rowtotal(H J)
egen New_DE = rowtotal(D E)
egen New_BC = rowtotal(B C)
replace New_GI= . if (New_GI == 0)
replace New_FL= . if (New_FL == 0)
replace New_HJ= . if (New_HJ == 0)
replace New_DE= . if (New_DE == 0)
replace New_BC= . if (New_BC == 0)
replace New_GI= GI if New_GI < GI & GI!=.
replace New_GI = GI if New_GI==.
replace New_FL= FL if New_FL < FL & FL!=.
replace New_FL = FL if New_FL ==.
replace New_HJ= HJ if New_HJ < HJ & HJ!=.
replace New_HJ = HJ if New_HJ ==.
replace New_DE= DE if New_DE < DE & DE!=.
replace New_DE = DE if New_DE ==.
replace New_BC= BC if New_BC < BC & BC!=.
replace New_BC = BC if New_BC==.

replace GI = New_GI if GI==.
replace FL = New_FL if FL==.
replace HJ = New_HJ if HJ==.
replace DE = New_DE if DE==.
replace BC = New_BC if BC==.

egen T = rowtotal(A BC)
egen NT = rowtotal(DE HJ FL GI)
replace T = . if T == 0
replace NT = . if NT == 0

replace  HH_mortgage = HH_other if country_name== "Philippines" & HH_mortgage == .
egen New_Tradables =rowtotal(New_DE New_FL New_GI New_HJ)
egen New_Non_Tradables = rowtotal(A New_BC)
replace New_Tradables= . if (New_Tradables == 0)
replace New_Non_Tradables= . if (New_Non_Tradables == 0)

egen NT =  rowtotal(F G H J K L D E)
egen T   = rowtotal(A B C)
replace NT= . if (NT == 0)
replace T= . if (T == 0)


global trade New_Tradables New_Non_Tradables NT_Kala T_Kala NT_Muller T_Muller NT_Piton T_Piton
global tnt T NT
global combinedsectors GI FL HJ DE BC
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

tsset country_id year


foreach i of global sectors {
      replace gdp_`i' = `i'/GDP
      }
foreach i of global trade {
      replace gdp_`i' = `i'/GDP
      }
foreach i of global tnt {
            replace gdp_`i' = `i'/GDP
            }
foreach i of global combinedsectors {
      replace gdp_New_`i' = New_`i'/GDP
      }
forval j=2/6{
   foreach i of global sectors {
      local J = `j'-1
      replace d2_`i'_`J' = (l.gdp_`i' - l`j'.gdp_`i')
         }
      }
forval j=2/6{
   foreach i of global tnt {
      local J = `j'-1
      replace d2_`i'_`J' = (l.gdp_`i' - l`j'.gdp_`i')
            }
         }
forval j=2/6{
   foreach i of global combinedsectors {
      local J = `j'-1
      gen d2_New_`i'_`J' = (l.gdp_New_`i' - l`j'.gdp_New_`i')
            }
         }

forval j=2/6{
   foreach i of global sectors{
      local J = `j'-1
      replace d1_`i'_`J' = (l.`i' - l`j'.`i')/l`j'.GDP
         }
      }
forval j=2/6{
   foreach i of global tnt{
      local J = `j'-1
      replace d1_`i'_`J' = (l.`i' - l`j'.`i')/l`j'.GDP
            }
      }

forval j=2/6{
   foreach i of global combinedsectors{
      local J = `j'-1
      replace d1_New_`i'_`J' = (l.New_`i' - l`j'.New_`i')/l`j'.GDP
            }
      }

   gen byte baseyear = 1 if year == 1990
   foreach i of global tnt {
         bysort country3d (baseyear): replace index_`i' = 100 *  gdp_`i'/gdp_`i'[1]
         }
   foreach i of global sectors {
         bysort country3d (baseyear):   replace index_`i' = 100*gdp_`i'/gdp_`i'[1]
         }
   foreach i of global combinedsectors {
         bysort country3d (baseyear):   gen index_New_`i' = 100*gdp_New_`i'/gdp_New_`i'[1]
         }
   sort  country3d year

global realGDP rGDPpc rGDP

forval j=0/4{
   foreach i of global realGDP{
      local J = `j'+1
      gen d_`i'_`J' = (F.`i' - l`j'.`i')
            }
      }

forval j=0/4{
   foreach i of global realGDP{
      local J = `j'+1
      gen PCTC_`i'_`J' = (F.`i'-l`j'.`i' )/(l`j'.`i')
                  }
            }

*Great Recession

gen byte baseyear2 = 1 if year == 2000
foreach i of global sectors {
   bysort country3d (baseyear2): gen index2000_`i' = 100 *  gdp_`i'/gdp_`i'[1]
   }
foreach i of global trade {
   bysort country3d (baseyear2):   gen index2000_`i' = 100*gdp_`i'/gdp_`i'[1]
   }

tsline index2000_HH index2000_New_Tradable index2000_New_Non_Tradable  if year <=2010 & year>=2000 & country3d=="KOR", ///
      xtitle(Years, size(vsmall)) ytitle(Indexed Credit/Nominal GDP, size(vsmall)) ///
      legend(label(1 "Households") label(2 "Tradables") ///
      label(3 "Non-Tradables") size(vsmall)) ///
      xline(2008, lwidth(20.5) lc(gs14) lpattern(solid)) legend(size(tiny)) ///
      xline(2007 2009, lcolor(gs12) lpattern(solid)) ///
      title("Korea: Indexed Credit to GDP (in %) (2000=100)", size(small))


tsline index_HH index_New_Tradable index_New_Non_Tradable  if year <=2000 & year>=1990 & country3d=="KOR", ///
      xtitle(Years, size(vsmall)) ytitle(Indexed Credit/Nominal GDP, size(vsmall)) ///
      legend(label(1 "Households") label(2 "Tradables") ///
      label(3 "Non-Tradables") size(vsmall)) ///
      xline(1997.5, lwidth(10.5) lc(gs14) lpattern(solid)) legend(size(tiny)) ///
      xline(1997 1998, lcolor(gs12) lpattern(solid)) ///
      title("Korea: Indexed Credit to GDP (in %) (1990=100)", size(small))
   tsline index_HH index_T index_NT   if year <=2000 & year>=1985 & country3d=="KOR", ///
            xtitle(Years, size(vsmall)) ytitle(Indexed Credit/Nominal GDP, size(vsmall)) ///
            legend(label(1 "Households") label(2 "Tradables") ///
            label(3 "Non-Tradables") size(vsmall)) ///
            xline(1997.5, lwidth(7) lc(gs15%55) lpattern(solid)) legend(size(tiny)) ///
            xline(1997 1998, lcolor(gs15%55) lpattern(solid)) ///
            title("Korea: Indexed Credit to GDP (in %) (1990=100)", size(small))

tsline index_HH index_New_GI index_New_FL index_New_HJ index_New_DE index_New_BC    if year <=2000 & year>=1985 & country3d=="KOR", ///
            xtitle(Years, size(vsmall)) ytitle(Indexed Credit/Nominal GDP, size(vsmall)) ///
            xline(1997.5, lwidth(7) lc(gs15%55) lpattern(solid)) legend(size(tiny)) ///
            xline(1997 1998, lcolor(gs15%55) lpattern(solid)) ///
            title("Korea: Indexed Credit to GDP (in %) (1990=100)", size(small))



      tsline index_HH   if  year>=1990, ///
            xtitle(Years, size(vsmall)) ytitle(Indexed Credit/Nominal GDP, size(vsmall)) ///
            legend(label(1 "Households") label(2 "Tradables") ///
            label(3 "Non-Tradables") size(vsmall)) ///
            title("Indonesia: Indexed Credit to GDP (in %) (1992=100)", size(small))



forval j=2/6{
      local J = `j'-1
      gen d2_HH_`J' = (l.gdp_HH - l`j'.gdp_HH)
            }


forval j=2/6 {
      local `J' = `j'-1
      gen LlnRainfall`J' = l`j'.lnrainfall
   }

   forval j=2/6{
         local J = `j'-1
         gen pc_lnRainfall_`J' = (l.lnrainfall - l`j'.lnrainfall)/l`j'.lnrainfall
               }


               forval j=2/6{
                     local J = `j'-1
                     gen d2_lnrainfall_`J' = (l.lnrainfall - l`j'.rainfall)
                           }



forval j=2/6{
   local J = `j'-1
   gen pc_int_real_`J' = (l.int_real - l`j'.int_real)/l`j'.int_real
   }


xtreg d1_HH_3 l5.democracy   i.year if (country3d=="VEN" | country3d=="GBR" | country3d=="ARE" | country3d =="UKR" | country3d =="USA"| country3d =="UKR" | country3d =="TUR" | country3d =="THA" | country3d =="TWN" | country3d =="CHE" | country3d =="SWE"| country3d =="LKA" | country3d =="ESP" | country3d =="ZAF" | country3d =="SVN" | country3d =="SVK" | country3d =="SGP" | country3d =="SAU" | country3d =="ROU" | country3d =="QAT"  | country3d =="PRT"  | country3d =="POL" | country3d =="PHL"  | country3d =="PER"  | country3d =="PNG"  | country3d =="PAN"  | country3d =="PAK"  | country3d =="OMN" | country3d =="NGA"| country3d =="NZL" | country3d =="NLD"   | country3d =="MAR" | country3d =="MNG" | country3d =="MEX"|country3d =="MUS" |country3d =="MYS"|country3d =="LUX"|country3d =="LTU" |country3d =="LBR"|country3d =="LVA"|country3d =="KWT" |country3d =="KOR"|country3d =="JPN"| country3d=="KAZ"| country3d=="ITA" | country3d=="ISR" | country3d=="IRL"|country3d=="IND" |country3d=="HUN"|country3d=="GRC"| country3d=="GHA"|country3d=="DEU" |country3d=="GAB"|country3d=="FRA" |country3d=="FIN" |country3d=="EST"|country3d=="EGY" |country3d=="DNK" |country3d=="CZE"|country3d=="CYP"|country3d=="COL"|country3d=="CHN" |country3d=="CHL" |country3d=="CAN"|country3d=="KHM"|country3d=="BGR"|country3d=="BRA"|country3d=="BEL"|country3d=="BLR"|country3d=="BGD" |country3d=="BHR"|country3d=="AUT" |country3d=="AUS" |country3d=="ARM"|country3d=="ARG"|country3d=="ARG"|country3d=="ALB"|country3d=="RUS")  & year<=2014& year>=1984, fe vce(cluster country_id)


xtreg d1_HH_3 l5.democracy   i.year if (country3d=="VEN" | country3d=="GBR" | country3d=="ARE" | country3d =="UKR" | country3d =="USA"| country3d =="UKR" | country3d =="TUR" | country3d =="TWN" | country3d =="CHE" | country3d =="SWE"| country3d =="LKA" | country3d =="ESP" | country3d =="ZAF" | country3d =="SVN" | country3d =="SVK" | country3d =="SGP" | country3d =="SAU" | country3d =="ROU" | country3d =="QAT"  | country3d =="PRT"  | country3d =="POL" | country3d =="PHL"  | country3d =="PER"  | country3d =="PNG"  | country3d =="PAN"  | country3d =="PAK"  | country3d =="OMN" | country3d =="NGA"| country3d =="NZL" | country3d =="NLD"   | country3d =="MAR" | country3d =="MNG" | country3d =="MEX"|country3d =="MUS" |country3d =="MYS"|country3d =="LUX"|country3d =="LTU" |country3d =="LBR"|country3d =="LVA"|country3d =="KWT" |country3d =="KOR"|country3d =="JPN"| country3d=="KAZ"| country3d=="ITA" | country3d=="IRL" |country3d=="HUN"|country3d=="GRC"| country3d=="GHA"|country3d=="DEU" |country3d=="GAB"|country3d=="FRA" |country3d=="FIN" |country3d=="EST"|country3d=="EGY" |country3d=="DNK" |country3d=="CZE"|country3d=="CYP"|country3d=="COL"|country3d=="CHN" |country3d=="CHL" |country3d=="CAN"|country3d=="KHM"|country3d=="BGR"|country3d=="BRA"|country3d=="BEL"|country3d=="BLR"|country3d=="BGD" |country3d=="BHR"|country3d=="AUT" |country3d=="AUS" |country3d=="ARM"|country3d=="ARG"|country3d=="ARG"|country3d=="ALB")  & year<=2014& year>=1984, fe vce(cluster country_id)


 xtreg d2_Corp_3 l5.democracy i.year if country3d!="URY" & country3d!="ISL",  fe vce(cluster country_id)


 global interest HH NT T

foreach i of global  interest {
   gen ln_gdp_`i' = ln(gdp_`i')
   forval j = 2/6{
      loc J = `j'-1
      gen d1_ln_`i'_`J' = ln(l.`i'/l`j'.GDP) - ln(l`j'.`i'/l`j'.GDP)
      gen d2_ln_`i'_`J' = ln(l.gdp_`i') - ln(l`j'.gdp_`i')
   }
   }

sum d1_HH_3 d1_NT_3 d1_T_3 if year==1997 & (country3d=="JPN" | country3d=="KOR" |country3d=="MYS"| country3d=="THA"| country3d=="HKG" | country3d="IDN")



estpost  ttest d1_NT_3  if year==1997, by(asia_c) uneq




forval j=2/6{
   foreach i of global sectors {
      replace d2_`i'_`j'_nl = (gdp_`i' - l`j'.gdp_`i')
         }
      }
forval j=2/6{
   foreach i of global tnt {
      replace d2_`i'_`j'_nl = (gdp_`i' - l`j'.gdp_`i')
            }
         }
forval j=2/6{
   foreach i of global combinedsectors {
      replace d2_New_`i'_`j'_nl = (gdp_New_`i' - l`j'.gdp_New_`i')
            }
         }

forval j=2/6{
   foreach i of global sectors{
      local J = `j'-1
      replace d1_`i'_`j'_nl = (`i' - l`j'.`i')/l`j'.GDP
         }
      }
forval j=2/6{
   foreach i of global tnt{
      local J = `j'-1
      replace d1_`i'_`j'_nl = (`i' - l`j'.`i')/l`j'.GDP
            }
      }

forval j=2/6{
   foreach i of global combinedsectors{
      local J = `j'-1
      replace d1_New_`i'_`j'_nl = (New_`i' - l`j'.New_`i')/l`j'.GDP
            }
      }
   foreach sector of glo tnt{
      	forval n=0/5 {
      		replace L`n'D1_GDP_`sector' = L`n'.D.gdp_`sector'
      		local lab: variable label `sector'
      		label var L`n'D1_GDP_`sector' "`lab'"

      		loc nlag = `n'+1
      		replace L`n'D1_Sh_`sector' = (L`n'.`sector'/L`n'.Total) - (L`nlag'.`sector'/L`nlag'.Total)
      		local lab: variable label `sector'
      		label var L`n'D1_Sh_`sector' "`lab'"
      	}
      }
xtscc F2crisiscum L1D3_GDP_T L1D3_GDP_NTH L1D3_GDP_HH, fe lag(3)


ivreghdfe F2crisiscum d1_NT_3_nl if year<=2010    & (F2crisiscum!=. & d2_NT_3_!=. &  d2_HH_3_!=. &  d2_T_3_!=.) & (country3d=="VEN" | country3d=="GBR" | country3d=="ARE" | country3d =="UKR" | country3d =="USA"| country3d =="UKR" | country3d =="TUR" | country3d =="THA" | country3d =="TWN" | country3d =="CHE" | country3d =="SWE"| country3d =="LKA" | country3d =="ESP" | country3d =="ZAF" | country3d =="SVN" | country3d =="SVK" | country3d =="SGP" | country3d =="SAU" | country3d =="ROU" | country3d =="QAT"  | country3d =="PRT"  | country3d =="POL" | country3d =="PHL"  | country3d =="PER"  | country3d =="PNG"  | country3d =="PAN"  | country3d =="PAK"  | country3d =="OMN" | country3d =="NGA"| country3d =="NZL" | country3d =="NLD"   | country3d =="MAR" | country3d =="MNG" | country3d =="MEX"|country3d =="MUS" |country3d =="MYS"|country3d =="LUX"|country3d =="LTU" |country3d =="LBR"|country3d =="LVA"|country3d =="KWT" |country3d =="KOR"|country3d =="JPN"| country3d=="KAZ"| country3d=="ITA" | country3d=="ISR" | country3d=="IRL"|country3d=="IND" |country3d=="HUN"|country3d=="GRC"| country3d=="GHA"|country3d=="DEU" |country3d=="GAB"|country3d=="FRA" |country3d=="FIN" |country3d=="EST"|country3d=="EGY" |country3d=="DNK" |country3d=="CZE"|country3d=="CYP"|country3d=="COL"|country3d=="CHN" |country3d=="CHL" |country3d=="CAN"|country3d=="KHM"|country3d=="BGR"|country3d=="BRA"|country3d=="BEL"|country3d=="BLR"|country3d=="BGD" |country3d=="BHR"|country3d=="AUT" |country3d=="AUS" |country3d=="ARM"|country3d=="ARG"|country3d=="ARG"|country3d=="ALB"|country3d=="RUS") ,  bw(3) a(country_id year) cluster(country_id year)

ivreghdfe F2crisiscum d1_HH_3_nl if year<=2010    & (F2crisiscum!=. & d2_NT_3_!=. &  d2_HH_3_!=. &  d2_T_3_!=.) & (country3d=="VEN" | country3d=="GBR" | country3d=="ARE" | country3d =="UKR" | country3d =="USA"| country3d =="UKR" | country3d =="TUR" | country3d =="THA" | country3d =="TWN" | country3d =="CHE" | country3d =="SWE"| country3d =="LKA" | country3d =="ESP" | country3d =="ZAF" | country3d =="SVN" | country3d =="SVK" | country3d =="SGP" | country3d =="SAU" | country3d =="ROU" | country3d =="QAT"  | country3d =="PRT"  | country3d =="POL" | country3d =="PHL"  | country3d =="PER"  | country3d =="PNG"  | country3d =="PAN"  | country3d =="PAK"  | country3d =="OMN" | country3d =="NGA"| country3d =="NZL" | country3d =="NLD"   | country3d =="MAR" | country3d =="MNG" | country3d =="MEX"|country3d =="MUS" |country3d =="MYS"|country3d =="LUX"|country3d =="LTU" |country3d =="LBR"|country3d =="LVA"|country3d =="KWT" |country3d =="KOR"|country3d =="JPN"| country3d=="KAZ"| country3d=="ITA" | country3d=="ISR" | country3d=="IRL"|country3d=="IND" |country3d=="HUN"|country3d=="GRC"| country3d=="GHA"|country3d=="DEU" |country3d=="GAB"|country3d=="FRA" |country3d=="FIN" |country3d=="EST"|country3d=="EGY" |country3d=="DNK" |country3d=="CZE"|country3d=="CYP"|country3d=="COL"|country3d=="CHN" |country3d=="CHL" |country3d=="CAN"|country3d=="KHM"|country3d=="BGR"|country3d=="BRA"|country3d=="BEL"|country3d=="BLR"|country3d=="BGD" |country3d=="BHR"|country3d=="AUT" |country3d=="AUS" |country3d=="ARM"|country3d=="ARG"|country3d=="ARG"|country3d=="ALB"|country3d=="RUS") ,  bw(3) a(country_id year) cluster(country_id year)

ivreghdfe F2bcrisis_bvxcum d2_HH_3_nl if year<=2010    & (d2_NT_3_nl!=. &  d2_HH_3_nl!=. &  d2_T_3_nl!=.  ) ,  bw(3) a(country_id year) cluster(country_id year)

ivreghdfe F2bcrisis_bvxcum d2_NT_3_nl     if (asia==1 & d2_NT_3_nl!=. &  d2_HH_3_nl!=. &  d2_T_3_nl!=.  ) ,  bw(3) a(country_id year) cluster(country_id year)

ivreghdfe F2bcrisis_bvx d2_T_3_nl     if (asia==1 & d2_NT_3_nl!=. &  d2_HH_3_nl!=. &  d2_T_3_nl!=.) ,  bw(3) a(country_id year) cluster(country_id year)

ivreghdfe F2bcrisis_bvx d2_T_3_nl d2_NT_3_nl d2_HH_3_nl     if (asia==1 & d2_NT_3_nl!=. &  d2_HH_3_nl!=. &  d2_T_3_nl!=.) ,  bw(3) a(country_id year) cluster(country_id year)

ivreghdfe bcrisis_bvx d1_HH_3 d1_NT_3  d1_T_3      if (d1_NT_3!=. &  d1_HH_3!=. &  d1_T_3!=.) ,   a(country_id year) cluster(country_id year)
