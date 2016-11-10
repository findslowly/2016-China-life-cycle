cd "C:\Research\2016 Life-Cycle Model in China\Code"

* health status by age 
use sample_ID.dta, clear 
merge 1:1 ID using "C:\Data\CHARLS\CHARLS 2011 WAVE 1\work_retirement_and_pension.dta", keepusing(fb011)
drop if _merge == 2

sum age
scalar obs = r(N)

gen retirement = 2 - fb011
collapse retirement, by(age)
scatter retirement age, title("Observation:`=obs'")

graph export "C:\Research\2016 Life-Cycle Model in China\Code\sample stat graph\retirement-enterprise.pdf", as(pdf) replace
 

