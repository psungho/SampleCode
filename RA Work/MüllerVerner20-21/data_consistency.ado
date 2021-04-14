*************************************************
***** Define program
*************************************************
cap program drop data_consistency
program define data_consistency
syntax varlist (min=1)

*************************************************
***** Save temporary file
*************************************************
qui tempfile precons
qui save `precons', replace

*************************************************
***** Check for duplicates in sector_ISIC and date
*************************************************
isid sector_ISIC date

*************************************************
***** Check for below-zero values
*************************************************
* Set maximum number of possible sources
qui novarabbrev isvar S*_data

* Show rows and variables with below-zero values for existing variables
forvalues i=1/$source_count {
   cap confirm var S`i'_data, exact
   if _rc==0 {
		list sector_ISIC S`i'_data if S`i'_data<0, clean
   }
}

list sector_ISIC date `varlist' if `varlist'<0, clean

*************************************************
***** Check whether `varlist' is in any source
*************************************************
/*gen test=0
forvalues i=1/$source_count {
   cap confirm var S`i'_data, exact
   if _rc==0 {
		qui replace test=1 if float(`varlist')==float(S`i'_data)
   }
}
list sector_ISIC date `varlist' if test==0
drop test
*/
*************************************************
***** Import accounting identities
*************************************************

qui {
	merge m:1 sector_ISIC using "$temp/accounting_identities", keep(1 3) nogen
	keep `varlist' date sector_ISIC identities*
	rename identities* i*_
	greshape wide `varlist' i*, i(date) j(sector_ISIC) s
	rename `varlist'* *
	missings dropvars, force
}

 *************************************************
 ***** Consistency of broad manufacturing sectors
 *************************************************
qui novarabbrev isvar $sectors_C
loc subs="`r(varlist)'"
if "`subs'"!="" {
	cap confirm var C, exact
	if _rc==0 {
		qui egen double C_total = rowtotal(`subs'), missing
		qui gen double Difference=C-C_total
		cap assert round(Difference,.01)==0 if Difference!=.
		if _rc!=0 {
			di as text "_________________________________________________________"
			di as text " "
			di as error "Error in accounting identity: C = Potential subsectors"
			di as text "_________________________________________________________"
			list date C C_total `subs' Difference if Difference !=. & round(Difference,.01)!=0, clean
			di as text "_________________________________________________________"
		}
		qui drop Difference C_total
	}
}

qui novarabbrev isvar C19 C20 C21 C22 C23 C22_23 C21_22 C20_21 C21_23 C20_23 ///
 C19_20 C19_21 C19_22
loc subs="`r(varlist)'"
if "`subs'"!="" {
	cap confirm C19_23
	if _rc==0 {
		qui egen double C19_23_total = rowtotal(`subs'), missing
		qui gen double Difference=C19_23-C19_23_total
		cap assert round(Difference,.01)==0 if Difference!=.
		if _rc!=0 {
			di as text "_________________________________________________________"
			di as text " "
			di as error "Error in accounting identity: C19_23 = Potential subsectors"
			di as text "_________________________________________________________"
			list date `subs' Difference if Difference !=. & round(Difference,.01)!=0, clean
			di as text "_________________________________________________________"
		}
		qui drop Difference C19_23_total
	}
}

qui novarabbrev isvar C23 C24 C25 C26 C27 C28 C29 C30 C29_30 C28_29 C28_30 ///
C27_28 C26_27 C26_28 C27_30 C26_30 C25_30 C25_26 C24_30 C24_25
loc subs="`r(varlist)'"
if "`subs'"!="" {
	cap confirm C23_30
	if _rc==0 {
		qui egen double C23_30_total = rowtotal(`subs'), missing
		qui gen double Difference=C23_30-C23_30_total
		cap assert round(Difference,.01)==0 if Difference!=.
		if _rc!=0 {
			di as text "_________________________________________________________"
			di as text " "
			di as error "Error in accounting identity: C23_30 = Potential subsectors"
			di as text "_________________________________________________________"
			list date `subs' Difference if Difference !=. & round(Difference,.01)!=0, clean
			di as text "_________________________________________________________"
		}
		qui drop Difference C19_23_total
	}
}

qui novarabbrev isvar C24 C24_25 C25 C25_28 C26 C26_27 C26_28 C27 C28
loc subs="`r(varlist)'"
if "`subs'"!="" {
	cap confirm C24_28
	if _rc==0 {
		qui egen double C24_28_total = rowtotal(`subs'), missing
		qui gen double Difference=C24_28-C24_28_total
		cap assert round(Difference,.01)==0 if Difference!=.
		if _rc!=0 {
			di as text "_________________________________________________________"
			di as text " "
			di as error "Error in accounting identity: C24_28 = Potential subsectors"
			di as text "_________________________________________________________"
			list date `subs' Difference if Difference !=. & round(Difference,.01)!=0, clean
			di as text "_________________________________________________________"
		}
		qui drop Difference C24_28_total
	}
}

qui novarabbrev isvar C24 C24_25 C24_28 C25 C25_28 C25_30 C26 C26_27 C26_28 C26_30 C27 C28 C28_30 C29 C29_30 C30
loc subs="`r(varlist)'"
if "`subs'"!="" {
	cap confirm C24_30
	if _rc==0 {
		qui egen double C24_30_total = rowtotal(`subs'), missing
		qui gen double Difference=C24_30-C24_30_total
		cap assert round(Difference,.01)==0 if Difference!=.
		if _rc!=0 {
			di as text "_________________________________________________________"
			di as text " "
			di as error "Error in accounting identity: C24_30 = Potential subsectors"
			di as text "_________________________________________________________"
			list date `subs' Difference if Difference !=. & round(Difference,.01)!=0, clean
			di as text "_________________________________________________________"
		}
		qui drop Difference C24_30_total
	}
}

qui novarabbrev isvar C25 C25_28 C25_30 C26 C26_27 C26_28 C26_30 C27 C28 C28_30 C29 C29_30 C30
loc subs="`r(varlist)'"
if "`subs'"!="" {
	cap confirm C25_30
	if _rc==0 {
		qui egen double C25_30_total = rowtotal(`subs'), missing
		qui gen double Difference=C25_30-C25_30_total
		cap assert round(Difference,.01)==0 if Difference!=.
		if _rc!=0 {
			di as text "_________________________________________________________"
			di as text " "
			di as error "Error in accounting identity: C25_30 = Potential subsectors"
			di as text "_________________________________________________________"
			list date `subs' Difference if Difference !=. & round(Difference,.01)!=0, clean
			di as text "_________________________________________________________"
		}
		qui drop Difference C25_30_total
	}
}

qui novarabbrev isvar C26 C26_27 C26_28 C26_30 C27 C28 C28_30 C29 C29_30 C30
loc subs="`r(varlist)'"
if "`subs'"!="" {
	cap confirm C26_30
	if _rc==0 {
		qui egen double C26_30_total = rowtotal(`subs'), missing
		qui gen double Difference=C26_30-C26_30_total
		cap assert round(Difference,.01)==0 if Difference!=.
		if _rc!=0 {
			di as text "_________________________________________________________"
			di as text " "
			di as error "Error in accounting identity: C26_30 = Potential subsectors"
			di as text "_________________________________________________________"
			list date `subs' Difference if Difference !=. & round(Difference,.01)!=0, clean
			di as text "_________________________________________________________"
		}
		qui drop Difference C26_30_total
	}
}

*************************************************
***** Consistency of total NFC credit
*************************************************
qui novarabbrev isvar $sectors_NFC
loc subs="`r(varlist)'"
if "`subs'"!="" {
	cap confirm var NFC, exact
	if _rc==0 {
		qui egen double NFC_total = rowtotal(`subs'), missing
		qui gen double Difference=NFC-NFC_total
		cap assert round(Difference,.01)==0 if Difference!=.
		if _rc!=0 {
			di as text "_________________________________________________________"
			di as text " "
			di as error "Error in accounting identity: NFC = Potential subsectors"
			di as text "_________________________________________________________"
			list date NFC NFC_total Difference `subs' if Difference !=. & round(Difference,.01)!=0, clean
			di as text "_________________________________________________________"
		}
		qui drop Difference NFC_total
	}
}

*************************************************
***** Other accounting identities
*************************************************
* Check identities, save results in comp_* variable
foreach v of varlist i?* {
	loc name=substr("`v'",strpos("`v'","_")+1,strlen("`v'"))
	qui gen double comp_`v' = 0
	qui levelsof `v'
	foreach lvl in `r(levels)' {
		loc identity=subinstr("`lvl'"," ", " + ",.)
		cap confirm var `lvl', exact
		if _rc==0 {
			foreach val of local lvl {
				qui replace comp_`v' = `val' + comp_`v' if `v' == "`lvl'"
			}
			qui gen double Difference = `name' - comp_`v'
			cap assert round(Difference,.01)==0 if `name'!=. & comp_`v'!=.
			if _rc!=0 {
				di as text "_________________________________________________________"
				di as text " "
				di as error "Error in accounting identity: `name' = `identity'"
				di as text "_________________________________________________________"
				list date `name' `lvl' Difference if round(Difference,.01)!=0 & `name'!=. & comp_`v'!=., clean
				di as text "_________________________________________________________"
			}
			drop Difference
		}
	}
	drop comp_`v'
}

*************************************************
***** Back to original format
*************************************************
* Save consistency file format
qui save "$temp/consistency_file", replace

* Back to regular format
use `precons', clear

di as text "$iso: Data consistency check complete."

end
