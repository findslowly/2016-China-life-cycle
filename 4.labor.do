clear 
local output  ".\sample_profile"        // **Please change to output data folder location**

use "`output'\temp_data\sample_panel.dta"
drop if ragey < 45 | ragey > 74

collapse rworkpay , by(ragey rhukou)

#delimit ;
twoway connected rwork ragey if rhukou == 1, msymbol(0)
  || connected rwork ragey if rhukou == 2, msymbol(D)
  ,
legend(label(1 "Rural") label(2 "Urban"))
xlabel(45(5)75)
  ;
#delimit cr
graph export "`output'\figures\rate_labor.pdf", as(pdf) replace

use "`output'\temp_data\sample_panel.dta", clear
drop if ragey < 45 | ragey > 74

collapse rworkpay, by(ragey rhukou rhealth) 
#delimit ;
twoway connected rwork ragey if rhukou == 1 & rhealth == 1 , msymbol(0)
  || connected rwork ragey if rhukou == 1 & rhealth == 0, msymbol(D)
  || connected rwork ragey if rhukou == 2 & rhealth == 1, msymbol(T) 
  || connected rwork ragey if rhukou == 2 & rhealth == 0, msymbol(S)
  ,
legend(label(1 "Rural, Good health") label(2 "Rural, Bad health") label(3 "Urban, Good health") label(4 "Urban, Bad health"))
xlabel(45(5)75)
  ;
#delimit cr
graph export "`output'\figures\rate_labor_health.pdf", as(pdf) replace

