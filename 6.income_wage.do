clear 
local output  ".\sample_profile"        // **Please change to output data folder location**

use "`output'\temp_data\sample_panel.dta"

drop if ragey < 45 | ragey > 74
winsor2 riearn riwagew, replace cuts(1 99) by(ragey)

collapse riearn, by(ragey rhukou)
 
#delimit ;
twoway connected  ragey if rhukou == 1, msymbol(0)
	  || connected  ragey if rhukou == 2, msymbol(D)
	  ,
	legend(label(1 "Rural") label(2 "Urban"))
	xlabel(45(5)75)
	  ;
#delimit cr

graph export "`output'\figures\wage_mean.pdf", as(pdf) replace
*
