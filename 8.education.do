clear 
local output  ".\sample_profile"        // **Please change to output data folder location**

use "`output'\temp_data\sample_panel.dta"

drop if ragey < 45 | ragey > 74

collapse raeduc_y, by(ragey rhukou)

#delimit ;
twoway connected rhoursy ragey if rhukou == 1, msymbol(0)
	  || connected rhoursy ragey if rhukou == 2, msymbol(D)
	  ,
	legend(label(1 "Rural") label(2 "Urban"))
	xlabel(45(5)75)
	  ;
#delimit cr
	
graph export "`output'\figures\working_hours.pdf", as(pdf) replace

 

