*************************************************
***** Define program
*************************************************
cap program drop data_plot
program define data_plot

*************************************************
***** Keep relevant data and reshape
*************************************************
* Check if adjusted data available or not
cap confirm var data_adjusted
if _rc==0 {
    loc data "data_raw data_adjusted"
}
else {
    loc data "data_raw"
}

* Keep relevant data
keep country sector_ISIC date `data'

* Reshape wide so that sectors are variables
qui greshape wide `data', i(date) j(sector_ISIC) s
qui ren data_raw* *
cap ren data_adjusted* *
order country date

* Temporary: Make HH_other sector
cap gen HH_other=.
cap replace HH_other = HH - HH_mortg_res - HH_consumer

cap gen Corp=Total - HH
cap gen NFC= Corp - K

* Drop
qui missings dropvars, force

*************************************************
***** Make locals with potential sectors
*************************************************
* Levels
cap confirm var HH_mortg_res HH_other HH_consumer NFC K
if _rc==0 {
	qui novarabbrev isvar HH_mortg_res HH_other HH_consumer NFC K
	loc broad_list `r(varlist)'
}

cap confirm var HH_mortg_res HH_other NFC K
if _rc==0 {
	qui novarabbrev isvar HH_mortg_res HH_other NFC K
	loc broad_list `r(varlist)'
}

cap confirm var HH NFC K
if _rc==0 {
	qui novarabbrev isvar HH NFC K
	loc broad_list `r(varlist)'
}

cap confirm var Corp HH
if _rc==0 {
	qui novarabbrev isvar Corp HH
	loc broad_list `r(varlist)'
}

qui novarabbrev isvar $sectors_NFC
loc NFC_list `r(varlist)'

* Percentage shares
loc broad_list_s
foreach sector of loc broad_list {
	qui gen `sector'_s= 100* ((`sector')/Total)
	loc broad_list_s `broad_list_s' `sector'_s
	label var `sector' "`sector'"
	label var `sector'_s "`sector'"
}

loc NFC_list_s
foreach sector of loc NFC_list{
	qui gen `sector'_s= 100* ((`sector')/Total)
	loc NFC_list_s `NFC_list_s' `sector'_s
	label var `sector' "`sector'"
	label var `sector'_s "`sector'"
}

*************************************************
***** Stack variables on top of each other
*************************************************
* Adjust values so that they are stacked on top of each other in twoway graphs
foreach list in broad_list broad_list_s NFC_list NFC_list_s {
	loc temp_list "``list''"
	qui tokenize `temp_list'
	loc counter : word count `temp_list'
	forval n=`counter'(-1)1 {
		qui egen temp = rowtotal(`temp_list'), missing
		qui replace ``n'' = temp
		qui drop temp
		loc temp_list : list temp_list - `n'
	}
}

* Reverse order of sector lists to make plots
foreach list in broad_list broad_list_s NFC_list NFC_list_s {
	loc temp_list
	qui tokenize ``list''
	loc counter : word count ``list''
	forval n=`counter'(-1)1 {
		loc temp_list "`temp_list' ``n''"
	}
	loc `list' `temp_list'
}

*************************************************
***** Make actual plots
*************************************************

* Plot broad levels
sort date
qui twoway (area `broad_list' date, sort), ///
		legend(pos(6) rows(1)) ///
		xlabel(,angle(45)) ylabel(, angle(horizontal))  yscale(titlegap(*10)) ///
		title("Level Composition of Total Credit", margin(bottom)) name(lvl, replace) ///
		subtitle("Real local currency (in millions)", pos(11) margin(bottom) size(medsmall)) ytitle("") xtitle("") ///
		 nodraw


* Plot broad percentages
qui	twoway (area `broad_list_s' date ,  sort), ///
		legend(pos(6) rows(1)) ylabel(0(25)100, angle(horizontal)) ///
		xlabel(,angle(45)) title("Composition of Total Credit", margin(bottom)) ///
		subtitle("In percent", pos(11) margin(bottom) size(medsmall)) ytitle("") xtitle("") name(pc, replace) nodraw

qui	    grc1leg lvl pc, title("Country: $iso") imargin(zero) name(total, replace)
qui	    graph export "$graphs/$iso_Total.pdf", as(pdf) replace

* Plot NFC levels
qui	twoway (area `NFC_list' date,  sort), ///
		legend(pos(6) rows(5)) xtitle("") title("Level Composition of NFC Credit", margin(bottom)) ///
		name(lvl, replace) subtitle("Real national currency (in millions)", pos(11) margin(bottom) size(medsmall)) ///
		nodraw ytitle("") ylab(, angle(horizontal)) xlabel(,angle(45))

* Plot NFC percentages
qui	twoway (area `NFC_list_s' date,  sort), ///
		xlabel(,angle(45)) ylabel(0(25)100, angle(horizontal)) xtitle("") legend(pos(6) rows(2)) title("% Composition of NFC Credit", margin(bottom)) ///
		subtitle("In percent", pos(11) margin(bottom) size(medsmall)) ytitle("") name(pc, replace) nodraw

qui		grc1leg lvl pc, title("Country: $iso") imargin(zero) name(nfc, replace)
qui 	graph export "$graphs/$iso_NFC.pdf", as(pdf) replace
clear

end
