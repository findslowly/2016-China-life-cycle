clear 
***define folder locations***
local inputw1 "..\data\rawdata\CHARLS 2011 WAVE 1" // **Please change to wave 1 data folder location**
local inputw2 "..\data\rawdata\CHARLS 2013 WAVE 2" // **Please change to wave 2 data folder location**
local output  ".\sample_profile"        // **Please change to output data folder location**

***define files locations
***respondent level file
local wave_1_demog      "`inputw1'\demographic_background"
local wave_1_mainr      "`inputw1'\mainr"
local wave_1_health     "`inputw1'\health_status_and_functioning"
local wave_1_healthcare "`inputw1'\health_care_and_insurance"
local wave_1_indinc     "`inputw1'\individual_income"
local wave_1_work       "`inputw1'\work_retirement_and_pension"
local wave_1_weight     "`inputw1'\weight"
local wave_1_biomark    "`inputw1'\biomarkers"

***household level file
local wave_1_house      "`inputw1'\housing_characteristics"
local wave_1_faminfo    "`inputw1'\family_information"
local wave_1_famtran    "`inputw1'\family_transfer"
local wave_1_hhinc      "`inputw1'\household_income"
local wave_1_psu        "`inputw1'\psu"
local wave_1_hhroster   "`inputw1'\household_roster"


**Wave 2 file
****respondent level file
local wave_2_demog      "`inputw2'\Demographic_Background"
local wave_2_health     "`inputw2'\Health_Status_and_Functioning"
local wave_2_healthcare "`inputw2'\Health_Care_and_Insurance"
local wave_2_indinc     "`inputw2'\Individual_Income"
local wave_2_work       "`inputw2'\Work_Retirement_and_Pension"
local wave_2_weight     "`inputw2'\Weights"


**household level file
local wave_2_house       "`inputw2'\Housing_Characteristics"
local wave_2_faminfo     "`inputw2'\Family_Information"
local wave_2_famtran     "`inputw2'\Family_Transfer"
local wave_2_hhinc       "`inputw2'\Household_Income"
local wave_2_psu        "`inputw2'\PSU"
*local wave_2_hhroster   "`inputw2'\household_roster" \\\no houshold roster file
local wave_2_child    "`inputw2'\Child"
local wave_2_biomark   "`inputw2'\Biomarker"

include "`output'\CHARLS_main.do"

* drop spouse data 
drop s1*

* male 
keep if ragender == 1 
* married or partnered 
keep if r1mstat == 1 | r1mstat == 3 

save "`output'\temp_data\sample.dta", replace 

