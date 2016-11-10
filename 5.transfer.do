cd "C:\Research\2016 Life-Cycle Model in China\Code"

* health status by age 
use sample_ID.dta, clear 
merge 1:1 householdID using "C:\Data\CHARLS\CHARLS 2011 WAVE 1\household_income.dta", keepusing(gd001* gd002* gd003*)
drop if _merge == 2 

sum gd001_c 

