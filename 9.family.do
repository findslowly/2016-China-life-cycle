clear 
local output  ".\sample_profile"        // **Please change to output data folder location**

use "`output'\temp_data\sample_panel.dta"

drop if ragey < 45 | ragey > 74

collapse hchild hhhres, by(ragey rhukou)

#delimit ;
twoway connected hchild ragey if rhukou == 1, msymbol(0)
	  || connected hchild ragey if rhukou == 2, msymbol(D)
	  ,
	legend(label(1 "Rural") label(2 "Urban"))
	xlabel(45(5)75)
	ytitle(Total number of living children)
	xtitle(Age)
	  ;
#delimit cr
	
graph export "`output'\figures\family_livingChild_num.pdf", as(pdf) replace

#delimit ;
twoway connected hhhres ragey if rhukou == 1, msymbol(0)
	  || connected hhhres ragey if rhukou == 2, msymbol(D)
	  ,
	legend(label(1 "Rural") label(2 "Urban"))
	xlabel(45(5)75)
	ytitle(Total number of living residents in the household)
	xtitle(Age)
	  ;
#delimit cr
	
graph export "`output'\figures\family_livingRes_num.pdf", as(pdf) replace

