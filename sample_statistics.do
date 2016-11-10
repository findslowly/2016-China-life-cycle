clear 
set more off
local output  ".\sample_profile"        // **Please change to output data folder location**

use "`output'\temp_data\sample_panel.dta"

drop if ragey < 45 | ragey > 74
keep if rhukou == 1 | rhukou == 2 
gen rhoursy = .
replace rhoursy = rjhourstot * rjweeks 
gen poor_health = rhealth == 0 
gen married = (rmstat == 1 | rmstat == 3)

sort rhukou
by rhukou: sum ragey rwork rhoursy hhatotb poor_health hchild hhhres married raeduc_y riearn

exit
collapse (mean) ragey rwork rhoursy mean_asset = hhatotb poor_health hchild hhhres married raeduc_y riearn ///
(p50) median_asset = hhatotb, by(rhukou)

