clear 
local output  ".\sample_profile"        // **Please change to output data folder location**

use "`output'\temp_data\sample_panel.dta"

drop if ragey < 45 | ragey > 74
sum hhatotb, detail 
winsor2 hhatotb, replace cuts(5 95) by(ragey)

gen asset = hhatotb  
collapse (mean) asset_mean = asset (p50) asset_median = asset, by(ragey rhukou)
 
#delimit ;
	twoway connected asset_mean ragey if rhukou == 1, msymbol(0)
	  || connected asset_mean ragey if rhukou == 2, msymbol(D)
	  ,
	legend(label(1 "Rural") label(2 "Urban"))
	xlabel(45(5)75)
	  ;
#delimit cr

graph export "`output'\figures\asset_mean.pdf", as(pdf) replace


#delimit ;
twoway connected asset_median ragey if rhukou == 1, msymbol(0)
	  || connected asset_median ragey if rhukou == 2, msymbol(D)
	  ,
	legend(label(1 "Rural") label(2 "Urban"))
	xlabel(45(5)75)
	  ;
#delimit cr

graph export "`output'\figures\asset_median.pdf", as(pdf) replace

exit 

*** drop bar graph 
use "`output'\temp_data\sample_panel.dta", clear

drop if ragey < 45 | ragey > 74
sum hhatotb, detail 
winsor2 hhatotb, replace cuts(5 95) by(ragey)

gen asset = hhatotb  
gen age_group = floor(ragey / 5) 
gen asset_Rural = asset if rhukou == 1 
gen asset_nonRural = asset if rhukou == 2 

collapse (mean) asset_mean_Rural = asset_Rural asset_mean_nonRural = asset_nonRural ///
(p50) asset_median_Rural = asset_Rural asset_median_nonRural = asset_nonRural, by(age_group)

#delimit ;
graph bar asset_mean_Rural asset_mean_nonRural, over(age_group, relabel(1 "45-49" 2 "50-54" 3 "55-59" 4 "60-64" 5 "65-69" 6 "70-74")) bargap(-30)
  legend( label(1 "Rural") label(2 "Urban") )
  ytitle("Mean assets")
  ;
#delimit cr
graph export "`output'\figures\asset_mean_bar.pdf", as(pdf) replace

#delimit ;
graph bar asset_median_Rural asset_median_nonRural, over(age_group, relabel(1 "45-49" 2 "50-54" 3 "55-59" 4 "60-64" 5 "65-69" 6 "70-74")) bargap(-30)
  legend( label(1 "Rural") label(2 "Urban") )
  ytitle("Median assets")
  ;
#delimit cr
graph export "`output'\figures\asset_median_bar.pdf", as(pdf) replace



