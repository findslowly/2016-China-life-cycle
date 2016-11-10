cd "C:\Research\2016 Life-Cycle Model in China\Code"

* health status by age 
use sample_ID.dta, clear 
merge 1:1 ID using "C:\Data\CHARLS\CHARLS 2011 WAVE 1\health_status_and_functioning.dta", keepusing(da001 da002)
drop if _merge == 2

gen health = (da001 <= 4 | da002 <= 3)

sum age
scalar obs = r(N)

collapse health, by(age)
scatter health age, title("Observation:`=obs'")

graph export "C:\Research\2016 Life-Cycle Model in China\Code\sample stat graph\health.pdf", as(pdf) replace
 

