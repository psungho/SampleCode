ssc install percom
ssc install reghdfe
ssc install RANDINF
net describe ritest, from(https://raw.githubusercontent.com/simonheb/ritest/master/)

* Aggregate Data

** Figure 1

sum att_prop if att_prop>0, meanonly
local a = r(mean)
graph hbar att_prop if att_prop!=0, over(barangay, sort(1)) ytitle("Proportion") ///
        yline(`a') title(Proportion of Attendees out of Registered Voters) ylabel(0(.05).25)

sum att_prop_turn if att_prop_turn>0, meanonly
local b = r(mean)
graph hbar att_prop_turn if att_prop_turn!=0, over(barangay, sort(1)) ytitle("Proportion") ///
        yline(`b') title(Proportion of Attendees out of Party-List Voters) ylabel(0(.05).30)

** Effect of treatment on outcomes

local vars turnout_party share_treated share_akbayan share_umalabka
        *** Compute probability of treatment
                
        sum assigment, meanonly
        local c = r(mean)
        gen weights = .

        xtset city
        *** Estimate the ATE
        foreach i of local vars {
                if `i' == turnout_party | `i' == share_treated  {
                        eststo `i'_ATE: qui areg  `i' assignment [aweight=weights], absorb(city)  rob
                         outreg2 using ATE.tex
                }
                if `i' == share_umalabka {
                        eststo `i'_ATE: qui areg share_umalabka assignment  if party==2 [aweight=weights], absorb(city) robust
                        outreg2
                }
                if `i' == share_akbayan {
                        eststo `i'_ATE: qui areg share_akbayan assignment  if party==1 [aweight=weights], absorb(city) robust
                        outreg2
                }
        }

        *** Estimate the CACE
        foreach i of local vars {
                if `i' == turnout_party | `i' == share_treated  {
                        eststo `i'_CACE: qui ivreghdfe  `i' (treatment=assignment), rob absorb(city)
                        outreg2 using CACE.tex
                }
                if `i' == share_umalabka {
                        eststo `i'_CACE: qui ivreghdfe share_umalabka (treatment=assignment)  ///
                                if party==2 [aweight=weights], absorb(city) robust
                                outreg2
                }
                if `i' == share_akbayan {
                        eststo `i'_CACE: qui ivreghdfe share_akbayan (treatment=assignment)  ///
                                if party==1 [aweight=weights], absorb(city) robust
                                outreg2
                }
        }
        ***  We estimate the control mean via the estimated intercept w/o fixed-effects
        foreach i of local vars {
                if `i' == turnout_party | `i' == share_treated  {
                        eststo `i'_control: qui reg  `i' assignment, rob
                        outreg2 using control.tex
                }
                if `i' == share_umalabka {
                        eststo `i'_control: qui reg  share_umalabka assignment ///
                                if party==2, rob
                        outreg2
                        }
                if `i' == share_akbayan {
                        eststo `i'_control: qui reg  share_akbayan assignment ///
                                if party==1, rob
                        outreg2
                        }
        }
        ***Randomized inference for this reserach ///
   
