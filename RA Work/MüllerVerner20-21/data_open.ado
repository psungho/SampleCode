*************************************************
***** Define program
*************************************************

cap program drop data_open
program define data_open
	syntax namelist(min=1 max=1)

	* Save country name for later use
	glo iso "`namelist'"

*************************************************
***** Import input file, save
*************************************************
* Import input file
	di as text "`namelist': Importing input file"
	qui import excel "$inputs/Raw-data/`namelist'/input_file.xlsx", firstrow clear
	qui destring *, replace
* Save
	qui save "$temp/input_file", replace

*************************************************
***** Import documentation file, save
*************************************************
* Import documentation file
	di as text "`namelist': Importing documentation file"
	qui import excel "$inputs/Raw-data/`namelist'/series_documentation.xlsx", firstrow clear allstring
* Save
	qui save "$temp/series_documentation", replace

*************************************************
***** Import adjustment file, save
*************************************************
* Check if adjustment file exists
	clear
	cap confirm file "$inputs/Raw-data/`namelist'/adjustment_file.xlsx"

* If yes, import
	if _rc==0 {
		di as text "`namelist': Importing adjustment file"
		qui import excel "$inputs/Raw-data/`namelist'/adjustment_file.xlsx", firstrow clear allstring

* Confirm if rescale variable exists, if yes add to local

		cap confirm var rescale, exact
		if _rc==0 {
			loc resc rescale
		}
		if _rc!=0 {
			loc resc ""
		}

* Get maximum number of sources
		qui destring series_number breaks*, replace
		qui sum series_number
		loc max_num=r(max)

* Create adjustment number (by sector and source)
		qui bysort sector_broad sector_ISIC series_number: gen adj_number=_n


* Reshape so that sources are wide
		qui reshape wide breaks `resc', i(country sector_broad sector_ISIC adj_number) j(series_number)

* Check if there are multiple adjustments per source and sector
		qui sum adj_number
		loc adj_num = r(max)

* If yes, reshape so that sources and adjustments are wide
		if `adj_num'>1 {
			qui reshape wide breaks* `resc'*, i(country sector_broad sector_ISIC) j(adj_number)
			if `max_num'>=10 {
				ren breaks??? breaks??_?
				ren `resc'??? `resc'??_?
			}
			ren breaks?? breaks?_?
			ren `resc'?? `resc'?_?
		}

* If no, drop adjustment number
		if `adj_num'==1 {
			qui drop adj_number
		}

* Convert date variables into Stata format
		foreach var of varlist breaks* {
		qui gen temp=monthly(`var', "YM")
		format temp %tm
		qui drop `var'
		ren temp `var'
		}

* Save file
		qui save "$temp/adjustment_file", replace
	}

* If there is no adjustment file, say that

	else {
		di as err "`namelist': No adjustment file found"
	}

* Clear space
clear

end
