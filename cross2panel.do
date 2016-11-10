clear 
set more off 

local output  ".\sample_profile"  

use "`output'\temp_data\sample.dta", clear 

*** renaming variables for reshaping *** 

** 1.demo info 
* age at the year interviewed  
ren r1agey ragey1 
ren r2agey ragey2 
* hukou status 
ren r1hukou rhukou1 
ren r2hukou rhukou2
* total number of living children
ren h1child hchild1
ren h2child hchild2
* number of people living in this household 
ren h1hhres hhhres1
ren h2hhres hhhres2
* marriage status 
ren r1mstat rmstat1
ren r2mstat rmstat2 

** 2.health 
* self-reported health  
ren r1shlta rshlta1
ren r2shlta rshlta2 

** 3.work 
* currently working (binary)
ren r1work rwork1
ren r2work rwork2
* currently working for pay
ren r1workpay rworkpay1
ren r2workpay rworkpay2
* Hours worked per week (summary for main job)
ren r1jhours_c rjhours1
ren r2jhours_c rjhours2 
* Hours worked per week (summary for other jobs)
ren r1jhour2 rjhours_other1
ren r2jhour2 rjhours_other2
* Hours worked per week (summary for main and other jobs)
ren r1jhourstot rjhourstot1 
ren r2jhourstot rjhourstot2 
* weeks worked per year (summary for main job)
ren r1jweeks_c rjweeks1 
ren r2jweeks_c rjweeks2 

** 4.income 
* the maximum of wage values from income and work module
ren r1iearn riearn1 
ren r2iearn riearn2
* earning from income module 
ren r1iwagei riwagei1
ren r2iwagei riwagei2
* earning from work module 
ren r1iwagew riwagew1
ren r2iwagew riwagew2

** 5.assets 
* total wealth 
ren hh1atotb hhatotb1 
ren hh2atotb hhatotb2 


*** reshape 
local stub 		   rwork  ragey  rhukou  rshlta  rjhours  rjhours_other  rjhourstot  rjweeks  riearn  ///
riwagei  riwagew  hhatotb  rworkpay  hchild  hhhres  rmstat
local keepvars     rwork* ragey* rhukou* rshlta* rjhours* rjhours_other* rjhourstot* rjweeks* riearn* ///
riwagei* riwagew* hhatotb* rworkpay* hchild* hhhres* rmstat* 
local idvars ID raeduc_c raeduc_y

keep `idvars' `keepvars' 

reshape long `stub', i(ID) j(wave) 

* generate variables 
gen rhealth = rshlta <= 3 
replace rhealth = . if rshlta == . 

save "`output'\temp_data\sample_panel.dta", replace 
