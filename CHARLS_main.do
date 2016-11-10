clear all
set more off

**************************************************************************************
*Title: H_CHARLS_long.do                                                             * 
*Summary: converts data from the CHARLS to create the Harmonized CHARLS, Version B.2 *
*Authors: Sandy Chien, Ashley Lin, Yaoyao Zhu, Drystan Phillps, & Jinkook Lee        *
*Date Created: 06/2016                                                               *
*Please note: Store CHARLS data files for Wave 1 and Wave 2 on your computer         *
*Edit lines 16 & 17 to list the folder location of the CHARLS raw data               *
*Edit line 18 to list the folder location where you would like to save               *
*    the Harmonized CHARLS dataset                                                   *
************************************************************************************** 


***define programs***
*generate spouse variables
* There is one program to generate spouse variables

***spouse
***this is a program that creates spouse variables from respondnet information
***
*** the program is called as follows
***		spouse varname, result(result) wave(wave)
***			where:
***				varname - name of respondent variable
***				result 	- name of spouse variable, must be generated before program
***				wave		-	number of the wave
capture program drop spouse
program define spouse
syntax varname, result(varname) wave(integer) [coupleid(varname)]
	if "`coupleid'" == "" {
		local coupleid h`wave'coupid
	}
		
	bysort `coupleid' : replace `result' = `varlist'[_n+1] if h`wave'cpl==1 & `coupleid'==`coupleid'[_n+1] &  !missing(`coupleid') & inw`wave'==1
	bysort `coupleid' : replace `result' = `varlist'[_n-1] if h`wave'cpl==1 & `coupleid'==`coupleid'[_n-1] &  !missing(`coupleid') & inw`wave'==1
	replace `result' = .u if !inlist(r`wave'mstat, 1, 3) & inw`wave' == 1
	replace `result' = .v if  inlist(r`wave'mstat, 1, 3) & h`wave'cpl==0 & inw`wave'==1
	replace `result' = .  if inw`wave'==0

end

*generate household financial variables
* There is one program to generate household financial variables 
*       based on respondent and spouse's values

***household
***this is a program that creates household variables from respondnet and spouse information
***
*** the program is called as follows
***		household varlist, result(result) wave(wave)
***			where:
***				varlist - respondent and spouse variable
***				result 	- name of household variable, must be generated before program
***				wave		-	number of the wave
capture program drop household
program define household
syntax varlist (min=2 max=2), result(varname) [wave(string)]
	tokenize `varlist'
	
	if "`wave'" == "" {
	    h_wy_level `result'
        local wv `r(wave)'
    }
    else {
        local wv `wave'
    }
	
	missing_H `1' if !inlist(r`wv'mstat,1,3) & inw`wv' == 1, result(`result')
    missing_H `1' `2' if inlist(r`wv'mstat,1,3), result(`result')
    replace `result' =.b if `2' == .v & inlist(r`wv'mstat,1,3)
    replace `result' = `1' if !mi(`1') & !inlist(r`wv'mstat,1,3) & inw`wv' == 1
    replace `result' = `1' + `2' if !mi(`1') & !mi(`2') & inlist(r`wv'mstat,1,3)

end

*choose the harmonized variable with the highest value
capture program drop max_h_value
program define max_h_value
syntax varlist, result(varname)
	missing_H `varlist', result(`result')
	tempvar rowmaxvar
	egen `rowmaxvar' = rowmax(`varlist')
	replace `result' = `rowmaxvar' if !mi(`rowmaxvar')
end
capture program drop h_wy_level 
program define h_wy_level, rclass
syntax varname [, HRS ELSA SHARE JSTAR CHARLS LASI KLOSA MHAS TILDA CRELES wy(string) asset income ]
    local l = substr("`varlist'",1,1)
    local ll = substr("`varlist'",1,2)
    local lll = substr("`varlist'",1,3)
    if "`ll'" == "hh" {
        local l = substr("`varlist'",1,2)
    }
    if "`lll'" == "inw" {
        local l = substr("`varlist'",1,3)
    }
    if "`l'" == "inw" {
        local t = substr("`varlist'",4,1)
        if "`t'"=="0"|"`t'"=="1"|"`t'"=="2"|"`t'"=="3"|"`t'"=="4"|"`t'"=="5"|"`t'"=="6"|"`t'"=="7"|"`t'"=="8"|"`t'"=="9" {
            local time wave
            local w = substr("`varlist'",4,1)
        	local tt = substr("`varlist'",5,1)
        	if "`tt'"=="0"|"`tt'"=="1"|"`tt'"=="2"|"`tt'"=="3"|"`tt'"=="4"|"`tt'"=="5"|"`tt'"=="6"|"`tt'"=="7"|"`tt'"=="8"|"`tt'"=="9" {
        	    local w = substr("`varlist'",4,2)
        	    local ttt = substr("`varlist'",6,1)
        	    if "`ttt'"=="0"|"`ttt'"=="1"|"`ttt'"=="2"|"`ttt'"=="3"|"`ttt'"=="4"|"`ttt'"=="5"|"`ttt'"=="6"|"`ttt'"=="7"|"`ttt'"=="8"|"`ttt'"=="9" {
        	        local w
        	        local y = substr("`varlist'",4,4)
        	        local time year
        	    }
        	}
    	}
    }
    else if "`l'" == "hh" {
        local t = substr("`varlist'",3,1)
        if "`t'"=="0"|"`t'"=="1"|"`t'"=="2"|"`t'"=="3"|"`t'"=="4"|"`t'"=="5"|"`t'"=="6"|"`t'"=="7"|"`t'"=="8"|"`t'"=="9" {
            local time wave
            local w = substr("`varlist'",3,1)
        	local tt = substr("`varlist'",4,1)
        	if "`tt'"=="0"|"`tt'"=="1"|"`tt'"=="2"|"`tt'"=="3"|"`tt'"=="4"|"`tt'"=="5"|"`tt'"=="6"|"`tt'"=="7"|"`tt'"=="8"|"`tt'"=="9" {
        	    local w = substr("`varlist'",3,2)
        	    local ttt = substr("`varlist'",5,1)
        	    if "`ttt'"=="0"|"`ttt'"=="1"|"`ttt'"=="2"|"`ttt'"=="3"|"`ttt'"=="4"|"`ttt'"=="5"|"`ttt'"=="6"|"`ttt'"=="7"|"`ttt'"=="8"|"`ttt'"=="9" {
        	        local w
        	        local y = substr("`varlist'",3,4)
        	        local time year
        	    }
        	}
    	}
    }
    else {
        local t = substr("`varlist'",2,1)
        if "`t'"=="0"|"`t'"=="1"|"`t'"=="2"|"`t'"=="3"|"`t'"=="4"|"`t'"=="5"|"`t'"=="6"|"`t'"=="7"|"`t'"=="8"|"`t'"=="9" {
            local time wave
            local w = substr("`varlist'",2,1)
        	local tt = substr("`varlist'",3,1)
        	if "`tt'"=="0"|"`tt'"=="1"|"`tt'"=="2"|"`tt'"=="3"|"`tt'"=="4"|"`tt'"=="5"|"`tt'"=="6"|"`tt'"=="7"|"`tt'"=="8"|"`tt'"=="9" {
        	    local w = substr("`varlist'",2,2)
        	    local ttt = substr("`varlist'",4,1)
        	    if "`ttt'"=="0"|"`ttt'"=="1"|"`ttt'"=="2"|"`ttt'"=="3"|"`ttt'"=="4"|"`ttt'"=="5"|"`ttt'"=="6"|"`ttt'"=="7"|"`ttt'"=="8"|"`ttt'"=="9" {
        	        local w
        	        local y = substr("`varlist'",2,4)
        	        local time year
        	    }
        	}
    	}
    }       
    
	return local level "`l'"
	
	if "`w'" == "" & "`y'" == "" {
	    if "`wy'"=="0"|"`wy'"=="1"|"`wy'"=="2"|"`wy'"=="3"|"`wy'"=="4"|"`wy'"=="5"|"`wy'"=="6"|"`wy'"=="7"|"`wy'"=="8"|"`wy'"=="9" | ///
	        "`wy'"=="10"|"`wy'"=="11"|"`wy'"=="12"|"`wy'"=="13"|"`wy'"=="14"|"`wy'"=="15"|"`wy'"=="16"|"`wy'"=="17"|"`wy'"=="18"|"`wy'"=="19" {
		    local w `wy'
		}
		else {
		    local y `wy'
		}
		local time panel
	}
	local studies `hrs' `elsa' `share' `jstar' `charls' `lasi' `klosa' `mhas' `tilda'
	local n_studies : word count `studies'
	if "`w'"=="0"|"`w'"=="1"|"`w'"=="2"|"`w'"=="3"|"`w'"=="4"|"`w'"=="5"|"`w'"=="6"|"`w'"=="7"|"`w'"=="8"|"`w'"=="9" | ///
	        "`w'"=="10"|"`w'"=="11"|"`w'"=="12"|"`w'"=="13"|"`w'"=="14"|"`w'"=="15"|"`w'"=="16"|"`w'"=="17"|"`w'"=="18"|"`w'"=="19" {
		if `n_studies' > 1 {
			di "can only specify one study"
			exit 198
		}
		else if "`hrs'" == "hrs" {
			local y = 1992 + ((`w'-1)*2)
		}
		else if "`elsa'" == "elsa" {
			local y = 2002 + ((`w'-1)*2)
		}
		else if "`share'" == "share" {
			local y = 2004 + ((`w'-1)*2)
		}
		else if "`jstar'" == "jstar" {
			local y = 2006 + ((`w'-1)*2)
		}
		else if "`charls'" == "charls" {
			local y = 2010 + ((`w'-1)*2)
		}
		else if "`lasi'" == "lasi" {
			local y = 2012 + ((`w'-1)*2)
		}
		else if "`klosa'" == "klosa" {
			local y = 2006 + ((`w'-1)*2)
		}
		else if "`mhas'" == "mhas" {
		    if `w' == 1 | `w' == 2 {
			    local y = 2000 + ((`w'-1)*2)
			}
			else {
			    local y = 2012 + ((`w'-1)*2)
			}
		}
		else if "`tilda'" == "tilda" {
			local y = 2010 + ((`w'-1)*2)
		}
		else if "`creles'" == "creles" {
		    if `w' == 1 | `w' == 2 | `w' == 3 {
			    local y = 2004 + ((`w'-1)*2)
			}
			else {
			    local y = 2010 + ((`w'-1)*2)
			}
		}
		return local wy `w'
	}
	else if "`y'" != "" {
		if `n_studies' > 1 {
			di "can only specify one study"
			exit 198
		}
		else if "`hrs'" == "hrs" {
			local w = ((`y'-1992)/2)+1
		}
		else if "`elsa'" == "elsa" {
			local w = ((`y'-2002)/2)+1
		}
		else if "`share'" == "share" {
			local w = ((`y'-2004)/2)+1
		}
		else if "`jstar'" == "jstar" {
			local w = ((`y'-2006)/2)+1
		}
		else if "`charls'" == "charls" {
			local w = ((`y'-2010)/2)+1
		}
		else if "`lasi'" == "lasi" {
			local w = ((`y'-2012)/2)+1
		}
		else if "`klosa'" == "klosa" {
			local w = ((`y'-2006)/2)+1
		}
		else if "`mhas'" == "mhas" {
		    if `y' == 2000 | `y' == 2002 {
			    local w = ((`y'-2000)/2)+1
			}
			else {
			    local w = ((`y'-2012)/2)+1
			}
		}
		else if "`tilda'" == "tilda" {
			local w = ((`y'-2010)/2)+1
		}
		else if "`creles'" == "creles" {
		    if `y' == 2004 | `y' == 2006 | `y' == 2008 {
			    local w = ((`y'-2004)/2)+1
			}
			else {
			    local w = ((`y'-2010)/2)+1
			}
		}
		return local wy `y'
	}
	
	if "`asset'" == "asset" {
	    if "`hrs'" == "hrs" {
			local fin_time this_year 
		}
		else if "`elsa'" == "elsa" {
			local fin_time this_year 
		}
		else if "`share'" == "share" {
			local fin_time this_year 
		}
		else if "`jstar'" == "jstar" {
			local fin_time this_year 
		}
		else if "`charls'" == "charls" {
			local fin_time this_year
		}
		else if "`lasi'" == "lasi" {
			local fin_time this_year 
		}
		else if "`klosa'" == "klosa" {
			local fin_time this_year 
		}
		else if "`mhas'" == "mhas" {
			local fin_time this_year 
		}
		else if "`tilda'" == "tilda" {
			local fin_time this_year 
		}
		else if "`creles'" == "creles" {
			local fin_time this_year 
		}
	}
	else if "`income'" == "income" {
	    if "`hrs'" == "hrs" {
	        if `w' == 1 {
	            local fin_time sp_year
	            local fin_sp_year = 1991
	        }
	        else if `w' == 2 {
	            local fin_time mixed
	            local fin_sp_year = 1993
	        }
	        else {
	            local fin_time last_year
			}
		}
		else if "`elsa'" == "elsa" {
			local fin_time this_year 
		}
		else if "`share'" == "share" {
			local fin_time last_year
		}
		else if "`jstar'" == "jstar" {
			local fin_time last_year
		}
		else if "`charls'" == "charls" {
			local fin_time last_year
		}
		else if "`lasi'" == "lasi" {
			local fin_time this_year
		}
		else if "`klosa'" == "klosa" {
			local fin_time last_year
		}
		else if "`mhas'" == "mhas" {
			local fin_time unknown
		}
		else if "`tilda'" == "tilda" {
			local fin_time unknown
		}
		else if "`creles'" == "creles" {
			local fin_time unknown
		}
	}
	
	return local wave `w'
	return local year `y'
	return local time `time'
	return local fin_time `fin_time'
	return local fin_sp_year `fin_sp_year'
end

*create special missing codes
***missing_c_w1
***this is a program that creates speical missing codes for CHARLS Wave 1 variables
***
*** the program is called as follows
***		missing_c varlist [if] [in], result(result)
***			where:
***				varlist - list of variables which should influnce missing codes
***				result 	- name of variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_c_w1
program define missing_c_w1
syntax varlist [if] [in], result(varname) [wave(string)]

    
    marksample touse, novarlist // process if and in statements
    if "`wave'" == "" {
        h_wy_level `result'
        local w `r(wave)'
        local time `r(time)'
    }
    else {
        local w `wave'
    }
       
        
    
    quietly {
    	if "`time'" == "wave" | "`wave'" != "" {
            foreach v of varlist `varlist' {
        		replace `result' = .m if inlist(`v',.,.e) & !inlist(`result',.d,.r) & inw`w' == 1 & (`touse') // this is the lowest category
        	}
        }
    	foreach v of varlist `varlist' {
    		replace `result' = .d if `v' == .d & `result'!=.r & (`touse')
    	}
    	foreach v of varlist `varlist' {
    		replace `result' = .r if `v' == .r & (`touse')
    	}
    }
end
***missing_H
***this is a program that creates special missing codes for RAND Harmonized variables
***
*** the program is called as follows
***		missing_H varlist, result(result)
***			where:
***				varlist - list of variables which should influence missing codes
***				result 	- name of harmonized variable, must be generated before program
***				[if] and [in] allow limitation of the program to a subsample using an if or in statement, both are optional
capture program drop missing_H
program define missing_H
syntax varlist [if] [in], result(varname)

marksample touse, novarlist // process if and in statements

quietly {
	foreach v of varlist `varlist' {
		replace `result' = .m if `v' == .m & !inlist(`result',.d,.r)  & (`touse') // this is the lowest category
	}
	foreach v of varlist `varlist' {
		replace `result' = .d if `v' == .d & `result'!=.r & (`touse')
	}
	foreach v of varlist `varlist' {
		replace `result' = .r if `v' == .r & (`touse')
	}
}
end


********************************************************************************************************************
********************************************************************************************************************
***Prepare Wave 2 Demog Weight file for merging
tempfile wave_2_weight_
use "`wave_2_weight'"
drop if mi(ID)
save `wave_2_weight_'
clear

********************************************************************************************************************
********************************************************************************************************************

***Identify family respondents
tempfile wave_1_hhroster_
use "`wave_1_hhroster'"
gen ID_fam = ID 
save "`wave_1_hhroster_'", replace
clear

********************************************************************************************************************
********************************************************************************************************************

***load full set of CHARLS respodents***
use ID householdID communityID using "`wave_1_demog'"

********************************************************************************************************************
********************************************************************************************************************


*yesno
label define yesno ///
   0 "0.no" ///
   1 "1.yes" ///
   .e ".e:Error" ///
   .m ".m:Missing" ///
   .p ".p:Proxy" ///
   .s ".s:Skipped" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" ///
   .k ".k:No kids" ///
   .n ".n:Not applicable" ///
   .a ".a:Age less than 50"
 
*whether in wave
label define inw ///
   0 "0.nonresp" ///
   1 "1.resp,alive" 

*flag birth year
label define fbdate ///
    0 "0.no dispute" ///
    1 "1.dispute, last report used" 

*interview status
label define wstat ///
   0 "0.inap." ///
   1 "1.resp, alive"  ///
   4 "4.nr, alive" ///
   5 "5.nr, died this wv" ///
   6 "6.nr, died prev wv" ///
   7 "7.nr, dropped from samp" ///
   9 "9.nr, dk if alive or died"

*whether couple household
label define cpl ///
   0 "0.not coupled" ///
   1 "1.coupled" 
   
*financial respondent indicator
label define finr ///
   0 "0.no" ///
   1 "1.yes" 
   
*household respondent indicator
label define hhr ///
   0 "0.no" ///
   1 "1.yes" 
   
*family respondent indicator
label define famr ///
   0 "0.no" ///
   1 "1.yes" 

*age category   
label define r1agecat ///
   1 "1.<54" ///
   2 "2.55-64" ///
   3 "3.65-74" /// 
   4 "4.75-84" ///
   5 "5.>85" ///
   .m ".m:missing" 

*Flag in age   
label define iwindflag     ///
	0 "0.mo & yr not missing"  ///
	1 "1.only yr missing"     ///
	2 "2.only mo missing"         

***define value lables for missing birthdate
label define bflag         ///
	0 "0.birthdate not missing" ///
	1 "1.missing birthdate" 
	
*gender
label define genderf ///
   1 "1.male"  ///
   2 "2.female" ///
	.r ".r:Refuse" ///
	.m ".m:missing" ///
	.d ".d:DK"

*gender flag
label define gendrf ///
   0 "0.no gender problem"  ///
   1 "1.gender prob, used health gender"  ///
   2 "2.gender prob, used gender mode" ///
   3 "3.gender prob, used first gender" ///
   .r ".r:Refuse" ///
	.m ".m:missing" ///
	.d ".d:DK"
	
label define mstat                ///
	1 "1.married"                      ///
	2 "2.married, sp abs"  ///
	3 "3.partnered" ///
	4 "4.separated"                   ///
	5 "5.divorced"                   ///
	7 "7.widowed"                   ///
	8 "8.never married"           ///
	.r ".r:Refuse" ///
	.m ".m:missing" ///
	.d ".d:DK"

	
label define momliv      ///
 .f ".f:Dispersed"         ///
 0 "0.no"                ///
 1 "1.yes" 	 ///
 .s ".s:skip" 

label define dadliv      ///
 .f ".f:Dispersed"         ///
 0 "0.no"                ///
 1 "1.yes" 	 ///
 .s ".s:skip" 
 
label define mpart /// 
 0 "0.no" ///
 1 "1.yes" /// 
 .s ".s:skip" /// 
 .d ".d:DK" ///
 .r ".r:RF"
 
label define mrct  ///
 .s ".s:skip" ///
 .d ".d:DK" ///
 .r ".r:RF"
 
label define rabplace ///
 1 "1.Interview place" ///
 2 "2.Another village/neighborhood in the same province as interview place" ///
 3 "3.Another village/neighborhood in other province than interview place" ///
 4 "4.Abroad" ///
 .m ".m:missing" ///
 .d ".d:DK" ///
 .r ".r:RF"
 
label define hukou ///
 1 "1.Agricultual hukou" ///
 2 "2.Non-agricultural hukou" ///
 3 "3.Unified residence hukou" ///
 4 "4.Do not have hukou" ///
 .d ".d:DK" ///
 .r ".r:RF" ///
 .m ".m:missing"
 
label define hukou1 ///
   0 "0.Urban hukou" ///
   1 "1.Rural hukou"  ///
   .n ".n:No hukou" ///
   .r ".r:Refuse" ///
	.m ".m:missing" ///
	.d ".d:DK"

label define livreg ///
 1 "1.Rural Village" ///
 0 "0.Urban Community" ///
 .d ".d:DK" ///
 .r ".r:RF" ///
 .m ".m:missing"

label define raeduc_c /// 
 1 "1.No formal education illiterate" ///
 2 "2.Did not finish primary school but capable of reading and/or writing" ///
 3 "3.Sishu" ///
 4 "4.Elementary school" ///
 5 "5.Middle school" ///
 6 "6.High school" ///
 7 "7.Vocational school" ///
 8 "8.Two/Three Year College/Associate degree" ///
 9 "9.Four Year College/Bachelor's degree" ///
 10 "10.Master's degree" ///
 11 "11.Doctoral degree/Ph.D." ///
 .u ".u.unmar"    ///
 .v ".v.Sp NR"   ///
 .m ".m:missing" ///
 .d ".d:DK" ///
 .r ".r:RF"
 
label define educisced                ///
	1 "1.Primary education"                    ///
	2 "2.Lower secondary education"                   ///
	3 "3.Upper secondary education"                   ///
	4 "4.Post-secondary non tertiary education"                  ///
  5 "5.First stage of tertiary education"                  ///
  6 "5.Second stage of tertiary education"                  ///
	.u ".u.unmar"    ///
  .v ".v.Sp NR"   ///
  .m ".m:oth missing" ///
 	.d ".d:DK" ///
 	.r ".r:RF"   
 
 ***current marital status: with implied partnerships***
label define marwpart ///
   1 "1.married"  ///
   3 "3.partnered" ///
   4 "4.separated" ///
   5 "5.divorced" ///
   7 "7.widowed" ///
   8 "8.never married" ///
   .r ".r:Refuse" ///
	 .m ".m:Oth missing" ///
	 .d ".d:DK"
 



*set wave number
local wv=1
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2

***merge with demog file***
local demo_w1_demog ba002_1 ba002_2 ba002_3 be003 ba004 ///
                    bb001 ///
                    bc001 ///
                    bd001 ///
                    bd00* ///
                    be001 be003 be004_1 be009_1 ///
                    rgender
merge 1:1 ID using "`wave_1_demog'", keepusing(`demo_w1_demog') nogen

***merge with weight file***
local demo_w1_weight HH_weight HH_weight_ad1 iyear imonth ///
                     ind_weight ind_weight_ad1 ind_weight_ad2 ///
                     bio_weight1 bio_weight2
merge 1:1 ID using "`wave_1_weight'", keepusing(`demo_w1_weight') 
drop if _merge==2
drop _merge

***merge with household roster file***
local demo_w1_hhroster ID_fam a001
merge m:1 householdID using "`wave_1_hhroster_'", keepusing(`demo_w1_hhroster') 
drop if _merge==2
drop _merge

***merge with psu file***
local demo_w1_psu urban_nbs
merge m:1 communityID using "`wave_1_psu'", keepusing(`demo_w1_psu') 
drop if _merge==2
drop _merge


*person number (char)	
gen pnc=substr(ID,10,2)
label variable pn "pn:person id /Num"

destring pnc, gen(pn)
label variable pnc "pnc:person id /2-char"

***household identifier***
destring householdID, gen(hhid)
label variable hhid "hhid:HHold ID /Num " 

gen hhidc=householdID
label variable hhidc "hhidc:HHold ID /10-char " 

***Community identifier***
label variable communityID "communityID:community ID/7-char"

***spouse identifiers****
*Spouse person number
gen s`wv'pn=.
bysort hhid: replace s`wv'pn = pn[_n+1] if hhid[_n+1]==hhid[_n] 
bysort hhid: replace s`wv'pn = pn[_n-1] if hhid[_n-1]==hhid[_n] 
replace s`wv'pn=0 if s`wv'pn==.
label variable s`wv'pn "s`wv'pn:w`wv' spouse person ID(num)"

*spouse id
egen s`wv'id = concat (householdID s`wv'pn), punct(0)
replace s`wv'id="0" if s`wv'pn==0
label variable s`wv'id "s`wv'id:w`wv' spouse ID (char)"

*id of first spouse
gen raspid1 = s`wv'id if !inlist(s`wv'pn,0,.)
label variable raspid1 "raspid1:ID of 1st spouse"

***wave status: response indicator****
gen inw`wv'=1
label variable inw`wv' "inw`wv':In wave `wv'" 
label values inw`wv' yesno

***interview status
*respondent
gen r`wv'iwstat=0
replace r`wv'iwstat=1 if inw1==1
label variable r`wv'iwstat "r`wv'iwstat: w`wv' R Interview Status"
label values r`wv'iwstat wstat


***Household weight without non-response adjustment***
gen r`wv'wthh = HH_weight 
label variable r`wv'wthh "r`wv'wthh:w`wv' Household weight without non-response adjustment"

***Household weight with non-response adjustment***
gen r`wv'wthha = HH_weight_ad1 
label variable r`wv'wthha "r`wv'wthha:w`wv' Household weight with non-response adjustment"

***Individual weight without non-response adjustment***
gen r`wv'wtresp = ind_weight 
label variable r`wv'wtresp "r`wv'wtresp:w`wv' Individual weight without non-response adjustment"


***Individual weight with HH non-response adjustment****
gen r`wv'wtrespa = ind_weight_ad1 
label var r`wv'wtrespa "r`wv'wtrespa:w`wv' Individual weight with HH non-response adjustment"

***Individual weight with HH/Ind non-response adjustment
gen r`wv'wtrespb = ind_weight_ad2 
label var r`wv'wtrespb "r`wv'wtrespb:w`wv' Individual weight with HH/Ind non-response adjustment"

***Individual biomarker weight with HH non-response adjustment***
gen r`wv'wtrespbioa = bio_weight1 
label var r`wv'wtrespbioa "r`wv'wtrespbioa:w`wv' Individual biomarker weight with HH non-response adjustment"

***Individual biomarker weight with HH/Ind non-response adjustment***
gen r`wv'wtrespbiob = bio_weight2 
label var r`wv'wtrespbiob "r`wv'wtrespbiob:w`wv' Individual biomarker weight with HH/Ind non-response adjustment"

***whether couple****
gen h`wv'cpl=.
replace h`wv'cpl=0 if s`wv'pn==0
replace h`wv'cpl=1 if inlist(s`wv'pn,1,2)
label variable h`wv'cpl "h`wv'cpl:w`wv' whether coupled"
label values h`wv'cpl cpl

***couple identifier***
egen h`wv'coupid=group(hhid)
label variable h`wv'coupid "h`wv'coupid:w`wv' couple ID/num" 

****count # HH respondents *******
bysort hhid: egen h`wv'hhresp=count(hhid)
label var h`wv'hhresp "h`wv'hhresp:w`wv' # respondents in household"

***Interview year***
***respondent 
destring(iyear), gen(r`wv'iwy) 
label variable r`wv'iwy  "r`wv'iwy:w`wv' R year of interview"

***Interview month***
*respondent 
destring(imonth), gen(r`wv'iwm) 
label variable r`wv'iwm  "r`wv'iwm:w`wv' R month of interview"

***Birth year***
*respondent
gen rabyear = .
missing_c_w1 ba002_1, result(rabyear) wave(`wv')
replace rabyear = ba002_1 if inrange(ba002_1,1900,2000)
label variable rabyear "rabyear:R birth year"

***Birth month***
*respondent
gen rabmonth = .
missing_c_w1 ba002_2, result(rabmonth) wave(`wv')
replace rabmonth = .m if ba002_2 == 0
replace rabmonth = ba002_2 if inrange(ba002_2,1,12)
label variable rabmonth "rabmonth:R birth month"

***Birth day***
*respondent
gen rabday = .
missing_c_w1 ba002_3, result(rabday) wave(`wv')
replace rabday = .m if ba002_3 == 0
replace rabday = ba002_3 if inrange(ba002_3,1,31)
label variable rabday "rabday:R birth day"

***Age***
*respondent
gen r`wv'agey = .
missing_c_w1 ba004, result(r`wv'agey)
replace r`wv'agey = ba004 if inrange(ba004,10,150)
replace r`wv'agey=floor((ym(r`wv'iwy,r`wv'iwm) - ym(rabyear,6))/12) if !mi(r`wv'iwy) & !mi(rabyear) & !mi(r`wv'iwm) & mi(rabmonth)
replace r`wv'agey=floor((ym(r`wv'iwy,r`wv'iwm) - ym(rabyear,rabmonth))/12) if !mi(r`wv'iwy) & !mi(rabyear) & !mi(r`wv'iwm) & !mi(rabmonth)
label var r`wv'agey "r`pre_wv'agey:w`wv' R age in years"

***gender*****
*respondent
gen r`wv'gender = .
missing_c_w1 rgender, result(r`wv'gender) wave(`wv')
replace r`wv'gender = rgender if inlist(rgender,1,2)
label variable r`wv'gender "r`wv'gender:R Gender"
label values r`wv'gender genderf

gen w1rgender = rgender
label values w1rgender genderf

***Current Marital Status: Without Partnership***
*respondent
gen r`wv'mstath=.
missing_c_w1 be001, result(r`wv'mstath)
replace r`wv'mstath=1 if be001==1
replace r`wv'mstath=2 if be001==2
replace r`wv'mstath=4 if be001==3
replace r`wv'mstath=5 if be001==4
replace r`wv'mstath=7 if be001==5
replace r`wv'mstath=8 if be001==6
label variable r`wv'mstath "r`wv'mstath:w`wv' R marital status"
label values r`wv'mstath mstat

*spouse current marital status
gen s`wv'mstath =.
spouse r`wv'mstath, result(s`wv'mstath) wave(`wv')
label variable s`wv'mstath "s`wv'mstath:w`wv' S marital status" 
label values s`wv'mstath mstat

***current marital status: with partnerships***
*espondent marital status with partnership
gen r1mstat=.
missing_c_w1 be001, result(r`wv'mstat)
replace r1mstat = 1 if be001 == 1
replace r1mstat = 4 if be001 == 3
replace r1mstat = 5 if be001 == 4
replace r1mstat = 7 if be001 == 5
replace r1mstat = 8 if be001 == 6
replace r1mstat = 3 if (be001 == 2) | (inlist(be001,3,4,5,6) & inlist(s`wv'pn,1,2))
label variable r1mstat "r1mstat:w1 r marital status w/partners, filled"
label values r1mstat marwpart

*spouse marital status with partnership
gen s`wv'mstat=.
spouse r`wv'mstat, result(s`wv'mstat) wave(1)
label variable s`wv'mstat "s`wv'mstat:w1 s marital status w/partners, filled"
label values  s`wv'mstat marwpart


****Education***
*respondent
gen raeduc_c=.
missing_c_w1 bd001, result(raeduc_c) wave(`wv')
replace raeduc_c= 1 if bd001==1
replace raeduc_c= 2 if bd001==2
replace raeduc_c= 3 if bd001==3
replace raeduc_c= 4 if bd001==4
replace raeduc_c= 5 if bd001==5
replace raeduc_c= 6 if bd001==6
replace raeduc_c= 7 if bd001==7
replace raeduc_c= 8 if bd001==8
replace raeduc_c= 9 if bd001==9
replace raeduc_c=10 if bd001==10
replace raeduc_c=11 if bd001==11
label variable raeduc_c "raeduc_c:R education (categ)"
label values raeduc_c raeduc_c

*spouse education
gen s`wv'educ_c =.
spouse raeduc_c, result(s`wv'educ_c) wave(`wv')
label variable s`wv'educ_c "s`wv'educ_c:w`wv' S education (categ)"
label values s`wv'educ_c raeduc_c

***education: total years 
gen raeduc_y = . 
replace raeduc_y = 0	 if bd001==1
replace raeduc_y = bd002 if bd001==2
replace raeduc_y = bd006-bd005 if inlist(bd001, 3,4,5,6,7,8,9,10,11) & bd005 != .d & bd006 != .d & bd006 > bd005

***education: isced category****
*respondent
gen raedisced=.
missing_c_w1 bd001, result(raedisced) wave(`wv')
replace raedisced=1  if inlist(bd001,1,2,3)
replace raedisced=2  if inlist(bd001,4,5)
replace raedisced=3  if bd001==6
replace raedisced=4  if bd001==7
replace raedisced=5  if inlist(bd001,8,9,10)
replace raedisced=6  if bd001==11
label variable raedisced "raedisced:R education ISCED"  
label val raedisced educisced

*spouse education
gen s`wv'edisced =.
spouse raedisced, result(s`wv'edisced) wave(`wv')
label variable s`wv'edisced "s`wv'edisced:w`wv' S education ISCED"
label val s1edisced educisced

***Number of Marriages***
*respondent
gen r`wv'mrct=.
missing_c_w1 be001 be003, result(r`wv'mrct)
replace r`wv'mrct= 0 if be001==6
replace r`wv'mrct=be003 if inrange(be003,0,6)
label variable r`wv'mrct "r`wv'mrct:w`wv' r # marriages"

*spouse number of marriages
gen s`wv'mrct =.
spouse r`wv'mrct, result(s`wv'mrct) wave(`wv')
label variable s`wv'mrct "s`wv'mrct:w`wv' S # marriages"

***Length of Current Marriage***
*respondent
gen r`wv'mcurln=.
missing_c_w1 be001 be003 be004_1 be009_1, result(r`wv'mcurln)
replace r`wv'mcurln =.u if inlist(r`wv'mstath,5,7,8)
replace r`wv'mcurln = r`wv'iwy - be004_1 if be003==1 & inlist(r`wv'mstath,1,2,4) & !mi(be004_1)
replace r`wv'mcurln = r`wv'iwy - be009_1 if inrange(be003,2,10) & inlist(r`wv'mstath,1,2,4) & !mi(be009_1)
label variable r`wv'mcurln "r`wv'mcurln:w`wv' r length of current marriage"

***Birth Place***
*respondent
gen rabplace_c= .
missing_c_w1 bb001, result(rabplace_c) wave(`wv')
replace rabplace_c = 1 if bb001 == 1
replace rabplace_c = 2 if bb001 == 2
replace rabplace_c = 2 if bb001 == 3
replace rabplace_c = 3 if bb001 == 4
replace rabplace_c = 4 if bb001 == 5
label variable rabplace_c "rabplace_c:R birth place"
label values rabplace_c rabplace

*spouse
gen s`wv'bplace_c =.
spouse rabplace_c, result(s`wv'bplace_c) wave(`wv')
label variable s`wv'bplace_c "s`wv'bplace_c:w`wv' S birth place"
label values s`wv'bplace_c rabplace

***Unified Residence HuKou***
*respondent
gen r`wv'hukou = .
missing_c_w1 bc001, result(r`wv'hukou)
replace r`wv'hukou= 1 if bc001==1
replace r`wv'hukou= 2 if bc001==2
replace r`wv'hukou= 3 if bc001==3
replace r`wv'hukou= 4 if bc001==4
label variable r`wv'hukou "r`wv'hukou:w`wv' R hukou status"
label values r`wv'hukou hukou

*spouse
gen s`wv'hukou =.
spouse r`wv'hukou, result(s`wv'hukou) wave(`wv')
label variable s`wv'hukou "s`wv'hukou:w`wv' S hukou status"
label values s`wv'hukou hukou

***urban /rural*****
*respondent
gen r`wv'rural = .
missing_c_w1 urban_nbs, result(r`wv'rural)
replace r`wv'rural = 0 if urban_nbs==1
replace r`wv'rural = 1 if urban_nbs==0
label var r`wv'rural "r`wv'rural:w`wv' R lives in rural or urban" 
label values r`wv'rural livreg
	
*spouse
gen s`wv'rural = .
spouse r`wv'rural, result(s`wv'rural) wave(1)
label var s`wv'rural "s`wv'rural:w`wv' S lives in rural or urban" 
label values s`wv'rural livreg

***Rural or urban hukou
gen r`wv'rural2 =.
missing_c_w1 bc001, result(r`wv'rural2)
replace r`wv'rural2=.n if bc001==4
replace r`wv'rural2=0 if bc001==1
replace r`wv'rural2=1 if inlist(bc001,2,3) 
label var r`wv'rural2 "r`wv'rural2:w`wv' R rural hukou" 
label value r`wv'rural2 hukou1

*spouse
gen s`wv'rural2 = .
spouse r`wv'rural2, result(s`wv'rural2) wave(1)
label var s`wv'rural2 "s`wv'rural2:w`wv' S rural hukou" 
label value s`wv'rural2 hukou1


****drop CHARLS demog raw variables***
drop `demo_w1_demog'

****drop CHARLS weight raw variables***
drop `demo_w1_weight'

****drop CHARLS household roster raw variables***
drop `demo_w1_hhroster'

****drop CHARLS psu raw variables***
drop `demo_w1_psu'

*******************************************************
****MERGE WITH WAVE 2**********************************
********************************************************

rename ID id_w1
label variable id_w1 "id_w1:Wave 1 person identifier/11-char"

rename householdID hhid_w1
label variable hhid_w1 "hhid_w1:Wave 1 hhold identifier/9-char"
gen householdID = hhid_w1 + "0"
gen ID = householdID + substr(id_w1,-2,2) 

merge 1:1 ID using "`wave_2_demog'" ,keepusing (ID householdID communityID) 

***in Wave 1 (update)
replace inw1 = 0 if inw1 ==.

***in Wave 2
gen inw2 = 0
replace inw2 = 1 if inlist(_merge,2,3)
label variable inw2 "inw2:In wave 2" 
label values inw2 yesno
drop _merge


*set wave number
local wv=2
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2


***merge with demog file***
local demo_w2_demog ba001_w2_1 ba002_1 ba002_2 ba002_3 be003 ba004 be004_2 ba000_w2_3 ///
                    bb001 ///
                    bc001 ///
                    bd001 bd001_w2_4 bd001_w2_1 bd001_w2_3 ///
                    be001 be003 be004_1 be009_1 be003_w2_1 ///
                    xrtype 
                    
merge 1:1 ID using "`wave_2_demog'", keepusing(`demo_w2_demog') 
drop if _merge==2
drop _merge

***merge with health file***
local demo_w2_health  xrgender
                    
merge 1:1 ID using "`wave_2_health'", keepusing(`demo_w2_health') 
drop if _merge==2
drop _merge


***merge with weight file***
local demo_w2_weight HH_weight HH_weight_ad1 ///
                     INDV_weight INDV_weight_ad1 INDV_weight_ad2 ///
                     HH_L_weight INDV_L_weight HH_L_Died INDV_L_Died imonth iyear
merge 1:1 ID using "`wave_2_weight_'", keepusing(`demo_w2_weight')
drop if _merge==2
drop _merge

***merge with psu file***
local demo_w2_psu urban_nbs
merge m:1 communityID using "`wave_2_psu'", keepusing(`demo_w2_psu') 
drop if _merge==2
drop _merge
foreach var of varlist `demo_w2_psu' {
    replace `var' = . if inw`wv' == 0 // *correct overassignmnet of community values to non-reponding community members who respondend previously 
}

label variable ID "ID:person identifier/12-char"

***person number (char)***
replace pnc = substr(ID,11,2) if mi(pnc)

replace pn = real(pnc) if mi(pn)

***household identifier (update)***
replace hhid = real(householdID) if mi(hhid)

replace hhidc = householdID if mi(hhidc)

****count # HH respondents *******
bysort hhid: egen h`wv'hhresp=count(hhid) if inw`wv'==1
label var h`wv'hhresp "h`wv'hhresp:w`wv' # respondents in household"

***spouse identifiers****
*spouse person number
gen s`wv'pn=.
bysort hhid: replace s`wv'pn = pn[_n+1] if hhid[_n+1]==hhid[_n] & inw`wv'==1 
bysort hhid: replace s`wv'pn = pn[_n-1] if hhid[_n-1]==hhid[_n] & inw`wv'==1
replace s`wv'pn=0 if s`wv'pn==. & inw`wv'==1
replace s`wv'pn=0 if h`wv'hhresp==1 & inw`wv'==1
label variable s`wv'pn "s`wv'pn:w`wv' spouse person ID(num)"

*spouse id
egen s`wv'id = concat (hhidc s`wv'pn) , punct(0)
replace s`wv'id="0" if s`wv'pn==. & inw`wv'==1
label variable s`wv'id "s`wv'id:w`wv' spouse ID (char)"

*id of first spouse (update)
replace raspid1 = s`wv'id if !inlist(s`wv'id,"0","") & missing(raspid1)

*id of second response
gen raspid2 =""
replace raspid2 = s`wv'id if s`wv'id != raspid1 & !inlist(s`wv'id,"0","") & !inlist(raspid1,"0","")
label variable raspid2 "raspid2:ID of 2nd spouse"

***whether couple****
gen h`wv'cpl=.
replace h`wv'cpl=0 if s`wv'pn==0
replace h`wv'cpl=1 if inlist(s`wv'pn,1,2,3,4)
label variable h`wv'cpl "h`wv'cpl:w`wv' whether coupled"
label values h`wv'cpl cpl

***couple identifier***
egen h`wv'coupid=group(hhid) if inw`wv'==1
label variable h`wv'coupid "h`wv'coupid:w`wv' couple ID/num" 

***Current Marital Status: Without Partnership***
**respondent 
gen r`wv'mstath=.
replace r`wv'mstath =.m if inw`wv'==1
replace r`wv'mstath=1 if be001==1
replace r`wv'mstath=2 if be001==2
replace r`wv'mstath=4 if be001==3
replace r`wv'mstath=5 if be001==4
replace r`wv'mstath=7 if be001==5
replace r`wv'mstath=8 if be001==6
replace r`wv'mstath=3 if be001==7
label variable r`wv'mstath "r`wv'mstath:w`wv' R marital status"
label values r`wv'mstath mstat

*spouse 
gen s`wv'mstath =.
spouse r`wv'mstath, result(s`wv'mstath) wave(`wv')
label variable s`wv'mstath "s`wv'mstath:w`wv' S marital status" 
label values s`wv'mstath mstat

***current marital status: with partnerships***
*respondent 
gen r`wv'mstat=.
replace r`wv'mstat =.m if  inw`wv'==1
replace r`wv'mstat = 1 if be001 == 1
replace r`wv'mstat = 4 if be001 == 3
replace r`wv'mstat = 5 if be001 == 4
replace r`wv'mstat = 7 if be001 == 5
replace r`wv'mstat = 8 if be001 == 6
replace r`wv'mstat = 3 if inlist(be001,2,7) | (inlist(be001,3,4,5,6) & inlist(s`wv'pn,1,2,3))
label variable r`wv'mstat "r`wv'mstat:w`wv' r marital status w/partners, filled"
label values r`wv'mstat marwpart

*spouse
gen s`wv'mstat=.
spouse r`wv'mstat, result(s`wv'mstat) wave(`wv')
label variable s`wv'mstat "s`wv'mstat:w`wv' s marital status w/partners, filled"
label values  s`wv'mstat marwpart

***Wave 1 interview status***
*respondent (update)
replace r`pre_wv'iwstat = 0 if r`pre_wv'iwstat == .

***Wave 2 interview status
*respondent
gen r`wv'iwstat=0
replace r`wv'iwstat=1 if inw2==1
replace r`wv'iwstat=9 if inw2==0 & inw1==1
replace r`wv'iwstat=5 if inw2==0 & INDV_L_Died==1
label variable r`wv'iwstat "r`wv'iwstat: w`wv' R Interview Status"
label values r`wv'iwstat wstat

***Household weight without non-response adjustment***
*respondent
gen r`wv'wthh = HH_weight 
label variable r`wv'wthh "r`wv'wthh:w`wv' Household weight without non-response adjustment"

***Household weight with non-response adjustment***
*respondent
gen r`wv'wthha = HH_weight_ad1 
label variable r`wv'wthha "r`wv'wthha:w`wv' Household weight with non-response adjustment"

***Household longitudinal weight ***
*respondent
gen r`wv'wthhl = HH_L_weight
label variable r`wv'wthhl "r`wv'wthhl:w`wv' Household longitudinal weight"

***Individual weight without non-response adjustment***
*respondent
gen r`wv'wtresp = INDV_weight  
label variable r`wv'wtresp "r`wv'wtresp:w`wv' Individual weight without non-response adjustment"

***Individual weight with HH non-response adjustment****
*respondent
gen r`wv'wtrespa = INDV_weight_ad1 
label var r`wv'wtrespa "r`wv'wtrespa:w`wv' Individual weight with HH non-response adjustment"


***Individual weight with HH/Ind non-response adjustment
*respondent
gen r`wv'wtrespb = INDV_weight_ad2
label var r`wv'wtrespb "r`wv'wtrespb:w`wv' Individual weight with HH/Ind non-response adjustment"

***Individual longitudinal weight 
*respondent
gen r`wv'wtrespl = INDV_L_weight
label variable r`wv'wtrespl "r`wv'wtrespl:w`wv' Individual longitudinal weight"

****Respondent Birth Year***
*responent (update)
replace ba002_1=1934 if ID=="094004103001" // *change one birth year after checking father bday

replace rabyear = .m if mi(rabyear) & !inlist(rabyear,.d,.r) & inw`wv' == 1
replace rabyear = .m if ba001_w2_1 == 2 // delete disputed report
replace rabyear = ba002_1 if inrange(ba002_1,1900,2000) & mi(rabyear)

****Respondent Birth Year***
*responent (update)
replace rabmonth = .m if mi(rabmonth) & !inlist(rabmonth,.d,.r) & inw`wv' == 1
replace rabmonth = .m if ba001_w2_1 == 2 // delete disputed report
replace rabmonth = ba002_2 if inrange(ba002_2,1,12) & mi(rabmonth)

****Respondent Birth Day***
*responent (update)
replace rabday = .m if mi(rabday) & !inlist(rabday,.d,.r) & inw`wv' == 1
replace rabday = .m if ba001_w2_1 == 2 // delete disputed report
replace rabday = ba002_3 if inrange(ba002_3,1,31) & mi(rabday)

****Respondent Birth Date Flag***
*respondent
gen rafbdate = .
replace rafbdate = 0
replace rafbdate = 1 if ba001_w2_1 == 2
label variable rafbdate "rabyear:R Flag birth year"
label values rafbdate fbdate

***interview year********
***respondent 
destring(iyear), gen(r`wv'iwy) 
replace r`wv'iwy=. if inw`wv'==0
label variable r`wv'iwy  "r`wv'iwy:w`wv' R year of interview"

***interview month
*respondent
destring(imonth), gen(r`wv'iwm) 
replace r`wv'iwm=. if inw`wv'==0
label variable r`wv'iwm  "r`wv'iwm:w`wv' R month of interview"

***Age in Years***
*respondent
gen r`wv'agey = .
missing_c_w1 ba004, result(r`wv'agey)
replace r`wv'agey = ba004 if inrange(ba004,10,150)
replace r`wv'agey=floor((ym(r`wv'iwy,r`wv'iwm) - ym(rabyear,6))/12) if !mi(r`wv'iwy) & !mi(rabyear) & !mi(r`wv'iwm) & mi(rabmonth)
replace r`wv'agey=floor((ym(r`wv'iwy,r`wv'iwm) - ym(rabyear,rabmonth))/12) if !mi(r`wv'iwy) & !mi(rabyear) & !mi(r`wv'iwm) & !mi(rabmonth)
label var r`wv'agey "r`pre_wv'agey:w`wv' R age in years"

***Gender***
*respondent
gen r`wv'gender = .
replace r`wv'gender = .m if inw`wv' == 1
replace r`wv'gender = ba000_w2_3 if inlist(ba000_w2_3,1,2)
label variable r`wv'gender "r`wv'gender:R Gender"
label values r`wv'gender genderf

gen r`wv'gender_h = .
replace r`wv'gender_h = .m if inw`wv' == 1
replace r`wv'gender_h = xrgender if inlist(xrgender,1,2)
label variable r`wv'gender_h "r`wv'gender_h:R Gender by health module"
label values r`wv'gender_h genderf

*******Education********
*respondent (update)
replace raeduc_c = .m if mi(raeduc_c) & !inlist(raeduc_c,.d,.r) & inw`wv' == 1
replace raeduc_c = 1 if (bd001 == 1 | bd001_w2_3) == 1 & mi(raeduc_c)
replace raeduc_c = 2 if (bd001 == 2 | bd001_w2_3) == 2 & mi(raeduc_c)
replace raeduc_c = 3 if (bd001 == 3 | bd001_w2_3) == 3 & mi(raeduc_c)
replace raeduc_c = 4 if (bd001 == 4 | bd001_w2_3) == 4 & mi(raeduc_c)
replace raeduc_c = 5 if (bd001 == 5 | bd001_w2_3) == 5 & mi(raeduc_c)
replace raeduc_c = 6 if (bd001 == 6 | bd001_w2_3) == 6 & mi(raeduc_c)
replace raeduc_c = 7 if (bd001 == 7 | bd001_w2_3) == 7 & mi(raeduc_c)
replace raeduc_c = 8 if (bd001 == 8 | bd001_w2_3) == 8 & mi(raeduc_c)
replace raeduc_c = 9 if (bd001 == 9 | bd001_w2_3) == 9 & mi(raeduc_c)
replace raeduc_c = 10 if (bd001 == 10 | bd001_w2_3) == 10 & mi(raeduc_c)
replace raeduc_c = 11 if (bd001 == 11 | bd001_w2_3) == 11 & mi(raeduc_c)

*spouse education
gen s`wv'educ_c =.
spouse raeduc_c, result(s`wv'educ_c) wave(`wv')
label variable s`wv'educ_c "s`wv'educ_c:w`wv' S education (categ)"
label values s`wv'educ_c raeduc_c

***education: isced category ******
*respondent (update)
replace raedisced = .m if mi(raedisced) & !inlist(raedisced,.d,.r) & inw`wv' == 1
replace raedisced = 1 if inlist(raeduc_c,1,2,3) & mi(raedisced)
replace raedisced = 2 if inlist(raeduc_c,4,5) & mi(raedisced)
replace raedisced = 3 if raeduc_c == 6 & mi(raedisced)
replace raedisced = 4 if raeduc_c == 7 & mi(raedisced)
replace raedisced = 5 if inlist(raeduc_c,8,9,10) & mi(raedisced)
replace raedisced = 6 if raeduc_c==11 & mi(raedisced)

*spouse education
gen s`wv'edisced =.
spouse raedisced, result(s`wv'edisced) wave(`wv')
label variable s`wv'edisced "s`wv'edisced:w`wv' S education ISCED"
label val s`wv'edisced educisced

***Number of Marriages***
*respondent
gen r`wv'mrct=.
replace r`wv'mrct =.m if inw`wv'==1
replace r`wv'mrct = 0 if be001==6
replace r`wv'mrct = be003 if inrange(be003,0,6)
replace r`wv'mrct = r`pre_wv'mrct + be003_w2_1 if inrange(be003_w2_1,0,6) & !mi(r`pre_wv'mrct) 
label variable r`wv'mrct "r`wv'mrct:w`wv' r # marriages"

*spouse number of marriages
gen s`wv'mrct =.
spouse r`wv'mrct, result(s`wv'mrct) wave(`wv')
label variable s`wv'mrct "s`wv'mrct:w`wv' S # marriages"

***Respondent Length of Current Marriage***
*respondent
gen r`wv'mcurln=.
replace r`wv'mcurln =.m  if inw`wv' == 1
replace r`wv'mcurln =.u if inlist(r`wv'mstath,5,7,8) 
replace r`wv'mcurln = r`pre_wv'mcurln + (r`wv'iwy - r`pre_wv'iwy) if be003_w2_1 == 0 & !mi(r`pre_wv'mcurln)
replace r`wv'mcurln = r`wv'iwy - be004_1 if (be003 == 1 | be003_w2_1 == 1)  & inlist(r`wv'mstath,1,2,4) & !mi(be004_1)
replace r`wv'mcurln = r`wv'iwy - be009_1 if (inrange(be003,2,10) | inrange(be003_w2_1,2,10)) & inlist(r`wv'mstath,1,2,4) & !mi(be009_1)
label variable r`wv'mcurln "r`wv'mcurln:w`wv' r length of current marriage"

***	Birth Place***
*respondent (update)
replace rabplace_c = .m if mi(rabplace_c) & !inlist(rabplace_c,.d,.r) & inw`wv' == 1
replace rabplace_c = 1 if bb001 == 1 & mi(rabplace_c)
replace rabplace_c = 2 if bb001 == 2 & mi(rabplace_c)
replace rabplace_c = 3 if bb001 == 3 & mi(rabplace_c)
replace rabplace_c = 4 if bb001 == 4 & mi(rabplace_c)

*spouse
gen s`wv'bplace_c =.
spouse rabplace_c, result(s`wv'bplace_c) wave(`wv')
label variable s`wv'bplace_c "s`wv'bplace_c:w`wv' S birth place"
label values s`wv'bplace_c rabplace

***Unified Residence HuKou***
*respondent
gen r`wv'hukou = . 
replace r`wv'hukou=.m if inw`wv' == 1
replace r`wv'hukou= 1 if bc001==1
replace r`wv'hukou= 2 if bc001==2
replace r`wv'hukou= 3 if bc001==3
replace r`wv'hukou= 4 if bc001==4 
label variable r`wv'hukou "r`wv'hukou:w`wv' R hukou status"
label values r`wv'hukou hukou

*spouse hukou
gen s`wv'hukou =.
spouse r`wv'hukou, result(s`wv'hukou) wave(`wv')
label variable s`wv'hukou "s`wv'hukou:w`wv' S hukou status"
label values s`wv'hukou hukou

***Respondent live region*****
***urban /rural*****
*respondent
gen r`wv'rural = .
replace r`wv'rural =.m if inw`wv' == 1
replace r`wv'rural = r`pre_wv'rural if xrtype == 2 & inw`wv' == 1
replace r`wv'rural = 0 if urban_nbs==1
replace r`wv'rural = 1 if urban_nbs==0
label var r`wv'rural "r`wv'rural:w`wv' R lives in rural or urban" 
label values r`wv'rural livreg
	
gen s`wv'rural = .
spouse r`wv'rural, result(s`wv'rural) wave(`wv')
label var s`wv'rural "s`wv'rural:w`wv' S lives in rural or urban" 
label values s`wv'rural livreg

***Rural or urban hukou
gen r`wv'rural2 =.
replace r`wv'rural2=.m if inw`wv'==1
replace r`wv'rural2=.n if bc001==4
replace r`wv'rural2 = 0 if bc001==1
replace r`wv'rural2 = 1 if inlist(bc001,2,3) 
label var r`wv'rural2 "r`wv'rural2:w`wv' R rural hukou" 
label value r`wv'rural2 hukou1

gen s`wv'rural2 = .
spouse r`wv'rural2, result(s`wv'rural2) wave(`wv')
label var s`wv'rural2 "s`wv'rural2:w`wv' S rural hukou" 
label value s`wv'rural2 hukou1


****drop CHARLS demog raw variables***
drop `demo_w2_demog' 

****drop CHARLS weight raw variables***
drop `demo_w2_weight'

****drop CHARLS health***
drop `demo_w2_health'

****drop CHARLS psu raw variables***
drop `demo_w`wv'_psu'

*set top wave number
local maxwave=2
local pre_maxwave=`maxwave'-1


***Interivew Year***
*spouse
forvalues w = 1 / `maxwave' {
    gen s`w'iwy = .
    spouse r`w'iwy, result(s`w'iwy) wave(`w')
    label variable s`w'iwy "s`w'iwy:w`w' S year of interview" 
}

***Interview Month***
*spouse
forvalues w = 1 / `maxwave' {
    gen s`w'iwm = .
    spouse r`w'iwm, result(s`w'iwm) wave(`w')
    label variable s`w'iwm "s`w'iwm:w`w' S month of interview" 
}

***Individual weight without non-response adjustment***
forvalues w = 1 / `maxwave' {
    gen s`w'wtresp =.
    spouse r`w'wtresp, result(s`w'wtresp) wave(`w')
    label variable s`w'wtresp "s`w'wtresp:w`w' S weight without non-response adjustment"
}

***Individual weight with HH non-response adjustment****
forvalues w = 1 / `maxwave' {
    gen s`w'wtrespa =.
    spouse r`w'wtrespa, result(s`w'wtrespa) wave(`w')
    label variable s`w'wtrespa "s`w'wtrespa:w`w' S weight with HH non-response adjustment"
}

***Individual weight with HH/Ind non-response adjustment***
forvalues w = 1 / `maxwave' {
    gen s`w'wtrespb =.
    spouse r`w'wtrespb, result(s`w'wtrespb) wave(`w')
    label variable s`w'wtrespb "s`w'wtrespb:w`w' S weight with HH/Ind non-response adjustment"
}

***Individual longitudinal weight***
forvalues w = 2 / `maxwave' {
    gen s`w'wtrespl = .
    spouse r`w'wtrespl, result(s`w'wtrespl) wave(`w')
    label variable s`w'wtrespl "s`w'wtrespl:w`w' Individual longitudinal weight"
}

***Individual biomarker weight with HH non-response adjustment***
forvalues w = 1 / 1 {
    gen s`w'wtrespbioa =.  
    spouse r`w'wtrespbioa, result(s`w'wtrespbioa) wave(`w')
    label var s`w'wtrespbioa "s`w'wtrespbioa:w`w' Individual biomarker weight with HH non-response adjustment"
}

***Individual biomarker weight with HH/Ind non-response adjustment***
forvalues w = 1 / 1 {
    gen s`w'wtrespbiob =.  
    spouse r`w'wtrespbiob, result(s`w'wtrespbiob) wave(`w')
    label var s`w'wtrespbiob "s`w'wtrespbiob:w`w' Individual biomarker weight with HH/Ind non-response adjustment"
}

***Birth year***
*respondent
forvalues w = `maxwave' (-1) 1 {
    replace rabyear = r`w'iwy - r`w'agey if mi(rabyear) & !mi(r`w'agey) & inw`w' ==1 // *use age to replace missing birth year
}

***Interview status***
*spouse
forvalues w = 1 / `maxwave' {
    gen s`w'iwstat =.
    spouse r`w'iwstat, result(s`w'iwstat) wave(`w')
    label variable s`w'iwstat "s`w'iwstat: w`w' S Interview Status"
    label values s`w'iwstat wstat
}

***Gender flag***
gen genderfirst = .
forvalues w = 1 / `maxwave' {
    if `w' == 1 {
        local genders r`w'gender
        local genders_h
    }
    else {
        local genders `genders' r`w'gender
        local genders_h `genders_h' r`w'gender_h
    }
    replace genderfirst = r`w'gender if !mi(r`w'gender) & mi(genderfirst)
}
egen gendern = rownonmiss(`genders')
egen gendern_h = rownonmiss(`genders_h')

preserve
reshape long r@gender, i(ID)
egen gendermode = mode(rgender), by(ID)
egen gendersd = sd(rgender), by(ID)
reshape wide

reshape long r@gender_h, i(ID)
egen gendermode_h = mode(rgender_h), by(ID)
egen gendersd_h = sd(rgender_h), by(ID)
reshape wide
keep ID gendermode gendersd gendermode_h gendersd_h
tempfile gender_file
save `gender_file'
restore
merge 1:1 ID using `gender_file', nogen

gen rafgendr = .
replace rafgendr = 0 if gendern == 1 | gendersd == 0
replace rafgendr = 1 if gendersd > 0 & !mi(gendersd) & (gendern_h == 1 | gendersd_h == 0)
replace rafgendr = 2 if gendersd > 0 & !mi(gendersd) & gendersd_h > 0 & !mi(gendersd_h) & !mi(gendermode)
replace rafgendr = 3 if gendersd > 0 & !mi(gendersd) & gendersd_h > 0 & !mi(gendersd_h) & mi(gendermode)
label variable rafgendr "rafgendr: Flag if problem with R gender"
label values rafgendr gendrf
    
*spouse
forvalues w = 1 / `maxwave' {
    gen s`w'fgendr =.
    spouse rafgendr, result(s`w'fgendr) wave(`w')
    label variable s`w'fgendr "s`w'fgendr:w`w' Flag if problem with S gender"
    label values s`w'fgendr gendrf
}
        
***Gender***
*respondent
gen ragender=.
missing_H `genders' `genders_h', result(ragender)
replace ragender = gendermode if gendern == 1 | gendersd == 0
replace ragender = gendermode_h if ((gendersd > 0 & !mi(gendersd)) | gendern == 0) & (gendern_h == 1 | gendersd_h == 0)
replace ragender = gendermode if gendersd > 0 & !mi(gendersd) & gendersd_h > 0 & !mi(gendersd_h) & !mi(gendermode)
replace ragender = genderfirst if gendersd > 0 & !mi(gendersd) & gendersd_h > 0 & !mi(gendersd_h) & mi(gendermode)
label variable ragender "ragender:R Gender"
label values ragender genderf

*spouse
forvalues w = 1 / `maxwave' {
    gen s`w'gender =.
    spouse ragender, result(s`w'gender) wave(`w')
    label variable s`w'gender "s`w'gender:w`w' S Gender"
    label values s`w'gender genderf
}

drop `genders' `genders_h' gendern gendern_h genderfirst gendermode gendersd gendermode_h gendersd_h

***Birth year***
*spouse
forvalues w = 1 / `maxwave' {
    gen s`w'byear =.
    spouse rabyear, result(s`w'byear) wave(`w')
    label variable s`w'byear "s`w'byear:w`w' S birth year"
}

***Birth month***
forvalues w = 1 / `maxwave' {
    gen s`w'bmonth =.
    spouse rabmonth, result(s`w'bmonth) wave(`w')
    label variable s`w'bmonth "s`w'bmonth:w`w' S birth month"
}

***Birth day***
forvalues w = 1 / `maxwave' {
    gen s`w'bday =.
    spouse rabday, result(s`w'bday) wave(`w')
    label variable s`w'bday "s`w'bday:w`w' S birth day"
}

****Respondent Birth Date Flag***
*rspouse
forvalues w = 1 / `maxwave' {
    gen s`w'fbdate = .
    spouse rafbdate, result(s`w'fbdate) wave(`w')
    label variable s`w'fbdate "s`w'fbdate:w`w' S Flag birth date"
    label values s`w'fbdate fbdate
}

***Age***
forvalues w = 1 / `maxwave' {
    gen s`w'agey =.
    spouse r`w'agey, result(s`w'agey) wave(`w')
    label variable s`w'agey "s`w'agey:w`w' S age in years"
}

***Length of current marriage***
*respondent 
forvalues w = 1 / `maxwave' {
    replace r`w'mcurln = .i if r`w'mcurln >= r`w'agey & inrange(r`w'mcurln,1,120) & inrange(r`w'agey,10,120)
}

*spouse
forvalues w = 1 / `maxwave' {
    gen s`w'mcurln =.
    spouse r`w'mcurln, result(s`w'mcurln) wave(`w')
    label variable s`w'mcurln "s`w'mcurln:w`w' S length of current marriage"
}






rename ID id_w2
rename householdID hhid_w2

rename id_w1 ID
replace ID = id_w2 if ID == ""

rename hhid_w1 householdID
replace householdID = hhid_w2 if householdID == ""


*self-report of health
label define health ///
   1 "1.Excellent"  ///
   2 "2.Very good" ///
   3 "3.Good" ///
   4 "4.Fair" ///
   5 "5.Poor" ///
   .m ".m:Missing" ///
   .s ".s:Skipped" ///
   .d ".d:DK" ///
   .p ".p:Proxy" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
  
*self-report of health question position
label define health_pos ///
	1 "1.beginning of module" ///
	2 "2.end of module" ///
	.m ".m:Missing" ///
	 .s ".s:Skipped" ///
  .d ".d:DK" ///
  .r ".r:Refuse" ///
  .u ".u:Unmar" ///
  .v ".v:Sp Nr" 
 
*self-report of health alternative scale
label define health_alt ///
   1 "1.Very good"  ///
   2 "2.Good" ///
   3 "3.Fair" ///
   4 "4.Poor" ///
   5 "5.Very Poor" ///
   .m ".m:Missing" ///
   .s ".s:Skipped" ///
   .p ".p:Proxy" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
   
*self-report of health alternative scale
label define change ///  
   1 "1.Better"  ///
   3 "3.Same" ///
   5 "5.Worse" ///
   .e ".e:Error" ///
   .m ".m:Missing" ///
   .p ".p:Proxy" ///
   .s ".s:Skipped,no prv IW" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 

label define vgactx_c ///
    0 "0.no" ///
    1 "1.yes" ///
    .d ".d:DK" ///
    .r ".r:RF" ///
    .s ".s:skip"
    
label define docf                ///
	0 "0.No missing info"                   ///
	1 "1.Missing Public Clinic"            ///
	2 "2.Missing Doctor"                  ///
	3 "3.Missing Public Clinic and Dr"   ///   

*label values
label define premium   ///
	.n ".n:Covered under Medical Aid"      ///
	1 "1.Paid by R"            ///
	2 "2.Paid by S"           ///
	3 "3.Paid by Other"   
   
*Whether health limits work
label define limits ///
   0 "0.Not limited"  ///
   1 "1.Limited, but not severely" /// 
   2 "2.Severely limited" ///
   .s ".s:Skipped" ///
   .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
   
*Some difficulty with ADLs and IADLs
label define diff ///
   0 "0.No"  ///
   1 "1.Yes" ///
   .e ".e:Error" ///
   .m ".m:Missing" ///
   .w ".w:Not working" ///
   .p ".p:Proxy" ///
   .s ".s:Skipped" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" ///
   .a ".a:Age less than 50"
   
*ADL summary
label define adla_c  ///
   .s ".s:skip"

*IADL summary
label define iadla_c ///
 .m ".m:missing"
 
*IADL summary 0-5
label define iadlza_c ///
  .m ".m:oth missing"
  
*CESD raw
label define cesdraw ///
   1 "1.Very rarely (less than 1 day)"  ///
   2 "2.Sometimes (1-2 days)" ///
   3 "3.Often (3-4 days)" ///
   4 "4.Almost always (5-7 days)" ///
   .a ".a:Taking antidepressant"       ///
   .g ".g:In Vignette sample" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" ///
    .d ".d:DK" ///
   .r ".r:Refuse" ///
   .m ".m:Missing" 

****mental health****
label define cesdd ///
    1 "1.Rarely or none of the time < 1 day"  ///
    2 "2.Some or a little of the time 1-2 days"  ///
    3 "3.Occasionally or a moderate amount of 3-4 days"  ///
    4 "4.Most or all of the time 5-7 days"  ///
    .d ".d:DK"  ///
    .r ".r:RF"  ///
    .m ".m:oth missing" ///
    .p ".p:proxy"
     
*define label for CESD variables
label define cesd_label              ///
	.a ".a:Taking antidepressant"       ///
	 .u ".u:Unmar" ///
   .v ".v:Sp Nr" ///
   .m ".m:Missing" ///
	1 "1.Very rarely (<1 day)"        ///
	2 "2.Sometimes (1-2 days)"       ///
	3 "3.Often (3-4 days)"          ///
	4 "4.Almost always (5-7 days)" 

   
***Health imputation flag
label define healthimpflag ///
   1 "1.no imputation" ///
   5 "5.imputation"
   
*Physical activity
label define activity ///
   2 "2.> 1 per week"  ///
   3 "3.1 per week"  ///
   4 "4.1-3 per mon"  ///
   5 "5.hardly ever or never" ///
   .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
   
*Ever drinks
label define drinkl ///
   0 "0.None"  ///
   1 "1.Yes" ///
   .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
   
*Days per week drinks
label define drinkx ///
	0 "0.none or less than once a month" ///
	1 "1.one to several times a month" ///
	2 "2.one to several times a week" ///
	3 "3.most days of the week" ///
	4 "4.Every day of the week" ///
	.m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr"


   
   
*Whether smokes
label define smokes ///
	0 "0.No" ///
	1 "1.Yes" ///
   .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 

*cognition date naming
label define recall ///
   0 "0.incorrect" ///
   1 "1.correct" ///
   .m ".m:Missing" ///
   .n ".n:not asked(re-IW)" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
label define numer ///
   1 "1.bad" ///
   5 "5.good" ///
   .m ".m:Missing" ///
   .n ".n:not asked(re-IW)" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr"    
label define orient ///
   0 "0.bad" ///
   4 "4.good" ///
   .m ".m:Missing" ///
   .n ".n:not asked(re-IW)" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr"    

label define doctor /// 
    0 "0.no" ///
    1 "1.yes" ///
    .m ".m:oth missing" ///
    .d ".d:DK" ///
    .r ".r:RF"
    
    
*define labels for drinking
*label define drinkd_k   ////
*	0 "0.0 or doesnt drink" 
   

 
   

*set wave number
local wv=1
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2


***merge with health file***
local health_w1_health da001 da002 da003 da004 ///
                       da005_1_ da005_2_ da005_3_ da005_4_ da005_5_  ///
                       da007_1_ da007_2_ da007_3_ da007_4_ da007_5_ da007_6_ da007_7_ ///
                       da007_8_ da007_9_ da007_10_ da007_11_ da007_12_ da007_13_ da007_14_ ///
                       da008_1_ da008_5_ da008_11_ ///
                       da051_1_ da051_2_ da051_3_ da052_1_ da052_2_ da052_3_ ///
                       da059 da061 da067 da068s? da069 da072 da074 da076 ///
                       da079 da080 ///
                       dc001s? dc002 dc009 dc010 dc011 dc012 dc013 dc014 dc015 dc016 dc017 dc018 ///
                       db001 db002 db003 db004 db005 db006 db007 db008 db009 db010 ///
                       db010 db011 db012 db013 db014 db015 db016 db017 db018 db019 db020 ///
                       db032 
merge 1:1 ID using "`wave_1_health'", keepusing(`health_w1_health')
drop if _merge==2
drop _merge

***merge with biomarker file***
local health_w1_biomark ql002 qi002
merge 1:1 ID using "`wave_1_biomark'", keepusing(`health_w1_biomark') 
drop if _merge==2
drop _merge

**merge with weight file***
local health_w1_weight  imonth iyear
merge 1:1 ID using "`wave_1_weight'", keepusing(`health_w1_weight')  
drop if _merge==2
drop _merge

***merge with work file***
local health_w1_work fa001 fa002 fa003 fa005 fa007 fa008 fb010 fc013 fd030 fh004 ///
                     fl020s7
merge 1:1 ID using "`wave_1_work'", keepusing(`health_w1_work') 
drop if _merge==2
drop _merge

******self-reported health*******
*respondent
gen r`wv'shlt =.
replace r`wv'shlt = .m if da001==. & da080==. & inw1==1
replace r`wv'shlt = .d if da001==.d | da080==.d
replace r`wv'shlt = .r if da001==.r | da080==.r
replace r`wv'shlt = 1 if da001==1 | da080==1
replace r`wv'shlt = 2 if da001==2 | da080==2
replace r`wv'shlt = 3 if da001==3 | da080==3
replace r`wv'shlt = 4 if da001==4 | da080==4
replace r`wv'shlt = 5 if da001==5 | da080==5
label variable r`wv'shlt "r`wv'shlt:w`wv' r self-report of health"
label values r`wv'shlt health

*spouse self reported health
gen s`wv'shlt =.
spouse r`wv'shlt, result(s`wv'shlt) wave(`wv')
label variable s`wv'shlt "s`wv'shlt:w`wv' s self-report of health"
label values s`wv'shlt health

***timing
gen r`wv'shltf =.
replace r`wv'shltf=.m if da001==. & da080==. & inw1==1
replace r`wv'shltf =1 if inlist(da001,1,2,3,4,5,.d,.r)
replace r`wv'shltf =2 if inlist(da080,1,2,3,4,5,.d,.r) 
replace r`wv'shltf=.s if r`wv'shlt==.s
label variable r`wv'shltf "r`wv'shltf:w`wv' r timing flag of self-report health"
label values r`wv'shltf health_pos

*spouse
gen s`wv'shltf =.
spouse r`wv'shltf, result(s`wv'shltf) wave(`wv')
label variable s`wv'shltf "s`wv'shltf:w`wv' s timing flag of self-report health"
label values s`wv'shltf health_pos

******self-reported health, European scale****
*respondent
gen r`wv'shlta =.
replace r`wv'shlta = .m if da002==. & da079==. & inw1==1
replace r`wv'shlta = .d if da002==.d | da079==.d
replace r`wv'shlta = .r if da002==.r | da079==.r
replace r`wv'shlta = 1 if da002==1 | (da079==1 & mi(da002))
replace r`wv'shlta = 2 if da002==2 | (da079==2 & mi(da002))
replace r`wv'shlta = 3 if da002==3 | (da079==3 & mi(da002))
replace r`wv'shlta = 4 if da002==4 | (da079==4 & mi(da002))
replace r`wv'shlta = 5 if da002==5 | (da079==5 & mi(da002))
label variable r`wv'shlta "r`wv'shlta:w`wv' r self-report of health alt"
label values r`wv'shlta health_alt

*spouse self-report of health, European scale
gen s`wv'shlta =.
spouse r`wv'shlta, result(s`wv'shlta) wave(`wv')
label variable s`wv'shlta "s`wv'shlta:w`wv' s self-report of health alt"
label values s`wv'shlta health_alt

***timing
gen r`wv'shltaf =.
replace r`wv'shltaf =.m if mi(da079) & mi(da002) & inw1==1
replace r`wv'shltaf =1 if inlist(da002,1,2,3,4,5,.d,.r)
replace r`wv'shltaf =2 if inlist(da079,1,2,3,4,5,.d,.r) & mi(da002)
label variable r`wv'shltaf "r`wv'shltaf:w`wv' r timing flag of self-report health alt"
label values r`wv'shltaf health_pos

*spouse
gen s`wv'shltaf =.
spouse r`wv'shltaf, result(s`wv'shltaf) wave(`wv')
label variable s`wv'shltaf "s`wv'shltaf:w`wv' s timing flag of self-report health alt"
label values s`wv'shltaf health_pos

***limitation for entering other functional problems
local healthyandyoung inrange(r`wv'agey,0,50) & (inlist(da001,1,2) | inlist(da002,1,2)) & da003==2 & da004==2 & (da005_1_==. | da005_2_==. | da005_3_==.| da005_4_==. | da005_5_==.) & (da007_1_==2 & da007_2_==2 & da007_3_==2 & da007_4_==2 & da007_5_==2 & da007_6_==2 & da007_7_==2 & da007_8_==2 & da007_9_==2 & da007_10_==2 & da007_11_==2 & da007_12_==2 & da007_13_==2 & da007_14_==2) | (da008_1_==2 & da008_5_==2 & da008_11_==2)

****other functional limitation****
***Difficult in running or jogging 1km 
gen r`wv'joga =.
replace r`wv'joga =.m if db001==. & inw1==1
replace r`wv'joga =.a if db001==. & (`healthyandyoung')
replace r`wv'joga =.d if db001==.d
replace r`wv'joga =.r if db001==.r
replace r`wv'joga = 0 if db001== 1
replace r`wv'joga = 1 if inlist(db001,2,3,4)
label variable r`wv'joga "r`wv'joga:w`wv' r diff-running or jogging 1 km"
label values r`wv'joga yesno

*Spouse difficult in runing or jogging 1km
gen s`wv'joga =.
spouse r`wv'joga, result(s`wv'joga) wave(`wv')
label variable s`wv'joga "s`wv'joga:w`wv' s diff-running or jogging 1 km"
label values s`wv'joga yesno

***Difficut in walking 1km 
gen r`wv'walk1kma =.
replace r`wv'walk1kma =.m if db002==. & inw1==1
replace r`wv'walk1kma =.a if db002==. & (`healthyandyoung')
replace r`wv'walk1kma =.d if db002==.d
replace r`wv'walk1kma =.r if db002==.r
replace r`wv'walk1kma = 0 if (db002==. & db001== 1) | db002== 1
replace r`wv'walk1kma = 1 if inlist(db002,2,3,4)
label variable r`wv'walk1kma "r`wv'walk1kma:w`wv' r diff-walking 1km"
label values r`wv'walk1kma yesno

*Spouse difficult in walking 1km
gen s`wv'walk1kma =.
spouse r`wv'walk1kma, result(s`wv'walk1kma) wave(`wv')
label variable s`wv'walk1kma "s`wv'walk1kma:w`wv' s diff-walking 1km"
label values s`wv'walk1kma yesno

***Difficult walking 100m***
gen r`wv'walk100a =.
replace r`wv'walk100a =.m if db003==. & inw1==1
replace r`wv'walk100a =.a if db003==. & (`healthyandyoung')
replace r`wv'walk100a =.d if db003==.d
replace r`wv'walk100a =.r if db003==.r
replace r`wv'walk100a = 0 if (db003==. & (db001== 1 | db002==1)) | db003== 1
replace r`wv'walk100a = 1 if inlist(db003,2,3,4)
label variable r`wv'walk100a "r`wv'walk100a:w`wv' r diff-walking 100 m"
label values r`wv'walk100a yesno

*Spouse difficult in walking 100m
gen s`wv'walk100a =.
spouse r`wv'walk100a, result(s`wv'walk100a) wave(`wv')
label variable s`wv'walk100a "s`wv'walk100a:w`wv' s diff-walking 100 m"
label values s`wv'walk100a yesno

***Difficult getting up after sitting**
gen r`wv'chaira =.
replace r`wv'chaira =.m if db004==. & inw1==1
replace r`wv'chaira =.a if db004==. & (`healthyandyoung')
replace r`wv'chaira =.d if db004==.d
replace r`wv'chaira =.r if db004==.r
replace r`wv'chaira = 0 if db004== 1
replace r`wv'chaira = 1 if inlist(db004,2,3,4)
label variable r`wv'chaira "r`wv'chaira:w`wv' r diff-getting up after sitting for a long period"
label values r`wv'chaira yesno

*Spouse difficult in getting up after sitting
gen s`wv'chaira =.
spouse r`wv'chaira, result(s`wv'chaira) wave(`wv')
label variable s`wv'chaira "s`wv'chaira:w`wv' s diff-getting up after sitting for a long period"
label values s`wv'chaira yesno

***Difficult climbing***
gen r`wv'climsa =.
replace r`wv'climsa =.m if db005==. & inw1==1
replace r`wv'climsa =.a if db005==. & (`healthyandyoung')
replace r`wv'climsa =.d if db005==.d
replace r`wv'climsa =.r if db005==.r
replace r`wv'climsa = 0 if db005== 1
replace r`wv'climsa = 1 if inlist(db005,2,3,4)
label variable r`wv'climsa "r`wv'climsa:w`wv' r diff-climbing sev flt stair"
label values r`wv'climsa yesno

*Spouse difficult in getting up after sitting
gen s`wv'climsa =.
spouse r`wv'climsa, result(s`wv'climsa) wave(`wv')
label variable s`wv'climsa "s`wv'climsa:w`wv' s diff-climbing sev flt stair"
label values s`wv'climsa yesno

***no clim1a diff-clmb 1 flt str***
***Difficult in stoop/kneel/crouch
gen r`wv'stoopa =.
replace r`wv'stoopa =.m if db006==. & inw1==1
replace r`wv'stoopa =.a if db006==. & (`healthyandyoung')
replace r`wv'stoopa =.d if db006==.d
replace r`wv'stoopa =.r if db006==.r
replace r`wv'stoopa = 0 if db006== 1
replace r`wv'stoopa = 1 if inlist(db006,2,3,4)
label variable r`wv'stoopa "r`wv'stoopa:w`wv' r diff-stoop/kneel/crouch"
label values r`wv'stoopa yesno

*Spouse difficult in stoop/kneel/crouch
gen s`wv'stoopa =.
spouse r`wv'stoopa, result(s`wv'stoopa) wave(`wv')
label variable s`wv'stoopa "s`wv'stoopa:w`wv' s diff-stoop/kneel/crouch"
label values s`wv'stoopa yesno

***Difficult in lifting/carry 10 jin**
gen r`wv'lifta =.
replace r`wv'lifta =.m if db008==. & inw1==1
replace r`wv'lifta =.a if db008==. & (`healthyandyoung')
replace r`wv'lifta =.d if db008==.d
replace r`wv'lifta =.r if db008==.r
replace r`wv'lifta = 0 if db008== 1
replace r`wv'lifta = 1 if inlist(db008,2,3,4)
label variable r`wv'lifta "r`wv'lifta:w`wv' r diff-lift/carry 10 jin"
label values r`wv'lifta yesno

*Spouse difficult in lifting/carry 10 jin**
gen s`wv'lifta =.
spouse r`wv'lifta, result(s`wv'lifta) wave(`wv')
label variable s`wv'lifta "s`wv'lifta:w`wv' s diff-lift/carry 10 jin"
label values r`wv'lifta yesno

***Difficult in picking up a coin
gen r`wv'dimea =.
replace r`wv'dimea =.m if db009==. & inw1==1
replace r`wv'dimea =.a if db009==. & (`healthyandyoung')
replace r`wv'dimea =.d if db009==.d
replace r`wv'dimea =.r if db009==.r
replace r`wv'dimea = 0 if db009== 1
replace r`wv'dimea = 1 if inlist(db009,2,3,4)
label variable r`wv'dimea "r`wv'dimea:w`wv' r diff-pick up a coin"
label values r`wv'dimea yesno

*Spouse difficult in lifting/carry 10 jin**
gen s`wv'dimea =.
spouse r`wv'dimea, result(s`wv'dimea) wave(`wv')
label variable s`wv'dimea "s`wv'dimea:w`wv' s diff-pick up a coin"
label values s`wv'dimea yesno

***Difficult in reaching/extending arms up
gen r`wv'armsa =.
replace r`wv'armsa =.m if db007==. & inw1==1
replace r`wv'armsa =.a if db007==. & (`healthyandyoung')
replace r`wv'armsa =.d if db007==.d
replace r`wv'armsa =.r if db007==.r
replace r`wv'armsa = 0 if db007== 1
replace r`wv'armsa = 1 if inlist(db007,2,3,4)
label variable r`wv'armsa "r`wv'armsa:w`wv' r diff-reach/extnd arms up"
label values r`wv'armsa yesno

*Spouse difficult in reaching/extending arms up
gen s`wv'armsa =.
spouse r`wv'armsa, result(s`wv'armsa) wave(`wv')
label variable s`wv'armsa "s`wv'armsa:w`wv' s diff-reach/extnd arms up"
label values s`wv'armsa yesno


*******ADLs***************************
***no walka walking accross room***
***Difficult in dressing
gen r`wv'dressa =.
replace r`wv'dressa =.m if db010==. & inw1==1
replace r`wv'dressa =.a if (`healthyandyoung')
replace r`wv'dressa =.d if db010==.d
replace r`wv'dressa =.r if db010==.r
replace r`wv'dressa =0 if (db010==. & db001==1 & db004==1 & db005==1 & db006==1 & db007==1 & db008==1 & db009==1) | db010==1
replace r`wv'dressa =1 if inlist(db010,2,3,4)
label variable r`wv'dressa "r`wv'dressa:w`wv' r diff-dressing"
label values r`wv'dressa diff

*Spouse difficult in dressing
gen s`wv'dressa =.
spouse r`wv'dressa, result(s`wv'dressa) wave(`wv')
label variable s`wv'dressa "s`wv'dressa:w`wv' s diff-dressing"
label values s`wv'dressa diff

***difficult in taking bath or shower
gen r`wv'batha =.
replace r`wv'batha =.m if db011==. & inw1==1
replace r`wv'batha =.a if (`healthyandyoung')
replace r`wv'batha =.d if db011==.d
replace r`wv'batha =.r if db011==.r
replace r`wv'batha =0 if (db011==. & db001==1 & db004==1 & db005==1 & db006==1 & db007==1 & db008==1 & db009==1) | db011==1
replace r`wv'batha =1 if inlist(db011,2,3,4)
label variable r`wv'batha "r`wv'batha:w`wv' r diff-bathing or shower"
label values r`wv'batha diff

*Spouse difficult in taking bath or shower
gen s`wv'batha =.
spouse r`wv'batha, result(s`wv'batha) wave(`wv')
label variable s`wv'batha "s`wv'batha:w`wv' s diff-bathing or shower"
label values s`wv'batha diff

***difficult in eating
gen r`wv'eata =.
replace r`wv'eata =.m if db012==. & inw1==1
replace r`wv'eata =.a if (`healthyandyoung')
replace r`wv'eata =.d if db012==.d
replace r`wv'eata =.r if db012==.r
replace r`wv'eata =0 if (db012==. & db001==1 & db004==1 & db005==1 & db006==1 & db007==1 & db008==1 & db009==1) | db012==1
replace r`wv'eata =1 if inlist(db012,2,3,4)
label variable r`wv'eata "r`wv'eata:w`wv' r diff-eating"
label values r`wv'eata diff

*spouse difficult in eating
gen s`wv'eata =.
spouse r`wv'eata, result(s`wv'eata) wave(`wv')
label variable s`wv'eata "s`wv'eata:w`wv' s diff-eating"
label values s`wv'eata diff

***Difficult in getting in/out bed***
gen r`wv'beda =.
replace r`wv'beda =.m if db013==. & inw1==1
replace r`wv'beda =.a if (`healthyandyoung')
replace r`wv'beda =.d if db013==.d
replace r`wv'beda =.r if db013==.r
replace r`wv'beda =0 if (db013==. & db001==1 & db004==1 & db005==1 & db006==1 & db007==1 & db008==1 & db009==1) | db013==1
replace r`wv'beda =1 if inlist(db013,2,3,4)
label variable r`wv'beda "r`wv'beda:w`wv' r diff-getting in/out of bed"
label values r`wv'beda diff

*spouse difficult in getting in/out bed***
gen s`wv'beda =.
spouse r`wv'beda, result(s`wv'beda) wave(`wv')
label variable s`wv'beda "s`wv'beda:w`wv' s diff-getting in/out of bed"
label values s`wv'beda diff

***Difficult in using the toilet*** 
gen r`wv'toilta =.
replace r`wv'toilta =.m if db014==. & inw1==1
replace r`wv'toilta =.a if (`healthyandyoung')
replace r`wv'toilta =.d if db014==.d
replace r`wv'toilta =.r if db014==.r
replace r`wv'toilta =0 if (db014==. & db001==1 & db004==1 & db005==1 & db006==1 & db007==1 & db008==1 & db009==1) | db014==1
replace r`wv'toilta =1 if inlist(db014,2,3,4)
label variable r`wv'toilta "r`wv'toilta:w`wv' r diff-using the toilet"
label values r`wv'toilta diff

*spouse difficult in using the toilet***
gen s`wv'toilta =.
spouse r`wv'toilta, result(s`wv'toilta) wave(`wv')
label variable s`wv'toilta "s`wv'toilta:w`wv' s diff-using the toilet"
label values s`wv'toilta diff

**********IADLs******************
****no use map and telephone****
***Difficult in managing money
gen r`wv'moneya =.
replace r`wv'moneya =.m if db019==. & inw1==1
replace r`wv'moneya =.d if db019==.d
replace r`wv'moneya =.r if db019==.r
replace r`wv'moneya = 0 if db019 ==1
replace r`wv'moneya = 1 if inlist(db019,2,3,4)
label variable r`wv'moneya "r`wv'moneya:w`wv' r diff-managing money"
label values r`wv'moneya diff

*Souse difficult in managing money
gen s`wv'moneya =.
spouse r`wv'moneya, result(s`wv'moneya) wave(`wv')
label variable s`wv'moneya "s`wv'moneya:w`wv' s diff-managing money"
label values s`wv'moneya diff

***Difficult in taking medication
gen r`wv'medsa =.
replace r`wv'medsa =.m if db020==. & inw1==1
replace r`wv'medsa =.d if db020==.d
replace r`wv'medsa =.r if db020==.r
replace r`wv'medsa = 0 if db020 ==1
replace r`wv'medsa = 1 if inlist(db020,2,3,4)
label variable r`wv'medsa "r`wv'medsa:w`wv' r diff-taking medications"
label values r`wv'medsa diff

*Spouse difficult in taking medication
gen s`wv'medsa =.
spouse r`wv'medsa, result(s`wv'medsa) wave(`wv')
label variable s`wv'medsa "s`wv'medsa:w`wv' s diff-taking medications"
label values s`wv'medsa diff

***Difficult in shopping for groceries
gen r`wv'shopa =.
replace r`wv'shopa =.m if db018==. & inw1==1
replace r`wv'shopa =.d if db018==.d
replace r`wv'shopa =.r if db018==.r
replace r`wv'shopa = 0 if db018 ==1
replace r`wv'shopa = 1 if inlist(db018,2,3,4)
label variable r`wv'shopa "r`wv'shopa:w`wv' r diff-shopping for groceries"
label values r`wv'shopa diff

*Spouse difficult in shopping for groceries
gen s`wv'shopa =.
spouse r`wv'shopa, result(s`wv'shopa) wave(`wv')
label variable s`wv'shopa "s`wv'shopa:w`wv' s diff-shopping for groceries"
label values s`wv'shopa diff

***Difficult in preparing hot meals
gen r`wv'mealsa =.
replace r`wv'mealsa =.m if db017==. & inw1==1
replace r`wv'mealsa =.d if db017==.d
replace r`wv'mealsa =.r if db017==.r
replace r`wv'mealsa = 0 if db017==1
replace r`wv'mealsa = 1 if inlist(db017,2,3,4)
label variable r`wv'mealsa "r`wv'mealsa:w`wv' r diff-preparing hot meals"
label values r`wv'mealsa diff

*spouse difficult in preparing hot meals
gen s`wv'mealsa =.
spouse r`wv'mealsa, result(s`wv'mealsa) wave(`wv')
label variable s`wv'mealsa "s`wv'mealsa:w`wv' s diff-preparing hot meals"
label values s`wv'mealsa diff

***Difficult in cleaning house
gen r`wv'housewka =.
replace r`wv'housewka =.m if db016==. & inw1==1
replace r`wv'housewka =.d if db016==.d
replace r`wv'housewka =.r if db016==.r
replace r`wv'housewka = 0 if db016== 1
replace r`wv'housewka = 1 if inlist(db016,2,3,4)
label variable r`wv'housewka "r`wv'housewka:w`wv' r diff-cleaning house"/***only for charls***/
label values r`wv'housewka diff

*Spouse difficult in cleanig house
gen s`wv'housewka =.
spouse r`wv'housewka, result(s`wv'housewka) wave(`wv')
label variable s`wv'housewka "s`wv'housewka:w`wv' s diff-cleaning house"
label values s`wv'housewka diff

******************************************************

***Missings in ADL score
*respondent
egen r`wv'adlam_c= rowmiss(r`wv'batha r`wv'dressa r`wv'eata r`wv'beda) if inw`wv'==1
label variable r`wv'adlam_c "r`wv'adlam_c:w`wv' r missings in ADL summary"

*spouse
gen s`wv'adlam_c =.
spouse r`wv'adlam_c, result(s`wv'adlam_c) wave(`wv')
label variable s`wv'adlam_c "s`wv'adlam_c:w`wv' s missings in ADL summary" 

***ADL Score
*respondent
egen r`wv'adla_c= rowtotal(r`wv'batha r`wv'dressa r`wv'eata r`wv'beda) if inrange(r`wv'adlam_c,0,3)
replace r`wv'adla_c=.m if r`wv'batha==.m & r`wv'dressa==.m & r`wv'eata==.m & r`wv'beda==.m 
replace r`wv'adla_c=.a if r`wv'batha==.a & r`wv'dressa==.a & r`wv'eata==.a & r`wv'beda==.a
replace r`wv'adla_c=.d if r`wv'batha==.d & r`wv'dressa==.d & r`wv'eata==.d & r`wv'beda==.d
replace r`wv'adla_c=.r if r`wv'batha==.r & r`wv'dressa==.r & r`wv'eata==.r & r`wv'beda==.r
label variable r`wv'adla_c "r`wv'adla_c:w`wv' r some diff-ADLs / 0-4"

*spouse ADL summary
gen s`wv'adla_c =.
spouse r`wv'adla_c, result(s`wv'adla_c) wave(`wv')
label variable s`wv'adla_c "s`wv'adla_c:w`wv' s some diff-ADLs / 0-4"

***Missings in Wallace ADL score
*respondent
egen r`wv'adlwam= rowmiss(r`wv'batha r`wv'dressa r`wv'eata ) if inw`wv'==1
label variable r`wv'adlwam "r`wv'adlwam:w`wv' r missings in ADL Wallace Score"  

*spouse
gen s`wv'adlwam =.
spouse r`wv'adlwam, result(s`wv'adlwam) wave(`wv')
label variable s`wv'adlwam "s`wv'adlwam:w`wv' s missings in ADL Wallace Score" 

***ADL Wallace Summary 0-3**
*respondent
egen r`wv'adlwa = rowtotal(r`wv'batha r`wv'dressa r`wv'eata) if inrange(r`wv'adlwam,0,2)
replace r`wv'adlwa =.m if r`wv'batha==.m & r`wv'dressa==.m & r`wv'eata==.m 
replace r`wv'adlwa =.a if r`wv'batha==.a & r`wv'dressa==.a & r`wv'eata==.a
replace r`wv'adlwa =.d if r`wv'batha==.d & r`wv'dressa==.d & r`wv'eata==.d
replace r`wv'adlwa =.r if r`wv'batha==.r & r`wv'dressa==.r & r`wv'eata==.r
label variable r`wv'adlwa  "r`wv'adlwa :w`wv' r some diff-ADLs: Wallace / 0-3"

*spouse 
gen s`wv'adlwa  =.
spouse r`wv'adlwa , result(s`wv'adlwa) wave(`wv')
label variable s`wv'adlwa  "s`wv'adlwa :w`wv' s some diff-ADLs: Wallace / 0-3"


****CESD: Mental Health Problem***
***Feel depressed***
gen r`wv'depresl =.
replace r`wv'depresl =.m if dc011==. & inw1==1
replace r`wv'depresl =.d if dc011==.d
replace r`wv'depresl =.r if dc011==.r
replace r`wv'depresl =.p if dc011==. & db032==4
replace r`wv'depresl = dc011 if inrange(dc011,1,4)
label variable r`wv'depresl "r`wv'depresl:w`wv' cesd: felt depressed"
label values r`wv'depresl cesdd

*Spouse feel depressed
gen s`wv'depresl =.
spouse r`wv'depresl, result(s`wv'depresl) wave(`wv')
label variable s`wv'depresl "s`wv'depresl:w`wv' cesd: felt depressed"
label values s`wv'depresl cesdd

***Everything an effort***
gen r`wv'effortl =.
replace r`wv'effortl =.m if dc012==. & inw1==1
replace r`wv'effortl =.d if dc012==.d
replace r`wv'effortl =.r if dc012==.r
replace r`wv'effortl =.p if dc012==. & db032==4
replace r`wv'effortl = dc012 if inrange(dc012,1,4)
label variable r`wv'effortl "r`wv'effortl:w`wv' cesd: everything an effort"
label values r`wv'effortl cesdd

*Spouse Everything an effort***
gen s`wv'effortl =.
spouse r`wv'effortl, result(s`wv'effortl) wave(`wv')
label variable s`wv'effortl "s`wv'effortl:w`wv' cesd: everything an effort"
label values s`wv'effortl cesdd

***Sleep was restless***
gen r`wv'sleeprl =.
replace r`wv'sleeprl =.m if dc015==. & inw1==1
replace r`wv'sleeprl =.d if dc015==.d
replace r`wv'sleeprl =.r if dc015==.r
replace r`wv'sleeprl =.p if dc015==. & db032==4
replace r`wv'sleeprl = dc015 if inrange(dc015,1,4)
label variable r`wv'sleeprl "r`wv'sleeprl:w`wv' cesd: sleep was restless"
label values r`wv'sleeprl cesdd

*Spouse Sleep was restless***
gen s`wv'sleeprl =.
spouse r`wv'sleeprl, result(s`wv'sleeprl) wave(`wv')
label variable s`wv'sleeprl "s`wv'sleeprl:w`wv' cesd: sleep was restless"
label values s`wv'sleeprl cesdd

***Happy***
gen r`wv'whappyl =.
replace r`wv'whappyl =.m if dc016==. & inw1==1
replace r`wv'whappyl =.d if dc016==.d
replace r`wv'whappyl =.r if dc016==.r
replace r`wv'whappyl =.p if dc016==. & db032==4
replace r`wv'whappyl = dc016 if inrange(dc016,1,4)
label variable r`wv'whappyl "r`wv'whappyl:w`wv' cesd: was happy"
label values r`wv'whappyl cesdd

*Spouse happy***
gen s`wv'whappyl =.
spouse r`wv'whappyl, result(s`wv'whappyl) wave(`wv')
label variable s`wv'whappyl "r`wv'whappyl:w`wv' cesd: was happy"
label values s`wv'whappyl cesdd

***Felt Lonely**
gen r`wv'flonel =.
replace r`wv'flonel =.m if dc017==. & inw1==1
replace r`wv'flonel =.d if dc017==.d
replace r`wv'flonel =.r if dc017==.r
replace r`wv'flonel =.p if dc017==. & db032==4
replace r`wv'flonel = dc017 if inrange(dc017,1,4)
label variable r`wv'flonel "r`wv'flonel:w`wv' cesd: felt lonely"
label values r`wv'flonel cesdd

*Spouse feel lonely
gen s`wv'flonel =.
spouse r`wv'flonel, result(s`wv'flonel) wave(`wv')
label variable s`wv'flonel "s`wv'flonel:w`wv' cesd: felt lonely"
label values s`wv'flonel cesdd

***bothered by little things**/*charls only*/
gen r`wv'botherl =.
replace r`wv'botherl =.m if dc009==. & inw1==1
replace r`wv'botherl =.d if dc009==.d
replace r`wv'botherl =.r if dc009==.r
replace r`wv'botherl =.p if dc009==. & db032==4
replace r`wv'botherl = dc009 if inrange(dc009,1,4)
label variable r`wv'botherl "r`wv'botherl:w`wv' cesd: bothered by little things"
label values r`wv'botherl cesdd

*spouse bothered by little thing
gen s`wv'botherl =.
spouse r`wv'botherl, result(s`wv'botherl) wave(`wv')
label variable s`wv'botherl "s`wv'botherl:w`wv' cesd: bothered by little things"
label values s`wv'botherl cesdd

***Can't get going***
gen r`wv'goingl =.
replace r`wv'goingl =.m if dc018==. & inw1==1
replace r`wv'goingl =.d if dc018==.d
replace r`wv'goingl =.r if dc018==.r
replace r`wv'goingl =.p if dc018==. & db032==4
replace r`wv'goingl = dc018 if !mi(dc018)
label variable r`wv'goingl "r`wv'goingl:w`wv' cesd: could not get going"

*Spouse cant get going***
gen s`wv'goingl =.
spouse r`wv'goingl, result(s`wv'goingl) wave(`wv')
label variable s`wv'goingl "s`wv'goingl:w`wv' cesd: could not get going"

*Label value
label values r`wv'goingl cesdd
label values s`wv'goingl cesdd

***Trouble keeping mind on what is doing
gen r`wv'mindtsl =.
replace r`wv'mindtsl =.m if dc010==. & inw1==1
replace r`wv'mindtsl =.d if dc010==.d
replace r`wv'mindtsl =.r if dc010==.r
replace r`wv'mindtsl =.p if dc010==. & db032==4
replace r`wv'mindtsl = dc010 if !mi(dc010)
label variable r`wv'mindtsl "r`wv'mindtsl:w`wv' cesd: had trouble keeping mind on what is doing"
label values r`wv'mindtsl cesdd

*Spouse has trouble keeping mind on what is doing
gen s`wv'mindtsl =.
spouse r`wv'mindtsl, result(s`wv'mindtsl) wave(`wv')
label variable s`wv'mindtsl "s`wv'mindtsl:w`wv' cesd: had trouble keeping mind on what is doing"
label values s`wv'mindtsl cesdd

***Feel hopeful about the future
gen r`wv'fhopel =.
replace r`wv'fhopel =.m if dc013==. & inw1==1
replace r`wv'fhopel =.d if dc013==.d
replace r`wv'fhopel =.r if dc013==.r
replace r`wv'fhopel =.p if dc013==. & db032==4
replace r`wv'fhopel = dc013 if !mi(dc013)
label variable r`wv'fhopel "r`wv'fhopel:w`wv' cesd: feel hopeful about the future"
label values r`wv'fhopel cesdd

*Spouse feel hopeful about the future
gen s`wv'fhopel =.
spouse r`wv'fhopel, result(s`wv'fhopel) wave(`wv')
label variable s`wv'fhopel "s`wv'fhopel:w`wv' cesd: feel hopeful about the future"
label values s`wv'fhopel cesdd

***Feel fearful
gen r`wv'fearll =.
replace r`wv'fearll =.m if dc014==. & inw1==1
replace r`wv'fearll =.d if dc014==.d
replace r`wv'fearll =.r if dc014==.r
replace r`wv'fearll =.p if dc014==. & db032==4
replace r`wv'fearll = dc014 if !mi(dc014)
label variable r`wv'fearll "r`wv'fearll:w`wv' cesd: feel fearful"
label values r`wv'fearll cesdd

*Spouse feel fearful
gen s`wv'fearll =.
spouse r`wv'fearll, result(s`wv'fearll) wave(`wv')
label variable s`wv'fearll "s`wv'fearll:w`wv' cesd: feel fearful"
label values s`wv'fearll cesdd

***Missing in CESD Score
*respondent
egen r`wv'cesd10m = rowmiss(r`wv'depresl r`wv'effortl r`wv'sleeprl r`wv'whappyl r`wv'flonel r`wv'botherl r`wv'goingl r`wv'mindtsl r`wv'fhopel r`wv'fearll) if  inw`wv'==1
label variable r`wv'cesd10m "r`wv'cesd10m:w`wv' Missing in CESD Score"

*spouse
gen s`wv'cesd10m = .
spouse r`wv'cesd10m, result(s`wv'cesd10m) wave(`wv')
label variable s`wv'cesd10m "s`wv'cesd10m:w`wv' Missing in CESD Score"

*****cesd score****
***recode the reversed
recode r`wv'whappyl (1=4) (2=3) (3=2)(4=1), gen(xr`wv'whappyl)
recode r`wv'fhopel  (1=4) (2=3) (3=2)(4=1), gen(xr`wv'fhopel)	
	
*total CESD score value 
foreach var in r`wv'depresl  r`wv'effortl  r`wv'sleeprl  xr`wv'whappyl  r`wv'flonel r`wv'botherl r`wv'goingl r`wv'mindtsl xr`wv'fhopel r`wv'fearll {
	gen `var'_scale = `var' - 1
}
*respondent
egen r`wv'cesd10 = rowtotal(r`wv'depresl_scale r`wv'effortl_scale r`wv'sleeprl_scale xr`wv'whappyl_scale r`wv'flonel_scale r`wv'botherl_scale r`wv'goingl_scale r`wv'mindtsl_scale xr`wv'fhopel_scale r`wv'fearll_scale) if inrange(r`wv'cesd10m,0,9)
replace r`wv'cesd10 = .m if r`wv'depresl == .m & r`wv'effortl == .m & r`wv'sleeprl == .m & r`wv'whappyl == .m & r`wv'flonel == .m & r`wv'botherl == .m & r`wv'goingl == .m & r`wv'mindtsl == .m & r`wv'fhopel == .m & r`wv'fearll == .m
replace r`wv'cesd10 = .d if r`wv'depresl == .d & r`wv'effortl == .d & r`wv'sleeprl == .d & r`wv'whappyl == .d & r`wv'flonel == .d & r`wv'botherl == .d & r`wv'goingl == .d & r`wv'mindtsl == .d & r`wv'fhopel == .d & r`wv'fearll == .d
replace r`wv'cesd10 = .r if r`wv'depresl == .r & r`wv'effortl == .r & r`wv'sleeprl == .r & r`wv'whappyl == .r & r`wv'flonel == .r & r`wv'botherl == .r & r`wv'goingl == .r & r`wv'mindtsl == .r & r`wv'fhopel == .r & r`wv'fearll == .r
replace r`wv'cesd10 = .p if r`wv'depresl == .p & r`wv'effortl == .p & r`wv'sleeprl == .p & r`wv'whappyl == .p & r`wv'flonel == .p & r`wv'botherl == .p & r`wv'goingl == .p & r`wv'mindtsl == .p & r`wv'fhopel == .p & r`wv'fearll == .p
label variable r`wv'cesd10 "r`wv'cesd10:w`wv' CESD Score"

*Spouse
gen s`wv'cesd10 =. 
spouse r`wv'cesd10, result(s`wv'cesd10) wave(`wv')
label variable s`wv'cesd10 "s`wv'cesd10:w`wv' CESD Score"

drop r1depresl_scale r1effortl_scale r1sleeprl_scale xr1whappyl_scale r1flonel_scale r1botherl_scale r1goingl_scale r1mindtsl_scale xr1fhopel_scale r1fearll_scale
drop xr`wv'whappyl xr`wv'fhopel

****doctor diagnosed health problems****
**Ever have high blood pressure
gen r`wv'hibpe =.
replace r`wv'hibpe =.m if da007_1_==. & inw1==1
replace r`wv'hibpe =.d if da007_1_==.d
replace r`wv'hibpe =.r if da007_1_==.r
replace r`wv'hibpe = 1 if da007_1_==1
replace r`wv'hibpe = 0 if da007_1_==2
label variable r`wv'hibpe "r`wv'hibpe:w`wv' r ever had high blood pressure"
label values r`wv'hibpe doctor

**spouse ever have high blood pressure
gen s`wv'hibpe =.
spouse r`wv'hibpe, result(s`wv'hibpe) wave(`wv')
label variable s`wv'hibpe "s`wv'hibpe:w`wv' s ever had high blood pressure"
label values s`wv'hibpe doctor

***Diabetes this wave
gen r`wv'diabe =.
replace r`wv'diabe =.m if da007_3_==. & inw1==1
replace r`wv'diabe =.d if da007_3_==.d
replace r`wv'diabe =.r if da007_3_==.r
replace r`wv'diabe = 1 if da007_3_==1
replace r`wv'diabe = 0 if da007_3_==2
label variable r`wv'diabe "r`wv'diabe:w`wv' r ever had diabetes"
label values r`wv'diabe doctor

*Spouse diabetes this wave
gen s`wv'diabe =.
spouse r`wv'diabe, result(s`wv'diabe) wave(`wv')
label variable s`wv'diabe "s`wv'diabe:w`wv' s ever had diabetes"
label values s`wv'diabe doctor

***Report cancer this wave
gen r`wv'cancre =.
replace r`wv'cancre =.m if da007_4_==. & inw1==1
replace r`wv'cancre =.d if da007_4_==.d
replace r`wv'cancre =.r if da007_4_==.r
replace r`wv'cancre = 1 if da007_4_==1
replace r`wv'cancre = 0 if da007_4_==2
label variable r`wv'cancre "r`wv'cancre:w`wv' r ever had cancer"
label values r`wv'cancre doctor

*Spouse cancer this wave
gen s`wv'cancre =.
spouse r`wv'cancre, result(s`wv'cancre) wave(`wv')
label variable s`wv'cancre "s`wv'cancre:w`wv' s ever had cancer"
label values s`wv'cancre doctor

***Lung disease this wave
gen r`wv'lunge =.
replace r`wv'lunge =.m if da007_5_==. & inw1==1
replace r`wv'lunge =.d if da007_5_==.d
replace r`wv'lunge =.r if da007_5_==.r
replace r`wv'lunge = 1 if da007_5_==1
replace r`wv'lunge = 0 if da007_5_==2
label variable r`wv'lunge "r`wv'lunge:w`wv' r ever had lung disease"
label values r`wv'lunge doctor

*Spouse lung disease this wave
gen s`wv'lunge =.
spouse r`wv'lunge, result(s`wv'lunge) wave(`wv')
label variable s`wv'lunge "s`wv'lunge:w`wv' s ever had lung disease"
label values s`wv'lunge doctor

***Have heart problem this wave
gen r`wv'hearte =.
replace r`wv'hearte =.m if da007_7_==. & inw1==1
replace r`wv'hearte =.d if da007_7_==.d
replace r`wv'hearte =.r if da007_7_==.r
replace r`wv'hearte = 1 if da007_7_==1
replace r`wv'hearte = 0 if da007_7_==2
label variable r`wv'hearte "r`wv'hearte:w`wv' r ever had heart problem"
label values r`wv'hearte doctor

*Spouse heart problem
gen s`wv'hearte =.
spouse r`wv'hearte, result(s`wv'hearte) wave(`wv')
label variable s`wv'hearte "s`wv'hearte:w`wv' s ever had heart problem"
label values s`wv'hearte doctor

*Have report stroke this wave
gen r`wv'stroke =.
replace r`wv'stroke =.m if da007_8_==. & inw1==1
replace r`wv'stroke =.d if da007_8_==.d
replace r`wv'stroke =.r if da007_8_==.r
replace r`wv'stroke = 1 if da007_8_==1
replace r`wv'stroke = 0 if da007_8_==2
label variable r`wv'stroke "r`wv'stroke:w`wv' r ever had stroke"
label values r`wv'stroke doctor

*Spouse report stroke this wave
gen s`wv'stroke =.
spouse r`wv'stroke, result(s`wv'stroke) wave(`wv')
label variable s`wv'stroke "s`wv'stroke:w`wv' s ever had stroke"
label values s`wv'stroke doctor

**Report psych problem this wave
gen r`wv'psyche =.
replace r`wv'psyche =.m if da007_11_==. & inw1==1
replace r`wv'psyche =.d if da007_11_==.d
replace r`wv'psyche =.r if da007_11_==.r
replace r`wv'psyche = 1 if da007_11_==1
replace r`wv'psyche = 0 if da007_11_==2
label variable r`wv'psyche "r`wv'psyche:w`wv' r ever had psych problem"
label values r`wv'psyche doctor

*Spouse psych problem this wave
gen s`wv'psyche =.
spouse r`wv'psyche, result(s`wv'psyche) wave(`wv')
label variable s`wv'psyche "s`wv'psyche:w`wv' s ever had psych problem"
label values s`wv'psyche doctor

**Arthritis
gen r`wv'arthre =.
replace r`wv'arthre =.m if da007_13_==. & inw1==1
replace r`wv'arthre =.d if da007_13_==.d
replace r`wv'arthre =.r if da007_13_==.r
replace r`wv'arthre = 1 if da007_13_==1
replace r`wv'arthre = 0 if da007_13_==2
label variable r`wv'arthre "r`wv'arthre:w`wv' r ever had arthritis"
label values r`wv'arthre doctor

*Spouse arth problem this wave
gen s`wv'arthre =.
spouse r`wv'arthre, result(s`wv'arthre) wave(`wv')
label variable s`wv'arthre "s`wv'arthre:w`wv' s ever had arthritis"
label values s`wv'arthre doctor

**Dyslipidemia
gen r`wv'dyslipe =.
replace r`wv'dyslipe =.m if da007_2_==. & inw1==1
replace r`wv'dyslipe =.d if da007_2_==.d
replace r`wv'dyslipe =.r if da007_2_==.r
replace r`wv'dyslipe = 1 if da007_2_==1
replace r`wv'dyslipe = 0 if da007_2_==2
label variable r`wv'dyslipe "r`wv'dyslipe:w`wv' r ever had dyslipidemia"
label values r`wv'dyslipe doctor

*Spouse dyslip this wave
gen s`wv'dyslipe =.
spouse r`wv'dyslipe, result(s`wv'dyslipe) wave(`wv')
label variable s`wv'dyslipe "s`wv'dyslipe:w`wv' s ever had dyslipidemia"
label values s`wv'dyslipe doctor

**Liver Disease
gen r`wv'livere =.
replace r`wv'livere =.m if da007_6_==. & inw1==1
replace r`wv'livere =.d if da007_6_==.d
replace r`wv'livere =.r if da007_6_==.r
replace r`wv'livere = 1 if da007_6_==1
replace r`wv'livere = 0 if da007_6_==2
label variable r`wv'livere "r`wv'livere:w`wv' r ever had liver disease"
label values r`wv'livere doctor

*Spouse liver problem this wave
gen s`wv'livere =.
spouse r`wv'livere, result(s`wv'livere) wave(`wv')
label variable s`wv'livere "s`wv'livere:w`wv' s ever had liver disease"
label values s`wv'livere doctor

**Kidney disease
gen r`wv'kidneye =.
replace r`wv'kidneye =.m if da007_9_==. & inw1==1
replace r`wv'kidneye =.d if da007_9_==.d
replace r`wv'kidneye =.r if da007_9_==.r
replace r`wv'kidneye = 1 if da007_9_==1
replace r`wv'kidneye = 0 if da007_9_==2
label variable r`wv'kidneye "r`wv'kidneye:w`wv' r ever had kidney disease"
label values r`wv'kidneye doctor

*Spouse arth problem this wave
gen s`wv'kidneye =.
spouse r`wv'kidneye, result(s`wv'kidneye) wave(`wv')
label variable s`wv'kidneye "s`wv'kidneye:w`wv' s ever had kidney disease"
label values s`wv'kidneye doctor

**Stomache or other digestive disease
gen r`wv'digeste =.
replace r`wv'digeste =.m if da007_10_==. & inw1==1
replace r`wv'digeste =.d if da007_10_==.d
replace r`wv'digeste =.r if da007_10_==.r
replace r`wv'digeste = 1 if da007_10_==1
replace r`wv'digeste = 0 if da007_10_==2
label variable r`wv'digeste "r`wv'digeste:w`wv' r ever had stomach or other digestive disease"
label values r`wv'digeste doctor

*Spouse arth problem this wave
gen s`wv'digeste =.
spouse r`wv'digeste, result(s`wv'digeste) wave(`wv')
label variable s`wv'digeste "s`wv'digeste:w`wv' s ever had stomach or other digestive disease"
label values s`wv'digeste doctor

**Asthma
gen r`wv'asthmae =.
replace r`wv'asthmae =.m if da007_14_==. & inw1==1
replace r`wv'asthmae =.d if da007_14_==.d
replace r`wv'asthmae =.r if da007_14_==.r
replace r`wv'asthmae = 1 if da007_14_==1
replace r`wv'asthmae = 0 if da007_14_==2
label variable r`wv'asthmae "r`wv'asthmae:w`wv' r ever had asthma"
label values r`wv'asthmae doctor

*Spouse arth problem this wave
gen s`wv'asthmae =.
spouse r`wv'asthmae, result(s`wv'asthmae) wave(`wv')
label variable s`wv'asthmae "s`wv'asthmae:w`wv' s ever had asthma"
label values s`wv'asthmae doctor

****Memory reltaed disease
gen r`wv'memrye =.
replace r`wv'memrye =.m if da007_12_==. & inw1==1
replace r`wv'memrye =.d if da007_12_==.d
replace r`wv'memrye =.r if da007_12_==.r
replace r`wv'memrye = 1 if da007_12_==1
replace r`wv'memrye = 0 if da007_12_==2
label variable r`wv'memrye "r`wv'memrye:w`wv' r ever had memory problem"
label values r`wv'memrye doctor

*Spouse memory realted disease
gen s`wv'memrye =.
spouse r`wv'memrye, result(s`wv'memrye) wave(`wv')
label variable s`wv'memrye "s`wv'memrye:w`wv' s ever had memory problem"
label values s`wv'memrye doctor

**********bmi***********
**Height in meteres
gen r`wv'height=.
replace r`wv'height = .m if qi002==993 | (qi002==. & inw`wv'==1)
replace r`wv'height = .d if qi002==.d
replace r`wv'height = .r if qi002==.r
replace r`wv'height = .i if inrange(qi002,10,99)
replace r`wv'height = qi002 if inrange(qi002,1,2) // assumed to be reported in meters
replace r`wv'height = qi002/100 if inrange(qi002,100,200) // reported in cm
label variable r`wv'height "r`wv'height:w`wv' height in meters"

*Spouse height in meteres
gen s`wv'height =.
spouse r`wv'height, result(s`wv'height) wave(`wv')
label variable s`wv'height "s`wv'height:w`wv' height in meters"

**Weight in kilograms
gen r`wv'weight=. 
replace r`wv'weight = .m if ql002 ==. & inw1==1
replace r`wv'weight = .d if ql002 ==.d
replace r`wv'weight = .i if inrange(ql002,0,20)
replace r`wv'weight = ql002 if inrange(ql002,21,200)
label variable r`wv'weight "r`wv'weight:w`wv' weight in kilograms"

*Spouse weight in kilograms
gen s`wv'weight =.
spouse r`wv'weight, result(s`wv'weight) wave(`wv')
label variable s`wv'weight "s`wv'weight:w`wv' weight in kilograms"

**BMI**
gen r`wv'bmi=.
missing_H r`wv'weight r`wv'height, result(r`wv'bmi)
replace r`wv'bmi=.i if r`wv'weight == .i | r`wv'height == .i
replace r`wv'bmi=r`wv'weight/(r`wv'height^2) if !mi(r`wv'weight) & !mi(r`wv'height)
label variable r`wv'bmi "r`wv'bmi:w`wv' body mass index=kg/m2"

*Spouse BMI
gen s`wv'bmi =.
spouse r`wv'bmi, result(s`wv'bmi) wave(`wv')
label variable s`wv'bmi "s`wv'bmi:w`wv' body mass index=kg/m2"

*****physical activity or exercise******
*vigorous physical activity
gen r`wv'vgact_c =.
replace r`wv'vgact_c =.m if da051_1_==. & inw1==1
replace r`wv'vgact_c =.d if da051_1_==.d
replace r`wv'vgact_c =.r if da051_1_==.r
replace r`wv'vgact_c = 1 if da051_1_==1
replace r`wv'vgact_c = 0 if da051_1_==2
label variable r`wv'vgact_c "r`wv'vgact_c:w`wv' r any vigorous physical activity or exercise at least 10 minutes"
label values r`wv'vgact_c vgactx_c
/*ask only the second sampled household* but how i can tell the difference btw .m and .s?* and decide to only used .m and documented in the codebook*/

*spouse vigorous physical activity
gen s`wv'vgact_c =.
spouse r`wv'vgact_c, result(s`wv'vgact_c) wave(`wv')
label variable s`wv'vgact_c "s`wv'vgact_c:w`wv' s any vigorous physical activity or exercise at least 10 minutes"
label values s`wv'vgact_c vgactx_c

*# of days/wk vigorous physical activity
gen r`wv'vgactx_c =.
replace r`wv'vgactx_c =.m if da052_1_==. & inw1==1 
replace r`wv'vgactx_c =.d if da052_1_==.d
replace r`wv'vgactx_c =.r if da052_1_==.r
replace r`wv'vgactx_c = 0 if da051_1_==2
replace r`wv'vgactx_c = da052_1_ if inrange(da052_1_,1,7)
label variable r`wv'vgactx_c "r`wv'vgactx_c:w`wv' r # days/wk vigorous physical activity or exercise at least 10 minutes"

*spouse # of days/wk vigorous physical activity
gen s`wv'vgactx_c =.
spouse r`wv'vgactx_c, result(s`wv'vgactx_c) wave(`wv')
label variable s`wv'vgactx_c "s`wv'vgactx_c:w`wv' s # days/wk vigorous physical activity or exercise at least 10 minutes"

***moderate physical activity***
*moderate physical activity
gen r`wv'mdact_c =.
replace r`wv'mdact_c =.m if da051_2_==. & inw1==1
replace r`wv'mdact_c =.d if da051_2_==.d
replace r`wv'mdact_c =.r if da051_2_==.r
replace r`wv'mdact_c = 1 if da051_2_==1
replace r`wv'mdact_c = 0 if da051_2_==2
label variable r`wv'mdact_c "r`wv'mdact_c:w`wv' r any moderate physical activity or exercise at least 10 minutes"
label values r`wv'mdact_c vgactx_c

*spouse moderate physical activity
gen s`wv'mdact_c =.
spouse r`wv'mdact_c, result(s`wv'mdact_c) wave(`wv')
label variable s`wv'mdact_c "s`wv'mdact_c:w`wv' s any moderate physical activity or exercise at least 10 minutes"
label values s`wv'mdact_c vgactx_c

*# of days/wk moderate physical activity
gen r`wv'mdactx_c =.
replace r`wv'mdactx_c =.m if da052_2_==. & inw1==1
replace r`wv'mdactx_c =.d if da052_2_==.d
replace r`wv'mdactx_c =.r if da052_2_==.r
replace r`wv'mdactx_c = 0 if da051_2_==2
replace r`wv'mdactx_c = da052_2_ if inrange(da052_2_,1,7)
label variable r`wv'mdactx_c "r`wv'mdactx_c:w`wv' r # days/wk moderate physical activity or exercise at least 10 minutes"

*spouse # of days/wk moderate physical activity
gen s`wv'mdactx_c =.
spouse r`wv'mdactx_c, result(s`wv'mdactx_c) wave(`wv')
label variable s`wv'mdactx_c "s`wv'mdactx_c:w`wv' s # days/wk moderate physical activity or exercise at least 10 minutes"

***light physical activity***
*light physical activity
gen r`wv'ltact_c =.
replace r`wv'ltact_c =.m if da051_3_==. & inw1==1
replace r`wv'ltact_c =.d if da051_3_==.d
replace r`wv'ltact_c =.r if da051_3_==.r
replace r`wv'ltact_c = 1 if da051_3_==1
replace r`wv'ltact_c = 0 if da051_3_==2
label variable r`wv'ltact_c "r`wv'ltact_c:w`wv' r any light physical activity or exercise at least 10 minutes"
label values r`wv'ltact_c vgactx_c

*spouselight physical activity
gen s`wv'ltact_c =.
spouse r`wv'ltact_c, result(s`wv'ltact_c) wave(`wv')
label variable s`wv'ltact_c "s`wv'ltact_c:w`wv' s any light physical activity or exercise at least 10 minutes"
label values s`wv'ltact_c vgactx_c

*# of days/wk light physical activity
gen r`wv'ltactx_c =.
replace r`wv'ltactx_c =.m if da052_3_==. & inw1==1
replace r`wv'ltactx_c =.d if da052_3_==.d
replace r`wv'ltactx_c =.r if da052_3_==.r
replace r`wv'ltactx_c = 0 if da051_3_==2
replace r`wv'ltactx_c = da052_3_ if inrange(da052_3_,1,7)
label variable r`wv'ltactx_c "r`wv'ltactx_c:w`wv' r # days/wk light physical activity or exercise at least 10 minutes"

*spouse # of days/wk light physical activity
gen s`wv'ltactx_c =.
spouse r`wv'ltactx_c, result(s`wv'ltactx_c) wave(`wv')
label variable s`wv'ltactx_c "s`wv'ltactx_c:w`wv' s # days/wk light physical activity or exercise at least 10 minutes"

***Drink***
*Ever drink alcohol last year
gen r`wv'drinkl =.
replace r`wv'drinkl =.m if da067==. & inw1==1
replace r`wv'drinkl =.d if da067==.d
replace r`wv'drinkl =.r if da067==.r
replace r`wv'drinkl = 1 if inlist(da067,1,2)
replace r`wv'drinkl = 0 if da067==3
label variable r`wv'drinkl "r`wv'drinkl:w`wv' r ever drinks any alcohol last year"
label values r`wv'drinkl drinkl

*Spouse alcohol last year
gen s`wv'drinkl =.
spouse r`wv'drinkl, result(s`wv'drinkl) wave(`wv')
label variable s`wv'drinkl "s`wv'drinkl:w`wv' s ever drinks any alcohol last year"
label values s`wv'drinkl drinkl

*Ever drink alcohol before
gen r`wv'drink = .
replace r`wv'drink =.m if da069==. & inw1==1
replace r`wv'drink =.d if da069==.d
replace r`wv'drink =.r if da069==.r
replace r`wv'drink = 1 if inlist(da069,2,3) | (da069==. & inlist(da067,1,2))
replace r`wv'drink = 0 if da069==1
label variable r`wv'drink "r`wv'drink:w`wv' r ever drinks any alcohol before"
label values r`wv'drink drinkl

*Spouse ever drink alcohol before
gen s`wv'drink =.
spouse r`wv'drink, result(s`wv'drink) wave(`wv')
label variable s`wv'drink "s`wv'drink:w`wv' s ever drinks any alcohol before"
label values s`wv'drink drinkl

egen w`wv'drinkx = rowmax(da072 da074 da076)

gen r`wv'drinkx=. 
missing_c_w1 da067 da069 da072 da074 da076, result(r`wv'drinkx)
replace r`wv'drinkx = 0 if inlist(da067,2,3) | w`wv'drink==0
replace r`wv'drinkx = 1 if inlist(w`wv'drinkx,1,2)
replace r`wv'drinkx = 2 if inlist(w`wv'drinkx,3,4)
replace r`wv'drinkx = 3 if inlist(w`wv'drinkx,5)
replace r`wv'drinkx = 4 if inlist(w`wv'drinkx,6,7,8)
label variable r`wv'drinkx "r`wv'drinkx:w`wv' r frequency of drinking last year"
label values r`wv'drinkx drinkx

drop w`wv'drinkx

*spouse drink frequency
gen s`wv'drinkx =.
spouse r`wv'drinkx, result(s`wv'drinkx) wave(`wv')
label variable s`wv'drinkx "s`wv'drinkx:w`wv' s frequency of drinking last year"
label values s`wv'drinkx drinkx

****Smoke****
*Smoke Ever
gen r`wv'smokev = .
replace r`wv'smokev = .m if da059 ==. & inw1==1
replace r`wv'smokev = .d if da059 ==.d
replace r`wv'smokev = .r if da059 ==.r
replace r`wv'smokev = 0 if da059 == 2
replace r`wv'smokev = 1 if da059 == 1
label variable r`wv'smokev "r`wv'smokev:w`wv' r smoke ever"
label values r`wv'smokev smokes

*Spouse smoke ever
gen s`wv'smokev =.
spouse r`wv'smokev, result(s`wv'smokev) wave(`wv')
label variable s`wv'smokev "s`wv'smokev:w`wv' s smoke ever"
label values s`wv'smokev smokes

*Smoking now
gen r`wv'smoken = .
replace r`wv'smoken = .m if da061 ==. & inw1 == 1
replace r`wv'smoken = .d if da061 ==.d
replace r`wv'smoken = .r if da061 ==.r
replace r`wv'smoken = 0 if da061 == 2 | da059 == 2
replace r`wv'smoken = 1 if da061 == 1
label variable r`wv'smoken "r`wv'smoken:w`wv' r smoke now"
label values r`wv'smoken smokes

*Spouse smoke now
gen s`wv'smoken =.
spouse r`wv'smoken, result(s`wv'smoken) wave(`wv')
label variable s`wv'smoken "s`wv'smoken:w`wv' s smoke now"
label values s`wv'smoken smokes

*****Health limit work******
gen r`wv'hlthlm_c=.
replace r`wv'hlthlm_c=.m if fc013==. & fd030==. & fh004==. & inw1==1
replace r`wv'hlthlm_c=.d if fc013==.d | fd030==.d  | fh004==.d 
replace r`wv'hlthlm_c=.r if fc013==.r | fd030==.r  | fh004==.r
replace r`wv'hlthlm_c=.w if (inlist(fa007,1,2) | fa008==2 | (fa001==2 & (fa002==1 | fa002==2 & fa003==1 & fa005==1))) 
replace r`wv'hlthlm_c=0 if (fc013==0  | fd030==0 | fh004==0) | inlist(fb010,1,4,5,6)
replace r`wv'hlthlm_c=1 if inrange(fc013,1,365) | inrange(fd030,1,365) | inrange(fh004,1,365) | fb010==2 | fl020s7==7
label variable r`wv'hlthlm_c "r`wv'hlthlm_c:w`wv' r health problems limit work"
label values r`wv'hlthlm_c diff

*Spouse 
gen s`wv'hlthlm_c =.
spouse r`wv'hlthlm_c, result(s`wv'hlthlm_c) wave(`wv')
label variable s`wv'hlthlm_c "s`wv'hlthlm_c:w`wv' s health problems limit work"
label values s`wv'hlthlm_c diff


****drop CHARLS health raw variables***
drop `health_w1_health'

****drop CHARLS biomarker raw variables***
drop `health_w1_biomark'

****drop CHARLS work raw variables***
drop `health_w1_work'

****drop CHARLS weight ra***
drop `health_w1_weight'




*insurance

label define ins ///
    1 "1.Public Insurance Plan" ///
    0 "0.No" ///   
   .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .q ".q:Not asked" ///
   .g ".g:Covered by gov ins" ///
   .n ".n:In NHM"  ///
   .v ".v:Sp Nr" 

  label define insp ///
    1 "1.Private Insurance Plan" ///
    0 "0.No" ///   
   .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .q ".q:Not asked" ///
   .g ".g:Covered by gov ins" ///
   .n ".n:In NHM"  ///
   .v ".v:Sp Nr" 
	
label define inso ///
    1 "1.Other Insurance Plan" ///
    0 "0.No" ///   
   .m ".m:Missing" ///
   .d ".d:DK" ///
   .r ".r:Refuse" ///
   .u ".u:Unmar" ///
   .q ".q:Not asked" ///
   .g ".g:Covered by gov ins" ///
   .n ".n:In NHM"  ///
   .v ".v:Sp Nr" 

*set wave number
*set wave number
local wv=1
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2

***merge with wave 1 ins data***
local ins_w1_hc ea001s1 ea001s2 ea001s3 ea001s4 ea001s5 ea001s6 ea001s7 ea001s8 ea001s9 ea001s10 ///
                ea006_?_  ///
                ed001 ed002 ed004s1 ed005_?_ ed006_1_?_ ed007_1_?_ ed023_1 ed024_1 ///
	 							ee003 ee004 ee005 ee005_1 ee006 ee006_1 ee016 ee024_1 ee027_1 ///
                ef006
                
merge 1:1 ID using "`wave_1_healthcare'", keepusing(`ins_w1_hc') nogen




***Hospital stay last year*************
*respondent
gen r`wv'hosp1y = .
replace r`wv'hosp1y = .m if ee003 == . & inw`wv' == 1
replace r`wv'hosp1y = .p if ee003 == . & ef006 == 4
replace r`wv'hosp1y = .d if ee003 == .d
replace r`wv'hosp1y = .r if ee003 == .r
replace r`wv'hosp1y = 0  if ee003 == 2
replace r`wv'hosp1y = 1  if ee003 == 1 | inrange(ee004,1,20)
label var r`wv'hosp1y "r`wv'hosp1y:w1 R hospital stay last year"
label val r`wv'hosp1y yesno

*spouse 
gen s`wv'hosp1y = .
spouse r`wv'hosp1y, result(s`wv'hosp1y) wave(1)
label var s`wv'hosp1y  "s`wv'hosp1y:w1 S hospital stay last year"
label val s`wv'hosp1y yesno

***# hospital stay last year*************
*respondent
gen r`wv'hsptim1y = .
replace r`wv'hsptim1y = .m if ee004 == . & inw`wv' == 1
replace r`wv'hsptim1y = .p if ee004 == . & ef006==4
replace r`wv'hsptim1y = .d if ee004 == .d | r`wv'hosp1y == .d
replace r`wv'hsptim1y = .r if ee004 == .r | r`wv'hosp1y == .r
replace r`wv'hsptim1y = 0 if r`wv'hosp1y == 0
replace r`wv'hsptim1y = ee004 if inrange(ee004,0,30)
label var r`wv'hsptim1y "r`wv'hsptim1y:w1 R # hosp stays last year"

*spouse 
gen s`wv'hsptim1y = .
spouse r`wv'hsptim1y, result(s`wv'hsptim1y) wave(1)
label var s`wv'hsptim1y "s`wv'hsptim1y:w1 S # hosp stays last year"

***# hosp nights last episode*************
*respondent
gen r`wv'hspnite =.
replace r`wv'hspnite = .m if ee016 == . & inw`wv' == 1
replace r`wv'hspnite = .p if ee016 == . & ef006 == 4
replace r`wv'hspnite = .d if ee016 == .d | r`wv'hosp1y == .d
replace r`wv'hspnite = .r if ee016 == .r | r`wv'hosp1y == .r
replace r`wv'hspnite = 0 if r`wv'hosp1y == 0
replace r`wv'hspnite = ee016 if inrange(ee016,0,120)
label var r`wv'hspnite 	"r`wv'hspnite:w1 R # hosp nights last episode"

*spouse 
gen s`wv'hspnite = .
spouse r`wv'hspnite, result(s`wv'hspnite) wave(1)
label var s`wv'hspnite "s`wv'hspnite:w1 S # hosp nights last episode"


***Doctor visit/outpatient last month*********
*respondent
gen r`wv'doctor1m = .
replace r`wv'doctor1m = .m if inw`wv'== 1
replace r`wv'doctor1m = .p if ed001 == . & ef006 == 4
replace r`wv'doctor1m = .d if ed001 == .d
replace r`wv'doctor1m = .r if ed001 == .r
replace r`wv'doctor1m = 1 if ed001 == 1
replace r`wv'doctor1m = 0 if ed001 == 2
label var r`wv'doctor1m   "r`wv'doctor1m:w1 R doctor visit/outpatient last month"
label val r`wv'doctor1m yesno

*spouse 
gen s`wv'doctor1m = .
spouse r`wv'doctor1m, result(s`wv'doctor1m) wave(1) 
label var s`wv'doctor1m  "s`wv'doctor1m:w1 S doctor visit/outpatient last month"
label val s`wv'doctor1m yesno

***# doctor visit/outpatient last month*********
egen doctim=rowtotal(ed005_1_ ed005_2_ ed005_3_ ed005_4_ ed005_5_ ed005_6_ ed005_7_),m

*respondent
gen r`wv'doctim1m = .  
replace r`wv'doctim1m = .m if doctim==. & inw`wv'== 1
replace r`wv'doctim1m = .d if r`wv'doctor1m==.d | ed004s1 == .d | ed005_1_==.d | ed005_2_==.d | ed005_3_==.d |ed005_4_==.d |ed005_5_==.d | ed005_6_==.d | ed005_7_==.d
replace r`wv'doctim1m = .r if r`wv'doctor1m==.r | ed004s1 == .d | ed005_1_==.r | ed005_2_==.r | ed005_3_==.r |ed005_4_==.r |ed005_5_==.r | ed005_6_==.r | ed005_7_==.r
replace r`wv'doctim1m = 0  if ed001 == 2
replace r`wv'doctim1m=doctim if inrange(doctim,0,30)
label var r`wv'doctim1m   "r`wv'doctim1m:w1 R # doctor visit/outpatient last month"

*spouse 
gen s`wv'doctim1m = .
spouse r`wv'doctim1m, result(s`wv'doctim) wave(1) 
label var s`wv'doctim1m  "s`wv'doctim1m:w1 S # doctor visit/outpatient last month"

drop doctim


***medical expenditures: out of pocket and total***************

****Inpatient expenditure****
*****total cost****
gen r`wv'tothos1y = .
replace r`wv'tothos1y = .m if inw`wv'==1
replace r`wv'tothos1y = .d if ee005_1 == .d | ee024_1 == .d | r`wv'hsptim1y==.d
replace r`wv'tothos1y = .r if ee005_1 == .r | ee024_1 == .r | r`wv'hsptim1y==.r
replace r`wv'tothos1y = 0 if r`wv'hsptim1y == 0 | ee005==2
replace r`wv'tothos1y = ee024_1 if inrange(ee024_1,0,200000) & r`wv'hsptim1y==1
replace r`wv'tothos1y = ee005_1 if inrange(ee005_1,0,8000000)& inrange(r`wv'hsptim1y,2,40)
label var r`wv'tothos1y "r`wv'tothos1y:w`wv' R hospitalization total expenditure last year"

***spouse 
gen s`wv'tothos1y = .
spouse r`wv'tothos1y, result(s`wv'tothos1y) wave(1)
label var s`wv'tothos1y "s`wv'tothos1y:w`wv' S hospitalization total expenditure last year"

****OOP******
gen r`wv'oophos1y=.  
replace r`wv'oophos1y= .m if  inw`wv'==1
replace r`wv'oophos1y =.d if ee006_1 == .d | ee027_1 == .d | r`wv'hsptim1y==.d
replace r`wv'oophos1y =.r if ee006_1 == .r | ee027_1 == .r | r`wv'hsptim1y==.r
replace r`wv'oophos1y = 0 if r`wv'hsptim1y == 0 | ee004 == 0 | (ee004 == 1 & ee027 == 2) 
replace r`wv'oophos1y = ee006_1 if inrange(ee006_1,0,8000000) & inrange(ee004,2,30) & ee006==1 
replace r`wv'oophos1y = ee027_1 if inrange(ee027_1,0,8000000) & ee004 == 1 & ee027==1 
label var r`wv'oophos1y "r`wv'oophos1y:w`wv' R hospitalization out-of-pocket expenditure last year"

gen s`wv'oophos1y = .
spouse r`wv'oophos1y, result(s`wv'oophos1y) wave(1)
label var s`wv'oophos1y "s`wv'oophos1y:w`wv' S hospitalization out-of-pocket expenditure last year"

	


/***Outpatient expenditure***/
***total cost****
egen sum_oop = rowtotal(ed006_1_1_ ed006_1_2_  ed006_1_3_  ed006_1_4_ ed006_1_5_ ed006_1_6_ ed006_1_7_  ed006_1_8_ ed006_1_9_),m

gen r`wv'totdoc1m= .
replace r`wv'totdoc1m= .m if inw`wv'==1
replace r`wv'totdoc1m =.m if r`wv'doctor1m==.m | ed006_1_1_==.e | ed006_1_2_==.e | ed006_1_3_==.e | ed006_1_4_==.e | ed006_1_5_==.e | ed006_1_6_==.e | ed006_1_7_==.e | ed006_1_8_==.e | ed006_1_9_==.e
replace r`wv'totdoc1m =.d if r`wv'doctor1m==.d | ed006_1_1_==.d | ed006_1_2_==.d | ed006_1_3_==.d | ed006_1_4_==.d | ed006_1_5_==.d | ed006_1_6_==.d | ed006_1_7_==.d | ed006_1_8_==.d | ed006_1_9_==.d
replace r`wv'totdoc1m =.r if r`wv'doctor1m==.r | ed006_1_1_==.r | ed006_1_2_==.r | ed006_1_3_==.r | ed006_1_4_==.r | ed006_1_5_==.r | ed006_1_6_==.r | ed006_1_7_==.r | ed006_1_8_==.r | ed006_1_9_==.r
replace r`wv'totdoc1m = 0 if r`wv'doctim1m == 0 
replace r`wv'totdoc1m = ed023_1 if inrange(ed023_1,0,999999) & r`wv'doctim1m == 1
replace r`wv'totdoc1m = sum_oop if inrange(r`wv'doctim1m,2,40) & inrange(sum_oop,0,300000)
label var r`wv'totdoc1m "r`wv'totdoc1m:w`wv' R doctor visit total expenditure last month"

drop sum_oop

***spouse 
gen s`wv'totdoc1m = .
spouse r`wv'totdoc1m, result(s`wv'totdoc1m) wave(1)
label var s`wv'totdoc1m "s`wv'totdoc1m:w`wv' S doctor visit total expenditure last month"

***out of pocket*****
egen sum_oop= rowtotal(ed007_1_1_ ed007_1_2_  ed007_1_3_  ed007_1_4_ ed007_1_5_ ed007_1_6_ ed007_1_7_  ed007_1_8_ ed007_1_9_),m

gen r`wv'oopdoc1m= .
replace r`wv'oopdoc1m= .m if inw`wv'==1
replace r`wv'oopdoc1m =.m if r`wv'doctor1m==.m | ed007_1_1_==.e | ed007_1_2_==.e | ed007_1_3_==.e | ed007_1_4_==.e | ed007_1_5_==.e | ed007_1_6_==.e | ed007_1_7_==.e | ed007_1_8_==.e | ed007_1_9_==.e
replace r`wv'oopdoc1m =.d if r`wv'doctor1m==.d | ed007_1_1_==.d | ed007_1_2_==.d | ed007_1_3_==.d | ed007_1_4_==.d | ed007_1_5_==.d | ed007_1_6_==.d | ed007_1_7_==.d | ed007_1_8_==.d | ed007_1_9_==.d
replace r`wv'oopdoc1m =.r if r`wv'doctor1m==.r | ed007_1_1_==.r | ed007_1_2_==.r | ed007_1_3_==.r | ed007_1_4_==.r | ed007_1_5_==.r | ed007_1_6_==.r | ed007_1_7_==.r | ed007_1_8_==.r | ed007_1_9_==.r
replace r`wv'oopdoc1m = 0 if r`wv'doctim1m == 0
replace r`wv'oopdoc1m = ed024_1 if inrange(ed024_1,0,999999) & r`wv'doctim1m==1
replace r`wv'oopdoc1m = sum_oop if inrange(sum_oop,0,300000) & inrange(r`wv'doctim1m,2,40)
label var r`wv'oopdoc1m "r`wv'oopdoc1m:w`wv' R doctor visit out-of-pocket expenditure last month"

drop sum_oop

***spouse 
gen s`wv'oopdoc1m = .
spouse r`wv'oopdoc1m, result(s`wv'oopdoc1m) wave(1)
label var s`wv'oopdoc1m "s`wv'oopdoc1m:w`wv' S doctor visit out-of-pocket expenditure last month"


****************************************************************************************
***cover by government Health insurance program ***
*wave 1 respondent cover by public Health insurance program
gen r`wv'higov=.
missing_c_w1 ea001s1 ea001s2 ea001s3 ea001s4 ea001s5 ea001s6 ea001s7 ea001s8 ea001s9 ea001s10, result(r`wv'higov)
replace r`wv'higov=0 if  ea001s10==10 |ea001s7==7 | ea001s8==8 |ea001s9==9
replace r`wv'higov=1 if  ea001s1==1 | ea001s2==2 | ea001s3==3 | ea001s4==4 | ea001s5==5 | ea001s6==6 
label variable r`wv'higov "r`wv'higov:w1 r cover by public health insurance"
label values r`wv'higov ins

*wave 1 spouse cover by government health insurance program
gen s`wv'higov=.
spouse r`wv'higov, result(s`wv'higov) wave(1)
label variable s`wv'higov "s`wv'higov:w1 s cover by public health insurance"
label values s`wv'higov ins


***cover by private Health insurance program ***
*wave 1 respondent cover by private health insurance program
gen r`wv'hipriv=.
replace r`wv'hipriv=.m if inw`wv'==1
replace r`wv'hipriv=.d if ea001s7==.d | ea001s8==.d
replace r`wv'hipriv=.r if ea001s7==.r | ea001s8==.r
replace r`wv'hipriv=0 if ea001s10==10 | ea001s1==1 | ea001s2==2 | ea001s3==3 | ea001s4==4 | ea001s5==5 | ea001s6==6 
replace r`wv'hipriv=1 if ea001s7==7 | ea001s8==8

label variable r`wv'hipriv "r`wv'hipriv:w1 R cover by Private Health Ins"
label values r`wv'hipriv insp

*wave 1 spouse cover by private health insurance program
gen s`wv'hipriv=.
spouse r`wv'hipriv, result(s`wv'hipriv) wave(1)
label variable s`wv'hipriv "s`wv'hipriv:w1 S cover by Private Health Ins"
label values s`wv'hipriv insp

***cover by other Health insurance program ***
*wave 1 respondent cover by other health insurance program
gen r`wv'hiothp=.
replace r`wv'hiothp=.m if inw`wv'==1
replace r`wv'hiothp=.d if ea001s9==.d 
replace r`wv'hiothp=.r if ea001s9==.r
replace r`wv'hiothp=0 if ea001s10==10 | ea001s1==1 | ea001s2==2 | ea001s3==3 | ea001s4==4 | ea001s5==5 | ea001s6==6 |ea001s7==7 | ea001s8==8
replace r`wv'hiothp=1 if ea001s9==9
label variable r`wv'hiothp "r`wv'hiothp:w1 r cover by other health ins"
label values r`wv'hiothp inso

*wave 1 spouse cover by other health insurance program
gen s`wv'hiothp=.
spouse r`wv'hiothp, result(s`wv'hiothp) wave(1)
label variable s`wv'hiothp "s`wv'hiothp:w1 s cover by other health ins"
label values s`wv'hiothp inso


***drop wave 1 file raw variables
drop `ins_w1_hc'


	

***cognition month naming***
label define monthnaming ///
   0 "0.no"  ///
   1 "1.yes" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .d ".d:DK" ///
	 .p ".p:Proxy" ///
	 .u ".u:Unmar" ///
	 .e ".e:Error"
	 
***cognition day naming***
label define daynaming ///
   0 "0.no"  ///
   1 "1.yes" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .d ".d:DK" ///
	 .p ".p:Proxy" ///
	 .u ".u:Unmar" ///
	 .e ".e:Error"
	  
***cognition year naming***
label define yeaernaming ///
   0 "0.no"  ///
   1 "1.yes" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .d ".d:DK" ///
   .p ".p:Proxy" ///
	 .u ".u:Unmar" ///
	 .e ".e:Error"
   
***cognition day of week naming***
label define daywnaming ///
   0 "0.no"  ///
   1 "1.yes" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .d ".d:DK" ///
	 .p ".p:Proxy" ///
	 .u ".u:Unmar" ///
	 .e ".e:Error"
	 
	 
***Self-reported memory***
label define memory ///
   1 "1.Excellent"  ///
   2 "2.Very Good" ///
   3 "3.Good" ///
   4 "4.Fair" ///
   5 "5.Poor" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .d ".d:DK" ///
	 .p ".p:Proxy" ///
	 .u ".u:Unmar" ///
	 .e ".e:Error"
	 

	 	 



*set wave number
local wv=1
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2

***merge with health file***
local cog_w1_health dc001s1 dc001s2 dc001s3 ///
                    dc002 dc004 ///
                    dc006s1 dc006s2 dc006s3 dc006s4 dc006s5 dc006s6 dc006s7 dc006s8 dc006s9 dc006s10 dc006s11 ///
                    dc019 dc020 dc021 dc022 dc023 dc025 ///
                    dc027s1 dc027s2 dc027s3 dc027s4 dc027s5 dc027s6 dc027s7 dc027s8 dc027s9 dc027s10 dc027s11 ///
                    db032
merge 1:1 ID using "`wave_1_health'", keepusing(`cog_w1_health') 
drop if _merge==2
drop _merge




***Self-reported memory***
*wave 1 respondent self-reported memory
gen r`wv'slfmem = .
replace r`wv'slfmem = .m if dc004==.
replace r`wv'slfmem = .p if dc004==. & db032 == 4
replace r`wv'slfmem = .d if dc004==.d
replace r`wv'slfmem = .r if dc004==.r
replace r`wv'slfmem = 1 if dc004==1
replace r`wv'slfmem = 2 if dc004==2
replace r`wv'slfmem = 3 if dc004==3
replace r`wv'slfmem = 4 if dc004==4
replace r`wv'slfmem = 5 if dc004==5
label variable r`wv'slfmem "r`wv'slfmem:w`wv' R Self-reported memory"
label values r`wv'slfmem memory

**wave 1 spouse Self-reported memory***
gen  s`wv'slfmem =.
spouse r`wv'slfmem, result(s`wv'slfmem) wave(1)
label variable  s`wv'slfmem "s`wv'slfmem:w`wv' S Self-reported memory"
label values s`wv'slfmem memory

***Recode Word listing scores***
forvalues i = 2 / 10 {
    recode dc006s`i' (`i'=1), gen(dc006s`i'_)
    recode dc027s`i' (`i'=1), gen(dc027s`i'_)
}
recode dc006s11 (11=0), gen(dc006s11_)
recode dc027s11 (11=0), gen(dc027s11_)

***immediate word recall***
*wave 1 respondent immediate word recall
egen r`wv'imrc =rowtotal(dc006s1 dc006s2_ dc006s3_ dc006s4_ dc006s5_ dc006s6_ dc006s7_ dc006s8_ dc006s9_ dc006s10_ dc006s11_),m
replace r`wv'imrc= .m if mi(r`wv'imrc) & inw`wv' == 1
replace r`wv'imrc= .d if dc006s1==.d
replace r`wv'imrc= .r if dc006s1==.r
replace r`wv'imrc= .p if dc006s1==. & db032 == 4
label variable r`wv'imrc "r1imrc:w1 R immediate word recall"

drop dc006s*_

*wave 1 spouse immediate word recall
gen s`wv'imrc =.
spouse r`wv'imrc, result(s`wv'imrc) wave(1)
label variable s`wv'imrc "s1imrc:w1 S immediate word recall"

**delayed word recall***
*wave 1 respondent delayed word recall
egen r`wv'dlrc =rowtotal(dc027s1 dc027s2_ dc027s3_ dc027s4_ dc027s5_ dc027s6_ dc027s7_ dc027s8_ dc027s9_ dc027s10_ dc027s11_),m
replace r`wv'dlrc= .m if mi(r`wv'dlrc) & inw`wv' == 1
replace r`wv'dlrc= .d if dc027s1==.d
replace r`wv'dlrc= .r if dc027s1==.r
replace r`wv'dlrc= .p if dc027s1==.& db032 == 4
label variable r`wv'dlrc "r1dlrc:w1 R delayed word recall"

drop dc027s*_

*wave 1 spouse delayed word recall
gen s`wv'dlrc =.
spouse r`wv'dlrc, result(s`wv'dlrc) wave(1)
label variable s`wv'dlrc "s1dlrc:w1 S delayed word recall"


***cognition month naming***
*wave 1 respondent cognition month naming
gen r`wv'mo= .
replace r`wv'mo = .m if dc001s2==. & inw`wv' == 1
replace r`wv'mo = .p if dc001s2==. & db032 == 4
replace r`wv'mo = .d if dc001s2==.d
replace r`wv'mo = .r if dc001s2==.r
replace r`wv'mo = 0 if dc001s2==.e
replace r`wv'mo = 1 if dc001s2==2 
label variable r`wv'mo "r1mo:w1 R cognition date naming-month"
label values r`wv'mo monthnaming

*wave 1 spouse month naming
gen s`wv'mo =.
spouse r`wv'mo, result(s`wv'mo) wave(1)
label variable s`wv'mo "s1mo:w1 S cognition date naming-month"
label values s`wv'mo monthnaming

***cognition day naming***
*wave 1 respondent cognition day naming
gen r`wv'dy= .
replace r`wv'dy = .m if dc001s3==. & inw`wv' == 1
replace r`wv'dy = .p if dc001s3==. & db032 == 4
replace r`wv'dy = .d if dc001s3==.d
replace r`wv'dy = .r if dc001s3==.r
replace r`wv'dy = 0 if dc001s3==.e
replace r`wv'dy = 1 if dc001s3==3 

label variable r`wv'dy "r1dy:w1 R cognition date naming-day of month"
label values r`wv'dy daynaming

*wave 1 spouse day naming
gen s`wv'dy =.
spouse r`wv'dy, result(s`wv'dy) wave(1)
label variable s`wv'dy "s1dy:w1 S cognition date naming-day of month"
label values s`wv'dy daynaming

***cognition year naming***
*wave 1 respondent cognition year naming
gen r`wv'yr= .
replace r`wv'yr = .m if dc001s1==. & inw`wv' == 1
replace r`wv'yr = .p if dc001s1==. & db032 == 4
replace r`wv'yr = .d if dc001s1==.d
replace r`wv'yr = .r if dc001s1==.r
replace r`wv'yr = 1 if dc001s1==1 
replace r`wv'yr = 0 if dc001s1==.e
label variable r`wv'yr "r1yr:w1 R cognition date naming-year"
label values r`wv'yr yeaernaming

*wave 1 spouse year naming
gen s`wv'yr =.
spouse r`wv'yr, result(s`wv'yr) wave(1)
label variable s`wv'yr "s1yr:w1 S cognition date naming-year"
label values s`wv'yr yeaernaming

***cognition day of week naming***
*wave 1 respondent cognition day of week naming
gen r`wv'dw= .
replace r`wv'dw = .m if dc002==. & inw`wv' == 1
replace r`wv'dw = .p if dc002==. & db032 == 4
replace r`wv'dw = .d if dc002==.d
replace r`wv'dw = .r if dc002==.r
replace r`wv'dw = 1 if dc002==1 
replace r`wv'dw = 0 if dc002==2
label variable r`wv'dw "r1dw:w1 R cognition date naming-day of week"
label values r`wv'dw daywnaming

*wave 1 spouse day of week naming
gen s`wv'dw =.
spouse r`wv'dw, result(s`wv'dw) wave(1)
label variable s`wv'dw "s1dw:w1 S cognition date naming-day of week"
label values s`wv'dw daywnaming

****cognition orient***
**wave 1 respondent cognition orient
egen r`wv'orient = rowtotal(r`wv'mo r`wv'dy r`wv'yr r`wv'dw),m
replace r`wv'orient= .m if (r`wv'mo== .m | r`wv'dy== .m | r`wv'yr== .m | r`wv'dw== .m) & mi(r`wv'orient)
replace r`wv'orient= .d if (r`wv'mo== .d | r`wv'dy== .d | r`wv'yr== .d | r`wv'dw== .d) & mi(r`wv'orient)
replace r`wv'orient= .r if (r`wv'mo== .r | r`wv'dy== .r | r`wv'yr== .r | r`wv'dw== .r) & mi(r`wv'orient)
replace r`wv'orient= .p if (r`wv'mo== .p | r`wv'dy== .p | r`wv'yr== .p | r`wv'dw== .p) & mi(r`wv'orient)
label variable r`wv'orient "r1orient:w1 R cognition orient (summary date naming)"

**wave 1 spouse cognition orient
gen  s`wv'orient =.
spouse r`wv'orient, result(s`wv'orient) wave(1)
label variable  s`wv'orient "s1orient:w1 S cognition orient (summary date naming)"

***recall summary  score***
*wave 1 respondent recall summary  score
gen r`wv'tr20 = .
missing_H r`wv'imrc r`wv'dlrc, result(r`wv'tr20)
replace r`wv'tr20 = .p if r`wv'imrc== .p | r`wv'dlrc== .p
replace r`wv'tr20 = r`wv'imrc + r`wv'dlrc if !mi(r`wv'imrc) & !mi(r`wv'dlrc)
label variable r`wv'tr20 "r1tr20:w1 R recall summary  score"

*wave 1 spouse recall summary  score
gen s`wv'tr20 =.
spouse r`wv'tr20, result(s`wv'tr20) wave(1)
label variable s`wv'tr20 "s1tr20:w1 S recall summary  score"

***serial 7s***
*wave 1 respondent serial 7s
gen r`wv'ser7=.
replace r`wv'ser7= .m if inw`wv' == 1
replace r`wv'ser7= .p if (dc019 ==. | dc020==. | dc021==. | dc022==.  | dc023==.) & db032 == 4
replace r`wv'ser7= .d if dc019 ==.d | dc020==.d | dc021==.d | dc022==.d | dc023==.d
replace r`wv'ser7= .r if dc019 ==.r | dc020==.r | dc021==.r | dc022==.r  | dc023==.r
replace r`wv'ser7= 0 if inrange(dc019,0,1300)
replace r`wv'ser7= r`wv'ser7+1 if dc019==93 & !mi(r`wv'ser7)
replace r`wv'ser7= r`wv'ser7+1 if dc020==86 & !mi(r`wv'ser7)
replace r`wv'ser7= r`wv'ser7+1 if dc021==79 & !mi(r`wv'ser7)
replace r`wv'ser7= r`wv'ser7+1 if dc022==72 & !mi(r`wv'ser7)
replace r`wv'ser7= r`wv'ser7+1 if dc023==65 & !mi(r`wv'ser7)
label variable r`wv'ser7  "r`wv'ser7:w`wv' R serial 7s"

*wave 1 spouse serial 7s
gen s`wv'ser7 =.
spouse r`wv'ser7, result(s`wv'ser7) wave(`wv')
label variable s`wv'ser7 "s`wv'ser7:w`wv' S serial 7s"

***Drawing picture***
*wave 1 respondent able to draw a picture
gen r`wv'draw= .
replace r`wv'draw = .m if dc025==. & inw`wv' == 1
replace r`wv'draw = .p if dc025==. & db032 == 4
replace r`wv'draw = .d if dc025==.d
replace r`wv'draw = .r if dc025==.r
replace r`wv'draw = 1 if dc025==1 
replace r`wv'draw = 0 if dc025==2
label variable r`wv'draw "r1draw:w1 R cognition able to draw assign picture"
label values r`wv'draw daywnaming

*wave 1 spouse able to draw a picture
gen s`wv'draw =.
spouse r`wv'draw, result(s`wv'draw) wave(1)
label variable s`wv'draw "s1draw:w1 S cognition able to draw assign picture"
label values s`wv'draw daywnaming


****drop CHARLS health raw variables***
drop `cog_w1_health'


***Owning a house***
label define own ///
   0 "0.no"  ///
   1 "1.yes" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .d ".d:DK" ///
	 .s ".s:Skipped" ///
	 .p ".p:Proxy" ///
	 .u ".u:Unmar" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 
	 
label define arlfg ///
   1 "1.from wave 1"  ///
   2 "2.from wave 2" ///
   3 "3.mixed from wave 1 and 2" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
   .u ".u:Unmar" ///
   .v ".v:Sp Nr" 


label define hous_ownflag ///
	 0 "0.does not own residence" ///
	 1 "1.single household, sole ownership"       ///
	 2 "2.single household, part ownership"   ///
	 3 "3.couple, sole ownership by one member"    ///
	 4 "4.couple, part ownership by both"     ///
	 5 "5.couple, more owners than hh members"    ///
	 6 "6.couple, both claim sole ownership" ///
	 7 "7.couple, other disputed ownership"
	 	 
label define areaimput ///
    0 "0.not imputed" ///
    1 "1.imputed using total land area" ///
    2 "2.imputed using community average" 
    


*set wave number
local wv=1
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2

***merge with demog file***
local asset_w1_demog be001 
merge 1:1 ID using "`wave_1_demog'", keepusing(`asset_w1_demog') nogen

***merge with individual income file***
local asset_w1_indinc hc001 hc003_1 hc003_2 hc004 hc005 hc007 hc008 ///
                      hc010 hc013 hc015 hc018 ///
                      hc021 hc022 hc027 hc028 ///
                      hc030 hc031 hc033 hc034 ///
                      hd001 hd003
merge 1:1 ID using "`wave_1_indinc'", keepusing(`asset_w1_indinc') 
drop if _merge==2
drop _merge

***merge with household income file***
local asset_w1_hhinc gb001 gb007 gb008 ///
                     ha007 ha009_?_ ha009_1?_ ///
                     ha011_1 ha011_2 ha013 ha014 ///
                     ha027 ha028 ha030_?_ ///
                     ha031_?_s? ha031_?_s1? ///
                     ha034_1_1_ ha034_1_2_ ha034_1_3_ ha034_2_1_ ha034_2_2_ ha034_2_3_ ///
                     ha036_1_ ha036_2_ ha036_3_ ///
                     ha037_1_ ha037_2_ ///
                     ha038_1_ ha038_2_ ///
                     ha051_1_ ha051_2_ ha051_3_ ///
                     ha054s? ha055_?_ ha057_?_  ///
                     ha065_1_?_ ha065_1_1?_ ha065s? ha065s1? ///
                     ha066s? ha066_1_?_  ///
                     ha067 ha068 ha068_1 ha069 ///
                     ha070 ha072 ha074_?_ ha074_1?_ ha075_?_ ha075_1?_ ///
                     proxy
merge m:1 householdID using "`wave_1_hhinc'", keepusing(`asset_w1_hhinc') 
drop if _merge==2
drop _merge

***merge with household roster file***
local asset_w1_hhroster a002_?_ a002_1?_ /// 
                      a006_?_ a006_1?_ 
merge m:1 householdID using "`wave_1_hhroster'", keepusing(`asset_w1_hhroster') 
drop if _merge==2
drop _merge

***merge with household characteristics file***
local asset_w1_house i001 i002
merge m:1 householdID using "`wave_1_house'", keepusing(`asset_w1_house') 
drop if _merge==2
drop _merge

****merge with psu data file*****
local asset_w1_psu urban_nbs
merge m:1 communityID using "`wave_1_psu'", keepusing (`asset_w1_psu') 
drop if _merge==2
drop _merge



*****************************************
*************E:  ASSETS******************
*****************************************
***Create inflation multiplier variables
*gen c2005cpindex =  86.6 // 2005
*gen c2006cpindex =  87.8 // 2006
*gen c2007cpindex =  92.0 // 2007
*gen c2008cpindex =  97.5 // 2008
gen c2009cpindex =  96.8 // 2009
gen c2010cpindex = 100.0 // 2010
gen c2011cpindex = 105.5 // 2011
gen c2012cpindex = 108.2 // 2012
*gen c2011ppp = 3.696

*label variable c2005cpindex "2005 consumer price index, 2010=100"
*label variable c2006cpindex "2006 consumer price index, 2010=100"
*label variable c2007cpindex "2007 consumer price index, 2010=100"
*label variable c2008cpindex "2008 consumer price index, 2010=100" 
label variable c2009cpindex "2009 consumer price index, 2010=100"
label variable c2010cpindex "2010 consumer price index, 2010=100"
label variable c2011cpindex "2011 consumer price index, 2010=100"
label variable c2012cpindex "2012 consumer price index, 2010=100"
*label variable c2011ppp "2011 Purchasing power parity"


** ===================================================
* ***                                               **
* ***      Individual Assets (r&s)                **
* ***                                               **
** =================================================**


********************************************************************
**********1. Value of cash and other deposit financial institution**
********************************************************************

*****1.1 Cash at home****
*respondent
gen r`wv'acash=.
missing_c_w1 be001 hc001 hc003_1 hc003_2, result(r`wv'acash)
replace r`wv'acash = hc001 if inrange(hc001,0,9999999) & inlist(be001,3,4,5,6)
replace r`wv'acash = 0 if hc001==0 & inlist(be001,1,2)
replace r`wv'acash = hc001*.5 if inrange(hc001,.01,50000000) & inlist(be001,1,2)
replace r`wv'acash = hc003_1 if inrange(hc003_1,0,99999999) & inlist(be001,1,2)
replace r`wv'acash = hc001*(hc003_2/100) if inrange(hc001,.01,50000000) & inrange(hc003_2,0,100) & inlist(be001,1,2)
label variable r`wv'acash "r`wv'acash:w`wv' Asset: cash"

*spouse
gen s`wv'acash=.
spouse r`wv'acash,result(s`wv'acash) wave(`wv')
label variable s`wv'acash "s`wv'acash:w`wv' Asset: cash"

***1.2 deposits **
***Individual level respondent
*respondent
gen r`wv'aodepo=.
missing_c_w1 hc004, result(r`wv'aodepo)
replace r`wv'aodepo= 0 if hc004==2
replace r`wv'aodepo= 1 if hc004==1
label variable r`wv'aodepo "r`wv'aodepo:w`wv' Asset: holding deposit account"

*Spouse
gen s`wv'aodepo =.
spouse r`wv'aodepo,result(s`wv'aodepo) wave(`wv')
label variable s`wv'aodepo "s`wv'aodepo:w`wv' Asset: holding deposit account"

****Amount of 
***respondent
gen r`wv'adepo=.
missing_c_w1 hc004 hc005, result(r`wv'adepo)
replace r`wv'adepo = 0 if r`wv'aodepo== 0
replace r`wv'adepo = hc005 if inrange(hc005,0,999999999)
label variable r`wv'adepo "r`wv'adepo:w`wv' Asset: total amount of deposit"

***Spouse
gen s`wv'adepo=.
spouse r`wv'adepo,result(s`wv'adepo) wave(`wv')
label variable s`wv'adepo "s`wv'adepo:w`wv' Asset total amount of deposit"

drop r`wv'aodepo s`wv'aodepo

********************************************
*****Value of cash and financial deposit****
gen r`wv'achck = .
missing_H  r`wv'acash r`wv'adepo, result(r`wv'achck)
replace r`wv'achck=r`wv'acash + r`wv'adepo if !mi(r`wv'acash) & !mi(r`wv'adepo)
label variable r`wv'achck "r`wv'achck:w`wv' Asset: R cash, checking and saving acct"

gen s`wv'achck=.
spouse r`wv'achck,result(s`wv'achck) wave(`wv')
label variable s`wv'achck "s`wv'achck:w`wv' Asset: S cash, checking and saving acct"

gen h`wv'achck= .
household r`wv'achck s`wv'achck, result(h`wv'achck)
label variable h`wv'achck "h`wv'achck:w`wv' Asset: r+s cash, checking and saving acct"

drop r`wv'acash r`wv'adepo
drop s`wv'acash s`wv'adepo

***********************************************************
*****2.Total value of stocks, mutual funds*****************
**********************************************************
***Having stock****
gen r`wv'aostoc=.
missing_c_w1 hc010, result(r`wv'aostoc)
replace r`wv'aostoc= 0 if hc010==2
replace r`wv'aostoc= 1 if hc010==1
label variable r`wv'aostoc "r`wv'aostoc:w`wv' Asset: r having stock"
label value r`wv'aostoc own

*Spouse 
gen s`wv'aostoc=.
spouse r`wv'aostoc,result(s`wv'aostoc) wave(`wv')
label variable s`wv'aostoc "s`wv'aostoc:w`wv' Asset: s having stock"
label value s`wv'aostoc own

****Value of stock
gen r`wv'astoc=.
missing_c_w1 hc010 hc013, result(r`wv'astoc)
replace r`wv'astoc= 0 if r`wv'aostoc== 0 
replace r`wv'astoc=hc013 if inrange(hc013,0,50000000)
label variable r`wv'astoc "r`wv'astoc:w`wv' Asset: r stocks"

*Spouse 
gen s`wv'astoc=.
spouse r`wv'astoc,result(s`wv'astoc) wave(`wv')
label variable s`wv'astoc "s`wv'astoc:w`wv' Asset: s stocks"

drop r`wv'aostoc s`wv'aostoc

***Having mutual fund****
gen r`wv'aofund=.
missing_c_w1 hc015, result(r`wv'aofund)
replace r`wv'aofund= 0 if hc015==2
replace r`wv'aofund= 1 if hc015==1
label variable r`wv'aofund "r`wv'aofund:w`wv' Asset: having mutual fund"
label value r`wv'aofund own

*Spouse 
gen s`wv'aofund=.
spouse r`wv'aofund,result(s`wv'aofund) wave(`wv')
label variable s`wv'aofund "s`wv'aofund:w`wv' Asset: having mutual fund"
label value s`wv'aofund own

****Value of mutual fund
gen r`wv'afund=.
missing_c_w1 hc015 hc018, result(r`wv'afund)
replace r`wv'afund =  0 if r`wv'aofund == 0
replace r`wv'afund = hc018 if inrange(hc018,0,9999999)
label variable r`wv'afund "r`wv'afund:w`wv' Asset: R mutual funds"

*Spouse 
gen s`wv'afund=.
spouse r`wv'afund,result(s`wv'afund) wave(`wv')
label variable s`wv'afund "s`wv'afund:w`wv' Asset: S mutual funds"

drop r`wv'aofund s`wv'aofund

***********************************************
*****Value of  stock and mutual fund****
*respondent
gen r`wv'astck=.
missing_H r`wv'afund r`wv'astoc, result(r`wv'astck)
replace r`wv'astck = r`wv'afund + r`wv'astoc if !mi(r`wv'afund) & !mi(r`wv'astoc)
label variable r`wv'astck "r`wv'astck:w`wv' Asset: R stocks and mutual funds"

*spouse
gen s`wv'astck=.
spouse r`wv'astck,result(s`wv'astck) wave(`wv')
label variable s`wv'astck "s`wv'astck:w`wv' Asset: S stocks and mutual funds"

*household
gen h`wv'astck=.
household r`wv'astck s`wv'astck, result(h`wv'astck)
label variable h`wv'astck "h`wv'astck:w`wv' Asset: r+s stocks and mutual funds"

drop r`wv'afund r`wv'astoc
drop s`wv'afund s`wv'astoc

**********************************************************
*****3.Value of government bonds*************************
*********************************************************
***Having government bonds****
gen r`wv'aobond=.
missing_c_w1 hc007, result(r`wv'aobond)
replace r`wv'aobond= 0 if hc007==2
replace r`wv'aobond= 1 if hc007==1
label variable r`wv'aobond "r`wv'aobond:w`wv' Asset: having government bond"
label value r`wv'aobond own

*Spouse 
gen s`wv'aobond=.
spouse r`wv'aobond,result(s`wv'aobond) wave(`wv')
label variable s`wv'aobond "s`wv'aobond:w`wv' Asset: having government bond"
label value s`wv'aobond own

****Value of government bond
gen r`wv'abond=.
missing_c_w1 hc007 hc008, result(r`wv'abond)
replace r`wv'abond= 0  if r`wv'aobond== 0
replace r`wv'abond=hc008 if inrange(hc008,0,200000)
label variable r`wv'abond "r`wv'abond:w`wv' Asset: R government bonds"

*Spouse 
gen s`wv'abond=.
spouse r`wv'abond,result(s`wv'abond) wave(`wv')
label variable s`wv'abond "s`wv'abond:w`wv' Asset: S government bonds"

***Household level 
gen h`wv'abond = .
household r`wv'abond s`wv'abond, result(h`wv'abond)
label variable h`wv'abond "h`wv'abond:w`wv' Asset: r+s government bonds"

drop r`wv'aobond s`wv'aobond

****************************************************************************
**********5. R+S Other saving        ***************************************
****************************************************************************
** Other financial asset
** hc022: what is the total value of other assets?
***Having other financial asset****
*respondent
gen r`wv'aofino=.
replace r`wv'aofino=.m if hc021==. & inw`wv' == 1
replace r`wv'aofino=0 if ((hc004 != 2 | hc007 != 2 | hc010 != 2 | hc015 != 2) & inw`wv' == 1) | hc021==2 
replace r`wv'aofino=1 if hc021==1
label variable r`wv'aofino "r`wv'aofino:w`wv' Asset: having other financial asset"
label value r`wv'aofino own

*Spouse 
gen s`wv'aofino=.
spouse r`wv'aofino,result(s`wv'aofino) wave(`wv')
label variable s`wv'aofino "s`wv'aofino:w`wv' Asset: having other financial asset"
label value s`wv'aofino own

***Value of other financial assets****
*respondent
gen r`wv'afino=.
missing_c_w1 hc004 hc007 hc010 hc015 hc021 hc022, result( r`wv'afino)
replace r`wv'afino=0 if r`wv'aofino==0 
replace r`wv'afino=hc022 if inrange(hc022,0,400000)
label variable r`wv'aofino "r`wv'aofino:w`wv' Asset: other financial asset"

*Spouse 
gen s`wv'afino=.
spouse r`wv'afino,result(s`wv'afino) wave(`wv')
label variable s`wv'aofino "s`wv'aofino:w`wv' Asset: other financial asset"

drop r`wv'aofino s`wv'aofino

***Having public housing fund****
*respondent
gen r`wv'aohpub=.
missing_c_w1 hc027, result(r`wv'aohpub)
replace r`wv'aohpub= 0 if hc027==2
replace r`wv'aohpub= 1 if hc027==1
label variable r`wv'aohpub "r`wv'aohpub:w`wv' Asset: having public housing fund"
label value r`wv'aohpub own

*Spouse 
gen s`wv'aohpub=.
spouse r`wv'aohpub,result(s`wv'aohpub) wave(`wv')
label variable s`wv'aohpub "s`wv'aohpub:w`wv' Asset: having public housing fund"
label value s`wv'aohpub own

****Value of public housing fund
*respondent
gen r`wv'ahpub=.
missing_c_w1 hc027 hc028, result(r`wv'ahpub)
replace r`wv'ahpub= 0 if r`wv'aohpub == 0
replace r`wv'ahpub=hc028 if inrange(hc028,0,4000000)
label variable r`wv'ahpub "r`wv'ahpub:w`wv' Asset: public housing fund"

*Spouse 
gen s`wv'ahpub=.
spouse r`wv'ahpub,result(s`wv'ahpub) wave(`wv')
label variable s`wv'ahpub "s`wv'ahpub:w`wv' Asset: public housing fund"

drop r`wv'aohpub s`wv'aohpub 

***Having jizikuan***
*respondent
gen r`wv'aojizi=.
missing_c_w1 hc030, result(r`wv'aojizi)
replace r`wv'aojizi= 0 if hc030==2
replace r`wv'aojizi= 1 if hc030==1
label variable r`wv'aojizi "r`wv'aojizi:w`wv' Asset: having jizikuan"
label value r`wv'aojizi own

*Spouse 
gen s`wv'aojizi=.
spouse r`wv'aojizi,result(s`wv'aojizi) wave(`wv')
label variable s`wv'aojizi "s`wv'aojizi:w`wv' Asset: having jizikuan"
label value s`wv'aojizi own

****Value of jizikuan
*respondent
gen r`wv'ajizi=.
missing_c_w1 hc030 hc031, result(r`wv'ajizi)
replace r`wv'ajizi= 0 if r`wv'aojizi== 0 
replace r`wv'ajizi=hc031 if inrange(hc031,0,9999999999)
label variable r`wv'ajizi "r`wv'ajizi:w`wv' Asset: jizikuan"

*Spouse 
gen s`wv'ajizi=.
spouse r`wv'ajizi,result(s`wv'ajizi) wave(`wv')
label variable s`wv'ajizi "s`wv'ajizi:w`wv' Asset: jizikuan"

drop r`wv'aojizi s`wv'aojizi

***Having unpaid salary***
*respondent
gen r`wv'aounpay=.
missing_c_w1 hc033, result(r`wv'aounpay)
replace r`wv'aounpay= 0 if hc033==2
replace r`wv'aounpay= 1 if hc033==1
label variable r`wv'aounpay "r`wv'aounpay:w`wv' Asset: having unpaid salary"
label value r`wv'aounpay own

*Spouse 
gen s`wv'aounpay=.
spouse r`wv'aounpay,result(s`wv'aounpay) wave(`wv')
label variable s`wv'aounpay "s`wv'aounpay:w`wv' Asset: having unpaid salary"
label value s`wv'aounpay own

****Value of unpaid salary
*respondent
gen r`wv'aunpay=.
missing_c_w1 hc033 hc034, result(r`wv'aunpay)
replace r`wv'aunpay= 0 if r`wv'aounpay== 0
replace r`wv'aunpay=hc034 if inrange(hc034,0,8000000)
label variable r`wv'aunpay "r`wv'aunpay:w`wv' Asset: unpaid salary"

*Spouse 
gen s`wv'aunpay=.
spouse r`wv'aunpay,result(s`wv'aunpay) wave(`wv')
label variable s`wv'aunpay "s`wv'aunpay:w`wv' Asset: unpaid salary"

drop r`wv'aounpay s`wv'aounpay

*************************************
****Net value of all other saving***
*respondent
gen r`wv'aothr = .
missing_H r`wv'ahpub r`wv'ajizi r`wv'aunpay r`wv'afino, result(r`wv'aothr)
replace r`wv'aothr = r`wv'ahpub + r`wv'ajizi + r`wv'aunpay + r`wv'afino if !mi(r`wv'ahpub) & !mi(r`wv'ajizi) & !mi(r`wv'aunpay) & !mi(r`wv'afino)
label variable r`wv'aothr "r`wv'aothr:w`wv' Asset: R all other savings"

*spouse
gen s`wv'aothr=.
spouse r`wv'aothr,result(s`wv'aothr) wave(`wv')
label variable s`wv'aothr "s`wv'aothr:w`wv' Asset: S all other savings"

*household
gen h`wv'aothr=.
household r`wv'aothr s`wv'aothr, result(h`wv'aothr)
label variable h`wv'aothr "h`wv'aothr:w`wv' Asset: R+S all other savings"

drop r`wv'ahpub r`wv'ajizi r`wv'aunpay r`wv'afino
drop s`wv'ahpub s`wv'ajizi s`wv'aunpay s`wv'afino

**************************************************************
***********6. VAlue of other debt
**************************************************************
*****unpaid loan: Other than housing loan****
****amount of loan***
*respondent
gen r`wv'aloan=.
missing_c_w1 hd001, result(r`wv'aloan)
replace r`wv'aloan=hd001 if inrange(hd001,0,2000000)
label variable r`wv'aloan "r`wv'aloan:w`wv' Asset: loan other than mortgage"

*Spouse 
gen s`wv'aloan=.
spouse r`wv'aloan,result(s`wv'aloan) wave(`wv')
label variable s`wv'aloan "s`wv'aloan:w`wv' Asset: loan other than mortgage"
label value s`wv'aloan own

****Credit Card debt****
*respondent
gen r`wv'accard=.
missing_c_w1 hd003, result(r`wv'accard)
replace r`wv'accard=hd003 if inrange(hd003,0,2000000)
label variable r`wv'accard "r`wv'accard:w`wv' Asset: credit card debt"

*Spouse 
gen s`wv'accard=.
spouse r`wv'accard,result(s`wv'accard) wave(`wv')
label variable s`wv'accard "s`wv'accard:w`wv' Asset: credit card debt"

******************************
****Total value of debt
*respondent
gen r`wv'adebt = .
missing_H r`wv'accard r`wv'aloan, result(r`wv'adebt)
replace r`wv'adebt = r`wv'accard + r`wv'aloan if !mi(r`wv'accard) & !mi(r`wv'aloan)
label variable r`wv'adebt "r`wv'adebt:w`wv' Asset: R debt" 

*spouse
gen s`wv'adebt=.
spouse r`wv'adebt,result(s`wv'adebt) wave(`wv')
label variable s`wv'adebt "s`wv'adebt:w`wv' Asset: S debt" 

*household
gen h`wv'adebt=.
household r`wv'adebt s`wv'adebt, result(h`wv'adebt)
label variable h`wv'adebt "h`wv'adebt:w`wv' Asset: R+S debt" 

drop r`wv'accard r`wv'aloan
drop s`wv'accard s`wv'aloan

**************************************************
***************************************************
****SUMMARY: total individual financial asset 
***************************************************
gen r`wv'atotf = .
missing_H r`wv'achck r`wv'astck r`wv'abond r`wv'aothr r`wv'adebt, result(r`wv'atotf)
replace r`wv'atotf = r`wv'achck + r`wv'astck + r`wv'abond + r`wv'aothr - r`wv'adebt if ///
                      !mi(r`wv'achck) & !mi(r`wv'astck) & !mi(r`wv'abond) & !mi(r`wv'aothr) & !mi(r`wv'adebt)
label variable r`wv'atotf "r`wv'atotf:w`wv' Asset:r total individual financial assets" 

gen s`wv'atotf=.
spouse r`wv'atotf,result(s`wv'atotf) wave(`wv')
label variable s`wv'atotf "s`wv'atotf:w`wv' Asset:s total individual financial assets" 

gen h`wv'atotf=.
household r`wv'atotf s`wv'atotf, result(h`wv'atotf)
label variable h`wv'atotf "h`wv'atotf:w`wv' Asset:r+s total individual financial assets" 

drop r`wv'atotf s`wv'atotf
 
** ================================================================
**                                                               **
**                 HOUSEHOLD ASSET                               **
**                                                               **
** ==============================================================**

**********************************************************************
** value of other house***********
**********************************************************************
forvalues i=1(1)3 {
    ** correct house price variables that appear to be using wrong unit
    replace ha034_2_`i'_=ha034_2_`i'_/1000  if ha034_2_`i'_>=1000  & !mi(ha034_2_`i'_)
    replace ha034_1_`i'_=ha034_1_`i'_/10000 if ha034_1_`i'_>=10000 & !mi(ha034_1_`i'_)
    
    gen hh`wv'ahoub`i'=.
    missing_c_w1 ha031_`i'_s? ha034_1_`i'_ ha051_`i'_, result(hh`wv'ahoub`i')
    replace hh`wv'ahoub`i' = 0 if (((ha031_`i'_s1 != pn | ha031_`i'_s1 != s`wv'pn) & !mi(ha031_`i'_s1)) | mi(ha031_`i'_s1)) & ///
                                  (((ha031_`i'_s2 != pn | ha031_`i'_s2 != s`wv'pn) & !mi(ha031_`i'_s2)) | mi(ha031_`i'_s2)) & ///
                                  (((ha031_`i'_s3 != pn | ha031_`i'_s3 != s`wv'pn) & !mi(ha031_`i'_s3)) | mi(ha031_`i'_s3)) & ///
                                  (((ha031_`i'_s4 != pn | ha031_`i'_s4 != s`wv'pn) & !mi(ha031_`i'_s4)) | mi(ha031_`i'_s4)) & ///
                                  !(mi(ha031_`i'_s1) & mi(ha031_`i'_s2) & mi(ha031_`i'_s3) & mi(ha031_`i'_s4) & mi(ha031_`i'_s5) & mi(ha031_`i'_s6) & mi(ha031_`i'_s7) & mi(ha031_`i'_s8) & mi(ha031_`i'_s9))
    replace hh`wv'ahoub`i' = ha034_2_`i'_*ha051_`i'_*1000 if inrange(ha034_2_`i'_,0,99999) & inrange(ha051_`i'_,0,99999)
    replace hh`wv'ahoub`i' = ha034_1_`i'_*10000  if inrange(ha034_1_`i'_,0,999999)
}
gen hh`wv'ahoub4=.
missing_c_w1 ha031_4_s?, result(hh`wv'ahoub4)
replace hh`wv'ahoub4 = 0 if (((ha031_4_s1 != pn | ha031_4_s1 != s`wv'pn) & !mi(ha031_4_s1)) | mi(ha031_4_s1)) & ///
                              (((ha031_4_s2 != pn | ha031_4_s2 != s`wv'pn) & !mi(ha031_4_s2)) | mi(ha031_4_s2)) & ///
                              (((ha031_4_s3 != pn | ha031_4_s3 != s`wv'pn) & !mi(ha031_4_s3)) | mi(ha031_4_s3)) & ///
                              (((ha031_4_s4 != pn | ha031_4_s4 != s`wv'pn) & !mi(ha031_4_s4)) | mi(ha031_4_s4)) & ///
                              !(mi(ha031_4_s1) & mi(ha031_4_s2) & mi(ha031_4_s3) & mi(ha031_4_s4) & mi(ha031_4_s5) & mi(ha031_4_s6) & mi(ha031_4_s7) & mi(ha031_4_s8) & mi(ha031_4_s9))

***Total value of other houses***
gen hh`wv'ahoub = .
missing_c_w1 ha027 ha028, result(hh`wv'ahoub)
missing_H hh`wv'ahoub1 hh`wv'ahoub2 hh`wv'ahoub3, result(hh`wv'ahoub)
replace hh`wv'ahoub = 0 if ha027 == 2 | ha028 == 0
replace hh`wv'ahoub = hh`wv'ahoub1 if !mi(hh`wv'ahoub1) & ha028 == 1
replace hh`wv'ahoub = hh`wv'ahoub1 + hh`wv'ahoub2 if !mi(hh`wv'ahoub1) & !mi(hh`wv'ahoub2) & ha028 == 2
replace hh`wv'ahoub = hh`wv'ahoub1 + hh`wv'ahoub2 + hh`wv'ahoub3 if !mi(hh`wv'ahoub1) & !mi(hh`wv'ahoub2) & !mi(hh`wv'ahoub3) & ha028 == 3 
replace hh`wv'ahoub = hh`wv'ahoub1 + hh`wv'ahoub2 + hh`wv'ahoub3 + hh`wv'ahoub4 if !mi(hh`wv'ahoub1) & !mi(hh`wv'ahoub2) & !mi(hh`wv'ahoub3) & !mi(hh`wv'ahoub4) & ha028 == 4
label variable hh`wv'ahoub "hh`wv'ahoub:w`wv' Asset: other real estate"

drop hh`wv'ahoub1 hh`wv'ahoub2 hh`wv'ahoub3 hh`wv'ahoub4

***whether have loan for other house
gen hh`wv'aoloanb1=.
missing_c_w1 ha036_1_ ha031_1_s?, result(hh`wv'aoloanb1)
replace hh`wv'aoloanb1= 0 if ha036_1_==2 | ((((ha031_1_s1 != pn | ha031_1_s1 != s`wv'pn) & !mi(ha031_1_s1)) | mi(ha031_1_s1)) & ///
                                            (((ha031_1_s2 != pn | ha031_1_s2 != s`wv'pn) & !mi(ha031_1_s2)) | mi(ha031_1_s2)) & ///
                                            (((ha031_1_s3 != pn | ha031_1_s3 != s`wv'pn) & !mi(ha031_1_s3)) | mi(ha031_1_s3)) & ///
                                            (((ha031_1_s4 != pn | ha031_1_s4 != s`wv'pn) & !mi(ha031_1_s4)) | mi(ha031_1_s4)) & ///
                                            !(mi(ha031_1_s1) & mi(ha031_1_s2) & mi(ha031_1_s3) & mi(ha031_1_s4) & mi(ha031_1_s5) & mi(ha031_1_s6) & mi(ha031_1_s7) & mi(ha031_1_s8) & mi(ha031_1_s9)))
replace hh`wv'aoloanb1= 1 if ha036_1_==1
label var hh`wv'aoloanb1 "hh`wv'aoloanb1:w`wv' Asset: mortgage for secondary residence 1"
label value hh`wv'aoloanb1 own

gen hh`wv'aoloanb2=.
missing_c_w1 ha036_2_ ha031_2_s?, result(hh`wv'aoloanb2)
replace hh`wv'aoloanb2= 0 if ha036_2_==2 | ((((ha031_2_s1 != pn | ha031_2_s1 != s`wv'pn) & !mi(ha031_2_s1)) | mi(ha031_2_s1)) & ///
                                            (((ha031_2_s2 != pn | ha031_2_s2 != s`wv'pn) & !mi(ha031_2_s2)) | mi(ha031_2_s2)) & ///
                                            (((ha031_2_s3 != pn | ha031_2_s3 != s`wv'pn) & !mi(ha031_2_s3)) | mi(ha031_2_s3)) & ///
                                            (((ha031_2_s4 != pn | ha031_2_s4 != s`wv'pn) & !mi(ha031_2_s4)) | mi(ha031_2_s4)) & ///
                                            !(mi(ha031_2_s1) & mi(ha031_2_s2) & mi(ha031_2_s3) & mi(ha031_2_s4) & mi(ha031_2_s5) & mi(ha031_2_s6) & mi(ha031_2_s7) & mi(ha031_2_s8) & mi(ha031_2_s9)))
replace hh`wv'aoloanb2= 1 if ha036_2_==1
label var hh`wv'aoloanb2 "hh`wv'aoloanb2:w`wv' Asset: mortgage for secondary residence 2"
label value hh`wv'aoloanb2 own

gen hh`wv'aoloanb3=.
missing_c_w1 ha036_3_ ha031_3_s?, result(hh`wv'aoloanb3)
replace hh`wv'aoloanb3= 0 if ha036_3_==2 | ((((ha031_3_s1 != pn | ha031_3_s1 != s`wv'pn) & !mi(ha031_3_s1)) | mi(ha031_3_s1)) & ///
                                            (((ha031_3_s2 != pn | ha031_3_s2 != s`wv'pn) & !mi(ha031_3_s2)) | mi(ha031_3_s2)) & ///
                                            (((ha031_3_s3 != pn | ha031_3_s3 != s`wv'pn) & !mi(ha031_3_s3)) | mi(ha031_3_s3)) & ///
                                            (((ha031_3_s4 != pn | ha031_3_s4 != s`wv'pn) & !mi(ha031_3_s4)) | mi(ha031_3_s4)) & ///
                                            !(mi(ha031_3_s1) & mi(ha031_3_s2) & mi(ha031_3_s3) & mi(ha031_3_s4) & mi(ha031_3_s5) & mi(ha031_3_s6) & mi(ha031_3_s7) & mi(ha031_3_s8) & mi(ha031_3_s9)))
replace hh`wv'aoloanb3= 1 if ha036_3_==1
label var hh`wv'aoloanb3 "hh`wv'aoloanb3:w`wv' Asset: mortgage for secondary residence 3"
label value hh`wv'aoloanb3 own

gen hh`wv'aoloanb4=.
missing_c_w1 ha031_4_s?, result(hh`wv'aoloanb4)
replace hh`wv'aoloanb4= 0 if (((ha031_4_s1 != pn | ha031_4_s1 != s`wv'pn) & !mi(ha031_4_s1)) | mi(ha031_4_s1)) & ///
                                            (((ha031_4_s2 != pn | ha031_4_s2 != s`wv'pn) & !mi(ha031_4_s2)) | mi(ha031_4_s2)) & ///
                                            (((ha031_4_s3 != pn | ha031_4_s3 != s`wv'pn) & !mi(ha031_4_s3)) | mi(ha031_4_s3)) & ///
                                            (((ha031_4_s4 != pn | ha031_4_s4 != s`wv'pn) & !mi(ha031_4_s4)) | mi(ha031_4_s4)) & ///
                                            !(mi(ha031_4_s1) & mi(ha031_4_s2) & mi(ha031_4_s3) & mi(ha031_4_s4) & mi(ha031_4_s5) & mi(ha031_4_s6) & mi(ha031_4_s7) & mi(ha031_4_s8) & mi(ha031_4_s9))
label var hh`wv'aoloanb4 "hh`wv'aoloanb4:w`wv' Asset: mortgage for secondary residence 4"
label value hh`wv'aoloanb4 own

**********************************************
***total mortgages for other house****
forvalues i=1/2 {
    gen hh`wv'amrtb`i'=.
    missing_c_w1 ha038_`i'_ ha037_`i'_, result(hh`wv'amrtb`i')
    missing_H hh`wv'aoloanb`i', result(hh`wv'amrtb`i')
    replace hh`wv'amrtb`i'= 0 if hh`wv'aoloanb`i' == 0
    replace hh`wv'amrtb`i'= ha038_`i'_*12 if inrange(ha038_`i'_,0,9999)
    replace hh`wv'amrtb`i'= ha037_`i'_*10000 if inrange(ha037_`i'_,0,10000)
}
gen hh`wv'amrtb3=.
missing_H hh`wv'aoloanb3, result(hh`wv'amrtb3)
replace hh`wv'amrtb3= 0 if hh`wv'aoloanb3 == 0

gen hh`wv'amrtb4=.
missing_H hh`wv'aoloanb4, result(hh`wv'amrtb4)
replace hh`wv'amrtb4= 0 if hh`wv'aoloanb4 == 0

gen hh`wv'amrtb = .
missing_c_w1 ha027 ha028, result(hh`wv'amrtb)
missing_H hh`wv'amrtb1 hh`wv'amrtb2 hh`wv'amrtb3, result(hh`wv'amrtb)
replace hh`wv'amrtb = 0 if ha027 == 2 | ha028 == 0
replace hh`wv'amrtb = hh`wv'amrtb1 if !mi(hh`wv'amrtb1) & ha028 == 1
replace hh`wv'amrtb = hh`wv'amrtb1 + hh`wv'amrtb2 if !mi(hh`wv'amrtb1) & !mi(hh`wv'amrtb2) & ha028 == 2
replace hh`wv'amrtb = hh`wv'amrtb1 + hh`wv'amrtb2 + hh`wv'amrtb3 if !mi(hh`wv'amrtb1) & !mi(hh`wv'amrtb2) & !mi(hh`wv'amrtb3) & ha028 == 3
replace hh`wv'amrtb = hh`wv'amrtb1 + hh`wv'amrtb2 + hh`wv'amrtb3 + hh`wv'amrtb4 if !mi(hh`wv'amrtb1) & !mi(hh`wv'amrtb2) & !mi(hh`wv'amrtb3) & !mi(hh`wv'amrtb4) & ha028 == 4
label variable hh`wv'amrtb "hh`wv'amrtb:w`wv' Asset: mortgage other real estate"

drop hh`wv'aoloanb1 hh`wv'aoloanb2 hh`wv'aoloanb3 hh`wv'aoloanb4
drop hh`wv'amrtb1 hh`wv'amrtb2 hh`wv'amrtb3 hh`wv'amrtb4

***********************************************************
*************Net value of other residential property(not primary)
gen hh`wv'arles = .
missing_H hh`wv'ahoub hh`wv'amrtb, result(hh`wv'arles)
replace hh`wv'arles = hh`wv'ahoub - hh`wv'amrtb if !mi(hh`wv'ahoub) & !mi(hh`wv'amrtb)
label variable hh`wv'arles "hh`wv'arles:w`wv' Asset: hh Net value of other real estate (not primary)"

** =================================================================
** Housing Ownership of Current Residence           *
** =================================================================

** ha007: whether the current residence is owned by household member

gen hh`wv'own_curr=.
missing_c_w1 ha007, result(hh`wv'own_curr)
replace hh`wv'own_curr=0 if ha007==3
replace hh`wv'own_curr=ha007 if inlist(ha007,1,2)

** ha009_*_: share of the house owned by each household member
egen ratio_total=rowtotal(ha009_*_),m

gen hh`wv'curr_ratio = .
missing_c_w1 ha009_*_, result(hh`wv'curr_ratio)
missing_H hh`wv'own_curr, result(hh`wv'curr_ratio)
replace hh`wv'curr_ratio = 0 if hh`wv'own_curr==0
replace hh`wv'curr_ratio = ratio_total if inrange(ratio_total,0,100)
replace hh`wv'curr_ratio = 100 if ratio_total>100 &!mi(ratio_total)  

drop ratio_total

gen hh`wv'ahrto=.
missing_H hh`wv'curr_ratio, result(hh`wv'ahrto)
replace hh`wv'ahrto=hh`wv'curr_ratio/100 if inrange(hh`wv'curr_ratio,0,100)
label variable hh`wv'ahrto "hh`wv'ahrto:w`wv' Asset: hh percent of ownership for primary residence"

drop hh`wv'curr_ratio

***************************************************************************
******** Value of primary residence**********************
***********************************************************

** Calculate currently owned house and current residece
** (1)currently owned housing value in yuan
* check price values that appear to be using wrong units
** generate dummy variables to keep track of the corrected values
gen change=0
replace change=1 if ha011_2>=1000 & !mi(ha011_2)  
replace change=1 if ha011_1>=10000 & !mi(ha011_1) 

** remove total value values which seems invalid
replace ha011_1=. if inlist(ha011_1,0.0001, 0.00001, 0.005,-9999)

** correct total value and value per m2 that appear to be using wrong unit. reason for including cases which equals to 10000/1000 pls see mem housing 3
replace ha011_2=ha011_2/1000 if ha011_2>=1000 & !mi(ha011_2)
replace ha011_1=ha011_1/10000 if ha011_1>=10000 & !mi(ha011_1) 


** 6.1.3 current residence value
** generate sqr meter area of current residence
** area_residence: i001_what is the construction area of your residence
** area_zhaijidi:i002_what is the total housing land area? (including b


gen area_residence = i001
gen area_zhaijidi  = i002
sum area_residence area_zhaijidi if !mi(area_residence) & !mi(area_zhaijidi)
gen ratio_area=area_residence/area_zhaijidi
egen meanr_area=mean(ratio_area)
gen area=area_residence

** use mean ratio to impute missing construction area
replace area=area_zhaijidi*meanr_area if mi(area) & !mi(area_zhaijidi)& area_zhaijidi~=0 
replace area=area_zhaijidi*meanr_area if area==0 & !mi(area_zhaijidi) & area_zhaijidi~=0 

bysort communityID:egen area_vmed=median(area)
replace area=area_vmed if mi(area)

** (1)currently owned housing value in yuan
gen hh`wv'cvalue_1=.
missing_c_w1 ha011_1, result(hh`wv'cvalue_1)
missing_H hh`wv'own_curr hh`wv'ahrto, result(hh`wv'cvalue_1)
replace hh`wv'cvalue_1 = ha011_1*10000 if !mi(ha011_1) & hh`wv'own_curr==1 
replace hh`wv'cvalue_1 = ha011_1*10000*hh`wv'ahrto if !mi(ha011_1) & !mi(hh`wv'ahrto) & hh`wv'own_curr==2 

** calculate housing value in yuan using reported value 1000yuan per m2 in full and partial ownership
gen hh`wv'cvalue_2=.
missing_c_w1 area ha011_2, result(hh`wv'cvalue_2)
missing_H hh`wv'own_curr hh`wv'ahrto, result(hh`wv'cvalue_2)
replace hh`wv'cvalue_2=ha011_2*1000*area if !mi(ha011_2) & !mi(area) & hh`wv'own_curr==1 
replace hh`wv'cvalue_2=ha011_2*1000*area*hh`wv'ahrto if !mi(ha011_2) & !mi(area) & !mi(hh`wv'ahrto) & hh`wv'own_curr==2

gen hh`wv'cvalue_own=.
missing_H hh`wv'own_curr hh`wv'cvalue_1 hh`wv'cvalue_2, result(hh`wv'cvalue_own)
replace hh`wv'cvalue_own=0 if hh`wv'own_curr==0
replace hh`wv'cvalue_own=hh`wv'cvalue_1 if inrange(hh`wv'cvalue_1,0,9999999999)
replace hh`wv'cvalue_own=hh`wv'cvalue_2 if mi(hh`wv'cvalue_own) & inrange(hh`wv'cvalue_2,0,9999999999)

** NOTES: Check consistency: 37 cases when both values are reported
** 36 of these are full owned by the household member and 1 is not owned by the household member 

** for urban house, its value is set to the larger one; 
replace hh`wv'cvalue_own=max(hh`wv'cvalue_1, hh`wv'cvalue_2) if urban_nbs==1 & change==0 &!mi(hh`wv'cvalue_1) &!mi(hh`wv'cvalue_2) 

** for rural houses, for original value<1000, set to the larger value of the two; for original value>10000, set to the smaller one
replace hh`wv'cvalue_own=max(hh`wv'cvalue_1, hh`wv'cvalue_2) if urban_nbs==0 & hh`wv'cvalue_own<=1000 & change==0 & !mi(hh`wv'cvalue_1) &!mi(hh`wv'cvalue_2)
replace hh`wv'cvalue_own=min(hh`wv'cvalue_1, hh`wv'cvalue_2) if urban_nbs==0 & hh`wv'cvalue_own>=10000 & change==0 & !mi(hh`wv'cvalue_1) &!mi(hh`wv'cvalue_2)

gen hh`wv'ahous=.
missing_H hh`wv'cvalue_own, result(hh`wv'ahous)
replace hh`wv'ahous=hh`wv'cvalue_own if inrange(hh`wv'cvalue_own,0,999999999)
label variable hh`wv'ahous "hh`wv'ahous:w`wv' Asset: hh primary residence with % of ownership"

***********************************************************
** (2)Current residence value regardless of the ownership
gen hh`wv'cv2_house=.
missing_c_w1 ha011_1, result(hh`wv'cv2_house)
replace hh`wv'cv2_house = ha011_1*10000 if !mi(ha011_1)

gen hh`wv'cv1_house=.
missing_c_w1 area ha011_2, result(hh`wv'cv1_house)
replace hh`wv'cv1_house = ha011_2*1000*area if !mi(ha011_2) & !mi(area)

gen hh`wv'cvalue_house=.
missing_H hh`wv'own_curr hh`wv'cv1_house hh`wv'cv2_house, result(hh`wv'cvalue_house)
replace hh`wv'cvalue_house=0  if hh`wv'own_curr==0
replace hh`wv'cvalue_house=hh`wv'cv1_house if inrange(hh`wv'cv1_house,0,9999999999)
replace hh`wv'cvalue_house=hh`wv'cv2_house if mi(hh`wv'cv1_house) & inrange(hh`wv'cv2_house,0,9999999999)

** for urban house, its value is set to the larger one; 
replace hh`wv'cvalue_house=max(hh`wv'cv1_house, hh`wv'cv2_house) if urban_nbs==1 & change==0 & !mi(hh`wv'cv1_house) &!mi(hh`wv'cv2_house)

** for rural houses, for original value<1000, set to the larger value of the two; for original value>10000, set to the smaller one
replace hh`wv'cvalue_house=max(hh`wv'cv1_house, hh`wv'cv2_house) if urban_nbs==0 & hh`wv'cvalue_house<=1000 & change==0 & !mi(hh`wv'cv1_house) &!mi(hh`wv'cv2_house)  
replace hh`wv'cvalue_house=min(hh`wv'cv1_house, hh`wv'cv2_house) if urban_nbs==0 & hh`wv'cvalue_house>=10000 & change==0 & !mi(hh`wv'cv1_house) &!mi(hh`wv'cv2_house)  

gen hh`wv'ahousa=.
missing_H hh`wv'cvalue_house, result(hh`wv'ahousa)
replace hh`wv'ahousa=hh`wv'cvalue_house if inrange(hh`wv'cvalue_house,0,999999999)
label variable hh`wv'ahousa "hh`wv'ahousa:w`wv' Asset: hh primary residence regardless of ownership"

**flag for area imputation
gen hh`wv'afhousar = .
replace hh`wv'afhousar = 0 if (!mi(i001) | !mi(ha011_1)) & !mi(hh`wv'ahousa)
replace hh`wv'afhousar = 1 if mi(i001) & !mi(i002) & mi(ha011_1) & !mi(hh`wv'ahousa)
replace hh`wv'afhousar = 2 if mi(i001) & mi(i002) & mi(ha011_1)  & !mi(hh`wv'ahousa)
label variable hh`wv'afhousar "hh`wv'afhousar:w`wv' Asset: hh imput flag for housing area"
label values hh`wv'afhousar areaimput

drop ratio_* area_* meanr_* hh`wv'cv* hh`wv'own_curr change area 

******************************************************************
****11 Value of all mortgage*************************
***Value of mortgages***
***whether have loan for primary
gen hh`wv'aohloan=.
missing_c_w1 ha007 ha013 ha014, result(hh`wv'aohloan)
replace hh`wv'aohloan= 0 if ha013==. & inlist(ha007,2,3)
replace hh`wv'aohloan= 0 if ha013==2 | ha014==0
replace hh`wv'aohloan= 1 if ha013==1
label variable hh`wv'aohloan "hh`wv'aohloan:w`wv' Asset: having mortgage for primary residence "
label value hh`wv'aohloan own

***total mortgages for primary residence****
gen hh`wv'amort=.
missing_c_w1 ha014, result(hh`wv'amort)
missing_H hh`wv'aohloan, result(hh`wv'amort)
replace hh`wv'amort = 0  if hh`wv'aohloan== 0
replace hh`wv'amort = ha014 if inrange(ha014,0,9999999)
label variable hh`wv'amort "hh`wv'amort:w`wv' Asset: hh total mortgage for primary residence"

drop hh`wv'aohloan

**************************************************
**** Net Value of primary residence***********
****Primary residence***
gen hh`wv'atoth=.
missing_H hh`wv'ahous hh`wv'amort, result(hh`wv'atoth)
replace hh`wv'atoth= hh`wv'ahous - hh`wv'amort if !mi(hh`wv'ahous) & !mi(hh`wv'amort)
label variable hh`wv'atoth "hh`wv'atoth:w`wv' Asset: hh net value of primary residence"

******value of consumer durable assets******************************
********************************************************************
********Value of vehicle       ***********************************
********************************************************************
***net value of vehicles***
*wave 1 household net value of vehicles
*whether has any vehicles 
gen hh`wv'aotran=.
missing_c_w1 ha065s? ha065s1?, result(hh`wv'aotran)
forvalues a = 1/17 {
    replace hh`wv'aotran= 0 if ha065s`a' == `a' |  ha065s18 == 18
}
replace hh`wv'aotran= 1 if ha065s1==1 | ha065s2==2 | ha065s3==3
label variable hh`wv'aotran "hh`wv'aotran:w`wv' Asset: own vehicle"
label value hh`wv'aotran own

****Value of vehicle****
gen hh`wv'atran=.
missing_c_w1 ha065_1_1_ ha065_1_2_ ha065_1_3_, result(hh`wv'atran)
missing_H hh`wv'aotran, result(hh`wv'atran)
replace hh`wv'atran = 0 if inlist(hh`wv'aotran,0,1)
replace hh`wv'atran = hh`wv'atran + ha065_1_1_ if inrange(ha065_1_1_,0,9999999) 
replace hh`wv'atran = hh`wv'atran + ha065_1_2_ if inrange(ha065_1_2_,0,9999999)
replace hh`wv'atran = hh`wv'atran + ha065_1_3_ if inrange(ha065_1_3_,0,9999999)
label variable hh`wv'atran "hh`wv'atran:w`wv' Asset: hh value of transportation"

drop hh`wv'aotran

*********************************************************************
*********14.Value of non-financial asset (Durable assets) ***********
*********************************************************************
*whether has any durable assets 
gen hh`wv'aodurbl=.
missing_c_w1 ha065s? ha065s1?, result(hh`wv'aodurbl)
forvalues a = 1/17 {
    replace hh`wv'aodurbl = 0 if ha065s`a' == `a' |  ha065s18 == 18
}
forvalues a = 4/17 {
    replace hh`wv'aodurbl = 1 if ha065s`a'==`a' 
}
label variable hh`wv'aodurbl "hh`wv'aodurbl:w`wv' Asset: own durable assests"
label value hh`wv'aodurbl own

*Value of durable assets
gen hh`wv'adurbl=.
missing_c_w1 ha065_1_4_ ha065_1_5_ ha065_1_4_ ha065_1_6_ ha065_1_7_ ha065_1_8_ ha065_1_9_ ha065_1_10_ ha065_1_11_ ha065_1_12_ ha065_1_13_ ha065_1_14_ ha065_1_15_ ha065_1_16_ ha065_1_17_, result(hh`wv'adurbl)
missing_H hh`wv'aodurbl, result(hh`wv'adurbl)
replace hh`wv'adurbl = 0 if inlist(hh`wv'aodurbl,0,1)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_4_ if inrange(ha065_1_4_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_5_ if inrange(ha065_1_5_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_6_ if inrange(ha065_1_6_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_7_ if inrange(ha065_1_7_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_8_ if inrange(ha065_1_8_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_9_ if inrange(ha065_1_9_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_10_ if inrange(ha065_1_10_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_11_ if inrange(ha065_1_11_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_12_ if inrange(ha065_1_12_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_13_ if inrange(ha065_1_13_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_14_ if inrange(ha065_1_14_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_15_ if inrange(ha065_1_15_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_16_ if inrange(ha065_1_16_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_17_ if inrange(ha065_1_17_,0,9999999)
label variable hh`wv'adurbl "hh`wv'adurbl:w`wv' Assets: hh consumer durable assets "

drop hh`wv'aodurbl

**************************************************
***15 Value of fixed capital assets***************
**************************************************
*whether has any fixed capital assets 
gen hh`wv'aofixc=.
missing_c_w1 ha066s? ha067 ha068, result(hh`wv'aofixc)
replace hh`wv'aofixc = 0 if ha066s6 == 6 & ha067 == 0 & ha068 == 2
forvalues a = 1 / 5 {
    replace hh`wv'aofixc = 1 if ha066s`a' == `a'
} 
replace hh`wv'aofixc = 1 if inrange(ha067,1,9999999)
replace hh`wv'aofixc = 1 if ha068 == 1
label variable hh`wv'aofixc "hh`wv'aofixc:w`wv' Asset: own fixed capital assests"
label value hh`wv'aofixc own

*Value of fixed capital assets
gen hh`wv'afixc =.
missing_H hh`wv'aofixc, result(hh`wv'afixc)
missing_c_w1 ha066_1_1_ ha066_1_2_ ha066_1_3_ ha066_1_4_ ha066_1_5_ ha067 ha068_1, result(hh`wv'afixc)
replace hh`wv'afixc = 0 if inlist(hh`wv'aofixc,0,1)
replace hh`wv'afixc = hh`wv'afixc + ha066_1_1_ if inrange(ha066_1_1_,0,999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha066_1_2_ if inrange(ha066_1_2_,0,999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha066_1_3_ if inrange(ha066_1_3_,0,999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha066_1_4_ if inrange(ha066_1_4_,0,999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha066_1_5_ if inrange(ha066_1_5_,0,999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha067 if inrange(ha067,0,9999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha068_1 if inrange(ha068_1,0,999999) & !mi(hh`wv'afixc)
label variable hh`wv'afixc "hh`wv'afixc:w`wv' Asset: hh fixed capital assets"

drop hh`wv'aofixc

**********************************************************************
****16. Value of irrigable land*************************************
**********************************************************************
*whether has any irrigable land
gen hh`wv'aoland=.
missing_c_w1 ha054s?, result(hh`wv'aoland)
replace hh`wv'aoland = 0 if ha054s5 == 5
forvalues l = 1/4 {
    replace hh`wv'aoland = 1 if ha054s`l' == `l'
}
label variable hh`wv'aoland "hh`wv'aoland:w`wv' Asset: own irrigable land"
label value hh`wv'aoland own

gen land_value=.
missing_c_w1 ha057_1_ ha055_1_, result(land_value)
replace land_value = ha057_1_*ha055_1_ if inrange(ha057_1_,0,100000) & inrange(ha055_1_,0,99999)

gen forest_value=.
missing_c_w1 ha057_2_ ha055_2_, result(forest_value)
replace forest_value = ha057_2_*ha055_2_ if inrange(ha057_2_,0,100000) & inrange(ha055_2_,0,99999)

gen ranch_value=.
missing_c_w1 ha057_3_ ha055_3_, result(ranch_value)
replace ranch_value = ha057_3_*ha055_3_ if inrange(ha057_3_,0,10000) & inrange(ha055_3_,0,99999)

gen pond_value=.
missing_c_w1 ha057_4_ ha055_4_, result(pond_value)
replace pond_value = ha057_4_*ha055_4_ if inrange(ha057_4_,0,200000) & inrange(ha055_4_,0,99999)

*****Total value of irrigable land*****
gen hh`wv'aland =.
missing_H land_value forest_value ranch_value pond_value hh`wv'aoland, result(hh`wv'aland)
replace hh`wv'aland = 0 if inlist(hh`wv'aoland,0,1)
replace hh`wv'aland = hh`wv'aland + land_value if !mi(land_value)
replace hh`wv'aland = hh`wv'aland + forest_value if !mi(forest_value)
replace hh`wv'aland = hh`wv'aland + ranch_value if !mi(ranch_value)
replace hh`wv'aland = hh`wv'aland + pond_value if !mi(pond_value)
label variable hh`wv'aland "hh`wv'aland:w`wv' Asset: hh value of irrigable land"

drop  hh`wv'aoland land_value forest_value ranch_value pond_value

***********************************************************************
****17 Agricultural Asset- livestock & fisheries*********************
***********************************************************************
*whether has any livestock or fisheres
gen hh`wv'aoagri=.
missing_c_w1 gb001 gb007, result(hh`wv'aoagri)
replace hh`wv'aoagri = 0 if gb001 == 2 | gb007 == 2
replace hh`wv'aoagri = 1 if gb007 == 1
label variable hh`wv'aoagri "hh`wv'aoagri:w`wv' Asset: own livestock or fisheries"
label value hh`wv'aoagri own

gen hh`wv'aagri=.
missing_c_w1 gb001 gb007 gb008, result(hh`wv'aagri)
replace hh`wv'aagri= 0 if hh`wv'aoagri == 0
replace hh`wv'aagri= gb008 if inrange(gb008,0,99999999)
label variable hh`wv'aagri "hh`wv'aagri:w`wv' Asset: Agricultural asset: hh livestock & fisheries"

drop hh`wv'aoagri

**************************************************
****Cash lending & borrowing ********************
** ha070_what is the total amount of loans that have not been paid by others?
gen hh`wv'alend=.
missing_c_w1 ha069 ha070, result(hh`wv'alend)
replace hh`wv'alend = 0 if ha069==2
replace hh`wv'alend = ha070 if inrange(ha070,0,500000)
replace hh`wv'alend = .i if ha070>500000 & !mi(ha070)
label variable hh`wv'alend "hh`wv'alend:w`wv' Asset: hh total amount of personal loans that have not been paid"

** borrowing: ha072_what is the total amout of loans that you are still owing to others?
gen hh`wv'aborr=.
missing_c_w1 ha072, result(hh`wv'aborr)
replace hh`wv'aborr=ha072 if inrange(ha072,0,500000)
replace hh`wv'aborr = .i if ha072>500000 & !mi(ha072)
label variable hh`wv'aborr "hh`wv'aborr:w`wv' Asset: hh total amount of money owing to others"

****personal loans******
gen hh`wv'aploan=.
missing_H hh`wv'alend hh`wv'aborr, result(hh`wv'aploan)
replace hh`wv'aploan = .i if hh`wv'alend == .i | hh`wv'aborr == .i
replace hh`wv'aploan = hh`wv'alend- hh`wv'aborr if !mi(hh`wv'alend) & !mi(hh`wv'aborr)
label variable hh`wv'aploan "hh`wv'aploan:w`wv' Asset: hh net value of personal loan"


**********************************************
****                                     *****
****   5. Other hh Member Assets         *****
****                                     *****
**********************************************


********************************************************************
****                                                              **
****5.1 Value of other HH members (individual-based) fiancial asset**
****                                                              **
*********************************************************************
** ha074_what is the value of all financial assets of household member?
forvalues x=1/16 {
    gen hh`wv'hhmasset_`x' =.
    missing_c_w1 a002_`x'_ a006_`x'_ ha074_`x'_, result(hh`wv'hhmasset_`x')
    replace hh`wv'hhmasset_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | pn == `x' | s1pn == `x'
    replace hh`wv'hhmasset_`x' = ha074_`x'_ if inrange(ha074_`x'_,-9999999,9999999)
}
gen hh`wv'afsst = .
missing_H hh`wv'hhmasset_1 hh`wv'hhmasset_2 hh`wv'hhmasset_3 hh`wv'hhmasset_4 hh`wv'hhmasset_5 hh`wv'hhmasset_6 hh`wv'hhmasset_7 hh`wv'hhmasset_8 hh`wv'hhmasset_9 hh`wv'hhmasset_10 hh`wv'hhmasset_11 hh`wv'hhmasset_12 hh`wv'hhmasset_13 hh`wv'hhmasset_14 hh`wv'hhmasset_15 hh`wv'hhmasset_16, result(hh`wv'afsst)
replace hh`wv'afsst = hh`wv'hhmasset_1 + hh`wv'hhmasset_2 + hh`wv'hhmasset_3 + hh`wv'hhmasset_4 + hh`wv'hhmasset_5 + hh`wv'hhmasset_6 + hh`wv'hhmasset_7 + hh`wv'hhmasset_8 + hh`wv'hhmasset_9 + hh`wv'hhmasset_10 + hh`wv'hhmasset_11 + hh`wv'hhmasset_12 + hh`wv'hhmasset_13 + hh`wv'hhmasset_14 + hh`wv'hhmasset_15 + hh`wv'hhmasset_16 if ///
                     !mi(hh`wv'hhmasset_1) & !mi(hh`wv'hhmasset_2) & !mi(hh`wv'hhmasset_3) & !mi(hh`wv'hhmasset_4) & !mi(hh`wv'hhmasset_5) & !mi(hh`wv'hhmasset_6) & !mi(hh`wv'hhmasset_7) & !mi(hh`wv'hhmasset_8) & !mi(hh`wv'hhmasset_9) & !mi(hh`wv'hhmasset_10) & !mi(hh`wv'hhmasset_11) & !mi(hh`wv'hhmasset_12) & !mi(hh`wv'hhmasset_13) & !mi(hh`wv'hhmasset_14) & !mi(hh`wv'hhmasset_15) & !mi(hh`wv'hhmasset_16)
label variable hh`wv'afsst "hh`wv'afsst:w`wv' Asset: value of other HH members financial asset"

drop hh`wv'hhmasset_1 hh`wv'hhmasset_2 hh`wv'hhmasset_3 hh`wv'hhmasset_4 hh`wv'hhmasset_5 hh`wv'hhmasset_6 hh`wv'hhmasset_7 hh`wv'hhmasset_8 hh`wv'hhmasset_9 hh`wv'hhmasset_10 hh`wv'hhmasset_11 hh`wv'hhmasset_12 hh`wv'hhmasset_13 hh`wv'hhmasset_14 hh`wv'hhmasset_15 hh`wv'hhmasset_16

********************************************************************
****                                                              **
****5.2 Value of other HH members (individual-based) fiancial debt*
****                                                              **
********************************************************************
** ha075_what is the value of all unpaid loans from banks or financial institutions of household member?
forvalues x=1/16 {
    gen hh`wv'hhmdebt_`x' =.
    missing_c_w1 a002_`x'_ a006_`x'_ ha075_`x'_, result(hh`wv'hhmdebt_`x')
    replace hh`wv'hhmdebt_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | pn == `x' | s1pn == `x'
    replace hh`wv'hhmdebt_`x' = ha075_`x'_ if inrange(ha075_`x'_,0,9999999)
}

gen hh`wv'afloa = .
missing_H hh`wv'hhmdebt_1 hh`wv'hhmdebt_2 hh`wv'hhmdebt_3 hh`wv'hhmdebt_4 hh`wv'hhmdebt_5 hh`wv'hhmdebt_6 hh`wv'hhmdebt_7 hh`wv'hhmdebt_8 hh`wv'hhmdebt_9 hh`wv'hhmdebt_10 hh`wv'hhmdebt_11 hh`wv'hhmdebt_12 hh`wv'hhmdebt_13 hh`wv'hhmdebt_14 hh`wv'hhmdebt_15 hh`wv'hhmdebt_16, result(hh`wv'afloa)
replace hh`wv'afloa = hh`wv'hhmdebt_1 + hh`wv'hhmdebt_2 + hh`wv'hhmdebt_3 + hh`wv'hhmdebt_4 + hh`wv'hhmdebt_5 + hh`wv'hhmdebt_6 + hh`wv'hhmdebt_7 + hh`wv'hhmdebt_8 + hh`wv'hhmdebt_9 + hh`wv'hhmdebt_10 + hh`wv'hhmdebt_11 + hh`wv'hhmdebt_12 + hh`wv'hhmdebt_13 + hh`wv'hhmdebt_14 + hh`wv'hhmdebt_15 + hh`wv'hhmdebt_16 if ///
                     !mi(hh`wv'hhmdebt_1) & !mi(hh`wv'hhmdebt_2) & !mi(hh`wv'hhmdebt_3) & !mi(hh`wv'hhmdebt_4) & !mi(hh`wv'hhmdebt_5) & !mi(hh`wv'hhmdebt_6) & !mi(hh`wv'hhmdebt_7) & !mi(hh`wv'hhmdebt_8) & !mi(hh`wv'hhmdebt_9) & !mi(hh`wv'hhmdebt_10) & !mi(hh`wv'hhmdebt_11) & !mi(hh`wv'hhmdebt_12) & !mi(hh`wv'hhmdebt_13) & !mi(hh`wv'hhmdebt_14) & !mi(hh`wv'hhmdebt_15) & !mi(hh`wv'hhmdebt_16)
label variable hh`wv'afloa "hh`wv'afloa:w`wv' Asset: value of other HH members financial debt"

drop hh`wv'hhmdebt_1 hh`wv'hhmdebt_2 hh`wv'hhmdebt_3 hh`wv'hhmdebt_4 hh`wv'hhmdebt_5 hh`wv'hhmdebt_6 hh`wv'hhmdebt_7 hh`wv'hhmdebt_8 hh`wv'hhmdebt_9 hh`wv'hhmdebt_10 hh`wv'hhmdebt_11 hh`wv'hhmdebt_12 hh`wv'hhmdebt_13 hh`wv'hhmdebt_14 hh`wv'hhmdebt_15 hh`wv'hhmdebt_16

*****************************************************
****NET value of other HH members of financial asset
gen hh`wv'afhhm = .
missing_H hh`wv'afsst hh`wv'afloa, result(hh`wv'afhhm)
replace hh`wv'afhhm = hh`wv'afsst - hh`wv'afloa if !mi(hh`wv'afsst) & !mi(hh`wv'afloa)
label variable hh`wv'afhhm "hh`wv'afhhm:w`wv' Asset: net value of other HH members financial asset"

****************************************************************
***SUMMARY *****************************************************
****************************************************************

***************************************************
****18. Net value of non-housing financial wealth
***************************************************
gen hh`wv'atotf = .
missing_H h`wv'atotf hh`wv'aploan hh`wv'afhhm, result(hh`wv'atotf)
replace hh`wv'atotf = .i if hh`wv'aploan == .i
replace hh`wv'atotf = .b if h`wv'atotf == .b
replace hh`wv'atotf = h`wv'atotf + hh`wv'aploan + hh`wv'afhhm if !mi(h`wv'atotf) & !mi(hh`wv'aploan) & !mi(hh`wv'afhhm)
label variable hh`wv'atotf "hh`wv'atotf:w`wv' Asset: hh net value of non-housing financial wealth"

**************************************************
****19. Total wealth*****************************
gen hh`wv'atotb = .
missing_H hh`wv'arles hh`wv'atoth hh`wv'atran hh`wv'adurbl hh`wv'afixc hh`wv'aland hh`wv'aagri hh`wv'atotf, result(hh`wv'atotb)
replace hh`wv'atotb = .i if hh`wv'atotf == .i
replace hh`wv'atotb = .b if hh`wv'atotf == .b
replace hh`wv'atotb = hh`wv'arles + hh`wv'atoth + hh`wv'atran + hh`wv'adurbl + hh`wv'afixc + hh`wv'aland + hh`wv'aagri + hh`wv'atotf if ///
                    !mi(hh`wv'arles) & !mi(hh`wv'atoth) & !mi(hh`wv'atran) & !mi(hh`wv'adurbl) & !mi(hh`wv'afixc) & !mi(hh`wv'aland) & !mi(hh`wv'aagri) & !mi(hh`wv'atotf)
label variable hh`wv'atotb "hh`wv'atotb:w`wv' Asset: hh total wealth"



***drop CHARLS demog file raw variables
drop `asset_w1_demog'

****drop CHARLS individual income raw variables***
drop `asset_w1_indinc'

****drop CHARLS household income raw variables***
drop `asset_w1_hhinc'

***drop CHARS houshold roster raw variables***
drop `asset_w1_hhroster'

****drop CHARLS household characteristics raw variables***
drop `asset_w1_house'

****drop CHARLS PSU raw file***
drop `asset_w1_psu'

***Work***
label define work ///
 0 "0.no" /// 
 1 "1.yes" ///
 .w ".w:not working" ///
 .d ".d:DK" ///
 .m ".m:Missing" ///
 .s ".s:skip" ///
 .r ".r:RF"
 
***Employee** 
label define slfemp ///
 0 "0.not self-employed" ///
 1 "1.self-employed" ///
 .w ".w:not working" ///
 .d ".d:DK" ///
 .m ".m:Missing" ///
 .s ".s:skip" ///
 .r ".r:RF"
 
**How you get paid***
label define paid ///
 1 "1.Yearly salary" ///
 2 "2.Monthly salary" ///
 3 "3.Weekly salary " ///
 4 "4.Daily salary " ///
 5 "5.Hourly salary" ///
 6 "6.Contract-based" ///
 7 "7.Performance-based" ///
 8 "8.Other"
 
***work status***
label define status ///
 1 "1.Farming"  ///
 2 "2.Employed" ///
 3 "3.Self-employed"  ///
 4 "4.Unpaid family business" ///
 5 "5.Unemployed" ///
 6 "6.Retired"  ///
 7 "7.Not in labor force" ///
 .w ".w:not working" ///
 .d ".d:DK" ///
 .m ".m:Missing" ///
 .s ".s:skip" ///
 .r ".r:RF"
 

*set wave number
local wv=1
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2

***merge with work file***
local employ_w1_work fa001 fa002 fa003 fa005 fa006 fa007 fa008 ///
                     fb002 fb011 fb012 ///
                     fc001 fc004 fc005 fc006 fc008 fc009 fc010 ///
                     fc011 fc014 fc015 fc017 fc019 fc020 fc021 ///
                     fd001 fd002 fd011_1 ///
                     fe001 fe002 fe003 ///
                     fh001 fh002 fh003 fh008_1 ///
                     fj001 fj002 fk002
merge 1:1 ID using "`wave_1_work'", keepusing(`employ_w1_work') 
drop if _merge==2
drop _merge

 

****Working status***
*respondent
gen r`wv'wstat =.
missing_c_w1 fa001 fa002 fa003 fa005 fb011 fc014 fc015 fc017 fc019 fc020 fc021 fk002, result(r`wv'wstat)
replace r`wv'wstat = 1 if fa001 == 1     // engage in agricultural work for more than 10 days in the past year

replace r`wv'wstat = 7 if fa001 == 2 & fa002 == 2 & (fa003 == 2 | fa005 == 2)  // currently not working
replace r`wv'wstat = 5 if fa001 == 2 & fa002 == 2 & (fa003 == 2 | fa005 == 2) & fk002 == 1 // currently not working, reports looking for work
replace r`wv'wstat = 6 if fa001 == 2 & fa002 == 2 & (fa003 == 2 | fa005 == 2) & fb011 == 1 // currently not working, reports retirement
      
replace r`wv'wstat = 4 if fc020 == 3     // besides farming, with more than one job, main job : (3) unpaid family business employed 
replace r`wv'wstat = 3 if fc020 == 2     // besides farming, with more than one job, main job : (2) self employed employed 
replace r`wv'wstat = 2 if fc020 == 1     // besides farming, with more than one job, main job : (1) employed 

replace r`wv'wstat = 4 if fc021 == 3     // besides farming, with only one job, main job : (3) unpaid family business employed 
replace r`wv'wstat = 3 if fc021 == 2     // besides farming, with only one job, main job : (2) self employed employed 
replace r`wv'wstat = 2 if fc021 == 1     // besides farming, with only one job, main job : (1) employed

***Labor Force Status***
*respondent
gen r`wv'lbrf_c =.
missing_H r`wv'wstat, result(r`wv'lbrf_c)
replace r`wv'lbrf_c = 1  if r`wv'wstat == 1
replace r`wv'lbrf_c = 2  if r`wv'wstat == 2
replace r`wv'lbrf_c = 3  if r`wv'wstat == 3 
replace r`wv'lbrf_c = 4  if r`wv'wstat == 4  
replace r`wv'lbrf_c = 5  if r`wv'wstat == 5
replace r`wv'lbrf_c = 6  if r`wv'wstat == 6
replace r`wv'lbrf_c = 7  if r`wv'wstat == 7
label variable r`wv'lbrf_c "r`wv'lbrf_c:w`wv' R labor force status"
label value r`wv'lbrf_c status 

*spouse
gen s`wv'lbrf_c =.
spouse r`wv'lbrf_c, result(s`wv'lbrf_c) wave(`wv')
label variable s`wv'lbrf_c "s`wv'lbrf_c:w`wv' S labor force status"
label value s`wv'lbrf_c status

***Currently working***
*respondent
gen r`wv'work=.
missing_H r`wv'wstat, result(r`wv'work)
replace r`wv'work = 0 if inlist(r`wv'wstat,5,6,7)
replace r`wv'work = 1 if inlist(r`wv'wstat,1,2,3,4)
label variable r`wv'work "r`wv'work:w1 r currently working"
label value r`wv'work work

*spouse 
gen s`wv'work =.
spouse r`wv'work, result(s`wv'work) wave(`wv')
label variable s`wv'work "s`wv'work:w`wv' S currently working"
label value s`wv'work work

*** currently working FOR PAY
*respondent
gen r`wv'workpay=.
missing_H r`wv'wstat, result(r`wv'workpay)
replace r`wv'workpay = 0 if inlist(r`wv'wstat,4, 5,6,7)
replace r`wv'workpay = 1 if inlist(r`wv'wstat,1,2,3)
label variable r`wv'workpay "r`wv'work:w1 r currently working for pay"
label value r`wv'workpay workpay

*spouse 
gen s`wv'workpay =.
spouse r`wv'workpay, result(s`wv'workpay) wave(`wv')
label variable s`wv'workpay "s`wv'work:w`wv' S currently working for pay"
label value s`wv'workpay workpay

***Works 2nd Job****
*respondent
gen r`wv'work2=.
missing_c_w1 fa001 fa002 fa003 fa005 fa006 fa007 fa008 fc014 fc015 fc017 fc019 fj001, result(r`wv'work2)
replace r`wv'work2 =.w if r`wv'work == 0
replace r`wv'work2 = 0 if fc019 == 2 | (fc014 == 2  & (fc015 == 1 & fc017 == 2) | fc015 == 2)
replace r`wv'work2 = 1 if inrange(fj001,1,20)
label variable r`wv'work2 "r`wv'work2:w`wv' R works more than one job"
label values r`wv'work2 work

*spouse 
gen s`wv'work2 =.
spouse r`wv'work2, result(s`wv'work2) wave(`wv')
label variable s`wv'work2 "s`wv'work2:w`wv' S works more than one job"
label values s`wv'work2 work

***Whether self-employed***
*respondent
gen r`wv'slfemp=.
replace r`wv'slfemp=.m if inw`wv' == 1
replace r`wv'slfemp=0 if inlist(r`wv'wstat,1,2,4,5,6,7)
replace r`wv'slfemp=1 if r`wv'wstat==3
label variable r`wv'slfemp "r`wv'slfemp:w`wv' R whether self-employed"
label values r`wv'slfemp slfemp

*spouse 
gen s`wv'slfemp =.
spouse r`wv'slfemp, result(s`wv'slfemp) wave(`wv')
label variable s`wv'slfemp "s`wv'slfemp:w`wv' S whether self-employed"
label values s`wv'slfemp work

***Whether retired***
*respondent
gen r`wv'retemp=.
replace r`wv'retemp=.m if inw`wv' == 1
replace r`wv'retemp=0  if inlist(r`wv'lbrf_c,1,2,3,4,5,7)
replace r`wv'retemp=1  if r`wv'lbrf_c==6
label variable r`wv'retemp "r`wv'retemp:w`wv' R whether retired"
label value r`wv'retemp work

*spouse  
gen s`wv'retemp =.
spouse r`wv'retemp, result(s`wv'retemp) wave(`wv')
label variable s`wv'retemp "s`wv'retemp:w`wv' S whether retired"
label value s`wv'retemp work   

***Months worked per year (employed by others)***
*respondent
gen r`wv'wmemp=.
missing_c_w1 fe001, result(r`wv'wmemp)
replace r`wv'wmemp = .w if r`wv'work == 0
replace r`wv'wmemp = 0 if inlist(r`wv'wstat,1,3,4)
replace r`wv'wmemp = fe001 if inrange(fe001,0,12)
label variable r`wv'wmemp "r`wv'wmemp:w`wv' R work how many months per year (employed by other)"/*for the work place not dispatch work unit*/

*spouse 
gen s`wv'wmemp =.
spouse r`wv'wmemp, result(s`wv'wmemp) wave(`wv')
label variable s`wv'wmemp "s`wv'wmemp:w`wv' S work how many months per year (employed by other)"

****Days worked per week (employed by others)*****
*respondent
gen r`wv'wdemp=.
missing_c_w1 fe002, result( r`wv'wdemp)
replace r`wv'wdemp = .w if r`wv'work == 0
replace r`wv'wdemp = 0 if inlist(r`wv'wstat,1,3,4)
replace r`wv'wdemp=fe002 if inrange(fe002,0,7)
label variable r`wv'wdemp "r`wv'wdemp:w`wv' R work how many days per week (employed by other)"

*spouse 
gen s`wv'wdemp =.
spouse r`wv'wdemp, result(s`wv'wdemp) wave(`wv')
label variable s`wv'wdemp "s`wv'wdemp:w`wv' S work how many days per week (employed by other)"

****Hours worked per day (employed by others)****
*respondent
gen r`wv'whemp=.
missing_c_w1 fe003, result(r`wv'whemp)
replace r`wv'whemp = .w if r`wv'work == 0
replace r`wv'whemp = 0 if inlist(r`wv'wstat,1,3,4)
replace r`wv'whemp=fe003 if inrange(fe003,0,24)
label variable r`wv'whemp "r`wv'whemp:w`wv' R work how many hours per day (employed by other)"/*for the work place not dispatch work unit*/

*spouse 
gen s`wv'whemp =.
spouse r`wv'whemp, result(s`wv'whemp) wave(`wv')
label variable s`wv'whemp "s`wv'whemp:w`wv' S work how many hours per day"

****hours worked per week (employed by others)*******
*respondent
gen r`wv'emphw=.
missing_H r`wv'wdemp r`wv'whemp, result(r`wv'emphw)
replace r`wv'emphw = .w if r`wv'work == 0
replace r`wv'emphw=r`wv'wdemp*r`wv'whemp if !mi(r`wv'wdemp) & !mi(r`wv'whemp)
label variable r`wv'emphw "r`wv'emphw:w`wv' R hours worked per week:employed"

*spouse 
gen s`wv'emphw =.
spouse r`wv'emphw, result(s`wv'emphw) wave(`wv')
label variable s`wv'emphw "s`wv'emphw:w`wv' S hours worked per week:employed"

drop r`wv'wdemp r`wv'whemp
drop s`wv'wdemp s`wv'whemp

****Months worked per year (self-employed)****
*respondent
gen r`wv'wmsef=.
missing_c_w1 fh001, result(r`wv'wmsef)
replace r`wv'wmsef = .w if r`wv'work == 0
replace r`wv'wmsef = 0 if inlist(r`wv'wstat,1,2,4)
replace r`wv'wmsef = fh001 if inrange(fh001,0,12)
label variable r`wv'wmsef "r`wv'wmsef:w`wv' R work how many months per year"

*spouse 
gen s`wv'wmsef =.
spouse r`wv'wmsef, result(s`wv'wmsef) wave(`wv')
label variable s`wv'wmsef "s`wv'wmsef:w`wv' S work how many months per year"

****Days worked per week (self-employed)*****
*respondent
gen r`wv'wdsef=.
missing_c_w1 fh002, result(r`wv'wdsef)
replace r`wv'wdsef = .w if r`wv'work == 0
replace r`wv'wdsef = 0 if inlist(r`wv'wstat,1,2,4)
replace r`wv'wdsef = fh002 if inrange(fh002,0,7)
replace r`wv'wdsef = 7 if inrange(fh002,8,30)
label variable r`wv'wdsef "r`wv'wdsef:w`wv' R work how many days per week "

*spouse 
gen s`wv'wdsef =.
spouse r`wv'wdsef, result(s`wv'wdsef) wave(`wv')
label variable s`wv'wdsef "s`wv'wdsef:w`wv' S work how many days per week "

****hours worked per day (self-employed)***
*respondent
gen r`wv'whsef=.
missing_c_w1 fh003, result(r`wv'whsef)
replace r`wv'whsef = .w if r`wv'work == 0
replace r`wv'whsef = 0 if inlist(r`wv'wstat,1,2,4)
replace r`wv'whsef = fh003 if inrange(fh003,0,24)
label variable r`wv'whsef "r`wv'whsef:w`wv' R self-employed how many hours a day"

*spouse 
gen s`wv'whsef =.
spouse r`wv'whsef, result(s`wv'whsef) wave(`wv')
label variable s`wv'whsef "s`wv'whsef:w`wv' S self-employed how many hours a day"

****hours worked per week (self-employed)*****
*respondent
gen r`wv'sefhw=.
missing_H r`wv'wdsef r`wv'whsef, result(r`wv'sefhw)
replace r`wv'sefhw = .w if r`wv'work == 0
replace r`wv'sefhw = r`wv'wdsef*r`wv'whsef if !mi(r`wv'wdsef) & !mi(r`wv'whsef)

*spouse 
gen s`wv'sefhw =.
spouse r`wv'sefhw, result(s`wv'sefhw) wave(`wv')
label variable s`wv'sefhw "s`wv'sefhw:w`wv' S hours worked per week:self-employed"

drop r`wv'wdsef r`wv'whsef
drop s`wv'wdsef s`wv'whsef

****Months worked per year (other farm work)****
*respondent
gen r`wv'wmofam=.
missing_c_w1 fc004, result(r`wv'wmofam)
replace r`wv'wmofam = .w if r`wv'work == 0
replace r`wv'wmofam = 0 if fc001 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'wmofam = fc004 if inrange(fc004,0,12)
label variable r`wv'wmofam "r`wv'wmofam:w`wv' R work how many months per year"

*spouse 
gen s`wv'wmofam =.
spouse r`wv'wmofam, result(s`wv'wmofam) wave(`wv')
label variable s`wv'wmofam "s`wv'wmofam:w`wv' S work how many months per year"

****Days worked per week (other farm work)*****
*respondent
gen r`wv'wdofam=.
missing_c_w1 fc005, result(r`wv'wdofam)
replace r`wv'wdofam = .w if r`wv'work == 0
replace r`wv'wdofam = 0 if fc001 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'wdofam = fc005 if inrange(fc005,0,7)
label variable r`wv'wdofam "r`wv'wdofam:w`wv' R work how many days per week "

*spouse 
gen s`wv'wdofam =.
spouse r`wv'wdofam, result(s`wv'wdofam) wave(`wv')
label variable s`wv'wdofam "s`wv'wdofam:w`wv' S work how many days per week "

*****Hours worked per day (other farm work)****
*respondent
gen r`wv'whofam=.
missing_c_w1 fc006, result(r`wv'whofam)
replace r`wv'whofam = .w if r`wv'work == 0
replace r`wv'whofam = 0 if fc001 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'whofam = fc006 if inrange(fc006,0,24)
label variable r`wv'whofam "r`wv'whofam:w`wv' R farming at other farm how many hours a day"

*spouse 
gen s`wv'whofam =.
spouse r`wv'whofam, result(s`wv'whofam) wave(`wv')
label variable s`wv'whofam "s`wv'whofam:w`wv' S farming at farm other how many hours a day"

****hours worked per week (other farm work)*****
*respondent
gen r`wv'ofamhw=.
missing_H r`wv'wdofam r`wv'whofam, result(r`wv'ofamhw)
replace r`wv'ofamhw = .w if r`wv'work == 0
replace r`wv'ofamhw = r`wv'wdofam*r`wv'whofam if !mi(r`wv'wdofam) & !mi(r`wv'whofam)
label variable r`wv'ofamhw "r`wv'ofamhw:w`wv' R hours worked per week:other farm"

*spouse 
gen s`wv'ofamhw =.
spouse r`wv'ofamhw, result(s`wv'ofamhw) wave(`wv')
label variable s`wv'ofamhw "s`wv'ofamhw:w`wv' S hours worked per week:other farm"

drop r`wv'wdofam r`wv'whofam
drop s`wv'wdofam s`wv'whofam

****Months worked per year (own farm)***
*respondent
gen r`wv'wmsfam=.
missing_c_w1 fc009, result(r`wv'wmsfam)
replace r`wv'wmsfam = .w if r`wv'work == 0
replace r`wv'wmsfam = 0 if fc008 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'wmsfam = fc009 if inrange(fc009,0,12)
label variable r`wv'wmsfam "r`wv'wmsfam:w`wv' R work how many months per year"

*spouse 
gen s`wv'wmsfam =.
spouse r`wv'wmsfam, result(s`wv'wmsfam) wave(`wv')
label variable s`wv'wmsfam "s`wv'wmsfam:w`wv' S work how many months per year"

****Days worked per week (own farm) *****
*respondent
gen r`wv'wdsfam=.
missing_c_w1 fc010, result(r`wv'wdsfam)
replace r`wv'wdsfam = .w if r`wv'work == 0
replace r`wv'wdsfam = 0 if fc008 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'wdsfam = fc010 if inrange(fc010,0,7)
label variable r`wv'wdsfam "r`wv'wdsfam:w`wv' R work how many days per week "

*spouse 
gen s`wv'wdsfam =.
spouse r`wv'wdsfam, result(s`wv'wdsfam) wave(`wv')
label variable s`wv'wdsfam "s`wv'wdsfam:w`wv' S work how many days per week "

*****Hours worked per day (own farm)*****
*respondent
gen r`wv'whsfam=.
missing_c_w1 fc011, result(r`wv'whsfam)
replace r`wv'whsfam = .w if r`wv'work == 0
replace r`wv'whsfam = 0 if fc008 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'whsfam = fc011 if inrange(fc011,0,24)
label variable r`wv'whsfam "r`wv'whsfam:w`wv' R farming at other farm how many hours a day"

*spouse 
gen s`wv'whsfam =.
spouse r`wv'whsfam, result(s`wv'whsfam) wave(`wv')
label variable s`wv'whsfam "s`wv'whsfam:w`wv' S farming at farm other how many hours a day"

****Days worked per week (own farm)*****
*respondent
gen r`wv'sfamhw=.
missing_H r`wv'wdsfam r`wv'whsfam, result(r`wv'sfamhw)
replace r`wv'sfamhw = .w if r`wv'work == 0
replace r`wv'sfamhw = r`wv'wdsfam*r`wv'whsfam if !mi(r`wv'wdsfam) & !mi(r`wv'whsfam)
label variable r`wv'sfamhw "r`wv'sfamhw:w`wv' R hours worked per week:own farm"

*wave 1 spouse 
gen s`wv'sfamhw =.
spouse r`wv'sfamhw, result(s`wv'sfamhw) wave(`wv')
label variable s`wv'sfamhw "s`wv'sfamhw:w`wv' S hours worked per week:own farm"

drop r`wv'wdsfam r`wv'whsfam
drop s`wv'wdsfam s`wv'whsfam

***Hours worked per week (all farm work)***
*respondent
gen r`wv'farmhw = .
missing_H r`wv'ofamhw r`wv'sfamhw, result(r`wv'farmhw)
replace r`wv'farmhw = .w if r`wv'work == 0
replace r`wv'farmhw = r`wv'ofamhw if !mi(r`wv'ofamhw) & mi(r`wv'sfamhw)
replace r`wv'farmhw = r`wv'sfamhw if !mi(r`wv'sfamhw) & mi(r`wv'ofamhw)
replace r`wv'farmhw = r`wv'sfamhw if r`wv'sfamhw == r`wv'ofamhw & !mi(r`wv'ofamhw) & !mi(r`wv'sfamhw)
replace r`wv'farmhw = r`wv'sfamhw if r`wv'sfamhw > r`wv'ofamhw & !mi(r`wv'ofamhw) & !mi(r`wv'sfamhw)
replace r`wv'farmhw = r`wv'ofamhw if r`wv'ofamhw > r`wv'sfamhw & !mi(r`wv'ofamhw) & !mi(r`wv'sfamhw)

drop r`wv'ofamhw r`wv'sfamhw 
drop s`wv'ofamhw s`wv'sfamhw 

***Hours worked per week (summary for main job)***
*respondent
gen r`wv'jhours_c =.
missing_H r`wv'emphw r`wv'sefhw r`wv'farmhw, result(r`wv'jhours_c)
replace r`wv'jhours_c = .w if r`wv'work == 0 
replace r`wv'jhours_c = .f if r`wv'wstat == 4
replace r`wv'jhours_c = r`wv'emphw if r`wv'wstat == 2 & !mi(r`wv'emphw)
replace r`wv'jhours_c = r`wv'sefhw if r`wv'wstat == 3 & !mi(r`wv'sefhw)
replace r`wv'jhours_c = r`wv'farmhw if r`wv'wstat == 1 & !mi(r`wv'farmhw)
label variable r`wv'jhours_c "r`wv'jhours_c:w`wv' R total hours worked per week on main job"

*spouse 
gen s`wv'jhours_c =.
spouse r`wv'jhours_c, result(s`wv'jhours_c) wave(`wv')
label variable s`wv'jhours_c "s`wv'jhours_c:w`wv' S total hours worked per week on main job"

drop r`wv'emphw r`wv'sefhw 
drop s`wv'emphw s`wv'sefhw  
drop r`wv'farmhw

****Hours worked per week (summary for other jobs)***
*respondent
gen r`wv'jhour2=.
missing_c_w1 fj002, result(r`wv'jhour2)
replace r`wv'jhour2 = .w if r`wv'work == 0 | r`wv'work2 == 0
replace r`wv'jhour2 = fj002 if inrange(fj002,0,168)
replace r`wv'jhour2 = 168 if inrange(fj002,169,200)
label variable r`wv'jhour2"r`wv'jhour2:w`wv' R hours worked/week on other jobs"

*spouse 
gen s`wv'jhour2=.
spouse r`wv'jhour2, result(s`wv'jhour2) wave(`wv')
label variable s`wv'jhour2"s`wv'jhour2:w`wv' S hours worked/week on other jobs"

*** Hours worked per week (main job + other jobs) *** 
gen r`wv'jhourstot=. 
missing_H r`wv'jhours_c r`wv'jhour2, result(r`wv'jhourstot)
replace r`wv'jhourstot = r`wv'jhours_c if !mi(r`wv'jhours_c) & mi(r`wv'jhour2) 
replace r`wv'jhourstot = r`wv'jhour2   if !mi(r`wv'jhour2) & mi(r`wv'jhours_c)
replace r`wv'jhourstot = r`wv'jhours_c + r`wv'jhour2 if !mi(r`wv'jhours_c) & !mi(r`wv'jhour2)
label variable r`wv'jhourstot "r`wv'jhourstot:w`wv' R total hours worked per week on main job and side jobs"

***Weeks worked per year (all farm work)***
*respondent
gen r`wv'wmfarm =.
missing_H r`wv'wmofam r`wv'wmsfam, result(r`wv'wmfarm)
replace r`wv'wmfarm =.w if r`wv'work == 0
replace r`wv'wmfarm = r`wv'wmofam if !mi(r`wv'wmofam) & mi(r`wv'wmsfam)
replace r`wv'wmfarm = r`wv'wmsfam if !mi(r`wv'wmsfam) & mi(r`wv'wmofam)
replace r`wv'wmfarm = r`wv'wmsfam if r`wv'wmsfam == r`wv'wmofam & !mi(r`wv'wmsfam) & !mi(r`wv'wmofam)
replace r`wv'wmfarm = r`wv'wmsfam if r`wv'wmsfam > r`wv'wmofam & !mi(r`wv'wmsfam) & !mi(r`wv'wmofam)
replace r`wv'wmfarm = r`wv'wmofam if r`wv'wmofam > r`wv'wmsfam & !mi(r`wv'wmsfam) & !mi(r`wv'wmofam)

drop r`wv'wmofam 
drop s`wv'wmofam

drop r`wv'wmsfam 
drop s`wv'wmsfam

*weeks worked per year (summary for main job)
*respondent
gen r`wv'jweeks_c =.
missing_H r`wv'wmemp r`wv'wmsef r`wv'wmfarm, result(r`wv'jweeks_c)
replace r`wv'jweeks_c = .w if r`wv'work == 0
replace r`wv'jweeks_c = .f if r`wv'wstat == 4
replace r`wv'jweeks_c = r`wv'wmemp*4.33 if r`wv'wstat==2 & !mi(r`wv'wmemp)
replace r`wv'jweeks_c = r`wv'wmsef*4.33 if r`wv'wstat == 3 & !mi(r`wv'wmsef)
replace r`wv'jweeks_c = r`wv'wmfarm*4.33 if r`wv'wstat == 1 & !mi(r`wv'wmfarm)
label variable r`wv'jweeks_c "r`wv'jweeks_c:w`wv' R weeks worked per year on main job"

*wave 1 spouse 
gen s`wv'jweeks_c =.
spouse r`wv'jweeks_c, result(s`wv'jweeks_c) wave(`wv')
label variable s`wv'jweeks_c "s`wv'jweeks_c:w`wv' S weeks worked per year on main job"

drop r`wv'wmemp
drop s`wv'wmemp
drop r`wv'wmsef
drop s`wv'wmsef
drop r`wv'wmfarm


*********************************************************
****====Years of tenure on current job====****
*wave 1 respondent years of tenure on current job employed
*gen r`wv'jcten=.
*replace r`wv'jcten = .m if fd011_1==. |fh008_1==.
*replace r`wv'jcten = .w if r`wv'work ==0
*replace r`wv'jcten = .s if r`wv'retemp==1 
*replace r`wv'jcten = .d if fd011_1==.d |fh008_1==.d
*replace r`wv'jcten = .r if fd011_1==.r |fh008_1==.r
*replace r`wv'jcten = (r`wv'iwy-fd011_1) if inrange(fd011_1,1900,2011)
*replace r`wv'jcten = (r`wv'iwy-fh008_1) if inrange(fh008_1,1900,2011) & fd011_1==. 
*label variable r`wv'jcten "r`wv'jcten:w`wv' Current Job Tenure (employed or self employed)"
*
**wave 1 spouse years of tenure on current job
*gen s`wv'jcten=.
*spouse r`wv'jcten, result(s`wv'jcten) wave(`wv')
*label variable s`wv'jcten "s`wv'jcten:w`wv' Current Job Tenure (employed or self employed)"

drop r`wv'wstat


****drop CHARLS work raw variables***
drop `employ_w1_work'

***income***
label define income ///
   0 "0.no"  ///
   1 "1.yes" ///
   .r ".r:Refuse" ///
	 .m ".m:Missing" ///
	 .d ".d:DK" ///
	 .s ".s:Skipped" ///
	 .p ".p:Proxy" ///
	 .u ".u:Unmar" ///
	 .e ".e:Error"


	 	 



*set wave number
local wv=1 
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2

***merge with household income file***
local inc_w1_hhinc ga005_?_ ga005_1?_ ///
                   ga006_1_?_ ga006_1_1?_  ga006_2_?_ ga006_2_1?_ ///
                   ga007_?_s? ga007_?_s1? ///
                   ga007_1?_s? ga007_1?_s1? ///
                   ga007_2?_s? ga007_2?_s1? ///
                   ga008_1_a_?_ ga008_1_a_26_ ga008_1_b_?_ ga008_1_b_26_ ///
                   ga008_2_a_3_ ga008_2_a_4_ ga008_2_b_3_ ga008_2_b_4_ ///
                   ga008_3_a_?_ ga008_3_a_11_ ga008_3_b_?_ ga008_3_b_11_ ///
                   ga008_4_a_?_ ga008_4_b_?_ ///
                   ga008_5_a_?_ ga008_5_b_?_ ///
                   ga008_6_a_?_ ga008_6_a_26_ ga008_6_b_?_ ga008_6_b_26_ ///
                   ga008_7_a_?_ ga008_7_b_?_ ///
                   ga008_8_a_?_ ga008_8_b_?_ ///
                   ga008_9_a_?_ ga008_9_b_?_ ///
                   gb001 gb002_?_ gb002_1?_ gb003 gb005 gb006 gb007 gb008 gb009 ///
                   gb010 gb011 gb012 gb013 ///
                   gc001 ///
                   gc002 ///
                   gc005_1_ gc005_2_ gc005_3_ ///
                   gd001 gd001_c gd002_1 gd002_2 gd002_3 gd002_4 gd002_5 gd002_6 gd002_7 ///
                   gd002s1 gd002s2 gd002s3 gd002s4 gd002s5 gd002s6 gd002s7 gd002s8 ///
                   gd003_1 gd003s1 gd003_2 gd003s2 gd003_3 gd003s3 gd003s4 ///
                   ge004 ge006 ge007 ge008 ///
                   ge009_1 ge009_2 ge009_3 ge009_4 ge009_5 ge009_6 ge009_7 ///
                   ge010_1 ge010_2 ge010_3 ge010_4 ge010_5 ge010_6 ge010_7 ///
                   ge010_8 ge010_9 ge010_10 ge010_11 ge010_12 ge010_13 ge010_14 ///
                   ha027 ha028 ///
                   ha052 ha052_1 ///
                   ha053 ha053_1 ha054s1 ha054s2 ha054s3 ha054s4 ha054s5 ///
                   ha058_1_ ha058_2_ ha058_3_ ha058_4_ ///
                   ha060_1_ ha060_2_ ha060_3_ ha060_4_ ///  
                   ha064 ha064_1 ///
                   ha069 ///
                   ha071
merge m:1 householdID using "`wave_1_hhinc'", keepusing(`inc_w1_hhinc') 
drop if _merge==2
drop _merge

***merge with individual income file***
local inc_w1_indinc ga001 ga002 ga002_1 ///
                    ga003s1 ga003s2 ga003s3 ga003s4 ga003s5 ga003s6 ga003s7 ga003s8 ga003s9 ga003s10  ///
                    ga004_1_1_ ga004_1_2_ ga004_1_3_ ga004_1_4_ ga004_1_5_ ga004_1_6_ ga004_1_7_ ga004_1_8_ ga004_1_9_ ///
                    ga004_2_1_ ga004_2_2_ ga004_2_3_ ga004_2_4_ ga004_2_5_ ga004_2_6_ ga004_2_7_ ga004_2_8_ ga004_2_9_ ///
                    hc010 hc011 hc012 hc012_2 hc015 hc016 hc017 hc023 hc024 
merge 1:1 ID using "`wave_1_indinc'", keepusing(`inc_w1_indinc') 
drop if _merge==2
drop _merge

***merge with work file***
local inc_w1_work fa001 fa002 fa003 fa005 fa006 fa007 fa008 ///
                     fb011 fb012 ///
                     fc001 fc004 fc005 fc006 fc007 fc008 fc009 fc010 ///
                     fc011 fc014 fc015 fc017 fc019 fc020 fc021 ///
                     fd001 fd011_1 ///
                     fe001 fe002 fe003 ///
                     ff001 ff002 ff004 ff006 ff008 ff010 ff012 ff014 ///
                     fg001s? fg001s1? fg002_?_ fg002_10_ ///
                     fh001 fh002 fh003 fh008_1 fh009 fh010 ///
                     fj001 fj002 fj003 fk002 ///
                     fm011 fm018_? fm019s? fm022 fm030_? fm033 fm034 ///
                     fn001 fn002s? fn003_? fn004 fn006_? fn007 fn012_? fn013 fn017_? fn018 fn021_? fn022 ///
                     fn071 fn077 fn078_? fn079
merge 1:1 ID using "`wave_1_work'", keepusing(`inc_w1_work') 
drop if _merge==2
drop _merge

***merge with weight file***
local inc_w1_weight iyear imonth
merge 1:1 ID using "`wave_1_weight'", keepusing(`inc_w1_weight') 
drop if _merge==2
drop _merge

***merge with household roster file***
local inc_w1_hhroster a002_?_ a002_1?_ /// 
                      a006_?_ a006_1?_ ///
                      a016_?_ a016_1?_ a017_?_ a017_1?_
merge m:1 householdID using "`wave_1_hhroster'", keepusing(`inc_w1_hhroster') 
drop if _merge==2
drop _merge


******************************************************************************************
****************************************
****                               *****     
**** INDIVIDUAL INCOME r+s       *****
****                               *****
****************************************


***************************************
***                                 ***
*** 1. R+S INDIVIDUAL WAGE INCOME   ***
***                                 ***
***************************************

*** 1.1.1  Respondent&Spouse Wage Income From Income Module  ***

*******Individual Earnings***** 
*wave 1 respondent earnings
gen r`wv'iowagei=.
missing_c_w1 ga001, result(r`wv'iowagei)
replace r`wv'iowagei = 0 if ga001==2
replace r`wv'iowagei = 1 if ga001==1
label variable r`wv'iowagei "r`wv'iowagei:w`wv' income: r wage and bonus from income module"
label value r`wv'iowagei income

*wave 1 spouse earnings
gen s`wv'iowagei =.
spouse r`wv'iowagei, result(s`wv'iowagei) wave(1)
label variable s`wv'iowagei "s`wv'iowagei:w`wv' income: s wage and bonus from income module"
label value s`wv'iowagei income

*wave 1 respondent earnings
gen r`wv'iwagei=.
missing_H r`wv'iowagei, result(r`wv'iwagei)
missing_c_w1 ga002_1 ga002, result(r`wv'iwagei)
replace r`wv'iwagei = 0 if r`wv'iowagei== 0
replace r`wv'iwagei = ga002_1 * 12 if inrange(ga002_1,0,50000)
replace r`wv'iwagei = ga002 if inrange(ga002,0,300000)
label variable r`wv'iwagei "r`wv'iwagei:w`wv' income: r wage and bonus from income module"

*wave 1 spouse earnings
gen s`wv'iwagei =.
spouse r`wv'iwagei, result(s`wv'iwagei) wave(1)
label variable s`wv'iwagei "s`wv'iwagei:w`wv' income: s wage and bonus from income module"

**H earnings
gen h`wv'iwagei= .
household r`wv'iwagei s`wv'iwagei, result(h`wv'iwagei)
label variable h`wv'iwagei "h`wv'iwagei:w`wv' income: hhold wage and bonus from income module(couple level)"

drop r`wv'iowagei s`wv'iowagei

**********************************************
** 1.2 Respondent & Spouse Income From Work Module   **
** 1.2.1 Income from Agricultural-related Activities **
*respondent
gen r`wv'ifmemp=.
missing_H r`wv'work, result(r`wv'ifmemp)
missing_c_w1 fc001 fc004 fc007, result(r`wv'ifmemp)
replace r`wv'ifmemp = 0 if r`wv'work == 0 | fc001 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'ifmemp=fc007*fc004 if inrange(fc007,0,99999) & inrange(fc004,0,12)
label variable r`wv'ifmemp "r`wv'ifmemp:w`wv' income: r agricultural-related activities income from work module"

*spouse
gen s`wv'ifmemp =.
spouse r`wv'ifmemp, result(s`wv'ifmemp) wave(1)
label variable s`wv'ifmemp "s`wv'ifmemp:w`wv' income: s agricultural-related activities income from work module"

*household
gen h`wv'ifmemp= .
household r`wv'ifmemp s`wv'ifmemp, result(h`wv'ifmemp)
label variable h`wv'ifmemp "h`wv'ifmemp:w`wv' income: hhold agricultural-related activities income from work module"

**==1.2.2 Income from Non-agricultural Job==*
** Yearly Wage Income From Work Module
*respondent
gen r`wv'iwagea=.
missing_H r`wv'lbrf_c, result(r`wv'iwagea)
missing_c_w1 fe001 fe002 fe003 ff002 ff004 ff006 ff008 ff010 ff012, result(r`wv'iwagea)
replace r`wv'iwagea = 0 if r`wv'work == 0 | inlist(r`wv'lbrf_c,1,3,4)
replace r`wv'iwagea = ff002 if inrange(ff002,0,1000000)
replace r`wv'iwagea = ff004*fe001 if inrange(ff004,0,99999) & inrange(fe001,0,12)
replace r`wv'iwagea = (ff006*52)/12*fe001 if inrange(ff006,0,99999) & inrange(fe001,0,12)
replace r`wv'iwagea = (ff008*fe002*52)/12*fe001 if inrange(ff008,0,9999) & inrange(fe002,0,7) & inrange(fe001,0,12)
replace r`wv'iwagea = (ff010*fe003*fe002*52)/12*fe001 if inrange(ff010,0,999) & inrange(fe003,0,24) & inrange(fe002,0,7) & inrange(fe001,0,12)
replace r`wv'iwagea = ff012*fe001 if inrange(ff012,0,999999) & inrange(fe001,0,12)
label variable r`wv'iwagea "r`wv'iwagea:w`wv' income: r wage from work module"

*spouse
gen s`wv'iwagea =.
spouse r`wv'iwagea, result(s`wv'iwagea) wave(1)
label variable s`wv'iwagea "s`wv'iwagea:w`wv' income: s wage from work module"

*household
gen h`wv'iwagea =.
household r`wv'iwagea s`wv'iwagea, result(h`wv'iwagea)
label variable h`wv'iwagea "h`wv'iwagea:w`wv' income: hhold wage from work module"

**==Yearly bonus from non-agricultural job==*
***all other bonus***
*respondent
gen r`wv'ibonus=.
missing_H r`wv'lbrf_c, result(r`wv'ibonus)
missing_c_w1 ff014, result(r`wv'ibonus)
replace r`wv'ibonus = 0 if r`wv'work == 0 | inlist(r`wv'lbrf_c,1,3,4)
replace r`wv'ibonus = ff014 if inrange(ff014,0,200000)
label variable r`wv'ibonus "r`wv'ibonus:w`wv' income: r earning from bonus"

*wave 1 spouse bonus
gen s`wv'ibonus =.
spouse r`wv'ibonus, result(s`wv'ibonus) wave(1)
label variable s`wv'ibonus "s`wv'ibonus:w`wv' income: s earning from bonus"

*household
gen h`wv'ibonus= .
household r`wv'ibonus s`wv'ibonus, result(h`wv'ibonus)
label variable h`wv'ibonus "h`wv'ibonus:w`wv' income: hhold earning from bonus"

** Wage Income from Side Jobs
** fe001: how many months did you work in the past year?
***side job
*wave 1 respondent side job
gen r`wv'isjob=.
missing_c_w1 fe001 fh001 fj003, result(r`wv'isjob)
replace r`wv'isjob = 0 if r`wv'work == 0 | r`wv'work2 == 0
replace r`wv'isjob = fj003 * fe001 if inrange(fj003,0,2000000) & inrange(fe001,0,12)
replace r`wv'isjob = fj003 * fh001 if inrange(fj003,0,2000000) & inrange(fh001,0,12)
label variable r`wv'isjob "r`wv'isjob:w`wv' income: r earning from side job"

*wave 1 spouse side job
gen s`wv'isjob =.
spouse r`wv'isjob, result(s`wv'isjob) wave(1)
label variable s`wv'isjob "s`wv'isjob:w`wv' income: s earning from side job"

*household4
gen h`wv'isjob= .
household r`wv'isjob s`wv'isjob, result(h`wv'isjob)
label variable h`wv'isjob "h`wv'isjob:w`wv' income: hhold earning from side job"

**********************************************
** Total Wage Income from main jobs and side jobs
gen r`wv'iwagew= .
missing_H r`wv'iwagea r`wv'ibonus r`wv'isjob r`wv'ifmemp, result(r`wv'iwagew)
replace r`wv'iwagew = r`wv'iwagea + r`wv'ibonus + r`wv'isjob + r`wv'ifmemp if !mi(r`wv'iwagea) & !mi(r`wv'ibonus) & !mi(r`wv'isjob) & !mi(r`wv'ifmemp)
label variable r`wv'iwagew "r`wv'iwagew:w`wv' income: r earning from work module"

gen s`wv'iwagew =.
spouse r`wv'iwagew, result(s`wv'iwagew) wave(1)
label variable s`wv'iwagew "s`wv'iwagew:w`wv' income: s earning from work module"

**take the maximum of wage values from income and work module
gen r`wv'iearn=.
max_h_value r`wv'iwagei r`wv'iwagew, result(r`wv'iearn)
label variable r`wv'iearn "r`wv'iearn:w`wv' income: r earning from income or work module"

*wave 1 spouse 
gen s`wv'iearn =.
spouse r`wv'iearn, result(s`wv'iearn) wave(1)
label variable s`wv'iearn "s`wv'iearn:w`wv' income: s earning from income or work module"

*household
gen h`wv'iearn = .
household r`wv'iearn s`wv'iearn, result(h`wv'iearn)
label variable h`wv'iearn "h`wv'iearn:w`wv' income: r+s earning from income or work module(couple level)"

drop h`wv'iwagei
**************************************************
***                                            ***
*** 2. R+S Individual INCOME           ***
***                             
**************************************************

**==2.1 public transfer from income module==*
******************************************
**2.1.1 pension
***2.1.9 having other income source(couple level)
gen r`wv'iopeni=.
replace r`wv'iopeni = .m if ga003s1==. & inw`wv' == 1
replace r`wv'iopeni = .d if ga003s1==.d
replace r`wv'iopeni = .r if ga003s1==.r
replace r`wv'iopeni = 0 if ga003s9 == 9 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 |  ga003s10 == 10
replace r`wv'iopeni = 1 if ga003s1 == 1
label variable r`wv'iopeni "r`wv'iopeni:w`wv' income: r pension income from income module"
label value r`wv'iopeni income


gen r`wv'ipeni=.
replace r`wv'ipeni = .m if inw`wv' == 1
replace r`wv'ipeni =.d if ga004_1_1_==.d | ga004_2_1_==.d
replace r`wv'ipeni =.r if ga004_1_1_==.r | ga004_2_1_==.r
replace r`wv'ipeni = 0 if r`wv'iopeni == 0
replace r`wv'ipeni = ga004_2_1_*12 if inrange(ga004_2_1_,0,20000)
replace r`wv'ipeni = ga004_1_1_ if inrange(ga004_1_1_,0,100000)
label variable r`wv'ipeni "r`wv'ipeni:w`wv' income: r pension income from income module"

gen s`wv'ipeni=.
spouse r`wv'ipeni, result(s`wv'ipeni) wave(1)
label variable s`wv'ipeni "s`wv'ipeni:w`wv' income: s pension income from income module"

*****************************************************
****total pension use only from income section********
*household
gen h`wv'ipeni= .
household r`wv'ipeni s`wv'ipeni, result(h`wv'ipeni)
label variable h`wv'ipeni "h`wv'ipeni:w`wv' income: r+s pension income from income module(couple level)"

drop r`wv'iopeni
******************************************************
*******PENSION from work module **********************
**== 2.2 pension income from work module for retirees==*
** This pension depends on how long the respondent has retired
** fm014: In what month and year did you take normal/early retirement
** fm018: In what month and year did you start to receive you pension benefits
destring imonth, gen(imonth_)

gen t_pen=.
replace t_pen = 12 if fm018_1  < 2010
replace t_pen = 12 if fm030_1  < 2010
replace t_pen = 12 if fm018_1 == 2010 & fm018_2 < imonth_
replace t_pen = 12 if fm030_1  < 2010 & fm030_2 < imonth_
replace t_pen = 12 + imonth_ - fm018_2 if fm018_1 == 2010 & fm018_2 >= imonth_
replace t_pen = 12 + imonth_ - fm030_2 if fm030_1 == 2010 & fm030_2 >= imonth_
replace t_pen = imonth_ - fm018_2 if inlist(fm018_1,2011,2012) // *the respondent retired in 2011 or 2012
replace t_pen = imonth_ - fm030_2 if inlist(fm030_1,2011,2012) // *the respondent retired in 2011 or 2012
replace t_pen = 1 if t_pen < 1

** 2.3 yearly pension income from monthly pension information
gen pension_work=.
replace pension_work = 0 if fb011 == 2
replace pension_work = fm022 * t_pen if inrange(fm022,0,99999)
replace pension_work = fm034 * t_pen if inrange(fm034,0,99999)

// supplemental pension insurance of the firm
gen t1=.
replace t1 = 12 if fn003_1  < 2010
replace t1 = 12 if fn003_1 == 2010 & fn003_2 < imonth_
replace t1 = 12 + imonth_ - fn003_2 if fn003_1 == 2010 & fn003_2 >= imonth_
replace t1 = imonth_ - fn003_2 if inlist(fn003_1,2011,2012) // *the respondent retired in 2011 or 2012
replace t1 = 1 if t1 < 1

gen pension1 = .
replace pension1 = 0 if fn001 == 2 | (fn001 == 1 & fn002s1 != 1)
replace pension1 = fn004 * t1 if inrange(fn004,0,9999) 

// commercial pension
gen t2=.
replace t2 = 12 if fn006_1  < 2010
replace t2 = 12 if fn006_1 == 2010 & fn006_2 < imonth_
replace t2 = 12 + imonth_ - fn006_2 if fn006_1 == 2010 & fn006_2 >= imonth_
replace t2 = imonth_ - fn006_2 if inlist(fn006_1,2011,2012) // *the respondent retired in 2011 or 2012
replace t2 = 1 if t2<1

gen pension2 =.
replace pension2 = 0 if fn001 == 2 | (fn001 == 1 & fn002s2 != 2)
replace pension2 = fn007 * t2 if inrange(fn007,0,99999) 

// rural pension, residents pension and urban residents pension
gen t3=.
replace t3 = 12 if fn012_1  < 2010
replace t3 = 12 if fn012_1 == 2010 & fn012_2 < imonth_
replace t3 = 12+imonth_ - fn012_2 if fn012_1 == 2010 & fn012_2 >= imonth_
replace t3 = imonth_ - fn012_2 if inlist(fn012_1,2011,2012) // *the respondent retired in 2011 or 2012
replace t3 = 1 if t3 < 1

gen pension3 =.
replace pension3 = 0 if fn001 == 2 | (fn001 == 1 & fn002s3 != 3 & fn002s4 != 4 & fn002s5 != 5)
replace pension3 = fn013 * t3 if inrange(fn013,0,99999) 

// pension subsidy to the oldest old
gen t4=.
replace t4 = 12 if fn017_1  < 2010
replace t4 = 12 if fn017_1 == 2010 & fn017_2 < imonth_
replace t4 = 12 + imonth_ - fn017_2 if fn017_1 == 2010 & fn017_2 >= imonth_
replace t4 = imonth_ - fn017_2 if inlist(fn017_1,2011,2012) // *the respondent retired in 2011 or 2012
replace t4 = 1 if t4 < 1

gen pension4 =.
replace pension4 = 0 if fn001 == 2 | (fn001 == 1 & fn002s6 != 6)
replace pension4 = fn018 * t4 if inrange(fn018,0,9999) 

// other pension
gen t5=.
replace t5 = 12 if fn021_1  < 2010
replace t5 = 12 if fn021_1 == 2010 & fn021_2 < imonth_
replace t5 = 12 + imonth_ - fn021_2 if fn021_1 == 2010 & fn021_2 >= imonth_
replace t5 = imonth_ - fn021_2 if inlist(fn021_1,2011,2012) // *the respondent retired in 2011 or 2012
replace t5 = 1 if t5 < 1

gen pension5 =.
replace pension5 = 0 if fn001 == 2 | (fn001 == 1 & fn002s7 != 7)
replace pension5 = fn022 * t5 if inrange(fn022,0,9999) 

// new rural social pension insurance
gen t6=.
replace t6 = 12 if fn078_1  < 2010
replace t6 = 12 if fn078_1 == 2010 & fn078_2 < imonth_
replace t6 = 12 + imonth_ - fn078_2 if fn078_1 == 2010 & fn078_2 >= imonth_
replace t6 = imonth_ - fn078_2 if inlist(fn078_1,2011,2012) // *the respondent retired in 2011 or 2012
replace t6 = 1 if t6 < 1

gen pension6 =.
replace pension6 = 0 if fn071 == 2 | fn077 == 2
replace pension6 = fn079 * t6 if inrange(fn079,0,9999) 

*********TOTAL PENSION from WORK SECTION*****
*respondent
gen r`wv'ipenw = .
missing_c_w1 fb011 fm018_1 fm030_1 fm022 fm034 fn001 fn003_1 fn003_2 fn004 fn006_1 fn006_2 fn007 fn012_1 fn012_2 fn013 fn017_1 fn017_2 fn018 fn021_1 fn021_2 fn022 fn078_1 fn078_2, result(r`wv'ipenw)
replace r`wv'ipenw = pension_work + pension1 + pension2 + pension3 + pension4 + pension5 + pension6 if ///
                    !mi(pension_work) & !mi(pension1) & !mi(pension2) & !mi(pension3) & !mi(pension4) & !mi(pension5) & !mi(pension6)
label variable r`wv'ipenw "r`wv'ipenw:w`wv' income: r pension income from work module"

*spouse
gen s`wv'ipenw=.
spouse r`wv'ipenw, result(s`wv'ipenw) wave(1)
label variable s`wv'ipenw "s`wv'ipenw:w`wv' income: s pension income from work module"

*household
gen h`wv'ipenw= .
household r`wv'ipenw s`wv'ipenw, result(h`wv'ipenw)
label variable h`wv'ipenw "h`wv'ipenw:w`wv' income: r+s pension income from work module (couple level)"

drop imonth_
drop t_pen t1 t2 t3 t4 t5 t6
drop pension1 pension1 pension2 pension3 pension4 pension5 pension6 pension_work

******************************************************
*******max of pension from income and work module****
*respondent
gen r`wv'ipen =.
max_h_value r`wv'ipeni r`wv'ipenw, result(r`wv'ipen)
label variable r`wv'ipen "r`wv'ipen:w`wv' income: r pension income from income or work module"

*spouse
gen s`wv'ipen=.
spouse r`wv'ipen, result(s`wv'ipen) wave(1)
label variable s`wv'ipen "s`wv'ipen:w`wv' income: s pension income from income or work module"

*household
gen h`wv'ipen = .
household r`wv'ipen s`wv'ipen, result(h`wv'ipen)
label variable h`wv'ipen "h`wv'ipen:w`wv' income: r+s pension income from work module (couple level)"


*******income related to working subsides*************
*****calculate yearly (not monthly)
***2.1.2 having unemployment compensation 
gen r`wv'iounec=.
replace r`wv'iounec = .m if ga003s2 ==. & inw`wv' == 1
replace r`wv'iounec = .d if ga003s2 ==.d
replace r`wv'iounec = .r if ga003s2 ==.r
replace r`wv'iounec = 0 if ga003s1 == 1 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'iounec = 1 if ga003s2 == 2
label variable r`wv'iounec "r`wv'iounec:w`wv' income: r unemployment compensation"
label value r`wv'iounec income

*wave 1 spouse 
gen s`wv'iounec =.
spouse r`wv'iounec, result(s`wv'iounec) wave(`wv')
label variable s`wv'iounec "s`wv'iounec:w`wv' income: s unemployment compensation"
label value s`wv'iounec income

***Value of unemployment compensation
gen r`wv'iunec=.
replace r`wv'iunec =.m if inw`wv' == 1
replace r`wv'iunec =.d if ga004_1_2_==.d | ga004_2_2_==.d
replace r`wv'iunec =.r if ga004_1_2_==.r | ga004_2_2_==.r
replace r`wv'iunec = 0 if r`wv'iounec == 0
replace r`wv'iunec = ga004_2_2_ * 12 if inrange(ga004_2_2_,0,20000)
replace r`wv'iunec = ga004_1_2_ if inrange(ga004_1_2_,0,100000)
label variable r`wv'iunec "r`wv'iunec:w`wv' income: r value of unemployment compensation"

**wave 1 spouse
gen s`wv'iunec=.
spouse r`wv'iunec, result(s`wv'iunec) wave(`wv')
label variable s`wv'iunec "s`wv'iunec:w`wv' income: s value of unemployment compensation"

***household value
gen h`wv'iunec= .
household r`wv'iunec s`wv'iunec, result(h`wv'iunec)
label variable h`wv'iunec "h`wv'iunec:w`wv' income: r+s value of unemployment compensation"

drop r`wv'iounec s`wv'iounec

***2.1.3 having pension subsidy
gen r`wv'iopens=.
replace r`wv'iopens = .m if ga003s3==. & inw`wv' == 1
replace r`wv'iopens = .d if ga003s3==.d
replace r`wv'iopens = .r if ga003s3==.r
replace r`wv'iopens = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'iopens = 1 if ga003s3 == 3
label variable r`wv'iopens "r`wv'iopens:w`wv' income: r pension subsidy"
label value r`wv'iopens income

*wave 1 spouse 
gen s`wv'iopens =.
spouse r`wv'iopens, result(s`wv'iopens) wave(`wv')
label variable s`wv'iopens "s`wv'iopens:w`wv' income: s pension subsidy"
label value s`wv'iopens income

***Value of pension subsidy
gen r`wv'ipens=.
replace r`wv'ipens =.m if inw`wv' == 1
replace r`wv'ipens =.d if ga004_1_3_==.d | ga004_2_3_==.d
replace r`wv'ipens =.r if ga004_1_3_==.r | ga004_2_3_==.r
replace r`wv'ipens = 0 if r`wv'iopens == 0
replace r`wv'ipens = ga004_2_3_*12 if inrange(ga004_2_3_,0,20000)
replace r`wv'ipens = ga004_1_3_ if inrange(ga004_1_3_,0,100000)
label variable r`wv'ipens "r`wv'ipens:w`wv' income: r value of pension subsidy"

**wave 1 spouse
gen s`wv'ipens=.
spouse r`wv'ipens, result(s`wv'ipens) wave(`wv')
label variable s`wv'ipens "s`wv'ipens:w`wv' income: s value of pension subsidy"

***household value
gen h`wv'ipens= .
household r`wv'ipens s`wv'ipens, result(h`wv'ipens)
label variable h`wv'ipens "h`wv'ipens:w`wv' income: r+s value of pension subsidy"

drop r`wv'iopens s`wv'iopens

***2.1.4 having worker compensation
gen r`wv'ioworkc=.
replace r`wv'ioworkc = .m if ga003s4==. & inw`wv' == 1
replace r`wv'ioworkc = .d if ga003s4==.d
replace r`wv'ioworkc = .r if ga003s4==.r
replace r`wv'ioworkc = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'ioworkc = 1 if ga003s4==4
label variable r`wv'ioworkc "r`wv'ioworkc:w`wv' income: r worker compensation"
label value r`wv'ioworkc income

*wave 1 spouse 
gen s`wv'ioworkc =.
spouse r`wv'ioworkc, result(s`wv'ioworkc) wave(`wv')
label variable s`wv'ioworkc "s`wv'ioworkc:w`wv' income: s worker compensation"
label value s`wv'ioworkc income


***Value of worker compensation
gen r`wv'iworkc=.
replace r`wv'iworkc =.m if inw`wv' == 1
replace r`wv'iworkc =.d if ga004_1_4_==.d | ga004_2_4_==.d
replace r`wv'iworkc =.r if ga004_1_4_==.r | ga004_2_4_==.r
replace r`wv'iworkc = 0 if r`wv'ioworkc == 0 
replace r`wv'iworkc = ga004_2_4_*12 if inrange(ga004_2_4_,0,20000)
replace r`wv'iworkc = ga004_1_4_ if inrange(ga004_1_4_,0,100000)
label variable r`wv'iworkc "r`wv'iworkc:w`wv' income: r value of worker compensation"

**wave 1 spouse
gen s`wv'iworkc=.
spouse r`wv'iworkc, result(s`wv'iworkc) wave(`wv')
label variable s`wv'iworkc "s`wv'iworkc:w`wv' income: s value of worker compensation"

***household value
gen h`wv'iworkc= .
household r`wv'iworkc s`wv'iworkc, result(h`wv'iworkc)
label variable h`wv'iworkc "h`wv'iworkc:w`wv' income: r+s value of worker compensation"

drop r`wv'ioworkc s`wv'ioworkc

***having elderly family planning subsides
gen r`wv'ioefps=.
replace r`wv'ioefps = .m if ga003s5==. & inw`wv' == 1
replace r`wv'ioefps = .d if ga003s5==.d
replace r`wv'ioefps = .r if ga003s5==.r
replace r`wv'ioefps = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'ioefps = 1 if ga003s5==5
label variable r`wv'ioefps "r`wv'ioefps:w`wv' income: r elderly family planning subsides"
label value r`wv'ioefps income

*wave 1 spouse 
gen s`wv'ioefps =.
spouse r`wv'ioefps, result(s`wv'ioefps) wave(`wv')
label variable s`wv'ioefps "s`wv'ioefps:w`wv' income: s elderly family planning subsides"
label value s`wv'ioefps income

***2.1.5 Value of elderly family planning subsides
gen r`wv'iefps=.
replace r`wv'iefps =.m if inw`wv' == 1
replace r`wv'iefps =.d if ga004_1_5_==.d | ga004_2_5_==.d
replace r`wv'iefps =.r if ga004_1_5_==.r | ga004_2_5_==.r
replace r`wv'iefps = 0 if r`wv'ioefps == 0 
replace r`wv'iefps = ga004_2_5_*12 if inrange(ga004_2_5_,0,20000)
replace r`wv'iefps = ga004_1_5_ if inrange(ga004_1_5_,0,100000)
label variable r`wv'iefps "r`wv'iefps:w`wv' income: r value of elderly family planning subsides"

**wave 1 spouse
gen s`wv'iefps=.
spouse r`wv'iefps, result(s`wv'iefps) wave(`wv')
label variable s`wv'iefps "s`wv'iefps:w`wv' income: s value of elderly family planning subsides"

***household value
gen h`wv'iefps= .
household r`wv'iefps s`wv'iefps, result(h`wv'iefps)
label variable h`wv'iefps "h`wv'iefps:w`wv' income: r+s value of elderly family planning subsides"

drop r`wv'ioefps s`wv'ioefps

***2.1.6 having medical aid
gen r`wv'iomed=.
replace r`wv'iomed = .m if ga003s6==. & inw`wv' == 1
replace r`wv'iomed = .d if ga003s6==.d
replace r`wv'iomed = .r if ga003s6==.r
replace r`wv'iomed = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s7 == 7 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'iomed = 1 if ga003s6==6
label variable r`wv'iomed "r`wv'iomed:w`wv' income: r medical aid"
label value r`wv'iomed income

*wave 1 spouse 
gen s`wv'iomed =.
spouse r`wv'iomed, result(s`wv'iomed) wave(`wv')
label variable s`wv'iomed "s`wv'iomed:w`wv' income: s medical aid"
label value s`wv'iomed income

*** Value of medical aid
gen r`wv'imed=.
replace r`wv'imed =.m if inw`wv' == 1
replace r`wv'imed =.d if ga004_1_6_==.d | ga004_2_6_==.d
replace r`wv'imed =.r if ga004_1_6_==.r | ga004_2_6_==.r
replace r`wv'imed = 0 if r`wv'iomed == 0
replace r`wv'imed = ga004_2_6_*12 if inrange(ga004_2_6_,0,20000)
replace r`wv'imed = ga004_1_6_ if inrange(ga004_1_6_,0,100000)
label variable r`wv'imed "r`wv'imed:w`wv' income: r value of medical aid"

**wave 1 spouse
gen s`wv'imed=.
spouse r`wv'imed, result(s`wv'imed) wave(`wv')
label variable s`wv'imed "s`wv'imed:w`wv' income: s value of medical aid"

***household value
gen h`wv'imed= .
household r`wv'imed s`wv'imed, result(h`wv'imed)
label variable h`wv'imed "h`wv'imed:w`wv' income: r+s value of medical aid"

drop r`wv'iomed s`wv'iomed

***2.1.7 having other government subsidies
gen r`wv'iogovs=.
replace r`wv'iogovs = .m if ga003s7==. & inw`wv' == 1
replace r`wv'iogovs = .d if ga003s7==.d
replace r`wv'iogovs = .r if ga003s7==.r
replace r`wv'iogovs = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'iogovs = 1 if ga003s7 == 7
label variable r`wv'iogovs "r`wv'iogovs:w`wv' income: r other government subsidies"
label value r`wv'iogovs income

*wave 1 spouse 
gen s`wv'iogovs =.
spouse r`wv'iogovs, result(s`wv'iogovs) wave(`wv')
label variable s`wv'iogovs "s`wv'iogovs:w`wv' income: s other government subsidies"
label value s`wv'iogovs income

*** Value of other government subsidies
gen r`wv'igovs=.
replace r`wv'igovs =.m if inw`wv' == 1
replace r`wv'igovs =.d if ga004_1_7_==.d | ga004_2_7_==.d
replace r`wv'igovs =.r if ga004_1_7_==.r | ga004_2_7_==.r
replace r`wv'igovs = 0 if r`wv'iogovs == 0
replace r`wv'igovs = ga004_2_7_*12 if inrange(ga004_2_7_,0,20000)
replace r`wv'igovs = ga004_1_7_ if inrange(ga004_1_7_,0,100000)
label variable r`wv'igovs "r`wv'igovs:w`wv' income: r value of other government subsidies"

**wave 1 spouse
gen s`wv'igovs=.
spouse r`wv'igovs, result(s`wv'igovs) wave(`wv')
label variable s`wv'igovs "s`wv'igovs:w`wv' income: s value of other government subsidies"

***household value
gen h`wv'igovs= .
household r`wv'igovs s`wv'igovs, result(h`wv'igovs)
label variable h`wv'igovs "h`wv'igovs:w`wv' income: r+s value of other government subsidies"

drop r`wv'iogovs s`wv'iogovs

***2.1.8 having social assistance
gen r`wv'iosoca=.
replace r`wv'iosoca = .m if ga003s8==. & inw`wv' == 1
replace r`wv'iosoca = .d if ga003s8==.d
replace r`wv'iosoca = .r if ga003s8==.r
replace r`wv'iosoca = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'iosoca = 1 if ga003s8 == 8
label variable r`wv'iosoca "r`wv'iosoca:w`wv' income: r social assistance"
label value r`wv'iosoca income

*wave 1 spouse 
gen s`wv'iosoca =.
spouse r`wv'iosoca, result(s`wv'iosoca) wave(`wv')
label variable s`wv'iosoca "s`wv'iosoca:w`wv' income: s social assistance"
label value s`wv'iosoca income

***Value of social assistance
gen r`wv'isoca=.
replace r`wv'isoca =.m if inw`wv' == 1
replace r`wv'isoca =.d if ga004_1_8_==.d | ga004_2_8_==.d
replace r`wv'isoca =.r if ga004_1_8_==.r | ga004_2_8_==.r
replace r`wv'isoca = 0 if r`wv'iosoca == 0
replace r`wv'isoca = ga004_2_8_*12 if inrange(ga004_2_8_,0,20000)
replace r`wv'isoca = ga004_1_8_ if inrange(ga004_1_8_,0,100000)
label variable r`wv'isoca "r`wv'isoca:w`wv' income: r value of social assistance"

**wave 1 spouse
gen s`wv'isoca=.
spouse r`wv'isoca, result(s`wv'isoca) wave(`wv')
label variable s`wv'isoca "s`wv'isoca:w`wv' income: s value of social assistance"

***household value
gen h`wv'isoca= .
household r`wv'isoca s`wv'isoca, result(h`wv'isoca)
label variable h`wv'isoca "h`wv'isoca:w`wv' income: r+s value of social assistance"

drop r`wv'iosoca s`wv'iosoca

***2.1.9 having other income source(couple level)
gen r`wv'ioothr=.
replace r`wv'ioothr = .m if ga003s9==. & inw`wv' == 1
replace r`wv'ioothr = .d if ga003s9==.d
replace r`wv'ioothr = .r if ga003s9==.r
replace r`wv'ioothr = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 |  ga003s10 == 10
replace r`wv'ioothr = 1 if ga003s9 == 9
label variable r`wv'ioothr "r`wv'ioothr:w`wv' income: r other income source (alimony or child support)"
label value r`wv'ioothr income

*wave 1 spouse 
gen s`wv'ioothr =.
spouse r`wv'ioothr, result(s`wv'ioothr) wave(`wv')
label variable s`wv'ioothr "s`wv'ioothr:w`wv' income: s other income source (alimony or child support)"
label value s`wv'ioothr income

******************************
***Value of other income source (alimony or child support)
gen r`wv'iothr=.
replace r`wv'iothr =.m if inw`wv' == 1
replace r`wv'iothr =.d if ga004_1_9_==.d | ga004_2_9_==.d
replace r`wv'iothr =.r if ga004_1_9_==.r | ga004_2_9_==.r
replace r`wv'iothr = 0 if r`wv'ioothr == 0 
replace r`wv'iothr = ga004_2_9_*12 if inrange(ga004_2_9_,0,20000)
replace r`wv'iothr = ga004_1_9_ if inrange(ga004_1_9_,0,100000)
label variable r`wv'iothr "r`wv'iothr:w`wv' income: r other income (alimony or child support)"

**wave 1 spouse
gen s`wv'iothr=.
spouse r`wv'iothr, result(s`wv'iothr) wave(`wv')
label variable s`wv'iothr "s`wv'iothr:w`wv' income: s other income (alimony or child support)"

***household value
gen h`wv'iothr= .
household r`wv'iothr s`wv'iothr, result(h`wv'iothr)
label variable h`wv'iothr "h`wv'iothr:w`wv' income: r+s other income(alimony or child support) (couple level)"

drop r`wv'ioothr s`wv'ioothr

******************************************************
*****R+S Goverment Transfer  not include rwiothr
*******************************************************
*respondent
gen r`wv'igxfr = .
missing_H r`wv'iunec r`wv'ipens r`wv'iworkc r`wv'iefps r`wv'imed r`wv'igovs r`wv'isoca, result(r`wv'igxfr)
replace r`wv'igxfr = r`wv'iunec + r`wv'ipens + r`wv'iworkc + r`wv'iefps + r`wv'imed + r`wv'igovs + r`wv'isoca if ///
                    !mi(r`wv'iunec) & !mi(r`wv'ipens) & !mi(r`wv'iworkc) & !mi(r`wv'iefps) & !mi(r`wv'imed) & !mi(r`wv'igovs) & !mi(r`wv'isoca)
label variable r`wv'igxfr "r`wv'igxfr:w`wv' income: r government transfer"

*spouse
gen s`wv'igxfr =.
spouse r`wv'igxfr, result(s`wv'igxfr) wave(`wv')
label variable s`wv'igxfr "s`wv'igxfr:w`wv' income: s government transfer"

*household
gen h`wv'igxfr = .
household r`wv'igxfr s`wv'igxfr, result(h`wv'igxfr)
label variable h`wv'igxfr "h`wv'igxfr:w`wv' income: r+s government transfer (couple level)"

drop r`wv'iunec r`wv'ipens r`wv'iworkc r`wv'iefps r`wv'imed r`wv'igovs r`wv'isoca s`wv'iunec s`wv'ipens s`wv'iworkc s`wv'iefps s`wv'imed s`wv'igovs s`wv'isoca h`wv'iunec h`wv'ipens h`wv'iworkc h`wv'iefps h`wv'imed h`wv'igovs h`wv'isoca 


**********************************************************
***                                                    ***
***       3. Fringe Benefits from work module          ***
***                                                    ***
**********************************************************

**==3.1 income from monthly fringe benefits==*
forvalues x = 1/10 {
    gen fringe_`x' = .
    replace fringe_`x' = 0 if r`wv'work == 0 | inlist(r`wv'lbrf_c,1,3,4)
    replace fringe_`x' = 0 if fg001s1 == 1 | fg001s2 == 2 | fg001s3 == 3 | fg001s4 == 4 | fg001s5 == 5 | fg001s6 == 6 | fg001s7 == 7 | fg001s8 == 8 | fg001s9 == 9 | fg001s10 == 10 | fg001s11 == 11
    replace fringe_`x' = fg002_`x'_ * fe001 if inrange(fg002_`x'_,0,999999)
}
gen r`wv'ifring = .
missing_c_w1 fe001 fg001s? fg001s1? fg002_?_ fg002_1?_, result(r`wv'ifring)
replace r`wv'ifring = fringe_1 + fringe_2 + fringe_3 + fringe_4 + fringe_5 + fringe_6 + fringe_7 + fringe_8 + fringe_9 + fringe_10 if ///
                      !mi(fringe_1) & !mi(fringe_2) & !mi(fringe_3) & !mi(fringe_4) & !mi(fringe_5) & !mi(fringe_6) & !mi(fringe_7) & !mi(fringe_8) & !mi(fringe_9) & !mi(fringe_10)
label variable r`wv'ifring "r`wv'ifring:w`wv' income: r fringe benefits"

**wave 1 spouse
gen s`wv'ifring=.
spouse r`wv'ifring, result(s`wv'ifring) wave(`wv')
label variable s`wv'ifring "s`wv'ifring:w`wv' income: s fringe benefits"

***household value
gen h`wv'ifring= .
household r`wv'ifring s`wv'ifring, result(h`wv'ifring)
label variable h`wv'ifring "h`wv'ifring:w`wv' income: r+s fringe benefits(couple level)"

drop fringe_1 fringe_2 fringe_3 fringe_4 fringe_5 fringe_6 fringe_7 fringe_8 fringe_9 fringe_10

**********************************************************
***                                                    ***
***      4. Other Self-employed Activity Income  from work module       ***
***                                                   ***
**********************************************************
*respondent
gen r`wv'isemp=.
missing_H r`wv'lbrf_c, result(r`wv'isemp)
missing_c_w1 fh009 fh010, result(r`wv'isemp)
replace r`wv'isemp = 0 if r`wv'work == 0 | inlist(r`wv'lbrf_c,1,2,4) | fh009 == 1
replace r`wv'isemp = fh010 if inrange(fh010,0,20000000)
label variable r`wv'isemp "r`wv'isemp:w`wv' income: r self-employment w/o other hh members"

**wave 1 spouse
gen s`wv'isemp=.
spouse r`wv'isemp, result(s`wv'isemp) wave(`wv')
label variable s`wv'isemp "s`wv'isemp:w`wv' income: s self-employment w/o other hh members"

***household value
gen h`wv'isemp=.
household r`wv'isemp s`wv'isemp, result(h`wv'isemp)
label variable h`wv'isemp "h`wv'isemp:w`wv' income: r+s self-employment w/o other hh members (couple level)"


*********************************************
**                                        ***                   
** 5. R+S  Capital Income                 ****               
****                                        ***                    
*********************************************

*****Value of income earned from stock*******
**modify: include cashflow income from stock, bonds and other investment 
** r+s finanical asset income
** Stock cashflow  = earn + lose ??
** hc012:how much did you earn from stocks?
** hc012_2: how much did you lose from stocks?

gen r`wv'stock_earn=.
missing_c_w1 hc010 hc011 hc012, result(r`wv'stock_earn)
replace r`wv'stock_earn = 0 if hc010 == 2 | inlist(hc011,2,3)
replace r`wv'stock_earn = hc012 if inrange(hc012,0,99999) & hc011 == 1

gen r`wv'stock_lose=.
missing_c_w1 hc010 hc011 hc012_2, result(r`wv'stock_lose)
replace r`wv'stock_lose = 0 if hc010 == 2 | inlist(hc011,1,3)
replace r`wv'stock_lose = -hc012_2 if inrange(hc012_2,0,9999999) & hc011 == 2

gen r`wv'istock = .
missing_H r`wv'stock_earn r`wv'stock_lose, result(r`wv'istock)
replace r`wv'istock = r`wv'stock_earn + r`wv'stock_lose if !mi(r`wv'stock_earn) & !mi(r`wv'stock_lose)
label variable r`wv'istock "r`wv'istock:w`wv' income: r net income earned from stock"

gen s`wv'istock=.
spouse r`wv'istock, result(s`wv'istock) wave(`wv')
label variable s`wv'istock "s`wv'istock:w`wv' income: s net income earned from stock"

*****Value of net income earned from fund******
** Funds cashflow 
gen r`wv'funds_earn=.
missing_c_w1 hc015 hc016 hc017, result(r`wv'funds_earn)
replace r`wv'funds_earn = 0 if hc015 == 2 | inlist(hc016,2,3)
replace r`wv'funds_earn = hc017 if inrange(hc017,0,999999) & hc016 == 1

gen r`wv'funds_lose=.
missing_c_w1 hc015 hc016 hc017, result(r`wv'funds_lose)
replace r`wv'funds_lose = 0 if hc015 == 2 | inlist(hc016,1,3)
replace r`wv'funds_lose = -hc017 if inrange(hc017,0,999999) & hc016==2

gen r`wv'ifunds = .
missing_H r`wv'funds_earn r`wv'funds_lose, result(r`wv'ifunds)
replace r`wv'ifunds = r`wv'funds_earn + r`wv'funds_lose if !mi(r`wv'funds_earn) & !mi(r`wv'funds_lose)
label variable r`wv'ifunds "r`wv'ifunds:w`wv' income: r net income earned from fund"

gen s`wv'ifunds=.
spouse r`wv'ifunds, result(s`wv'ifunds) wave(`wv')
label variable s`wv'ifunds "s`wv'ifunds:w`wv' income: s net income earned from fund"

drop r1funds_earn r1funds_lose
drop r1stock_earn r1stock_lose

****Income  from investment*******
****cashflow income from other investments 
gen r`wv'iovest=.
replace r`wv'iovest = .m if hc023==. & inw`wv' == 1
replace r`wv'iovest = .d if hc023==.d  
replace r`wv'iovest = .r if hc023==.r  
replace r`wv'iovest = 1  if hc023== 1  
replace r`wv'iovest = 0  if hc023== 2 
label variable r`wv'iovest "r`wv'iovest:w`wv' income: R having other investment"
label value r`wv'iovest income

gen s`wv'iovest=.
spouse r`wv'iovest, result(s`wv'iovest) wave(`wv')
label variable s`wv'iovest "s`wv'iovest:w`wv' income: S having other investment"
label value s`wv'iovest income

****Value of income from investment
gen r`wv'ivest=.
replace r`wv'ivest = .m if inw`wv' == 1
replace r`wv'ivest = .d if hc024==.d 
replace r`wv'ivest = .r if hc024==.r 
replace r`wv'ivest = 0 if r`wv'iovest == 0
replace r`wv'ivest = hc024 if inrange(hc024,-10000000,10000000)
label variable r`wv'ivest "r`wv'ivest:w`wv' income: r amount of income receive from other investment"

gen s`wv'ivest=.
spouse r`wv'ivest, result(s`wv'ivest) wave(`wv')
label variable s`wv'ivest "s`wv'ivest:w`wv' income: s amount of income receive from other investment"

drop r`wv'iovest s`wv'iovest

****************************************
****TOTAL R+S capital income*****
*respondent
gen r`wv'icap = .
missing_H r`wv'istock r`wv'ifunds r`wv'ivest, result(r`wv'icap)
replace r`wv'icap = r`wv'istock + r`wv'ifunds + r`wv'ivest if ///
                !mi(r`wv'istock) & !mi(r`wv'ifunds) & !mi(r`wv'ivest)
label variable r`wv'icap "r`wv'icap:w`wv' income: R capital income"

*spouse
gen s`wv'icap=.
spouse r`wv'icap, result(s`wv'icap) wave(`wv')
label variable s`wv'icap "s`wv'icap:w`wv' income: S capital income"

*household
gen h`wv'icap = .
household r`wv'icap s`wv'icap, result(h`wv'icap)
label variable h`wv'icap "h`wv'icap:w`wv' income: r+s capital income (couple level)"

drop r`wv'istock r`wv'ifunds r`wv'ivest s`wv'istock s`wv'ifunds s`wv'ivest

*********************************************************************************
*********************************************************************************
****5.Other household members' wage income and transfer (Individual based)*******
*********************************************************************************
*********************************************************************************

*****5.1 other HH member wage icnome ****

***Value of other household member income
forvalues x=1/15 {
    gen hhmwage_`x' =.
    replace hhmwage_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | ga005_`x'_ == 2
    replace hhmwage_`x' = ga006_2_`x'_ * 12 if inrange(ga006_2_`x'_,0,99999)
    replace hhmwage_`x' = ga006_1_`x'_ if inrange(ga006_1_`x'_,0,999999)
}

gen hh`wv'iwageo = .
missing_c_w1 ga006_2_?_ ga006_2_1?_ ga006_1_?_ ga006_1_1?_, result(hh`wv'iwageo)
replace hh`wv'iwageo = hhmwage_1 + hhmwage_2 + hhmwage_3 + hhmwage_4 + hhmwage_5 + hhmwage_6 + hhmwage_7 + hhmwage_8 + hhmwage_9 + hhmwage_10 + hhmwage_11 + hhmwage_12 + hhmwage_13 + hhmwage_14 + hhmwage_15 if ///
                     !mi(hhmwage_1) & !mi(hhmwage_2) & !mi(hhmwage_3) & !mi(hhmwage_4) & !mi(hhmwage_5) & !mi(hhmwage_6) & !mi(hhmwage_7) & !mi(hhmwage_8) & !mi(hhmwage_9) & !mi(hhmwage_10) & !mi(hhmwage_11) & !mi(hhmwage_12) & !mi(hhmwage_13) & !mi(hhmwage_14) & !mi(hhmwage_15)
label variable hh`wv'iwageo "hh`wv'iwageo:w`wv' income: other household member wage income"

drop hhmwage_1 hhmwage_2 hhmwage_3 hhmwage_4 hhmwage_5 hhmwage_6 hhmwage_7 hhmwage_8 hhmwage_9 hhmwage_10 hhmwage_11 hhmwage_12 hhmwage_13 hhmwage_14 hhmwage_15 

***************************************************
** 5.2 Other hhmembers' Individual-based transfers  
***************************************************

******5.2.1 HH member pension (yearly)
**Value of pension 
foreach x in 1 2 3 4 5 6 7 8 9 {
    gen hpension_`x' =. 
    replace hpension_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hpension_`x' = ga008_1_b_`x'_*12 if inrange(ga008_1_b_`x'_,0,99999)
    replace hpension_`x' = ga008_1_a_`x'_ if inrange(ga008_1_a_`x'_,0,99999)
}

gen hpension_26 = .
replace hpension_26 = 0 if (ga007_26_s2 == 2 | ga007_26_s3 == 3 | ga007_26_s4 == 4 | ga007_26_s5 == 5 | ga007_26_s6 == 6 | ga007_26_s7 == 7 | ga007_26_s8 == 8 | ga007_26_s9 == 9 | ga007_26_s10 == 10) | ///
                           (mi(ga007_26_s1) & mi(ga007_26_s2) & mi(ga007_26_s3) & mi(ga007_26_s4) & mi(ga007_26_s5) & mi(ga007_26_s6) & mi(ga007_26_s7) & mi(ga007_26_s8) & mi(ga007_26_s9) & mi(ga007_26_s10) & inw`wv' == 1)
replace hpension_26 = ga008_1_b_26_*12 if inrange(ga008_1_b_26_,0,99999)
replace hpension_26 = ga008_1_a_26_ if inrange(ga008_1_a_26_,0,99999)

gen hh`wv'ipeno = .
missing_c_w1 ga007_?_s? ga007_26_s? ga008_1_b_?_ ga008_1_a_?_ ga008_1_b_26_ ga008_1_a_26_, result(hh`wv'ipeno)
replace hh`wv'ipeno = hpension_1 + hpension_2 + hpension_3 + hpension_4 + hpension_5 + hpension_6 + hpension_7 + hpension_8 + hpension_9 + hpension_26 if ///
                    !mi(hpension_1) & !mi(hpension_2) & !mi(hpension_3) & !mi(hpension_4) & !mi(hpension_5) & !mi(hpension_6) & !mi(hpension_7) & !mi(hpension_8) & !mi(hpension_9) & !mi(hpension_26)
label variable hh`wv'ipeno "hh`wv'ipeno:w`wv' income: other hhold member pension income"

drop hpension_1 hpension_2 hpension_3 hpension_4 hpension_5 hpension_6 hpension_7 hpension_8 hpension_9 hpension_26

*************************************************************
*******Other HHmember goveremnt transfer Individual-based******
***********************************************
** 5.2.2 unemployment  compensation
forvalues x=3/4 {
    gen hunem_`x'=.
    replace hunem_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hunem_`x' = ga008_2_b_`x'_*12 if inrange(ga008_2_b_`x'_,0,9999)
    replace hunem_`x' = ga008_2_a_`x'_ if inrange(ga008_2_a_`x'_,0,9999)
}

gen hh`wv'iunec = .
missing_c_w1 ga008_2_b_?_ ga008_2_a_?_, result(hh`wv'iunec)
replace hh`wv'iunec = hunem_3 + hunem_4 if !mi(hunem_3) & !mi(hunem_4)
label variable hh`wv'iunec "hh`wv'iunec:w`wv' income:other hhold member unemployment income"

drop hunem_3 hunem_4

** 5.2.3 pension subsidy
foreach x in 1 2 3 4 6 7 9 11 {
    gen psub_`x' =.
    replace psub_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace psub_`x' = ga008_3_b_`x'_*12 if inrange(ga008_3_b_`x'_,0,9999)
    replace psub_`x' = ga008_3_a_`x'_ if inrange(ga008_3_a_`x'_,0,9999)
}

gen hh`wv'ipens = .
missing_c_w1 ga008_3_b_?_ ga008_3_b_1?_ ga008_3_a_?_ ga008_3_a_1?_, result(hh`wv'ipens)
replace hh`wv'ipens = psub_1 + psub_2 + psub_3 + psub_4 + psub_6 + psub_7 + psub_9 + psub_11 if ///
                !mi(psub_1) & !mi(psub_2) & !mi(psub_3) & !mi(psub_4) & !mi(psub_6) & !mi(psub_7) & !mi(psub_9) & !mi(psub_11)
label variable hh`wv'ipens "hh`wv'ipens:w`wv' income:other hhold member pension subsidy income"

drop psub_1 psub_2 psub_3 psub_4 psub_6 psub_7 psub_9 psub_11


** 5.2.4 work compensation
foreach x in 1 2 3 4 6 {
    gen wcomp_`x'= .
    replace wcomp_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace wcomp_`x' = ga008_4_b_`x'_*12 if inrange(ga008_4_b_`x'_,0,9999)
    replace wcomp_`x' = ga008_4_a_`x'_ if inrange(ga008_4_a_`x'_,0,9999)
}

gen hh`wv'iworkc = .
missing_c_w1 ga007_?_s? ga008_4_b_?_ ga008_4_a_?_, result(hh`wv'iworkc)
replace hh`wv'iworkc = wcomp_1 + wcomp_2 + wcomp_3 + wcomp_4 + wcomp_6 if ///
                        !mi(wcomp_1) & !mi(wcomp_2) & !mi(wcomp_3) & !mi(wcomp_4) & !mi(wcomp_6)
label variable hh`wv'iworkc "hh`wv'iworkc:w`wv' income:other hhold member workers compensation income"

drop wcomp_1 wcomp_2 wcomp_3 wcomp_4 wcomp_6


** 5.2.5 elderly family planning
forvalues x=1/7 {
    gen hfsub_`x'=.
    replace hfsub_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hfsub_`x' = ga008_5_b_`x'_*12 if inrange(ga008_5_b_`x'_,0,9999)
    replace hfsub_`x' = ga008_5_a_`x'_ if inrange(ga008_5_a_`x'_,0,9999)
}

gen hh`wv'iefps = .
missing_c_w1 ga007_?_s? ga008_5_b_?_ ga008_5_a_?_, result(hh`wv'iefps)
replace hh`wv'iefps = hfsub_1 + hfsub_2 + hfsub_3 + hfsub_4 + hfsub_5 + hfsub_6 + hfsub_7 if ///
                !mi(hfsub_1) & !mi(hfsub_2) & !mi(hfsub_3) & !mi(hfsub_4) & !mi(hfsub_5) & !mi(hfsub_6) & !mi(hfsub_7)
label variable hh`wv'iefps "hh`wv'iefps:w`wv' income:other hhold member elderly family planning income"

drop hfsub_1 hfsub_2 hfsub_3 hfsub_4 hfsub_5 hfsub_6 hfsub_7


** 5.2.6 medical aid
foreach  x in 1 2 3 4 5 6 7 {
    gen hmed_`x'=.
    replace hmed_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hmed_`x' = ga008_6_b_`x'_*12 if inrange(ga008_6_b_`x'_,0,9999)
    replace hmed_`x' = ga008_6_a_`x'_ if inrange(ga008_6_a_`x'_,0,9999)
}

gen hmed_26=.
replace hmed_26 = 0 if (ga007_26_s1 == 1 | ga007_26_s2 == 2 | ga007_26_s3 == 3 | ga007_26_s4 == 4 | ga007_26_s5 == 5 | ga007_26_s7 == 7 | ga007_26_s8 == 8 | ga007_26_s9 == 9 | ga007_26_s10 == 10 ) | ///
                       (mi(ga007_26_s1) & mi(ga007_26_s2) & mi(ga007_26_s3) & mi(ga007_26_s4) & mi(ga007_26_s5) & mi(ga007_26_s6) & mi(ga007_26_s7) & mi(ga007_26_s8) & mi(ga007_26_s9) & mi(ga007_26_s10) & inw`wv' == 1)
replace hmed_26 = ga008_6_b_26_*12 if inrange(ga008_6_b_26_,0,9999)
replace hmed_26 = ga008_6_a_26_ if inrange(ga008_6_a_26_,0,9999)

gen hh`wv'imed = .
missing_c_w1 ga007_?_s? ga008_6_b_?_ ga008_6_a_?_ ga008_6_b_26_ ga008_6_a_26_, result(hh`wv'imed)
replace hh`wv'imed = hmed_1 + hmed_2 + hmed_3 + hmed_4 + hmed_5 + hmed_6 + hmed_7 + hmed_26 if ///
                    !mi(hmed_1) & !mi(hmed_2) & !mi(hmed_3) & !mi(hmed_4) & !mi(hmed_5) & !mi(hmed_6) & !mi(hmed_7) & !mi(hmed_26)
label variable hh`wv'imed "hh`wv'imed:w`wv' income:other hhold member medical aid income"

drop hmed_1 hmed_2 hmed_3 hmed_4 hmed_5 hmed_6 hmed_7 hmed_26


** 5.2.7 other government subsidy
forvalues x=1/7 {
    gen hgsub_`x'=.
    replace hgsub_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hgsub_`x' = ga008_7_b_`x'_*12 if inrange(ga008_7_b_`x'_,0,9999)
    replace hgsub_`x' = ga008_7_a_`x'_ if inrange(ga008_7_a_`x'_,0,9999)
}

gen hh`wv'igovs = .
missing_c_w1 ga007_?_s? ga008_7_b_?_ ga008_7_a_?_, result(hh`wv'igovs)
replace hh`wv'igovs = hgsub_1 + hgsub_2 + hgsub_3 + hgsub_4 + hgsub_5 + hgsub_6 + hgsub_7 if ///
                    !mi(hgsub_1) & !mi(hgsub_2) & !mi(hgsub_3) & !mi(hgsub_4) & !mi(hgsub_5) & !mi(hgsub_6) & !mi(hgsub_7)
label variable hh`wv'igovs "hh`wv'igovs:w`wv' income:other hhold member other goverment income"

drop hgsub_1 hgsub_2 hgsub_3 hgsub_4 hgsub_5 hgsub_6 hgsub_7

** 5.2.8 social assistance
foreach x in 1 2 3 4 5 6 8 {
    gen hass_`x'=.
    replace hass_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hass_`x' = ga008_8_b_`x'_*12 if inrange(ga008_8_b_`x'_,0,9999)
    replace hass_`x' = ga008_8_a_`x'_ if inrange(ga008_8_a_`x'_,0,9999)
}

gen hh`wv'isoca = .
missing_c_w1 ga007_?_s? ga008_8_b_?_ ga008_8_a_?_, result(hh`wv'isoca)
replace hh`wv'isoca = hass_1 + hass_2 + hass_3 + hass_4 + hass_5 + hass_6 + hass_8 if ///
                    !mi(hass_1) & !mi(hass_2) & !mi(hass_3) & !mi(hass_4) & !mi(hass_5) & !mi(hass_6) & !mi(hass_8)
label variable hh`wv'isoca "hh`wv'isoca:w`wv' income:other hhold member social assistance income"

drop hass_1 hass_2 hass_3 hass_4 hass_5 hass_6 hass_8

** 5.2.9 other income- (alimony or child support)
forvalues x=1/7 {
    gen hothers_`x'=.
    replace hothers_`x' = 0 if (mi(a002_`x'_) & mi(a006_`x'_) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s10 == 10
    replace hothers_`x' = ga008_9_b_`x'_*12 if inrange(ga008_9_b_`x'_,0,99999)
    replace hothers_`x' = ga008_9_a_`x'_ if inrange(ga008_9_a_`x'_,0,99999)
}

gen hh`wv'iothro = .
missing_c_w1 ga007_?_s? ga008_9_b_?_ ga008_9_a_?_, result(hh`wv'iothro)
replace hh`wv'iothro = hothers_1 + hothers_2 + hothers_3 + hothers_4 + hothers_5 + hothers_6 + hothers_7 if ///
                        !mi(hothers_1) & !mi(hothers_2) & !mi(hothers_3) & !mi(hothers_4) & !mi(hothers_5) & !mi(hothers_6) & !mi(hothers_7)
label var hh`wv'iothro "hh`wv'iothro:w`wv' income: other hhold member other income (alimony or child support)"

drop hothers_1 hothers_2 hothers_3 hothers_4 hothers_5 hothers_6 hothers_7

******************************************************
*****Total other HHmember Individual-based goverment transfer income
*******************************************************
gen hh`wv'igxfro = .
missing_H hh`wv'iunec hh`wv'ipens hh`wv'iworkc hh`wv'iefps hh`wv'imed hh`wv'igovs hh`wv'isoca, result(hh`wv'igxfro)
replace hh`wv'igxfro = hh`wv'iunec + hh`wv'ipens + hh`wv'iworkc + hh`wv'iefps + hh`wv'imed + hh`wv'igovs + hh`wv'isoca if ///
                    !mi(hh`wv'iunec) & !mi(hh`wv'ipens) & !mi(hh`wv'iworkc) & !mi(hh`wv'iefps) & !mi(hh`wv'imed) & !mi(hh`wv'igovs) & !mi(hh`wv'isoca)
label var hh`wv'igxfro "hh`wv'igxfro:w`wv' income: other hhold member government transfer"

drop hh`wv'iunec  hh`wv'ipens hh`wv'iworkc hh`wv'iefps hh`wv'imed hh`wv'igovs hh`wv'isoca

********************************************************
***************Household Level Income*******************
********************************************************


**********************************************************
*****HH Agricultural income from crop and livestock***
**********************************************************

************************************
***Engaging in agricultural work***
gen hh`wv'ioagri =.
missing_c_w1 gb001 gb002_1_ gb002_2_ gb002_3_ gb002_4_ gb002_5_ gb002_6_ gb002_7_ gb002_8_ gb002_9_ gb002_10_ gb002_11_ gb002_12_ gb002_13_ gb002_14_ gb002_15_ gb002_16_, result(hh`wv'ioagri)
foreach v in gb001 gb002_1_ gb002_2_ gb002_3_ gb002_4_ gb002_5_ gb002_6_ gb002_7_ gb002_8_ gb002_9_ gb002_10_ gb002_11_ gb002_12_ gb002_13_ gb002_14_ gb002_15_ gb002_16_ {
    replace hh`wv'ioagri = 0 if `v' == 2 & hh`wv'ioagri != 1
    replace hh`wv'ioagri = 1 if `v' == 1
}
label variable hh`wv'ioagri "hh`wv'ioagri:w`wv' income: engaging in agricultural work "
label value hh`wv'ioagri income

drop hh`wv'ioagri

***Engaging in cropping***
gen hh`wv'iocrop=.
replace hh`wv'iocrop = .m if gb003==. & inw`wv' == 1
replace hh`wv'iocrop = .d if gb003==.d
replace hh`wv'iocrop = .r if gb003==.r
replace hh`wv'iocrop = 0 if gb001 == 2 | gb003 == 2
replace hh`wv'iocrop = 1 if gb003 == 1
label variable hh`wv'iocrop "hh`wv'iocrop:w`wv' income: engaging in cropping or forestry"
label value hh`wv'iocrop income


***Value of all crop and forestry product***
gen hh`wv'icrop1=.
replace hh`wv'icrop1 = .m if gb005==. & inw`wv' == 1
replace hh`wv'icrop1 = .d if gb005==.d 
replace hh`wv'icrop1 = .r if gb005==.r 
replace hh`wv'icrop1 = 0 if hh`wv'iocrop== 0
replace hh`wv'icrop1 = gb005 if inrange(gb005,0,10000000)
label variable hh`wv'icrop1 "hh`wv'icrop1:w`wv' income: value of cropping or forestry"

***Cost of all crop and forestry product
gen hh`wv'icrop2=.
replace hh`wv'icrop2 = .m if gb006==. & inw`wv' == 1
replace hh`wv'icrop2 = .d if gb006==.d 
replace hh`wv'icrop2 = .r if gb006==.r 
replace hh`wv'icrop2 = 0 if hh`wv'iocrop== 0
replace hh`wv'icrop2 = gb006 if inrange(gb006,0,10000000)
label variable hh`wv'icrop2 "hh`wv'icrop2:w`wv' income: cost of cropping or forestry"

***Net of all crop and forestry product***
gen hh`wv'icrop =.
missing_H hh`wv'icrop1 hh`wv'icrop2, result(hh`wv'icrop)
replace hh`wv'icrop = hh`wv'icrop1 - hh`wv'icrop2 if !mi(hh`wv'icrop1) & !mi(hh`wv'icrop2)
label variable hh`wv'icrop "hh`wv'icrop:w`wv' income: net value of cropping or forestry"

drop hh`wv'icrop1 hh`wv'icrop2
drop hh`wv'iocrop

**********************************
***Grow any livestock or aquatic
gen hh`wv'iolive=.
missing_c_w1 gb001 gb007, result(hh`wv'iolive)
replace hh`wv'iolive = 0 if gb001 == 2 | gb007 == 2
replace hh`wv'iolive = 1 if gb007 == 1
label variable hh`wv'iolive "hh`wv'iolive:w`wv' income: growing livestock or aquatic life"
label value hh`wv'iolive income

***Value of any livestock or aquatic***
gen hh`wv'ilive1 =.
missing_c_w1 gb001 gb007 gb011 gb012 gb008 gb009, result(hh`wv'ilive1)
replace hh`wv'ilive1 = 0 if gb001 == 2 | gb007 == 2
replace hh`wv'ilive1 = gb011 + gb012 + gb008 - gb009 if !mi(gb011) & !mi(gb012) & !mi(gb009) & !mi(gb008)
label variable hh`wv'ilive1 "hh`wv'ilive1:w`wv' income: value of growing livestock or aquatic life and side product"

***Cost of any livestock or aquatic
gen hh`wv'ilive2 =.
missing_c_w1 gb001 gb007 gb010 gb013, result(hh`wv'ilive2)
replace hh`wv'ilive2 = 0 if gb001 == 2 | gb007 == 2
replace hh`wv'ilive2 = gb010 + gb013 if !mi(gb010) & !mi(gb013)
label variable hh`wv'ilive2 "hh`wv'ilive2:w`wv' income: value of growing livestock or aquatic life and side product"

***Net of any livestock or aquatic***
gen hh`wv'ilive =.
missing_H hh`wv'ilive1 hh`wv'ilive2, result(hh`wv'ilive)
replace hh`wv'ilive = hh`wv'ilive1 - hh`wv'ilive2 if !mi(hh`wv'ilive1) & !mi(hh`wv'ilive2)
label variable hh`wv'ilive "hh`wv'ilive:w`wv' income: net value of growing livestock or aquatic life and side product"

drop hh`wv'ilive1 hh`wv'ilive2
drop hh`wv'iolive

******************************************************************
**** Total Net Agricultural income from crop and livestock********
gen hh`wv'iagri = .
missing_H hh`wv'icrop hh`wv'ilive, result(hh`wv'iagri)
replace hh`wv'iagri = hh`wv'icrop + hh`wv'ilive if !mi(hh`wv'icrop) & !mi(hh`wv'ilive)
label variable hh`wv'iagri "hh`wv'iagri:w`wv' income: hhold net agricultural income"

drop hh`wv'icrop hh`wv'ilive

******************************************************
****non-agricultural income household level**********
******************************************************

********************************
***HH Self-employed activities*****
********************************
gen hh`wv'iosemp =.
replace hh`wv'iosemp =.m if gc001 ==. & inw`wv' == 1
replace hh`wv'iosemp =.d if gc001 ==.d
replace hh`wv'iosemp =.r if gc001 ==.r
replace hh`wv'iosemp = 0 if gc001 == 2
replace hh`wv'iosemp = 1 if gc001 == 1
label variable hh`wv'iosemp "hh`wv'iosemp:w`wv' income: self-employed activities"
label value hh`wv'iosemp income

***Value of self-employed activities***
***Total household income from self-employed activities********
gen hh`wv'isemp =.
missing_c_w1 gc001 gc002 gc005_1_ gc005_2_ gc005_3_, result(hh`wv'isemp)
replace hh`wv'isemp = 0 if hh`wv'iosemp == 0 | gc002 == 0
replace hh`wv'isemp = gc005_1_ if gc002 == 1 & !mi(gc005_1_)
replace hh`wv'isemp = gc005_1_ + gc005_2_ if gc002 == 2 & !mi(gc005_1_) & !mi(gc005_2_)
replace hh`wv'isemp = gc005_1_ + gc005_2_ + gc005_3_ if gc002 == 3 & !mi(gc005_1_) & !mi(gc005_2_) & !mi(gc005_3_)
label variable hh`wv'isemp "hh`wv'isemp:w`wv' income: hhold self-employed activities"

drop hh`wv'iosemp

*****************************************************************
*******HH Goverment Transfer income      ************************
*****************************************************************

******income from government subsides*****
***Dibao assistance***
gen hh`wv'iodiabo=.
replace hh`wv'iodiabo =.m if gd001 ==. & inw`wv' == 1
replace hh`wv'iodiabo =.d if gd001 ==.d
replace hh`wv'iodiabo =.r if gd001 ==.r
replace hh`wv'iodiabo = 0 if gd001 == 2
replace hh`wv'iodiabo = 1 if gd001 == 1
label variable hh`wv'iodiabo "hh`wv'iodiabo_c:w`wv' income: receiving Dibao assistance "
label value hh`wv'iodiabo income

***value of Dibao
gen hh`wv'idibao=.
replace hh`wv'idibao =.m if inw`wv' == 1
replace hh`wv'idibao =.d if gd001_c ==.d 
replace hh`wv'idibao =.r if gd001_c ==.r 
replace hh`wv'idibao = 0 if hh`wv'iodiabo == 0
replace hh`wv'idibao = gd001_c if inrange(gd001_c,0,100000)
label variable hh`wv'idibao "hh`wv'idibao:w`wv' income: amount of Dibao assistance"

drop hh`wv'iodiabo
***having reforestation
gen hh`wv'iorefo=.
replace hh`wv'iorefo =.m if gd002s1 ==. & inw`wv' == 1
replace hh`wv'iorefo =.d if gd002s1 ==.d
replace hh`wv'iorefo =.r if gd002s1 ==.r
replace hh`wv'iorefo = 0 if gd002s2 == 2 | gd002s3 == 3 | gd002s4 == 4 | gd002s5 == 5 | gd002s6 == 6 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'iorefo = 1 if gd002s1 == 1
label variable hh`wv'iorefo "hh`wv'iorefo:w`wv' income: receiving government subsidies in reforestation"
label value hh`wv'iorefo income


***Value of reforestation
gen hh`wv'irefo=.
replace hh`wv'irefo =.m if inw`wv' == 1
replace hh`wv'irefo =.d if gd002_1 ==.d 
replace hh`wv'irefo =.r if gd002_1 ==.r 
replace hh`wv'irefo = 0 if hh`wv'iorefo == 0
replace hh`wv'irefo = gd002_1 if inrange(gd002_1,0,100000)
label variable hh`wv'irefo "hh`wv'irefo:w`wv' income: amount government subsidies in reforestation"

drop hh`wv'iorefo
***having agriculture subsidy
gen hh`wv'ioagris=.
replace hh`wv'ioagris =.m if gd002s2==. & inw`wv' == 1
replace hh`wv'ioagris =.d if gd002s2==.d
replace hh`wv'ioagris =.r if gd002s2==.r
replace hh`wv'ioagris = 0 if gd002s1 == 1 | gd002s3 == 3 | gd002s4 == 4 | gd002s5 == 5 | gd002s6 == 6 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'ioagris = 1 if gd002s2==2
label variable hh`wv'ioagris "hh`wv'ioagris:w`wv' income: receiving government subsidies in agricultural work"
label value hh`wv'ioagris income



***Value of agriculture subsidy
gen hh`wv'iagris=.
replace hh`wv'iagris =.m if inw`wv' == 1
replace hh`wv'iagris =.d if gd002_2 ==.d 
replace hh`wv'iagris =.r if gd002_2 ==.r 
replace hh`wv'iagris = 0 if hh`wv'ioagris == 0
replace hh`wv'iagris = gd002_2 if inrange(gd002_2,0,100000)
label variable hh`wv'iagris "hh`wv'iagris:w`wv' income: amount government subsidies in agricultural work"

drop hh`wv'ioagris

***having Wubaohu
gen hh`wv'iowuba=.
replace hh`wv'iowuba =.m if gd002s3 ==. & inw`wv' == 1
replace hh`wv'iowuba =.d if gd002s3 ==.d
replace hh`wv'iowuba =.r if gd002s3 ==.r
replace hh`wv'iowuba = 0 if gd002s1 == 1 | gd002s2 == 2 | gd002s4 == 4 | gd002s5 == 5 | gd002s6 == 6 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'iowuba = 1 if gd002s3 == 3
label variable hh`wv'iowuba "hh`wv'iowuba:w`wv' income: receiving government subsidies in Wubaohu"
label value hh`wv'iowuba income


***Value of Wubaohu
gen hh`wv'iwuba=.
replace hh`wv'iwuba =.m if inw`wv' == 1
replace hh`wv'iwuba =.d if gd002_3 ==.d 
replace hh`wv'iwuba =.r if gd002_3 ==.r 
replace hh`wv'iwuba = 0 if hh`wv'iowuba == 0
replace hh`wv'iwuba = gd002_3 if inrange(gd002_3,0,100000)
label variable hh`wv'iwuba "hh`wv'iwuba:w`wv' income: amount government subsidies in Wubaohu"

drop hh`wv'iowuba

***having Tekunhu
gen hh`wv'ioteku=.
replace hh`wv'ioteku =.m if gd002s4==. & inw`wv' == 1
replace hh`wv'ioteku =.d if gd002s4==.d
replace hh`wv'ioteku =.r if gd002s4==.r
replace hh`wv'ioteku = 0 if gd002s1 == 1 | gd002s2 == 2 | gd002s3 == 3 | gd002s5 == 5 | gd002s6 == 6 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'ioteku = 1 if gd002s4 == 4
label variable hh`wv'ioteku "hh`wv'ioteku:w`wv' income: receiving government subsidies in Tekunhu"
label value hh`wv'ioteku income

***Value of Tekunhu 
gen hh`wv'iteku=.
replace hh`wv'iteku =.m if inw`wv' == 1
replace hh`wv'iteku =.d if gd002_4 ==.d 
replace hh`wv'iteku =.r if gd002_4 ==.r 
replace hh`wv'iteku = 0 if hh`wv'ioteku == 0
replace hh`wv'iteku = gd002_4 if inrange(gd002_4,0,100000)
label variable hh`wv'iteku "hh`wv'iteku:w`wv' income: amount government subsidies in Tekunhu"

drop hh`wv'ioteku

***having work injury
gen hh`wv'iowinju=.
replace hh`wv'iowinju =.m if gd002s5 ==. & inw`wv' == 1
replace hh`wv'iowinju =.d if gd002s5 ==.d
replace hh`wv'iowinju =.r if gd002s5 ==.r
replace hh`wv'iowinju = 0 if gd002s1 == 1 | gd002s2 == 2 | gd002s3 == 3 | gd002s4 == 4 | gd002s6 == 6 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'iowinju = 1 if gd002s5 == 5
label variable hh`wv'iowinju "hh`wv'iowinju:w`wv' income: receiving government subsidies in work injury"
label value hh`wv'iowinju income

***Value of work injury 
gen hh`wv'iwinju=.
replace hh`wv'iwinju =.m if inw`wv' == 1
replace hh`wv'iwinju =.d if gd002_5 ==.d 
replace hh`wv'iwinju =.r if gd002_5 ==.r 
replace hh`wv'iwinju = 0 if hh`wv'iowinju == 0
replace hh`wv'iwinju = gd002_5 if inrange(gd002_5,0,100000)
label variable hh`wv'iwinju "hh`wv'iwinju:w`wv' income: amount government subsidies in work injury"

drop hh`wv'iowinju

***having emergency or disaster relief
gen hh`wv'ioreli=.
replace hh`wv'ioreli =.m if gd002s6 ==. & inw`wv' == 1
replace hh`wv'ioreli =.d if gd002s6 ==.d
replace hh`wv'ioreli =.r if gd002s6 ==.r
replace hh`wv'ioreli = 0 if gd002s1 == 1 | gd002s2 == 2 | gd002s3 == 3 | gd002s4 == 4 | gd002s5 == 5 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'ioreli = 1 if gd002s6 == 6
label variable hh`wv'ioreli "hh`wv'ioreli:w`wv' income: receiving government subsidies in emergency or disaster relief"
label value hh`wv'ioreli income


***Value of emergency or disaster relief 
gen hh`wv'ireli=.
replace hh`wv'ireli =.m if inw`wv' == 1
replace hh`wv'ireli =.d if gd002_6 ==.d 
replace hh`wv'ireli =.r if gd002_6 ==.r 
replace hh`wv'ireli = 0 if hh`wv'ioreli == 0
replace hh`wv'ireli = gd002_6 if inrange(gd002_6,0,100000)
label variable hh`wv'ireli "hh`wv'ireli:w`wv' income: amount government subsidies in emergency or disaster relief"

drop hh`wv'ioreli

***having other subsidies
gen hh`wv'iogothe=.
replace hh`wv'iogothe =.m if gd002s7 ==. & inw`wv' == 1
replace hh`wv'iogothe =.d if gd002s7 ==.d
replace hh`wv'iogothe =.r if gd002s7 ==.r
replace hh`wv'iogothe = 0 if gd002s1 == 1 | gd002s2 == 2 | gd002s3 == 3 | gd002s4 == 4 | gd002s5 == 5 | gd002s6 == 6 | gd002s8 == 8 
replace hh`wv'iogothe = 1 if gd002s7 == 7
label variable hh`wv'iogothe "hh`wv'iogothe:w`wv' income: receiving other government subsidies"
label value hh`wv'iogothe income

***Value of other subsidies 
gen hh`wv'igothe=.
replace hh`wv'igothe =.m if inw`wv' == 1
replace hh`wv'igothe =.d if gd002_7 ==.d 
replace hh`wv'igothe =.r if gd002_7 ==.r 
replace hh`wv'igothe = 0 if hh`wv'iogothe == 0
replace hh`wv'igothe = gd002_7 if inrange(gd002_7,0,100000)
label variable hh`wv'igothe "hh`wv'igothe:w`wv' income: amount in other government subsidies"

drop hh`wv'iogothe

****************************************************************************************
********************Total goverment Transfer Income ************************
gen hh`wv'igxfrh = .
missing_H hh`wv'idibao hh`wv'irefo hh`wv'iagris hh`wv'iwuba hh`wv'iteku hh`wv'iwinju hh`wv'ireli hh`wv'igothe, result(hh`wv'igxfrh)
replace hh`wv'igxfrh = hh`wv'idibao + hh`wv'irefo + hh`wv'iagris + hh`wv'iwuba + hh`wv'iteku + hh`wv'iwinju + hh`wv'ireli + hh`wv'igothe if ///
                !mi(hh`wv'idibao) & !mi(hh`wv'irefo) & !mi(hh`wv'iagris) & !mi(hh`wv'iwuba) & !mi(hh`wv'iteku) & !mi(hh`wv'iwinju) & !mi(hh`wv'ireli) & !mi(hh`wv'igothe)
label variable hh`wv'igxfrh "hh`wv'igxfrh:w`wv' income: hhold other government transfer income"

drop hh`wv'idibao hh`wv'irefo hh`wv'iagris hh`wv'iwuba hh`wv'iteku hh`wv'iwinju hh`wv'ireli hh`wv'igothe

***************************************
******Other public transfer income ********************
***************************************

***************************************
*****related to donation
***having donation***
gen hh`wv'iodona=.
replace hh`wv'iodona =.m if gd003s1 ==. & inw`wv' == 1
replace hh`wv'iodona =.d if gd003s1 ==.d
replace hh`wv'iodona =.r if gd003s1 ==.r
replace hh`wv'iodona = 0 if gd003s2 == 2 | gd003s3 == 3 | gd003s4 == 4 
replace hh`wv'iodona = 1 if gd003s1 == 1
label variable hh`wv'iodona "hh`wv'iodona:w`wv' income: receiving donation from the society"
label value hh`wv'iodona income

***Value of donation***
gen hh`wv'idona=.
replace hh`wv'idona =.m if inw`wv' == 1
replace hh`wv'idona =.d if gd003_1 ==.d 
replace hh`wv'idona =.r if gd003_1 ==.r 
replace hh`wv'idona = 0 if hh`wv'iodona == 0
replace hh`wv'idona = gd003_1 if inrange(gd003_1,0,100000)
label variable hh`wv'idona "hh`wv'idona:w`wv' income: amount of receiving donation from the society"
drop hh`wv'iodona

***having compensation for land seizure***
gen hh`wv'iolands=.
replace hh`wv'iolands = .m if gd003s2 ==. & inw`wv' == 1
replace hh`wv'iolands = .d if gd003s2 ==.d
replace hh`wv'iolands = .r if gd003s2 ==.r
replace hh`wv'iolands = 0 if gd003s1 == 1 | gd003s3 == 3 | gd003s4 == 4 
replace hh`wv'iolands = 1 if gd003s2 == 2
label variable hh`wv'iolands "hh`wv'iolands:w`wv' income: receiving compensation for land seizure"
label value hh`wv'iolands income

***Value of compensation for land seizure***
gen hh`wv'ilands=.
replace hh`wv'iland =.m if inw`wv' == 1
replace hh`wv'iland =.d if gd003_2==.d 
replace hh`wv'iland =.r if gd003_2==.r 
replace hh`wv'iland = 0 if hh`wv'ioland == 0
replace hh`wv'iland = gd003_2 if inrange(gd003_2,0,100000)
label variable hh`wv'ilands "hh`wv'ilands:w`wv' income: amount of receiving compensation for land seizure"

drop hh`wv'iolands

***having house compensation ***
gen hh`wv'iopull=.
replace hh`wv'iopull =.m if gd003s3 ==. & inw`wv' == 1
replace hh`wv'iopull =.d if gd003s3 ==.d
replace hh`wv'iopull =.r if gd003s3 ==.r
replace hh`wv'iopull = 0 if gd003s1 == 1 | gd003s2 == 2 | gd003s4 == 4 
replace hh`wv'iopull = 1 if gd003s3 == 3

label variable hh`wv'iopull "hh`wv'iopull:w`wv' income: receiving compensation for pulling down house or apartment"
label value hh`wv'iopull income


***Value of pulling***
gen hh`wv'ipull=.
replace hh`wv'ipull =.m if inw`wv' == 1
replace hh`wv'ipull =.d if gd003_3 ==.d 
replace hh`wv'ipull =.r if gd003_3 ==.r 
replace hh`wv'ipull = 0 if hh`wv'iopull == 0
replace hh`wv'ipull = gd003_3 if inrange(gd003_3,0,20000000)
label variable hh`wv'ipull "hh`wv'ipull:w`wv' income: amount of receiving compensation for pulling down house or apartment"


***********************************************************************
********************Total other Income ********************************
gen hh`wv'igxfrt = .
missing_H hh`wv'idona hh`wv'ilands hh`wv'ipull, result(hh`wv'igxfrt)
replace hh`wv'igxfrt = hh`wv'idona + hh`wv'ilands + hh`wv'ipull if !mi(hh`wv'idona) & !mi(hh`wv'ilands) & !mi(hh`wv'ipull)
label variable hh`wv'igxfrt "hh`wv'igxfrt:w`wv' income: hhold other public transfer income"

drop hh`wv'idona hh`wv'ilands hh`wv'ipull hh`wv'iopull

****************************************
**************Capital Income************
****************************************

** houseshole housing rental income 
gen h`wv'iorent=.
replace h`wv'iorent =.m if ha052 ==. & inw`wv' == 1
replace h`wv'iorent =.d if ha052 ==.d 
replace h`wv'iorent =.r if ha052 ==.r 
replace h`wv'iorent = 0 if ha027 == 2 | ha052 == 2
replace h`wv'iorent = 1 if ha052 == 1 
label variable h`wv'iorent "h`wv'iorent:w`wv' income: cpl having rental income"
label value h`wv'iorent income


***Value of rental income***
gen h`wv'irent=.
replace h`wv'irent =.m if inw`wv' == 1
replace h`wv'irent =.d if ha052_1==.d 
replace h`wv'irent =.r if ha052_1==.r 
replace h`wv'irent = 0 if h`wv'iorent== 0
replace h`wv'irent = ha052_1 * 12 if inrange(ha052_1,0,10000)
label variable h`wv'irent "hh`wv'irent:w`wv' income: cpl amount of rental income annually"

drop h`wv'iorent

*****************************
****monthly Rental income by other household members***
gen hh`wv'iorento=.
replace hh`wv'iorento =.m if ha053==. & inw`wv' == 1
replace hh`wv'iorento =.d if ha053==.d 
replace hh`wv'iorento =.r if ha053==.r 
replace hh`wv'iorento = 0 if ha027 == 2 | ha053 == 2
replace hh`wv'iorento = 1 if ha053 == 1 
label variable hh`wv'iorento "hh`wv'iorento:w`wv' income: othr hh mems having rental income"
label value hh`wv'iorento income

***Value of rental income by other housheold members***
gen hh`wv'irento=. 
replace hh`wv'irento =.m if inw`wv' == 1
replace hh`wv'irento =.d if ha053_1 ==.d 
replace hh`wv'irento =.r if ha053_1 ==.r 
replace hh`wv'irento = 0 if hh`wv'iorent == 0
replace hh`wv'irento = ha053_1*12 if inrange(ha053_1,0,10000)
label variable hh`wv'irento "hh`wv'irento:w`wv' income: othr hh mems amount of rental income annually"
drop  hh`wv'iorento

********************
****income from land
****first type of land:cultivated land
gen hh`wv'ioclan=.
replace hh`wv'ioclan =.m if ha054s1 ==. & inw`wv' == 1
replace hh`wv'ioclan =.d if ha054s1 ==.d  
replace hh`wv'ioclan =.r if ha054s1 ==.r  
replace hh`wv'ioclan = 0 if ha054s2 == 2 | ha054s3 == 3 | ha054s4 == 4 | ha054s5 == 5 | ha058_1_ == 2
replace hh`wv'ioclan = 1 if ha058_1_ == 1
label variable hh`wv'ioclan "hh`wv'ioclan:w`wv' income: having cultivated land"
label value hh`wv'ioclan income


***Value of cultivated land***
gen hh`wv'iclan=.
replace hh`wv'iclan =.m if inw`wv' == 1
replace hh`wv'iclan =.d if ha060_1_ ==.d
replace hh`wv'iclan =.r if ha060_1_ ==.r
replace hh`wv'iclan = 0 if hh`wv'ioclan == 0 
replace hh`wv'iclan = ha060_1_ if inrange(ha060_1_,0,100000)
label variable hh`wv'iclan "hh`wv'iclan:w`wv' income: amount of income receive from cultivated land"

drop hh`wv'ioclan

****second type of land:forest
****income from forest
gen hh`wv'iofore=.
replace hh`wv'iofore =.m if ha054s2 ==.  & inw`wv' == 1
replace hh`wv'iofore =.d if ha054s2 ==.d  
replace hh`wv'iofore =.r if ha054s2 ==.r  
replace hh`wv'iofore = 0 if ha054s1 == 1 | ha054s3 == 3 | ha054s4 == 4 | ha054s5 == 5 | ha058_2_ == 2
replace hh`wv'iofore = 1 if ha058_2_ == 1  
label variable hh`wv'iofore "hh`wv'iofore:w`wv' income: having forest land"
label value hh`wv'iofore income

***Value of forest land***
gen hh`wv'ifore=.
replace hh`wv'ifore =.m if inw`wv' == 1
replace hh`wv'ifore =.d if ha060_2_ ==.d
replace hh`wv'ifore =.r if ha060_2_ ==.r
replace hh`wv'ifore = 0 if hh`wv'iofore == 0 
replace hh`wv'ifore = ha060_2_ if inrange(ha060_2_,0,100000)
label variable hh`wv'ifore "hh`wv'ifore:w`wv' income: amount of income receive from forest land"

drop hh`wv'iofore

****third type of land
****income from pasture
gen hh`wv'iopast=.
replace hh`wv'iopast =.m if ha054s3 ==. & inw`wv' == 1
replace hh`wv'iopast =.d if ha054s3 ==.d  
replace hh`wv'iopast =.r if ha054s3 ==.r  
replace hh`wv'iopast = 0 if ha054s1 == 1 | ha054s2 == 2 | ha054s4 == 4 | ha054s5 == 5 | ha058_3_ == 2
replace hh`wv'iopast = 1 if ha058_3_ == 1
label variable hh`wv'iopast "hh`wv'iopast:w`wv' income: having a pasture"
label value hh`wv'iopast income

***Value of pasture land***
gen hh`wv'ipast=.
replace hh`wv'ipast =.m if inw`wv' == 1
replace hh`wv'ipast =.d if ha060_3_ ==.d
replace hh`wv'ipast =.r if ha060_3_ ==.r
replace hh`wv'ipast = 0 if hh`wv'iopast == 0 
replace hh`wv'ipast = ha060_3_ if inrange(ha060_3_,0,100000)
label variable hh`wv'ipast "hh`wv'ipast:w`wv' income: amount of income receive from pasture"

drop hh`wv'iopast

***fourth type of land
****income from pond
gen hh`wv'iopond=.
replace hh`wv'iopond =.m if ha054s4 ==. & inw`wv' == 1
replace hh`wv'iopond =.d if ha054s4 ==.d  
replace hh`wv'iopond =.r if ha054s4 ==.r  
replace hh`wv'iopond = 0 if ha054s1 == 1 | ha054s2 == 2 | ha054s3 == 3 | ha054s5 == 5 | ha058_4_ == 2
replace hh`wv'iopond = 1 if ha058_4_ == 1  
label variable hh`wv'iopond "hh`wv'iopond:w`wv' income: having a pond"
label value hh`wv'iopond income

***Value of pond***
gen hh`wv'ipond=.
replace hh`wv'ipond =.m if inw`wv' == 1
replace hh`wv'ipond =.d if ha060_4_ ==.d
replace hh`wv'ipond =.r if ha060_4_ ==.r
replace hh`wv'ipond = 0 if hh`wv'iopond == 0 
replace hh`wv'ipond = ha060_4_ if inrange(ha060_4_,0,100000)
label variable hh`wv'ipond "hh`wv'ipond:w`wv' income: amount of income receive from pond"

drop hh`wv'iopond

*******************************
***TOTAL household land rent***
gen hh`wv'iland = .
missing_H hh`wv'iclan hh`wv'ifore hh`wv'ipast hh`wv'ipond, result(hh`wv'iland)
replace hh`wv'iland = hh`wv'iclan + hh`wv'ifore + hh`wv'ipast + hh`wv'ipond if ///
                    !mi(hh`wv'iclan) & !mi(hh`wv'ifore) & !mi(hh`wv'ipast) & !mi(hh`wv'ipond)
label variable hh`wv'iland "hh`wv'iland:w`wv' income: total amount of income receive from land"

drop hh`wv'iclan hh`wv'ifore hh`wv'ipast hh`wv'ipond

*************************************
****Other capital asset income*******
*************************************

**Income not from land and housing***
gen hh`wv'ioasst=.
replace hh`wv'ioasst =.m if inw`wv' == 1
replace hh`wv'ioasst =.d if ha064 ==.d  
replace hh`wv'ioasst =.r if ha064 ==.r  
replace hh`wv'ioasst = 0 if ha064 == 2 
replace hh`wv'ioasst = 1 if ha064 == 1  
label variable hh`wv'ioasst "hh`wv'ioasst:w`wv' income: having other income from assets"
label value hh`wv'ioasst income

***Value of asst***
gen hh`wv'ioast=.
replace hh`wv'ioast =.m if inw`wv' == 1
replace hh`wv'ioast =.d if ha064_1 ==.d
replace hh`wv'ioast =.r if ha064_1 ==.r
replace hh`wv'ioast = 0 if hh`wv'ioasst == 0 
replace hh`wv'ioast = ha064_1 if inrange(ha064_1,0,200000)
label variable hh`wv'ioast "hh`wv'ioast:w`wv' income: amount of income receive from other assets"

*Income value from interest
gen hh`wv'ioitrest=.
replace hh`wv'ioitrest =.m if inw`wv' == 1
replace hh`wv'ioitrest =.d if ha069 ==.d  
replace hh`wv'ioitrest =.r if ha069 ==.r  
replace hh`wv'ioitrest = 0 if ha069 == 2 
replace hh`wv'ioitrest = 1 if ha069 == 1  
label variable hh`wv'ioitrest "hh`wv'ioitrest:w`wv' income: having other income from interest"
label value hh`wv'ioitrest income

***Value of asst***
gen hh`wv'iitrest=.
replace hh`wv'iitrest =.m if inw`wv' == 1
replace hh`wv'iitrest =.d if ha071 ==.d 
replace hh`wv'iitrest =.r if ha071 ==.r 
replace hh`wv'iitrest = 0 if hh`wv'ioitrest == 0
replace hh`wv'iitrest = ha071 if inrange(ha071,0,4000000)
label variable hh`wv'iitrest "hh`wv'iitrest:w`wv' income: amount of income receive from interest"

drop hh`wv'ioasst hh`wv'ioitrest

*****************************************************
*******total household capital income**********
gen hh`wv'icaph = .
missing_H h`wv'irent hh`wv'irento hh`wv'iland hh`wv'ioast hh`wv'iitrest, result(hh`wv'icaph)
replace hh`wv'icaph = h`wv'irent + hh`wv'irento + hh`wv'iland + hh`wv'ioast + hh`wv'iitrest if ///
                    !mi(h`wv'irent) & !mi(hh`wv'irento) & !mi(hh`wv'iland) & !mi(hh`wv'ioast) & !mi(hh`wv'iitrest)
label variable hh`wv'icaph "hh`wv'icaph:w`wv' income: hhold other capital income"

drop h`wv'irent hh`wv'irento hh`wv'iland hh`wv'ioast hh`wv'iitrest

**********************************************
****calculate total household income ***
gen hh`wv'iearn = .
missing_H hh`wv'iagri hh`wv'isemp hh`wv'iwageo h`wv'iearn h`wv'isemp h`wv'ifring, result(hh`wv'iearn)
replace hh`wv'iearn = .b if h`wv'iearn == .b | h`wv'isemp == .b | h`wv'ifring == .b
replace hh`wv'iearn = hh`wv'iagri + hh`wv'isemp + hh`wv'iwageo + h`wv'iearn + h`wv'isemp + h`wv'ifring if ///
                  !mi(hh`wv'iagri) & !mi(hh`wv'isemp) & !mi(hh`wv'iwageo) & !mi(h`wv'iearn) & !mi(h`wv'isemp) & !mi(h`wv'ifring)
label variable hh`wv'iearn "hh`wv'iearn:w`wv' income: hhold total earnings"

gen hh`wv'ipen =.
missing_H h`wv'ipen hh`wv'ipeno, result(hh`wv'ipen)
replace hh`wv'ipen = .b if h`wv'ipen == .b
replace hh`wv'ipen = h`wv'ipen + hh`wv'ipeno if !mi(h`wv'ipen) & !mi(hh`wv'ipeno)
label variable hh`wv'ipen "hh`wv'ipen:w`wv' income: hhold total pension income "

gen hh`wv'igxfr = .
missing_H h`wv'igxfr hh`wv'igxfro hh`wv'igxfrh hh`wv'igxfrt, result(hh`wv'igxfr)
replace hh`wv'igxfr = .b if h`wv'igxfr == .b
replace hh`wv'igxfr = h`wv'igxfr + hh`wv'igxfro + hh`wv'igxfrh + hh`wv'igxfrt if ///
                   !mi(h`wv'igxfr) & !mi(hh`wv'igxfro) & !mi(hh`wv'igxfrh) & !mi(hh`wv'igxfrt)
label variable hh`wv'igxfr "hh`wv'igxfr:w`wv' income: hhold total government transfers "

gen hh`wv'iothr =.
missing_H  h`wv'iothr hh`wv'iothro, result(hh`wv'iothr)
replace hh`wv'iothr = .b if h`wv'iothr == .b
replace hh`wv'iothr = h`wv'iothr + hh`wv'iothro if !mi(h`wv'iothr) & !mi(hh`wv'iothro)
label variable hh`wv'iothr "hh`wv'iothrr:w`wv' income: hhold other household income"

gen hh`wv'icap =.
missing_H h`wv'icap hh`wv'icaph, result(hh`wv'icap)
replace hh`wv'icap = .b if h`wv'icap == .b
replace hh`wv'icap = h`wv'icap + hh`wv'icaph if !mi(h`wv'icap) & !mi(hh`wv'icaph)
label variable hh`wv'icap "hh`wv'icap:w`wv' income: hhold total capital income"

*****************************************************************
***TOTAL HH INCOME (HH MEMBER + R+S)  ***************************
*****************************************************************
gen hh`wv'itot = .
missing_H hh`wv'iearn hh`wv'ipen hh`wv'igxfr hh`wv'iothr hh`wv'icap, result(hh`wv'itot)
replace hh`wv'itot = .b if hh`wv'iearn == .b | hh`wv'ipen == .b | hh`wv'igxfr == .b | hh`wv'iothr == .b | hh`wv'icap == .b
replace hh`wv'itot = hh`wv'iearn + hh`wv'ipen + hh`wv'igxfr + hh`wv'iothr + hh`wv'icap if ///
                    !mi(hh`wv'iearn) & !mi(hh`wv'ipen) & !mi(hh`wv'igxfr) & !mi(hh`wv'iothr) & !mi(hh`wv'icap)
label variable hh`wv'itot "hh`wv'itot:w`wv' income: hhold total household income" 

**************************************************************************************************

*****************************************************************
***********                                      ****************
*********** EXPENDITURE MODULE **********************************
*********************************************************************

* ***********************************
* ****                          *****
* ****  HOUSEHODLE EXPENDITURE  *****
* ****                          *****
* ***********************************

* *==1. Food expenditure==*

* 1.1 Last week buy food, outdinning, alcohol, cigars, cigarettes and tobacco
gen hh`wv'cbfood=.
replace hh`wv'cbfood =.m if inw`wv' == 1
replace hh`wv'cbfood =.d if ge006==.d
replace hh`wv'cbfood =.r if ge006==.r
replace hh`wv'cbfood = ge006 if inrange(ge006,0,200000)

gen hh`wv'codinn=.
replace hh`wv'codinn =.m if inw`wv' == 1
replace hh`wv'codinn =.d if ge007==.d
replace hh`wv'codinn =.r if ge007==.r
replace hh`wv'codinn = ge007 if inrange(ge007,0,200000)

gen hh`wv'cacct=.
replace hh`wv'cacct =.m if inw`wv' == 1
replace hh`wv'cacct =.d if ge008==.d
replace hh`wv'cacct =.r if ge008==.r
replace hh`wv'cacct = ge008 if inrange(ge008,0,200000)

*****==========================******
**total household food consumption****
*****==========================*******
gen hh`wv'cfood =.
missing_H hh`wv'cbfood hh`wv'codinn hh`wv'cacct, result(hh`wv'cfood)
replace hh`wv'cfood = hh`wv'cbfood + hh`wv'codinn + hh`wv'cacct if ///
                    !mi(hh`wv'cbfood) & !mi(hh`wv'codinn) & !mi(hh`wv'cacct)
label variable hh`wv'cfood "hh`wv'cfood:w`wv' hhold food consumption, past 7 days"

drop hh`wv'cbfood hh`wv'codinn hh`wv'cacct


****===========================******
****Number of people at the household*****

gen hh`wv'cnump=.
replace hh`wv'cnump =.m if inw`wv' == 1
replace hh`wv'cnump =.d if ge004==.d
replace hh`wv'cnump =.r if ge004==.r
replace hh`wv'cnump =.i if inrange(ge004,150,500)
replace hh`wv'cnump = ge004 if inrange(ge004,0,100)
label variable hh`wv'cnump "hh`wv'cnump:w`wv' number of people having meal at the household "

* *==2. non-food daily expenditure fees monthly report== 
gen hh`wv'ccomu=. 
replace hh`wv'ccomu =.m if inw`wv' == 1
replace hh`wv'ccomu =.r if ge009_1==.r
replace hh`wv'ccomu =.d if inlist(ge009_1,9999,-999,-9999,.d)
replace hh`wv'ccomu = ge009_1 if inrange(ge009_1,0,9998)

gen hh`wv'cutil=.
replace hh`wv'cutil =.m if inw`wv' == 1
replace hh`wv'cutil =.r if ge009_2==.r
replace hh`wv'cutil =.d if inlist(ge009_2,9999,-999,-9999,.d)
replace hh`wv'cutil = ge009_2 if inrange(ge009_2,0,9998)

gen hh`wv'cfuel=.
replace hh`wv'cfuel =.m if inw`wv' == 1
replace hh`wv'cfuel =.r if ge009_3==.r
replace hh`wv'cfuel =.d if inlist(ge009_3,9999,-70,-999,-9999,.d)
replace hh`wv'cfuel = ge009_3 if inrange(ge009_3,0,9998)

gen hh`wv'cserv=.
replace hh`wv'cserv =.m if inw`wv' == 1
replace hh`wv'cserv =.r if ge009_4==.r
replace hh`wv'cserv =.d if inlist(ge009_4,9999,-999,-9999,.d)
replace hh`wv'cserv = ge009_4 if inrange(ge009_4,0,9998)

gen hh`wv'ctran=.
replace hh`wv'ctran =.m if inw`wv' == 1
replace hh`wv'ctran =.r if ge009_5==.r
replace hh`wv'ctran =.d if inlist(ge009_5,9999,-999,-9999,.d)
replace hh`wv'ctran = ge009_5 if inrange(ge009_5,0,9998)

gen hh`wv'cday=.
replace hh`wv'cday =.m if inw`wv' == 1
replace hh`wv'cday =.r if ge009_6==.r
replace hh`wv'cday =.d if inlist(ge009_6,9999,-999,-9999,.d)
replace hh`wv'cday = ge009_6 if inrange(ge009_6,0,9998)

gen hh`wv'centa=.
replace hh`wv'centa =.m if inw`wv' == 1
replace hh`wv'centa =.r if ge009_7==.r
replace hh`wv'centa =.d if inlist(ge009_7,9999,-999,-9999,.d)
replace hh`wv'centa = ge009_7 if inrange(ge009_7,0,9998)

**********************************
******Total non food expediture***
**********************************
gen hh`wv'cnf1m =.
missing_H hh`wv'ccomu hh`wv'cutil hh`wv'cfuel hh`wv'cserv hh`wv'ctran hh`wv'cday hh`wv'centa, result(hh`wv'cnf1m)
replace hh`wv'cnf1m = hh`wv'ccomu + hh`wv'cutil + hh`wv'cfuel + hh`wv'cserv + hh`wv'ctran + hh`wv'cday + hh`wv'centa if ///
                    !mi(hh`wv'ccomu) & !mi(hh`wv'cutil) & !mi(hh`wv'cfuel) & !mi(hh`wv'cserv) & !mi(hh`wv'ctran) & !mi(hh`wv'cday) & !mi(hh`wv'centa)
label variable hh`wv'cnf1m "hh`wv'cnf1m:w`wv' hhold non-food consumption, last month" 

drop hh`wv'ccomu hh`wv'cutil hh`wv'cfuel hh`wv'cserv hh`wv'ctran hh`wv'cday hh`wv'centa

* ==3. non-food expenditure==*
** Notes: exclude durable purchases (cars, appliances, electronics) and taxes

gen hh`wv'cbedd=.
replace hh`wv'cbedd =.m if inw`wv'==1
replace hh`wv'cbedd =.r if ge010_1==.r
replace hh`wv'cbedd =.d if inlist(ge010_1,9999,-999,-9999,-99990,.d)
replace hh`wv'cbedd = ge010_1 if inrange(ge010_1,0,9998) | inrange(ge010_1,10000,999999)

gen hh`wv'ctravel=.
replace hh`wv'ctravel =.m if inw`wv'==1
replace hh`wv'ctravel =.r if ge010_2==.r
replace hh`wv'ctravel =.d if inlist(ge010_2,9999,-999,-9999,.d)
replace hh`wv'ctravel = ge010_2 if inrange(ge010_2,0,9998) | inrange(ge010_2,10000,999999)

gen hh`wv'cheat=.
replace hh`wv'cheat =.m if inw`wv'==1
replace hh`wv'cheat =.r if ge010_3==.r
replace hh`wv'cheat =.d if inlist(ge010_3,9999,-999,-9999,.d)
replace hh`wv'cheat = ge010_3 if inrange(ge010_3,0,9998) | inrange(ge010_3,10000,999999)

gen hh`wv'cfurn=.
replace hh`wv'cfurn =.m if inw`wv'==1
replace hh`wv'cfurn =.r if ge010_4==.r
replace hh`wv'cfurn =.d if inlist(ge010_4,9999,-999,-9999,.d)
replace hh`wv'cfurn = ge010_4 if inrange(ge010_4,0,9998) | inrange(ge010_4,10000,999999)

gen hh`wv'cfit=.
replace hh`wv'cfit =.m if inw`wv'==1
replace hh`wv'cfit =.r if ge010_5==.r
replace hh`wv'cfit =.d if inlist(ge010_5,9999,-999,-9999,.d)
replace hh`wv'cfit = ge010_5 if inrange(ge010_5,0,9998) | inrange(ge010_5,10000,999999)

gen hh`wv'cbeau=.
replace hh`wv'cbeau =.m if inw`wv'==1
replace hh`wv'cbeau =.r if ge010_6==.r
replace hh`wv'cbeau =.d if inlist(ge010_6,9999,-999,-9999,.d)
replace hh`wv'cbeau = ge010_6 if inrange(ge010_6,0,9998) | inrange(ge010_6,10000,999999)

gen hh`wv'crepa=.
replace hh`wv'crepa =.m if inw`wv'==1
replace hh`wv'crepa =.r if ge010_7==.r
replace hh`wv'crepa =.d if inlist(ge010_7,9999,-999,-9999,.d)
replace hh`wv'crepa = ge010_7 if inrange(ge010_7,0,9998) | inrange(ge010_7,10000,999999)

gen hh`wv'ctax=.
replace hh`wv'ctax =.m if inw`wv'==1
replace hh`wv'ctax =.r if ge010_8==.r
replace hh`wv'ctax =.d if inlist(ge010_8,9999,-999,-9999,.d)
replace hh`wv'ctax = ge010_8 if inrange(ge010_8,0,9998) | inrange(ge010_8,10000,999999)

gen hh`wv'ceduc=.
replace hh`wv'ceduc =.m if inw`wv'==1
replace hh`wv'ceduc =.r if ge010_9==.r
replace hh`wv'ceduc =.d if inlist(ge010_9,9999,-999,-9999,.d)
replace hh`wv'ceduc = ge010_9 if inrange(ge010_9,0,9998) | inrange(ge010_9,10000,999999)

gen hh`wv'cmedi=.
replace hh`wv'cmedi =.m if inw`wv'==1
replace hh`wv'cmedi =.r if ge010_10==.r
replace hh`wv'cmedi =.d if inlist(ge010_10,9999,-999,-9999,.d)
replace hh`wv'cmedi = ge010_10 if inrange(ge010_10,0,9998) | inrange(ge010_10,10000,999999)

gen hh`wv'cauto=.
replace hh`wv'cauto =.m if inw`wv'==1
replace hh`wv'cauto =.r if ge010_11==.r
replace hh`wv'cauto =.d if inlist(ge010_11,999,-999,-9999,.d)
replace hh`wv'cauto = ge010_11 if inrange(ge010_11,0,9998) | inrange(ge010_11,10000,999999)

gen hh`wv'celec=.
replace hh`wv'celec =.m if inw`wv'==1
replace hh`wv'celec =.r if ge010_12==.r
replace hh`wv'celec =.d if inlist(ge010_12,9999,-999,-9999,.d)
replace hh`wv'celec = ge010_12 if inrange(ge010_12,0,9998) | inrange(ge010_12,10000,999999)

gen hh`wv'cprop=.
replace hh`wv'cprop =.m if inw`wv'==1
replace hh`wv'cprop =.r if ge010_13==.r
replace hh`wv'cprop =.d if inlist(ge010_13,9999,-999,-9999,.d)
replace hh`wv'cprop = ge010_13 if inrange(ge010_13,0,9998) | inrange(ge010_13,10000,999999)

gen hh`wv'cdona=.
replace hh`wv'cdona =.m if inw`wv'==1
replace hh`wv'cdona =.r if ge010_14==.r
replace hh`wv'cdona =.d if inlist(ge010_14,9999,-999,-9999,.d)
replace hh`wv'cdona = ge010_14 if inrange(ge010_14,0,9998) | inrange(ge010_14,10000,999999)


**********************************
******Total non food expediture***
**********************************
gen hh`wv'cnf1y =.
missing_H hh`wv'cbedd hh`wv'ctravel hh`wv'cheat hh`wv'cfit hh`wv'cbeau hh`wv'crepa hh`wv'ceduc hh`wv'cmedi hh`wv'cprop hh`wv'cdona hh`wv'cfurn hh`wv'ctax hh`wv'cauto hh`wv'celec, result(hh`wv'cnf1y)
replace hh`wv'cnf1y = hh`wv'cbedd + hh`wv'ctravel + hh`wv'cheat + hh`wv'cfit + hh`wv'cbeau + hh`wv'crepa + hh`wv'ceduc + hh`wv'cmedi + hh`wv'cprop + hh`wv'cdona + hh`wv'cfurn + hh`wv'ctax + hh`wv'cauto + hh`wv'celec if ///
                !mi(hh`wv'cbedd) & !mi(hh`wv'ctravel) & !mi(hh`wv'cheat) & !mi(hh`wv'cfit) & !mi(hh`wv'cbeau) & !mi(hh`wv'crepa) & !mi(hh`wv'ceduc) & !mi(hh`wv'cmedi) & !mi(hh`wv'cprop) & !mi(hh`wv'cdona) & !mi(hh`wv'cfurn) & !mi(hh`wv'ctax) & !mi(hh`wv'cauto) & !mi(hh`wv'celec)
label variable hh`wv'cnf1y "hh`wv'cnf1y:w`wv' hhold other non-food consumption, past year" 

drop hh`wv'cbedd hh`wv'ctravel hh`wv'cheat hh`wv'cfit hh`wv'cbeau hh`wv'crepa hh`wv'ceduc hh`wv'cmedi hh`wv'cprop hh`wv'cdona hh`wv'cfurn hh`wv'ctax hh`wv'cauto hh`wv'celec

* ===total household expenditure===****
***make all the consumption to annual***
gen hh`wv'cfooda =.
missing_H hh`wv'cfood, result(hh`wv'cfooda)
replace hh`wv'cfooda = hh`wv'cfood*52 if !mi(hh`wv'cfood)

gen hh`wv'cnf1ma =.
missing_H hh`wv'cnf1m, result(hh`wv'cnf1ma)
replace hh`wv'cnf1ma = hh`wv'cnf1m*12 if !mi(hh`wv'cnf1m)

gen hh`wv'ctot =.
missing_H hh`wv'cfooda hh`wv'cnf1ma hh`wv'cnf1y, result(hh`wv'ctot)
replace hh`wv'ctot = hh`wv'cfooda + hh`wv'cnf1ma + hh`wv'cnf1y if ///
                !mi(hh`wv'cfooda) & !mi(hh`wv'cnf1ma) & !mi(hh`wv'cnf1y)
label variable hh`wv'ctot "hh`wv'ctot:w`wv' total household consumption"

drop hh`wv'cfooda hh`wv'cnf1ma hh`wv'cnump

*******=======Total household per capita consumption=====**************
gen hh`wv'cperc = .
missing_H hh`wv'ctot h`wv'hhres, result(hh`wv'cperc)
replace hh`wv'cperc = hh`wv'ctot / h`wv'hhres if !mi(hh`wv'ctot) & !mi(h`wv'hhres)
label variable hh`wv'cperc "hh`wv'cperc:w`wv' total household per capita consumption"

drop r`wv'ifmemp s`wv'ifmemp h`wv'ifmemp r`wv'iwagea s`wv'iwagea h`wv'iwagea r`wv'ibonus s`wv'ibonus h`wv'ibonus r`wv'isjob s`wv'isjob h`wv'isjob
drop h`wv'ipeni h`wv'ipenw


***drop CHARLS household income raw variables***
drop `inc_w1_hhinc'

***drop CHARLS individual income raw variables***
drop `inc_w1_indinc'

***drop CHARLS employement raw variables***
drop `inc_w1_work'

***drop CHARLS weight raw variables***
drop `inc_w1_weight'

**drop CHARLS household roster file raw variables
drop `inc_w1_hhroster'



label define momdec      ///
 .f ".f:Dispersed"         ///
 0 "0.no"                ///
 1 "1.yes" 	 ///
 .s ".s=skip" 

label define daddec      ///
 .f ".f:Dispersed"         ///
 0 "0.no"                ///
 1 "1.yes" 	 ///
 .s ".s=skip" 
********************create wave 1 family variables*********************


*ret program name
local program H_CHARLS_family_w`wv'

*ret wave number
local wv=1
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2


***merge with household roster file***
local family_w1_hhroster a002_?_ a003* a002_1?_ /// 
                         a006_?_ a006_1?_ ///
                         a016_?_ a016_1?_ a017_?_ a017_1?_
merge m:1 householdID using "`wave_1_hhroster'", keepusing(`family_w1_hhroster') 
drop if _merge==2
drop _merge

***merge with family information file***
local family_w1_faminfo ca001_1_ ca001_2_ ca001_3_ ca001_4_  ///
                        ca007_1_ ca007_2_ ca007_3_ ca007_4_ ///
                        ca008_1_1_ ca008_1_2_ ca008_1_3_ ca008_1_4_ ///
                        ca008_2_1_ ca008_2_2_ ca008_2_3_ ca008_2_4_ ///
                        cb001 cb003 cb006_?_ ///
                        cb009 cb011 cb014_?_ cb017 cb019 ///
                        cb022_?_ cb025 cb027 ///
                        cb030_?_ cb033 cb035 cb038_?_ cb041 cb043 cb046_?_  ///
                        cb049_?_ cb049_1?_ ///
                        cc002_1 cc002_2 cc002_3 cc002_4 ///
                        cc001 cc003 cc004_? cc007_? cc008 cc006 ///
                        cc009_1 cc009_2 cc009_3 cc009_4 /// 
                        proxy
merge m:1 householdID using "`wave_1_faminfo'", keepusing(`family_w1_faminfo')
drop if _merge==2
drop _merge

***merge with demog file***
local family_w`wv'_demog be001
merge 1:1 ID using "`wave_1_demog'", keepusing(`family_w`wv'_demog') 
drop if _merge==2
drop _merge

***merge with family transfer file***
local family_w`wv'_famtran ce001 ce002_? ce002_1_every ///
                        ce004 ce005_? ce005_?_every ///
                        ce007 ce009_?_? ce009_1?_? ce009_?_?_every ce009_1?_?_every ///
                        ce011 ce013_?_? ce013_1?_? ce013_?_?_every ce013_1?_?_every ///
                        ce015 ce016_? ce016_?_every ///
                        ce018 ce019_? ce019_?_every ///
                        ce021 ce022_? ce022_?_every ///
                        ce024 ce025_? ce025_?_every ///
                        ce027 ce029_?_? ce029_1?_? ce029_?_?_every ce029_1?_?_every ///
                        ce031 ce033_?_? ce033_1?_? ce033_?_?_every ce033_1?_?_every ///
                        ce035 ce036_? ce036_?_every ///
                        ce038 ce039_? ce039_?_every
merge m:1 householdID using "`wave_1_famtran'", keepusing(`family_w`wv'_famtran') 
drop if _merge==2
drop _merge


*****************# people living in the household*****************

gen hhmsize =0 if inw`wv'==1
forvalues i=1/16 {
	replace hhmsize = hhmsize +1 if !mi(a002_`i'_) 
	replace hhmsize = hhmsize +1 if mi(a002_`i'_) & !mi(a006_`i'_)
	}


gen h`wv'hhres = hhmsize + h`wv'hhresp
label variable h`wv'hhres "h`wv'hhres:w`wv' number of people living in this household"

drop hhmsize

******************number of living sons and daughters ***************************
******************first, calculate the number in the household************
gen h`wv'cson=0 if inw`wv'==1
gen h`wv'cdau=0 if inw`wv'==1

forvalues i =1/16 { 
    replace h`wv'cson = h`wv'cson + 1 if ((a006_`i'_ == 7) & (a002_`i'_ == 1))   
    replace h`wv'cdau = h`wv'cdau + 1 if ((a006_`i'_ == 7) & (a002_`i'_ == 2))
}
label variable h`wv'cson "h`wv'cson:w`wv' Number of co-residing sons"
label variable h`wv'cdau "h`wv'cdau:w`wv' Number of co-residing daughters"

***********then, calculate the number outside the household************************
gen h`wv'ncson=0 if inw`wv'==1
gen h`wv'ncdau=0 if inw`wv'==1

forvalues i =1/14 { 
    replace h`wv'ncson = h`wv'ncson + (cb049_`i'_ == 1)   
    replace h`wv'ncdau = h`wv'ncdau + (cb049_`i'_ == 2) 
}
label variable h`wv'ncson "h`wv'ncson:w`wv' Number of non-coresiding sons"
label variable h`wv'ncdau "h`wv'ncdau:w`wv' Number of non-coresiding daughters"

***calculate the total number of living children********
gen h`wv'cchild = h`wv'cson + h`wv'cdau
label variable h`wv'cchild "h`wv'cchild:w`wv' Number of co-residing children"

gen h`wv'ncchild = h`wv'ncson + h`wv'ncdau
label variable h`wv'ncchild "h`wv'ncchild:w`wv' Number of non-coresiding children"

gen h`wv'dau = h`wv'cdau + h`wv'ncdau
label variable h`wv'dau "h`wv'dau:w`wv' Number of living daughters"

gen h`wv'son = h`wv'cson + h`wv'ncson
label variable h`wv'son "h`wv'son:w`wv' Number of living sons"

gen h`wv'child = h`wv'cchild + h`wv'ncchild
label variable h`wv'child "h`wv'child:w`wv' Number of living children"

drop h?cson h?cdau h?ncson h?ncdau h?cchild

******************number of deceased sons and daughters ***************************
gen h`wv'dson1=0 if inw`wv'==1
gen h`wv'ddau1=0 if inw`wv'==1

forvalues i =1/6 { 
    replace h`wv'dson1 = h`wv'dson1 + (cb006_`i'_ == 1)
    replace h`wv'ddau1 = h`wv'ddau1 + (cb006_`i'_ == 2) 
}

gen h`wv'dson2=0 if inw`wv'==1
gen h`wv'ddau2=0 if inw`wv'==1
forvalues i =1/2 { 
    replace h`wv'dson2 = h`wv'dson2 + (cb014_`i'_ == 1) 
    replace h`wv'ddau2 = h`wv'ddau2 + (cb014_`i'_ == 2)
}

gen h`wv'dson3=0 if inw`wv'==1
gen h`wv'ddau3=0 if inw`wv'==1
forvalues i =1/5 { 
    replace h`wv'dson3 = h`wv'dson3 + (cb022_`i'_ == 1) 
    replace h`wv'ddau3 = h`wv'ddau3 + (cb022_`i'_ == 2)
}

gen h`wv'dson4=0 if inw`wv'==1
gen h`wv'ddau4=0 if inw`wv'==1
forvalues i =1/3 { 
    replace h`wv'dson4 = h`wv'dson4 + (cb030_`i'_ == 1)
    replace h`wv'ddau4 = h`wv'ddau4 + (cb030_`i'_ == 2)
}

gen h`wv'dson5=0 if inw`wv'==1
gen h`wv'ddau5=0 if inw`wv'==1
forvalues i =1/5 { 
    replace h`wv'dson5 = h`wv'dson5 + (cb038_`i'_ == 1) 
    replace h`wv'ddau5 = h`wv'ddau5 + (cb038_`i'_ == 2)
}

gen h`wv'dson6=0 if inw`wv'==1
gen h`wv'ddau6=0 if inw`wv'==1
forvalues i =1/2 { 
    replace h`wv'dson6 = h`wv'dson6 + (cb046_`i'_ == 1)
    replace h`wv'ddau6 = h`wv'ddau6 + (cb046_`i'_ == 2)
}


***Nmber of deseased sons***
gen h`wv'dson = h`wv'dson1 + h`wv'dson2 + h`wv'dson3 + h`wv'dson4 + h`wv'dson5 + h`wv'dson6
label variable h`wv'dson "h`wv'dson:w`wv' Number of deceased sons"

***Number of deseased daughters***
gen h`wv'ddau = h`wv'ddau1 + h`wv'ddau2 + h`wv'ddau3 + h`wv'ddau4 + h`wv'ddau5 + h`wv'ddau6
label variable h`wv'ddau "h`wv'ddau:w`wv' Number of deceased daughters"

***Number of deceased children
gen h`wv'dchild = h`wv'dson + h`wv'ddau
label variable h`wv'dchild "h`wv'dchild:w`wv' Total number of deceased children"

drop h`wv'dson1 h`wv'dson2 h`wv'dson3 h`wv'dson4 h`wv'dson5 h`wv'dson6
drop h`wv'ddau1 h`wv'ddau2 h`wv'ddau3 h`wv'ddau4 h`wv'ddau5 h`wv'ddau6


****Number of Sibling*****
****Number of Alive older brother****
gen r`wv'livob=.
replace r`wv'livob= .m if cc002_1==. & inw`wv'==1
replace r`wv'livob= .p if cc002_1==. & proxy ==1
replace r`wv'livob= .d if cc002_1==.d
replace r`wv'livob= .r if cc002_1==.r
replace r`wv'livob=  0 if cc002_1==. & cc001==0 
replace r`wv'livob= cc002_1 if inrange(cc002_1,0,10)
label variable r`wv'livob "r`wv'livob:w`wv' R Number of living older brothers"

gen s`wv'livob=.
replace s`wv'livob=.m if cc007_1==. & inw`wv'==1
replace s`wv'livob=.p if cc007_1==. & proxy ==1
replace s`wv'livob=.d if cc007_1==.d
replace s`wv'livob=.r if cc007_1==.r
replace s`wv'livob= 0 if cc007_1==. & cc006 ==0
replace s`wv'livob=cc007_1 if inrange(cc007_1,0,10)
label variable s`wv'livob "s`wv'livob:w`wv' S Number of living older brothers"

****Number of Alive younger brother****
gen r`wv'livyb=.
replace r`wv'livyb= .m if cc002_2==. & inw`wv'==1
replace r`wv'livyb= .p if cc002_2==. & proxy ==1
replace r`wv'livyb= .d if cc002_2==.d
replace r`wv'livyb= .r if cc002_2==.r
replace r`wv'livyb=  0 if cc002_2==. & cc001==0 
replace r`wv'livyb= cc002_2 if inrange(cc002_2,0,10)
label variable r`wv'livyb "r`wv'livyb:w`wv' R Number of living younger brothers"

gen s`wv'livyb=.
replace s`wv'livyb=.m if cc007_2==. & inw`wv'==1
replace s`wv'livyb=.p if cc007_2==. & proxy ==1
replace s`wv'livyb=.d if cc007_2==.d
replace s`wv'livyb=.r if cc007_2==.r
replace s`wv'livyb= 0 if cc007_2==. & cc006 ==0
replace s`wv'livyb=cc007_2 if inrange(cc007_2,0,10)
label variable s`wv'livyb "s`wv'livyb:w`wv' S Number of living younger brothers"

****Number of Alive older sister****
gen r`wv'livos=.
replace r`wv'livos= .m if cc002_3==. & inw`wv'==1
replace r`wv'livos= .p if cc002_3==. & proxy ==1
replace r`wv'livos= .d if cc002_3==.d
replace r`wv'livos= .r if cc002_3==.r
replace r`wv'livos=  0 if cc002_3==. & cc001 ==0
replace r`wv'livos= cc002_3 if inrange(cc002_3,0,10)
label variable r`wv'livos "r`wv'livos:w`wv' R Number of living older sisters"

gen s`wv'livos=.
replace s`wv'livos=.m if cc007_3==. & inw`wv'==1
replace s`wv'livos=.p if cc007_3==. & proxy ==1
replace s`wv'livos=.d if cc007_3==.d
replace s`wv'livos=.r if cc007_3==.r
replace s`wv'livos= 0 if cc007_3==. & cc006 ==0
replace s`wv'livos=cc007_3 if inrange(cc007_3,0,10)
label variable s`wv'livos "s`wv'livos:w`wv' S Number of living older sisters"

****Number of Alive younger sister****
gen r`wv'livys=.
replace r`wv'livys= .m if cc002_4==. & inw`wv'==1
replace r`wv'livys= .p if cc002_4==. & proxy ==1
replace r`wv'livys= .d if cc002_4==.d
replace r`wv'livys= .r if cc002_4==.r
replace r`wv'livys=  0 if cc002_4==. & cc001 ==0
replace r`wv'livys=cc002_4 if inrange(cc002_4,0,10)
label variable r`wv'livys "r`wv'livys:w`wv' R Number of living younger sisters"

gen s`wv'livys=.
replace s`wv'livys=.m if cc007_4==. & inw`wv'==1
replace s`wv'livys=.p if cc007_4==. & proxy ==1
replace s`wv'livys=.d if cc007_4==.d
replace s`wv'livys=.r if cc007_4==.r
replace s`wv'livys= 0 if cc007_4==. & cc006 ==0
replace s`wv'livys=cc007_4 if inrange(cc007_4,0,10)
label variable s`wv'livys "s`wv'livys:w`wv' S Number of living younger sisters"

**********************************************************
**********summary of living brother, sister and siblings

gen r`wv'livsis=.
missing_H r`wv'livos r`wv'livys, result(r`wv'livsis)
replace r`wv'livsis= .p if r`wv'livos==.p | r`wv'livys==.p
replace r`wv'livsis= r`wv'livos + r`wv'livys if !mi(r`wv'livos) & !mi(r`wv'livys)
label variable r`wv'livsis "r`wv'livsis:w`wv' r Number of living sisters"

gen s`wv'livsis=.
missing_H s`wv'livos s`wv'livys, result(s`wv'livsis)
replace s`wv'livsis= .p if s`wv'livos==.p | s`wv'livys==.p
replace s`wv'livsis= s`wv'livos + s`wv'livys if !mi(s`wv'livos) & !mi(s`wv'livys)
label variable s`wv'livsis "s`wv'livsis:w`wv' s Number of living sisters"

gen r`wv'livbro=.
missing_H r`wv'livob r`wv'livyb, result(r`wv'livbro)
replace r`wv'livbro= .p if r`wv'livob==.p | r`wv'livyb==.p
replace r`wv'livbro= r`wv'livob + r`wv'livyb if !mi(r`wv'livob) & !mi(r`wv'livyb)
label variable r`wv'livbro "r`wv'livbro:w`wv' r Number of living brothers"

gen s`wv'livbro=.
missing_H s`wv'livob s`wv'livyb, result(s`wv'livbro)
replace s`wv'livbro= .p if s`wv'livob==.p | s`wv'livyb==.p
replace s`wv'livbro= s`wv'livob + s`wv'livyb if !mi(s`wv'livob) & !mi(s`wv'livyb)
label variable s`wv'livbro "s`wv'livbro:w`wv' s Number of living brothers"

gen r`wv'livsib=.
missing_H r`wv'livsis r`wv'livbro, result(r`wv'livsib)
replace r`wv'livsib= .p if r`wv'livsis==.p & r`wv'livbro==.p 
replace r`wv'livsib= r`wv'livsis + r`wv'livbro if !mi(r`wv'livsis) & !mi(r`wv'livbro)
label variable r`wv'livsib "r`wv'livsib:w`wv' r Number of living siblings"

gen s`wv'livsib=.
missing_H s`wv'livsis s`wv'livbro, result(s`wv'livsib)
replace s`wv'livsib= .p if s`wv'livsis==.p | s`wv'livbro==.p
replace s`wv'livsib= s`wv'livsis + s`wv'livbro if !mi(s`wv'livsis) & !mi(s`wv'livbro)
label variable s`wv'livsib "s`wv'livsib:w`wv' s Number of living siblings"

drop r`wv'livob r`wv'livyb r`wv'livos r`wv'livys s`wv'livob s`wv'livyb s`wv'livos s`wv'livys

***Number of deceased sibling***
****Number of Dead older brother****
gen r`wv'decob=.
replace r`wv'decob= .m if cc004_1==. & inw`wv'==1
replace r`wv'decob= .p if cc004_1==. & proxy ==1
replace r`wv'decob= .d if cc004_1==.d
replace r`wv'decob= .r if cc004_1==.r
replace r`wv'decob=  0 if cc004_1==. & cc003==0
replace r`wv'decob= cc004_1 if inrange(cc004_1,0,15)
label variable r`wv'decob "r`wv'decob:w`wv' R Number of deceased older brothers"

gen s`wv'decob=.
replace s`wv'decob= .m if cc009_1==. & inw`wv'==1
replace s`wv'decob= .p if cc009_1==. & proxy ==1
replace s`wv'decob= .d if cc009_1==.d
replace s`wv'decob= .r if cc009_1==.r
replace s`wv'decob=  0 if cc009_1==. & cc008==0
replace s`wv'decob=cc009_1 if inrange(cc009_1,0,15)
label variable s`wv'decob "s`wv'decob:w`wv' s numbers of deceased older brothers"

****Number of Dead younger brother****
gen r`wv'decyb=.
replace r`wv'decyb= .m if cc004_2==. & inw`wv'==1
replace r`wv'decyb= .p if cc004_2==. & proxy ==1
replace r`wv'decyb= .d if cc004_2==.d
replace r`wv'decyb= .r if cc004_2==.r
replace r`wv'decyb=  0 if cc004_2==. & cc003==0
replace r`wv'decyb=cc004_2 if inrange(cc004_2,0,15)
label variable r`wv'decyb "r`wv'decyb:w`wv' r Number of deceased younger brothers"

gen s`wv'decyb=.
replace s`wv'decyb= .m if cc009_2==. & inw`wv'==1
replace s`wv'decyb= .p if cc009_2==. & proxy ==1
replace s`wv'decyb= .d if cc009_2==.d
replace s`wv'decyb= .r if cc009_2==.r
replace s`wv'decyb=  0 if cc009_2==. & cc008==0
replace s`wv'decyb=cc009_2 if inrange(cc009_2,0,15)
label variable s`wv'decyb "s`wv'decyb:w`wv' s Number of deceased younger brothers"

****Number of Dead older sister****
gen r`wv'decos=.
replace r`wv'decos= .m if cc004_3==. & inw`wv'==1
replace r`wv'decos= .p if cc004_3==. & proxy ==1
replace r`wv'decos= .d if cc004_3==.d
replace r`wv'decos= .r if cc004_3==.r
replace r`wv'decos=  0 if cc004_3==. & cc003==0
replace r`wv'decos= cc004_3 if inrange(cc004_3,0,15)
label variable r`wv'decos "r`wv'decos:w`wv' R Number of deceased older sisters"

gen s`wv'decos=.
replace s`wv'decos= .m if cc009_3==. & inw`wv'==1
replace s`wv'decos= .p if cc009_3==. & proxy ==1
replace s`wv'decos= .d if cc009_3==.d
replace s`wv'decos= .r if cc009_3==.r
replace s`wv'decos=  0 if cc009_3==. & cc008==0
replace s`wv'decos=cc009_3 if inrange(cc009_3,0,15)
label variable s`wv'decos "s`wv'decos:w`wv' S Number of deceased older sisters"

****Number of Dead younger sister****
gen r`wv'decys=.
replace r`wv'decys= .m if cc004_4==. & inw`wv'==1
replace r`wv'decys= .p if cc004_4==. & proxy ==1
replace r`wv'decys= .d if cc004_4==.d
replace r`wv'decys= .r if cc004_4==.r
replace r`wv'decys=  0 if cc004_4==. & cc003==0
replace r`wv'decys=cc004_4 if inrange(cc004_4,0,15)
label variable r`wv'decys "r`wv'decys:w`wv' R Number of deceased younger sisters"

gen s`wv'decys=.
replace s`wv'decys= .m if cc009_4==. & inw`wv'==1
replace s`wv'decys= .p if cc009_4==. & proxy ==1
replace s`wv'decys= .d if cc009_4==.d
replace s`wv'decys= .r if cc009_4==.r
replace s`wv'decys=  0 if cc009_4==. & cc008==0
replace s`wv'decys=cc009_4 if inrange(cc009_4,0,15)
label variable s`wv'decys "s`wv'decys:w`wv' S Number of deceased younger sisters"

***Number of deceased sisters***
gen r`wv'decsis=.
missing_H r`wv'decos r`wv'decys, result(r`wv'decsis)
replace r`wv'decsis= .p if r`wv'decos==.p | r`wv'decys==.p
replace r`wv'decsis= r`wv'decos + r`wv'decys if !mi(r`wv'decos) & !mi(r`wv'decys)
label variable r`wv'decsis "r`wv'decsis:w`wv' r Number of deceased sisters"

gen s`wv'decsis=.
missing_H s`wv'decos s`wv'decys, result(s`wv'decsis)
replace s`wv'decsis= .p if s`wv'decos==.p | s`wv'decys==.p
replace s`wv'decsis= s`wv'decos + s`wv'decys if !mi(s`wv'decos) & !mi(s`wv'decys)
label variable s`wv'decsis "s`wv'decsis:w`wv' s Number of deceased sisters"

gen r`wv'decbro=.
missing_H r`wv'decob r`wv'decyb, result(r`wv'decbro)
replace r`wv'decbro= .p if r`wv'decob==.p | r`wv'decyb==.p
replace r`wv'decbro= r`wv'decob + r`wv'decyb if !mi(r`wv'decob) & !mi(r`wv'decyb)
label variable r`wv'decbro "r`wv'decbro:w`wv' r Number of deceased brothers"

gen s`wv'decbro=.
missing_H s`wv'decob s`wv'decyb, result(s`wv'decbro)
replace s`wv'decbro= .p if s`wv'decob==.p | s`wv'decyb==.p
replace s`wv'decbro= s`wv'decob + s`wv'decyb if !mi(s`wv'decob) & !mi(s`wv'decyb)
label variable s`wv'decbro "s`wv'decbro:w`wv' s Number of deceased brothers"

gen r`wv'decsib=.
missing_H r`wv'decsis r`wv'decbro, result(r`wv'decsib)
replace r`wv'decsib= .p if r`wv'decsis==.p | r`wv'decbro==.p 
replace r`wv'decsib=r`wv'decsis + r`wv'decbro if !mi(r`wv'decsis) & !mi(r`wv'decbro)
label variable r`wv'decsib "r`wv'decsib:w`wv' r Number of deceased siblings"

gen s`wv'decsib=.
missing_H s`wv'decsis s`wv'decbro, result(s`wv'decsib)
replace s`wv'decsib= .p if s`wv'decsis==.p | s`wv'decbro==.p
replace s`wv'decsib=s`wv'decsis + s`wv'decbro if !mi(s`wv'decsis) & !mi(s`wv'decbro)
label variable s`wv'decsib "s`wv'decsib:w`wv' s Number of deceased siblings"

drop r`wv'decob r`wv'decyb r`wv'decos r`wv'decys s`wv'decob s`wv'decyb s`wv'decos s`wv'decys

*******************************************
***Parental Mortality: Mother Alive***

***Parents are HH members****
gen w1rmom=0 if inw`wv'==1
gen w1smom=0 if inw`wv'==1
gen w1rdad=0 if inw`wv'==1
gen w1sdad=0 if inw`wv'==1
forvalues i =1/16 { 
    replace w1rmom = w1rmom + 1 if a006_`i'_ == 1
    replace w1smom = w1smom + 1 if a006_`i'_ == 3
    replace w1rdad = w1rdad + 1 if a006_`i'_ == 2
    replace w1sdad = w1sdad + 1 if a006_`i'_ == 4  
}

gen r`wv'momliv=.
replace r`wv'momliv = .m if inw`wv'==1 
replace r`wv'momliv = 0 if ca001_2_ == 2
replace r`wv'momliv = 1 if ca001_2_ == 1
replace r`wv'momliv = 1 if inrange(w1rmom,1,2)
label variable r`wv'momliv "r`wv'momliv:w`wv' r mother alive"
label values r`wv'momliv momliv

*spouse parental motality mother alive
gen s`wv'momliv=.
replace s`wv'momliv = .m if inw`wv'==1 
replace s`wv'momliv = 0 if ca001_4_ == 2
replace s`wv'momliv = 1 if ca001_4_ == 1
replace s`wv'momliv = 1 if inrange(w1smom,1,2)
label variable s`wv'momliv "s`wv'momliv:w`wv' s mother alive"
label values s`wv'momliv momliv

***Parental Mortality: Father Alive***
gen r`wv'dadliv=.
replace r`wv'dadliv = .m if inw`wv'==1 
replace r`wv'dadliv = 0 if ca001_1_ == 2
replace r`wv'dadliv = 1 if ca001_1_ == 1
replace r`wv'dadliv = 1 if inrange(w1rdad,1,2)
label variable r`wv'dadliv "r`wv'dadliv:w`wv' r father alive"
label values r`wv'dadliv dadliv

**spouse parental motality father alive
gen s`wv'dadliv=.
replace s`wv'dadliv = .m if inw`wv'==1 
replace s`wv'dadliv = 0 if ca001_3_ == 2
replace s`wv'dadliv = 1 if ca001_3_ == 1
replace s`wv'dadliv = 1 if inrange(w1sdad,1,2)
label variable s`wv'dadliv "s`wv'dadliv:w`wv' s father alive"
label values s`wv'dadliv dadliv

***Number of living parents***
gen r`wv'livpar = .
replace r`wv'livpar = .m if r`wv'dadliv == .m | r`wv'momliv == .m
replace r`wv'livpar = 0  if r`wv'dadliv == 0 & r`wv'momliv == 0
replace r`wv'livpar = 1  if r`wv'momliv == 1 & r`wv'dadliv == 0
replace r`wv'livpar = 1  if r`wv'momliv == 0 & r`wv'dadliv == 1
replace r`wv'livpar = 2  if r`wv'momliv == 1 & r`wv'dadliv == 1
label variable r`wv'livpar "r`wv'livpar:w`wv' r Number of living parents"


gen s`wv'livpar=.
replace s`wv'livpar = .m if s`wv'dadliv == .m | s`wv'momliv == .m
replace s`wv'livpar = 0  if s`wv'dadliv == 0 & s`wv'momliv == 0
replace s`wv'livpar = 1  if s`wv'momliv == 1 & s`wv'dadliv == 0
replace s`wv'livpar = 1  if s`wv'momliv == 0 & s`wv'dadliv == 1
replace s`wv'livpar = 2  if s`wv'momliv == 1 & s`wv'dadliv == 1
label variable s`wv'livpar "s`wv'livpar:w`wv' r Number of living parents"

**********Parent age**************
gen w1rmomy=0 if inw`wv'==1
gen w1smomy=0 if inw`wv'==1
gen w1rdady=0 if inw`wv'==1
gen w1sdady=0 if inw`wv'==1
forvalues i =1/16 { 
    replace w1rmomy = a003_1_`i'_ if a006_`i'_ == 1 & inrange(a003_1_`i'_,1900,1990)
    replace w1smomy = a003_1_`i'_ if a006_`i'_ == 3 & inrange(a003_1_`i'_,1900,1990)
    replace w1rdady = a003_1_`i'_ if a006_`i'_ == 2 & inrange(a003_1_`i'_,1900,1990)
    replace w1sdady = a003_1_`i'_ if a006_`i'_ == 4 & inrange(a003_1_`i'_,1900,1990) 
}

gen w1drmomy=ca008_1_2_ if inrange(ca008_1_2_,1000,2030)
gen w1drmoma=ca008_2_2_ if inrange(ca008_2_2_ ,1000,2030)
gen w1armomy=ca007_2_  if inrange(ca007_2_,1000,2030)

gen w1dsmomy=ca008_1_4_ if inrange(ca008_1_4_,1000,2030)
gen w1dsmoma=ca008_2_4_ if inrange(ca008_2_4_ ,1000,2030)
gen w1asmomy=ca007_4_  if inrange(ca007_4_,1000,2030)

gen w1drdady=ca008_1_1_ if inrange(ca008_1_1_,1000,2030)
gen w1drdada=ca008_2_1_ if inrange(ca008_2_1_ ,1000,2030)
gen w1ardady=ca007_1_  if inrange(ca007_1_,1000,2030)

gen w1dsdady=ca008_1_3_ if inrange(ca008_1_3_,1000,2030)
gen w1dsdada=ca008_2_3_ if inrange(ca008_2_3_ ,1000,2030)
gen w1asdady=ca007_3_  if inrange(ca007_3_,1000,2030)


****Mother's deceased age ****

gen r1momage=.
replace r1momage=.m if (ca007_2_==. | ca008_1_2_==.) & inw`wv' == 1
replace r1momage=.i if !inrange(ca007_2_,1850,1950) | !inrange(ca008_1_2_,1900,2011)
replace r1momage=.d if inlist(ca007_2_,9999,-9999) | inlist(ca008_1_2_,9999,-9999) | ca007_2_==ca008_1_2_
replace r1momage=(r1iwy-w1rmomy)    if inrange(w1rmomy,1900,1990)
replace r1momage=(r1iwy-ca007_2_)   if ca001_2_==1 & inrange(ca007_2_,1850,1950)
replace r1momage=(ca008_1_2_ - ca007_2_) if ca001_2_==2 & inrange(ca008_1_2_,1900,2011) & inrange(ca007_2_,1850,1950) & ca007_2_~=ca008_1_2_
replace r1momage=ca008_2_2_            if ca001_2_==2 & inrange(ca008_2_2_,1,120)
label variable r`wv'momage "r`wv'momage:w`wv' r mother's age current/at death "

*spouse parental motality mother age
gen s1momage=.
replace s1momage=.m if (ca007_4_==. | ca008_1_4_==.) & inw`wv' == 1
replace s1momage=.i if !inrange(ca007_4_,1850,1950) | !inrange(ca008_1_4_,1900,2011)
replace s1momage=.d if inlist(ca007_4_,9999,-9999) | inlist(ca008_1_4_,9999,-9999) | ca007_4_==ca008_1_4_
replace s1momage=(r1iwy-w1smomy)    if inrange(w1smomy,1900,1990)
replace s1momage=(r1iwy-ca007_4_)   if ca001_4_==1 & inrange(ca007_4_,1850,1950)
replace s1momage=(ca008_1_4_-ca007_4_) if ca001_4_==2 & inrange(ca008_1_4_,1900,2011) & inrange(ca007_4_,1850,1950) & ca007_4_~=ca008_1_4_
replace s1momage=ca008_2_4_            if ca001_4_==2 & inrange(ca008_2_4_,1,120)
label variable s`wv'momage "s`wv'momage:w`wv' s mother's age current/at death"

****Father deceased age***
gen r1dadage=.
replace r1dadage=.m if (ca007_1_==. | ca008_1_1_==.) & inw`wv' == 1
replace r1dadage=.i if !inrange(ca007_1_,1850,1950) | !inrange(ca008_1_1_,1900,2011)
replace r1dadage=.d if inlist(ca007_1_,9999,-9999) | inlist(ca008_1_1_,9999,-9999) | ca007_1_==ca008_1_1_
replace r1dadage=(r1iwy-w1rdady)    if inrange(w1rdady,1900,1990)
replace r1dadage=(r1iwy-ca007_1_)   if ca001_1_==1 & inrange(ca007_1_,1850,1950)
replace r1dadage=(ca008_1_1_ - ca007_1_) if ca001_1_==2 & inrange(ca008_1_1_,1900,2011) & inrange(ca007_1_,1850,1950) & ca007_1_~=ca008_1_1_
replace r1dadage=ca008_2_1_              if ca001_1_==2 & inrange(ca008_2_1_,1,120)
replace r1dadage=.m if inrange(r1dadage,120,150)
label variable r`wv'dadage "r`wv'dadage:w`wv' r mother's age current/at death"

*spouse parental motality father age
gen s1dadage=.
replace s1dadage=.m if (ca007_3_==. | ca008_1_3_==.) & inw`wv' == 1
replace s1dadage=.i if !inrange(ca007_3_,1850,1950) | !inrange(ca008_1_3_,1900,2011)
replace s1dadage=.d if inlist(ca007_3_,9999,-9999) | inlist(ca008_1_3_,9999,-9999) | ca007_3_==ca008_1_3_
replace s1dadage=(r1iwy-w1sdady)    if inrange(w1sdady,1900,1990)
replace s1dadage=(r1iwy-ca007_3_)   if ca001_3_==1 & inrange(ca007_3_,1850,1950)
replace s1dadage=(ca008_1_3_ - ca007_3_) if ca001_3_==2 & inrange(ca008_1_3_,1900,2011) & inrange(ca007_3_,1850,1950) & ca007_3_~=ca008_1_3_
replace s1dadage=ca008_2_3_              if ca001_3_==2 & inrange(ca008_2_3_,1,120)
label variable s`wv'dadage "s`wv'dadage:w`wv' s mother's age current/at death"



*******************************************************************************
**                                                                          ***
** 6. Private Transfer Variables between parents and children               ***
**                                                                          ***
*******************************************************************************

*****************************************
* help from parents ce001
*skip if both or one of parents died before 2010 or both are hhmember

gen w1ce001s=0 if inw`wv' == 1
replace w1ce001s=1 if ca001_1_==1 | (ca001_1_==2 & inrange(ca008_1_1,2010,2020) ) | ca001_2_==1 |  (ca001_2_==2 & inrange(ca008_1_2,2010,2020) )

gen h`wv'opar=.
replace h`wv'opar =.m if ce001==. & inw`wv'==1 
replace h`wv'opar =.d if ce001==.d
replace h`wv'opar =.r if ce001==.r
replace h`wv'opar = 0 if w1ce001s==0
replace h`wv'opar = 0 if ce001==2
replace h`wv'opar = 1 if ce001==1

forvalues i=1/4 {
	if `i'<2 {
		gen help_`i'=.m
	  replace help_`i'=.d           if inlist(ce002_`i',-9999)
		replace help_`i'=ce002_`i'*12 if ce002_`i'_every==1
		replace help_`i'=ce002_`i'*4  if ce002_`i'_every==2
		replace help_`i'=ce002_`i'*2  if ce002_`i'_every==3
		replace help_`i'=ce002_`i'    if ce002_`i'_every==4
		replace help_`i'=ce002_`i'    if mi(ce002_`i'_every)
	}
	else {
	  gen help_`i'=.d           if inlist(ce002_`i',-9999)
		replace help_`i'=ce002_`i'  
	}
}

egen h1par=rowtotal(help_1-help_4),m
replace h`wv'par = .m if h`wv'opar==1 & (h`wv'par<0 | h`wv'par==.)
replace h`wv'par = h`wv'opar if inlist(h`wv'opar,.d,.r,.n,.m)
replace h`wv'par = 0 if h`wv'opar==0


drop help_1-help_4

*****************************************
* help from  parents-in-law ce004

gen w1ce004s=0 if inw`wv' == 1
replace w1ce004s=1 if ca001_4_==1 | (ca001_4_==2 & inrange(ca008_1_4_,2010,2020) ) | ca001_3_==1 |  (ca001_3_==2 & inrange(ca008_1_3,2010,2020) )


gen h`wv'oparlaw=.
replace h`wv'oparlaw =.m if ce004==. & inw`wv'==1 
replace h`wv'oparlaw =.d if ce004==.d
replace h`wv'oparlaw =.r if ce004==.r
replace h`wv'oparlaw = 0 if w1ce004s==0
replace h`wv'oparlaw = 0 if ce004==2
replace h`wv'oparlaw = 1 if ce004==1


forvalues i=1/4 {
	if `i'<3 {
	  gen help_`i'=.m
	  replace help_`i'=.d          if inlist(ce005_`i',-9999)
		replace help_`i'=ce005_`i'*12    if ce005_`i'_every==1
		replace help_`i'=ce005_`i'*4 if ce005_`i'_every==2
		replace help_`i'=ce005_`i'*2 if ce005_`i'_every==3
		replace help_`i'=ce005_`i'   if ce005_`i'_every==4
		replace help_`i'=ce005_`i'   if mi(ce005_`i'_every)
	}
	else {
	  gen help_`i'=.d           if inlist(ce005_`i',-9999)
		replace help_`i'=ce005_`i'  
	}
}
egen h`wv'parlaw=rowtotal(help_1-help_4),m
replace h`wv'parlaw =.m if h`wv'oparlaw==1 & (h`wv'parlaw<0 | h`wv'parlaw==.)
replace h`wv'parlaw = h`wv'oparlaw if inlist(h`wv'oparlaw,.d,.r,.n,.m)
replace h`wv'parlaw =0 if h`wv'oparlaw==0

drop help_1-help_4


******************************
* help to parents ce021

gen h`wv'o2par=.
replace h`wv'o2par =.m if ce021==. & inw`wv'==1 
replace h`wv'o2par =.d if ce021==.d
replace h`wv'o2par =.r if ce021==.r
replace h`wv'o2par = 0 if w1ce001s==0
replace h`wv'o2par = 0 if ce021==2
replace h`wv'o2par = 1 if ce021==1

forvalues i=1/4 {
	if `i'<3 {
	  gen help_`i'=.m
	  replace help_`i'=.d           if inlist(ce022_`i',-9999)
		replace help_`i'=ce022_`i'*12    if ce022_`i'_every==1
		replace help_`i'=ce022_`i'*4 if ce022_`i'_every==2
		replace help_`i'=ce022_`i'*2 if ce022_`i'_every==3
		replace help_`i'=ce022_`i'   if ce022_`i'_every==4
		replace help_`i'=ce022_`i'   if mi(ce022_`i'_every)
	*	replace help_`i'=(ce022_`i'_a+ce022_`i'_b)/2 if mi(help_`i') & ce022_`i'_b<1000000
	}
	else {
	  gen help_`i'=.d           if inlist(ce022_`i',-9999)
		replace help_`i'=ce022_`i'  
	*	replace help_`i'=(ce022_`i'_a+ce022_`i'_b)/2 if mi(help_`i') & ce022_`i'_b<1000000
	}
}
egen h`wv'2par=rowtotal(help_1-help_4),m
replace h`wv'2par = .m if h`wv'o2par==1 & (h`wv'2par<0 | h`wv'2par==.)
replace h`wv'2par = h`wv'o2par if mi(h12par) & inlist(h`wv'o2par,.d,.r,.n,.m)
replace h`wv'2par = 0 if h`wv'o2par == 0

drop help_1-help_4

******************************
* help to parents-in-law ce024

gen h`wv'o2parlaw=.
replace h`wv'o2parlaw =.m if ce024==. & inw`wv'==1 
replace h`wv'o2parlaw =.d if ce024==.d
replace h`wv'o2parlaw =.r if ce024==.r
replace h`wv'o2parlaw = 0 if w1ce004s==0
replace h`wv'o2parlaw = 0 if ce024==2
replace h`wv'o2parlaw = 1 if ce024==1

forvalues i=1/4 {
	if `i'<3 {
	  gen help_`i'=.m
	  replace help_`i'=.d          if inlist(ce025_`i',-9999)
		replace help_`i'=ce025_`i'*12    if ce025_`i'_every==1
		replace help_`i'=ce025_`i'*4 if ce025_`i'_every==2
		replace help_`i'=ce025_`i'*2 if ce025_`i'_every==3
		replace help_`i'=ce025_`i'   if ce025_`i'_every==4
		replace help_`i'=ce025_`i'   if mi(ce025_`i'_every)
	*	replace help_`i'=(ce025_`i'_a+ce025_`i'_b)/2 if mi(help_`i') & ce025_`i'_b<1000000
	}
	else {
	  gen help_`i'=.d          if inlist(ce025_`i',-9999)
		replace help_`i'=ce025_`i'  
	*	replace help_`i'=(ce025_`i'_a+ce025_`i'_b)/2 if mi(help_`i') & ce025_`i'_b<1000000
	}
}
egen h`wv'2parlaw=rowtotal(help_1-help_4),m
replace h`wv'2parlaw =.m if h`wv'o2parlaw==1 & (h`wv'2parlaw<0 | h`wv'2parlaw==.)
replace h`wv'2parlaw = h`wv'o2parlaw if mi(h12parlaw) & inlist(h`wv'o2parlaw,.d,.r,.n,.m)
replace h`wv'2parlaw = 0 if h`wv'o2parlaw == 0

drop help_1-help_4


*****************************************
********===Parents Transfer===**********
*****************************************
gen h`wv'fpany = .
missing_H h`wv'opar h`wv'oparlaw, result(h`wv'fpany)
replace h`wv'fpany = 0 if h`wv'opar== 0 | h`wv'oparlaw== 0
replace h`wv'fpany = 1 if h`wv'opar== 1 | h`wv'oparlaw== 1
la var h`wv'fpany "h`wv'fpany:w`wv' any transfer from parents/parents-in-law"
label val h`wv'fpany yesno

gen h`wv'fpamt=.
missing_H h`wv'par h`wv'parlaw, result(h`wv'fpamt)
replace h`wv'fpamt = 0 if h`wv'fpany== 0
replace h`wv'fpamt = h`wv'par + h`wv'parlaw if !mi(h`wv'par) & !mi(h`wv'parlaw)
la var h`wv'fpamt "h`wv'fpamt:w`wv' amount of transfers from parents/parents-in-law"

gen h`wv'tpany = .
missing_H h`wv'o2par h`wv'o2parlaw, result(h`wv'tpany)
replace h`wv'tpany = 0 if h`wv'o2par== 0 | h`wv'o2parlaw== 0 
replace h`wv'tpany = 1 if h`wv'o2par== 1 | h`wv'o2parlaw== 1
la var h`wv'tpany "h`wv'tpany:w`wv' any transfer to parents/parents-in-law"
label val h`wv'tpany yesno

gen h`wv'tpamt=.
missing_H h`wv'2par h`wv'2parlaw, result(h`wv'tpamt)
replace h`wv'tpamt =0  if h`wv'tpany== 0 
replace h`wv'tpamt = h`wv'2par + h`wv'2parlaw if !mi(h`wv'2par) & !mi(h`wv'2parlaw)
la var h`wv'tpamt "h`wv'tpamt:w`wv' amount of transfers to parents/parents-in-law"


**********************************************
**********************************************
* help from children ce007
**skip if no child, or no non-coresiding child

gen h`wv'oichild=.
replace h`wv'oichild =.m if ce007==. & inw`wv'==1 
replace h`wv'oichild =.d if ce007==.d
replace h`wv'oichild =.r if ce007==.r
replace h`wv'oichild = 0 if h`wv'child==0
replace h`wv'oichild = 0 if h`wv'ncchild==0
replace h`wv'oichild = 0 if ce007==2
replace h`wv'oichild = 1 if ce007==1

forvalues j=1/10 {	
    forvalues i=1/4 {
		     if `i'<3 {
		  gen help_`j'_`i' = .m
		  replace help_`j'_`i' =.d if inlist(ce009_`j'_`i',-9999)
			replace help_`j'_`i'=ce009_`j'_`i'*12    if ce009_`j'_`i'_every==1 
			replace help_`j'_`i'=ce009_`j'_`i'*4 if ce009_`j'_`i'_every==2
			replace help_`j'_`i'=ce009_`j'_`i'*2 if ce009_`j'_`i'_every==3
			replace help_`j'_`i'=ce009_`j'_`i'   if ce009_`j'_`i'_every==4
			replace help_`j'_`i'=ce009_`j'_`i'   if mi(ce009_`j'_`i'_every)
		}
		else {
		  gen help_`j'_`i' =.d if inlist(ce009_`j'_`i',-9999)
			replace help_`j'_`i'=ce009_`j'_`i'  
		}
	}
}
egen h`wv'ichild=rowtotal(help_1_1-help_10_4),m
replace h`wv'ichild=.m if h`wv'oichild==1 & ( h`wv'ichild <0 | h`wv'ichild==.)
replace h`wv'ichild=h`wv'oichild if mi(h1ichild) & inlist(h`wv'oichild,.d,.r,.m)
replace h`wv'ichild=0 if mi(h1ichild) & h`wv'oichild==0

drop help_1_1-help_10_4

******************************
* help from grandchildren ce011 **NEED CHECK SKIP PATTERN
***skip if no non-coresident grandchild or grandchild are younger than 10

gen h`wv'ogchild=.
replace h`wv'ogchild =.m if ce011==. & inw`wv'==1 
replace h`wv'ogchild =.d if ce011==.d
replace h`wv'ogchild =.r if ce011==.r
replace h`wv'ogchild = 0 if h`wv'child==0
replace h`wv'ogchild = 0 if h`wv'ncchild==0
replace h`wv'ogchild = 0 if ce011==2
replace h`wv'ogchild = 1 if ce011==1


forvalues j=1/10 {
	forvalues i=1/4 {
		if `i'<3 {
		  gen help_`j'_`i' = .m
		  replace help_`j'_`i' =.d if inlist(ce013_`j'_`i',-9999)
		 	replace help_`j'_`i'=ce013_`j'_`i'*12 if ce013_`j'_`i'_every==1
			replace help_`j'_`i'=ce013_`j'_`i'*4  if ce013_`j'_`i'_every==2
			replace help_`j'_`i'=ce013_`j'_`i'*2  if ce013_`j'_`i'_every==3
			replace help_`j'_`i'=ce013_`j'_`i'    if ce013_`j'_`i'_every==4
			replace help_`j'_`i'=ce013_`j'_`i'    if mi(ce013_`j'_`i'_every)
		*	replace help_`j'_`i'=(ce013_`j'_`i'_a+ce013_`j'_`i'_b)/2 if mi(help_`j'_`i') & ce013_`j'_`i'_b<1000000
		}
		else {
		  gen help_`j'_`i' =.d if inlist(ce013_`j'_`i',-9999)
			replace help_`j'_`i'=ce013_`j'_`i'  
		*	replace help_`j'_`i'=(ce013_`j'_`i'_a+ce013_`j'_`i'_b)/2 if mi(help_`j'_`i') & ce013_`j'_`i'_b<1000000
		}
	}
}
egen h`wv'gchild=rowtotal(help_1_1-help_10_4),m
replace h`wv'gchild=.m if h`wv'ogchild==1 & ( h`wv'gchild <0 | h`wv'gchild==.)
replace h`wv'gchild=h`wv'ogchild if mi(h`wv'gchild) & inlist(h`wv'ogchild,.d,.r,.m)
replace h`wv'gchild=0 if mi(h`wv'gchild) & h`wv'ogchild==0

drop help_1_1-help_10_4

******************************
* help to children ce027 skip if no non-coresdient children

gen h`wv'o2child=.
replace h`wv'o2child =.m if ce027==. & inw`wv'==1
replace h`wv'o2child =.d if ce027==.d
replace h`wv'o2child =.r if ce027==.r
replace h`wv'o2child = 0 if h`wv'child==0
replace h`wv'o2child = 0 if h`wv'ncchild==0
replace h`wv'o2child = 0 if ce027==2
replace h`wv'o2child = 1 if ce027==1


forvalues j=1/10 {
	forvalues i=1/4 {
		if `i'<3 {
		  gen help_`j'_`i' = .m
		  replace help_`j'_`i' =.d if inlist(ce029_`j'_`i',-9999)
			replace help_`j'_`i'=ce029_`j'_`i'*12    if ce029_`j'_`i'_every==1
			replace help_`j'_`i'=ce029_`j'_`i'*4 if ce029_`j'_`i'_every==2
			replace help_`j'_`i'=ce029_`j'_`i'*2 if ce029_`j'_`i'_every==3
			replace help_`j'_`i'=ce029_`j'_`i'   if ce029_`j'_`i'_every==4
			replace help_`j'_`i'=ce029_`j'_`i'   if mi(ce029_`j'_`i'_every)
		*	replace help_`j'_`i'=(ce029_`j'_`i'_a+ce029_`j'_`i'_b)/2 if mi(help_`j'_`i') & ce029_`j'_`i'_b<1000000
		}
		else {
		  gen help_`j'_`i' =.d if inlist(ce029_`j'_`i',-9999)
			replace help_`j'_`i'=ce029_`j'_`i'  
		*	replace help_`j'_`i'=(ce029_`j'_`i'_a+ce029_`j'_`i'_b)/2 if mi(help_`j'_`i') & ce029_`j'_`i'_b<1000000
		}
	}
}
egen h`wv'2child=rowtotal(help_1_1-help_10_4),m
replace h`wv'2child=.m if h`wv'o2child==1 & ( h`wv'2child <0 | h`wv'2child==.)
replace h`wv'2child=h`wv'o2child if mi(h12child) &  inlist(h`wv'o2child,.d,.r,.m)
replace h`wv'2child=0 if mi(h12child) & h`wv'o2child==0

drop help_1_1-help_10_4

******************************
* help to grandchildren ce031
**skip if no non-coresident grandchild

gen h`wv'o2gchild=.
replace h`wv'o2gchild =.m if ce031==. & inw`wv'==1 
replace h`wv'o2gchild =.d if ce031==.d
replace h`wv'o2gchild =.r if ce031==.r
replace h`wv'o2gchild = 0 if h`wv'child==0
replace h`wv'o2gchild = 0 if h`wv'ncchild==0
replace h`wv'o2gchild = 0 if ce031==2
replace h`wv'o2gchild = 1 if ce031==1

forvalues j=1/10 {
	forvalues i=1/4 {
		if `i'<3 {
		  gen help_`j'_`i' = .m
		  replace help_`j'_`i' =.d if inlist(ce033_`j'_`i',-9999)
			replace help_`j'_`i'=ce033_`j'_`i'*12    if ce033_`j'_`i'_every==1
			replace help_`j'_`i'=ce033_`j'_`i'*4 if ce033_`j'_`i'_every==2
			replace help_`j'_`i'=ce033_`j'_`i'*2 if ce033_`j'_`i'_every==3
			replace help_`j'_`i'=ce033_`j'_`i'   if ce033_`j'_`i'_every==4
			replace help_`j'_`i'=ce033_`j'_`i'   if mi(ce033_`j'_`i'_every)
		*	replace help_`j'_`i'=(ce033_`j'_`i'_a+ce033_`j'_`i'_b)/2 if mi(help_`j'_`i') & ce033_`j'_`i'_b<1000000
		}
		else {
		  gen help_`j'_`i' =.d if inlist(ce033_`j'_`i',-9999)
			replace help_`j'_`i'=ce033_`j'_`i'  
		*	replace help_`j'_`i'=(ce033_`j'_`i'_a+ce033_`j'_`i'_b)/2 if mi(help_`j'_`i') & ce033_`j'_`i'_b<1000000
		}
	}
}
egen h`wv'2gchild=rowtotal(help_1_1-help_10_4),m
replace h`wv'2gchild=.m if h`wv'o2gchild==1 & ( h`wv'2gchild <0 | h`wv'2gchild==.)
replace h`wv'2gchild=h`wv'o2gchild if mi(h12gchild) & inlist(h`wv'o2gchild,.d,.r,.m)
replace h`wv'2gchild=0 if  mi(h12gchild) & h`wv'o2gchild==0

drop help_1_1-help_10_4
drop h?ncchild

*****************************************
********===Children Transfer===**********
*****************************************

gen h`wv'fcany = .
missing_H h`wv'oichild h`wv'ogchild, result( h`wv'fcany)
replace h`wv'fcany = 0 if h`wv'oichild== 0 | h`wv'ogchild== 0
replace h`wv'fcany = 1 if h`wv'oichild== 1 | h`wv'ogchild== 1
la var h`wv'fcany "h`wv'fcany:w`wv' any transfer from children/grandchildren"
label val h`wv'fcany yesno

gen h`wv'fcamt = .
missing_H h`wv'ichild h`wv'gchild, result(h`wv'fcamt)
replace h`wv'fcamt =0 if h`wv'fcany==0
replace h`wv'fcamt = h`wv'ichild + h`wv'gchild if !mi( h`wv'ichild) & !mi(h`wv'gchild)
la var h`wv'fcamt "h`wv'fcamt:w`wv' amount of transfers from children/grandchildren"

gen h`wv'tcany=.
missing_H h`wv'o2child h`wv'o2gchild, result(h`wv'tcany)
replace h`wv'tcany = 0 if h`wv'o2child== 0 | h`wv'o2gchild== 0
replace h`wv'tcany = 1 if h`wv'o2child== 1 | h`wv'o2gchild== 1 
la var h`wv'tcany "h`wv'tcany:w`wv' any transfer to children/grandchildren"
label val h`wv'tcany yesno

gen h`wv'tcamt=.
missing_H h`wv'2child h`wv'2gchild, result(h`wv'tcamt)
replace h`wv'tcamt = 0 if h`wv'tcany== 0 
replace h`wv'tcamt = h`wv'2child + h`wv'2gchild if !mi(h`wv'2child) & !mi( h`wv'2gchild)
la var h`wv'tcamt "h`wv'tcamt:w`wv' amount of transfers to children/grandchildren"

****************************************
****************************************
* help from relatives ce015

gen h`wv'orela=.
replace h`wv'orela =.m if ce015==. & inw`wv'==1 
replace h`wv'orela =.d if ce015==.d
replace h`wv'orela =.r if ce015==.r
replace h`wv'orela = 0 if ce015==2
replace h`wv'orela = 1 if ce015==1


forvalues i=1/4 {
	if `i'<3 {
		gen help_`i'=ce016_`i'*12    if ce016_`i'_every==1
		replace help_`i'=ce016_`i'*4 if ce016_`i'_every==2
		replace help_`i'=ce016_`i'*2 if ce016_`i'_every==3
		replace help_`i'=ce016_`i'   if ce016_`i'_every==4
		replace help_`i'=ce016_`i'   if mi(ce016_`i'_every)
	*	replace help_`i'=(ce016_`i'_a+ce016_`i'_b)/2 if mi(help_`i') & ce016_`i'_b<1000000
	}
	else {
		gen help_`i'=ce016_`i'  
	*	replace help_`i'=(ce016_`i'_a+ce016_`i'_b)/2 if mi(help_`i') & ce016_`i'_b<1000000
	}
}
egen h`wv'rela=rowtotal(help_1-help_4),m
replace h`wv'rela=.m if h`wv'orela==1 & ( h`wv'rela <0 | h`wv'rela==.)
replace h`wv'rela=h`wv'orela if inlist(h`wv'orela,.d,.r,.m)
replace h`wv'rela=0 if h`wv'orela==0

drop help_1-help_4

***************************
* help to relatives ce035

gen h`wv'o2rela=.
replace h`wv'o2rela =.m if ce035==. & inw`wv'==1 
replace h`wv'o2rela =.d if ce035==.d
replace h`wv'o2rela =.r if ce035==.r
replace h`wv'o2rela = 0 if ce035==2
replace h`wv'o2rela = 1 if ce035==1

forvalues i=1/4 {
	if `i'<3 {
		gen help_`i'=ce036_`i'*12    if ce036_`i'_every==1
		replace help_`i'=ce036_`i'*4 if ce036_`i'_every==2
		replace help_`i'=ce036_`i'*2 if ce036_`i'_every==3
		replace help_`i'=ce036_`i'   if ce036_`i'_every==4
		replace help_`i'=ce036_`i'   if mi(ce036_`i'_every)
	 * replace help_`i'=(ce036_`i'_a+ce036_`i'_b)/2 if mi(help_`i') & ce036_`i'_b<1000000
	}
	else {
		gen help_`i'=ce036_`i'  
	*	replace help_`i'=(ce036_`i'_a+ce036_`i'_b)/2 if mi(help_`i') & ce036_`i'_b<1000000
	}
}
egen h`wv'2rela=rowtotal(help_1-help_4),m
replace h`wv'2rela=.m if h`wv'o2rela==1 & ( h`wv'2rela <0 | h`wv'2rela==.)
replace h`wv'2rela=h`wv'o2rela if inlist(h`wv'o2rela,.d,.r,.m)
replace h`wv'2rela=0 if h`wv'o2rela==0

drop help_1-help_4

**********************************
**************************
* help from others ce018

gen h`wv'oother=.
replace h`wv'oother =.m if ce018==. & inw`wv'==1 
replace h`wv'oother =.d if ce018==.d
replace h`wv'oother =.r if ce018==.r
replace h`wv'oother = 0 if ce018==2
replace h`wv'oother = 1 if ce018==1

forvalues i=1/4 {
	if `i'<3 {
		gen help_`i'=ce019_`i'*12    if ce019_`i'_every==1
		replace help_`i'=ce019_`i'*4 if ce019_`i'_every==2
		replace help_`i'=ce019_`i'*2 if ce019_`i'_every==3
		replace help_`i'=ce019_`i'   if ce019_`i'_every==4
		replace help_`i'=ce019_`i'   if mi(ce019_`i'_every)
	*	replace help_`i'=(ce019_`i'_a+ce019_`i'_b)/2 if mi(help_`i') & ce019_`i'_b<1000000
	}
	else {
		gen help_`i'=ce019_`i'  
	*	replace help_`i'=(ce019_`i'_a+ce019_`i'_b)/2 if mi(help_`i') & ce019_`i'_b<1000000
	}
}
egen h`wv'other=rowtotal(help_1-help_4),m
replace h`wv'other=.m if h`wv'oother==1 & ( h`wv'other <0 | h`wv'other==.)
replace h`wv'other=h`wv'oother if inlist(h`wv'oother,.d,.r,.m)
replace h`wv'other=0 if h`wv'oother==0

drop help_1-help_4

*************************
* help to others ce038

gen h`wv'o2other=.
replace h`wv'o2other =.m if ce038==. & inw`wv'==1 
replace h`wv'o2other =.d if ce038==.d
replace h`wv'o2other =.r if ce038==.r
replace h`wv'o2other = 0 if ce038==2
replace h`wv'o2other = 1 if ce038==1

forvalues i=1/4 {
	if `i'<3 {
		gen help_`i'=ce039_`i'*12    if ce039_`i'_every==1
		replace help_`i'=ce039_`i'*4 if ce039_`i'_every==2
		replace help_`i'=ce039_`i'*2 if ce039_`i'_every==3
		replace help_`i'=ce039_`i'   if ce039_`i'_every==4
		replace help_`i'=ce039_`i'   if mi(ce039_`i'_every)
	*	replace help_`i'=(ce039_`i'_a+ce039_`i'_b)/2 if mi(help_`i') & ce039_`i'_b<1000000
	}
	else {
		gen help_`i'=ce039_`i'  
	*	replace help_`i'=(ce039_`i'_a+ce039_`i'_b)/2 if mi(help_`i') & ce039_`i'_b<1000000
	}
}
egen h`wv'2other=rowtotal(help_1-help_4),m
replace h`wv'2other=.m if h`wv'o2other==1 & ( h`wv'2other <0 | h`wv'2other==.)
replace h`wv'2other=h`wv'o2other if inlist(h`wv'o2other,.d,.r,.m)
replace h`wv'2other=0 if h`wv'o2other==0

drop help_1-help_4


**********************************************
********===Relative Transfer/other transfer===**********
*****************************************

gen h`wv'foany  = .
replace h`wv'foany =.m if h`wv'orela==.m | h`wv'oother==.m
replace h`wv'foany =.d if h`wv'orela==.d | h`wv'oother==.d
replace h`wv'foany =.r if h`wv'orela==.r | h`wv'oother==.r
replace h`wv'foany = 0 if h`wv'orela== 0 | h`wv'oother== 0
replace h`wv'foany = 1 if h`wv'orela== 1 | h`wv'oother== 1
la var h`wv'foany "h`wv'foany:w`wv' any transfer from others"
label val h`wv'foany yesno

gen h`wv'foamt=.
missing_H h`wv'rela h`wv'other, result(h`wv'foamt)
replace h`wv'foamt = 0 if h`wv'foany== 0
replace h`wv'foamt = h`wv'rela + h`wv'other if !mi(h`wv'rela) & !mi(h`wv'other)
la var h`wv'foamt "h`wv'fotmt:w`wv' amount of transfers from others"

gen h`wv'toany = .
replace h`wv'toany =.m if h`wv'o2rela==.m | h`wv'o2other==.m
replace h`wv'toany =.d if h`wv'o2rela==.d | h`wv'o2other==.d
replace h`wv'toany =.r if h`wv'o2rela==.r | h`wv'o2other==.r
replace h`wv'toany = 0 if h`wv'o2rela== 0 | h`wv'o2other== 0
replace h`wv'toany = 1 if h`wv'o2rela== 1 | h`wv'o2other== 1
la var h`wv'toany "h`wv'toany:w`wv' any transfer to others"
label val h`wv'toany yesno

gen h`wv'toamt=.
missing_H h`wv'2rela h`wv'2other, result( h`wv'toamt) 
replace h`wv'toamt = 0 if h`wv'toany== 0 
replace h`wv'toamt= h`wv'2rela + h`wv'2other if !mi(h`wv'2rela) & !mi(h`wv'2other)
la var h`wv'toamt "h`wv'toamt:w`wv' amount of transfers to others"

******************************
*****TOTAL Family transfer****
******************************
gen h`wv'frec=.
missing_H h`wv'par h`wv'parlaw h`wv'ichild h`wv'gchild h`wv'rela h`wv'other, result(h`wv'frec)
replace h`wv'frec = h`wv'par + h`wv'parlaw + h`wv'ichild + h`wv'gchild + h`wv'rela + h`wv'other if !mi(h`wv'par) & !mi(h`wv'parlaw) & !mi(h`wv'ichild) & !mi(h`wv'gchild) & !mi(h`wv'rela) & !mi(h`wv'other)
label variable h`wv'frec "h`wv'frec:w`wv' total amount of transfers received"

gen h`wv'tgiv=.
missing_H h`wv'2par h`wv'2parlaw h`wv'2child h`wv'2gchild h`wv'2rela h`wv'2other, result(h`wv'tgiv)
replace h`wv'tgiv=h`wv'2par + h`wv'2parlaw + h`wv'2child + h`wv'2gchild + h`wv'2rela + h`wv'2other if !mi(h`wv'2par) & !mi(h`wv'2parlaw) & !mi(h`wv'2child) & !mi(h`wv'2gchild) & !mi(h`wv'2rela) & !mi(h`wv'2other)
label variable h`wv'tgiv "h`wv'tgiv:w`wv' total amount of transfers given"

gen h`wv'ftot=.
missing_H h`wv'frec h`wv'tgiv, result(h`wv'ftot)
replace h`wv'ftot= h`wv'frec - h`wv'tgiv if !mi(h`wv'frec) & !mi(h`wv'tgiv)
label variable h`wv'ftot "h`wv'ftot:w`wv' net value of financial transfers"


drop h`wv'opar h`wv'oparlaw h`wv'oichild h`wv'ogchild h`wv'orela h`wv'oother h`wv'par h`wv'parlaw h`wv'ichild h`wv'gchild h`wv'rela h`wv'other
drop h`wv'o2par h`wv'o2parlaw h`wv'o2child h`wv'o2gchild h`wv'o2rela h`wv'o2other
drop h`wv'2par h`wv'2parlaw h`wv'2child h`wv'2gchild h`wv'2rela h`wv'2other



****drop CHARLS household roster raw variables***
drop `family_w`wv'_hhroster'

****drop CHARLS family information raw variables***
drop `family_w`wv'_faminfo'

****drop CHARLS demog raw variables***
drop `family_w`wv'_demog'

****drop CHARLS family transfer raw variables***
drop `family_w`wv'_famtran'

*******************************************************
****MERGE WITH WAVE 2**********************************
********************************************************

rename ID id_w1
rename householdID hhid_w1

rename id_w2 ID
rename hhid_w2 householdID



*set wave number
local wv=2
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2

***merge with health file***
local health_w2_health da001 da002 da003 da004 ///
                       da005_1_ da005_2_ da005_3_ da005_4_ da005_5_  ///
                       zda005_1_ zda005_2_ zda005_3_ zda005_4_ zda005_5_ zda005_6_ ///
                       da007_1_ da007_2_ da007_3_ da007_4_ da007_5_ da007_6_ da007_7_ ///
                       da007_8_ da007_9_ da007_10_ da007_11_ da007_12_ da007_13_ da007_14_ ///
                       zda007_1_ zda007_2_ zda007_3_ zda007_4_ zda007_5_ zda007_6_ ///
                       zda007_7_ zda007_8_ zda007_9_ zda007_10_ zda007_11_ zda007_12_ zda007_13_ ///
                       zda007_14_  ///
                       da008_1_ da008_2_ da008_5_ da008_11_ zda008_1_ zda008_2_ zda008_5_ zda008_6_ zda008_11_ ///
                       da007_w2_1_1_ da007_w2_2_1_  da007_w2_1_2_ da007_w2_2_2_  da007_w2_1_3_ da007_w2_2_3_ ///
                       da007_w2_1_4_ da007_w2_2_4_  da007_w2_1_5_ da007_w2_2_5_  da007_w2_1_6_ da007_w2_2_6_ ///
                       da007_w2_1_7_ da007_w2_2_7_  da007_w2_1_8_ da007_w2_2_8_  da007_w2_1_9_ da007_w2_2_9_ ///
                       da007_w2_1_10_ da007_w2_2_10_  da007_w2_1_11_ da007_w2_2_11_  da007_w2_1_12_ da007_w2_2_12_ ///
                       da007_w2_1_13_ da007_w2_2_13_  da007_w2_1_14_ da007_w2_2_14_ ///
                       da008_1_ da008_2_ da008_5_ da008_6_ da008_11_ ///
                       da051_1_ da051_2_ da051_3_ da052_1_ da052_2_ da052_3_ ///
                       da059 zda059 da061 da067 da068s? da069 da072 da074 da076 ///
                       da079 da080 ///
                       da002_w2_1 ///
                       dc009 dc010 dc011 dc012 dc013 dc014 dc015 dc016 dc017 dc018 ///
                       db001 db002 db003 db004 db005 db006 db007 db008 db009 db010 ///
                       db010 db011 db012 db013 db014 db015 db016 db017 db018 db019 db020 ///
                       db032 db035 ///
                       xrtype ///                 
                     
merge 1:1 ID using "`wave_2_health'", keepusing(`health_w2_health') 
drop if _merge==2
drop _merge
 
*merge with weight file***
local health_w2_weight  imonth iyear

merge 1:1 ID using "`wave_2_weight_'", keepusing(`health_w2_weight')  
drop if _merge==2
drop _merge

***merge with biomarker file***
local health_w2_biomark qi001s1 qi001s2 qi001s3 qi001s4 qi001s5 qi001s6 qi001s7 qi001s8 qi001s97 ///
                        ql001s1 ql001s2 ql001s3 ql001s4 ql001s5 ql001s6 ql001s7 ql001s8 ql001s97 ///
                        ql002 qi002
merge 1:1 ID using "`wave_2_biomark'", keepusing(`health_w2_biomark') 
drop if _merge==2
drop _merge

***merge with work file***
local health_w2_work fa001 fa002 fa003 fa005 fa007 fa008 fb010 fc013 fd030 fh004 ///
                     fl020s7 xf1 ///
                     
merge 1:1 ID using "`wave_2_work'", keepusing(`health_w2_work')
drop if _merge==2
drop _merge


******self-reported health*******
gen r`wv'shlt =.
replace r`wv'shlt = .m if  da001==. & da080==.  & inw`wv'==1  
replace r`wv'shlt = 1 if (da001==1 | da080==1) & inw`wv'==1
replace r`wv'shlt = 2 if (da001==2 | da080==2) & inw`wv'==1
replace r`wv'shlt = 3 if (da001==3 | da080==3) & inw`wv'==1
replace r`wv'shlt = 4 if (da001==4 | da080==4) & inw`wv'==1
replace r`wv'shlt = 5 if (da001==5 | da080==5) & inw`wv'==1

label variable r`wv'shlt "r`wv'shlt:w`wv' r self-report of health"
label values r`wv'shlt health
tab r`wv'shlt,m
*spouse self reported health
gen s`wv'shlt =.
spouse r`wv'shlt, result(s`wv'shlt) wave(`wv')
label variable s`wv'shlt "s`wv'shlt:w`wv' s self-report of health"
label values s`wv'shlt health

***timing
gen r`wv'shltf =.
replace r`wv'shltf =.m if mi(da080) & mi(da001) & inw`wv'==1
replace r`wv'shltf =1 if inlist(da001,1,2,3,4,5,.d,.r)  & inw`wv'==1
replace r`wv'shltf =2 if inlist(da080,1,2,3,4,5,.d,.r)   & inw`wv'==1
*replace r`wv'shltf =1 if r`wv'shltf==. & inw`wv'==1

label variable r`wv'shltf "r`wv'shltf:w`wv' r timing flag of self-report health"
label values r`wv'shltf health_pos

*spouse
gen s`wv'shltf =.
spouse r`wv'shltf, result(s`wv'shltf) wave(`wv')
label variable s`wv'shltf "s`wv'shltf:w`wv' s timing flag of self-report health"
label values s`wv'shltf health_pos

******self-reported health, European scale****
gen r`wv'shlta =.
replace r`wv'shlta = .m if mi(da002) & mi(da079) & inw`wv'==1
replace r`wv'shlta = 1 if (da002==1 |da079==1) 
replace r`wv'shlta = 2 if (da002==2 |da079==2)
replace r`wv'shlta = 3 if (da002==3 |da079==3) 
replace r`wv'shlta = 4 if (da002==4 |da079==4)
replace r`wv'shlta = 5 if (da002==5 |da079==5) 
label variable r`wv'shlta "r`wv'shlta:w`wv' r self-report of health alt"
label values r`wv'shlta health_alt

tab r`wv'shlta,m
*spouse self-report of health, European scale
gen s`wv'shlta =.
spouse r`wv'shlta, result(s`wv'shlta) wave(`wv')
label variable s`wv'shlta "s`wv'shlta:w`wv' s self-report of health alt"
label values s`wv'shlta health_alt


***timing
gen r`wv'shltaf =.
replace r`wv'shltaf =.m if mi(da079) & mi(da002) & inw`wv'==1
replace r`wv'shltaf =2 if inlist(da079,1,2,3,4,5) & inw`wv'==1
replace r`wv'shltaf =1 if inlist(da002,1,2,3,4,5) & inw`wv'==1
label variable r`wv'shltaf "r`wv'shltaf:w`wv' r timing flag of self-report health alt"
label values r`wv'shltaf health_pos


*spouse
gen s`wv'shltaf =.
spouse r`wv'shltaf, result(s`wv'shltaf) wave(`wv')
label variable s`wv'shltaf "s`wv'shltaf:w`wv' s timing flag of self-report health alt"
label values s`wv'shltaf health_pos

***limitation for entering other functional problems

local healthyandyoung_reintervew inrange(r`wv'agey,0,49) & (inlist(da001,1,2) | inlist(da002,1,2) | inlist(da079,1,2) | inlist(da080,1,2)) & da003==2 & da004==2 & (da005_1_==2 & da005_2_==2 & da005_3_==2 & da005_4_==2 & da005_5_==2 ) & xrtype == 1 
local healthyandyoung_baseline   inrange(r`wv'agey,0,49) & (inlist(da001,1,2) | inlist(da002,1,2) | inlist(da079,1,2) | inlist(da080,1,2)) & da003==2 & da004==2 & (zda005_1_==2 & zda005_2_==2 & zda005_3_==2 & zda005_4_==2 & zda005_5_==2 & zda005_6_==2) & xrtype == 2

****age limitation for entering other functional problems
*gen r`wv'limita=.
*replace r`wv'limita=.a if 
*tab r`wv'limita,m

****other functional limitation****
***Difficult in running or jogging 1km  //charls only
gen r`wv'joga =.
replace r`wv'joga =.m if db001==. & inw`wv'==1
replace r`wv'joga =.a if db001==. & ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'joga = 0 if db001== 1
replace r`wv'joga = 1 if inlist(db001,2,3,4)
label variable r`wv'joga "r`wv'joga:w`wv' r diff-running or jogging 1 km"
label values r`wv'joga yesno

*Spouse difficult in runing or jogging 1km
gen s`wv'joga =.
spouse r`wv'joga, result(s`wv'joga) wave(`wv')
label variable s`wv'joga "s`wv'joga:w`wv' s diff-running or jogging 1 km"
label values s`wv'joga yesno

***Difficut in walking 1km  //charls only
gen r`wv'walk1kma =.
replace r`wv'walk1kma =.m if mi(db002) & inw`wv'==1
replace r`wv'walk1kma =.a if db002==. & ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'walk1kma = 0 if db002==. & db001== 1
replace r`wv'walk1kma = 0 if db002== 1
replace r`wv'walk1kma = 1 if inlist(db002,2,3,4)
label variable r`wv'walk1kma "r`wv'walk1kma:w`wv' r diff-walking 1km"
label values r`wv'walk1kma yesno

*Spouse difficult in walking 1km
gen s`wv'walk1kma =.
spouse r`wv'walk1kma, result(s`wv'walk1kma) wave(`wv')
label variable s`wv'walk1kma "s`wv'walk1kma:w`wv' s diff-walking 1km"
label values s`wv'walk1kma yesno


***Difficult walking 100m***//charls only
gen r`wv'walk100a =.
replace r`wv'walk100a =.m if db003==. & inw`wv'==1
replace r`wv'walk100a =.a if db003==. & ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'walk100a = 0 if db003==. & (db001== 1 | db002==1)
replace r`wv'walk100a = 0 if db003== 1
replace r`wv'walk100a = 1 if inlist(db003,2,3,4)
label variable r`wv'walk100a "r`wv'walk100m:w`wv' r diff-walking 100 m"
label values r`wv'walk100a yesno

*Spouse difficult in walking 100m
gen s`wv'walk100a =.
spouse r`wv'walk100a, result(s`wv'walk100a) wave(`wv')
label variable s`wv'walk100a "s`wv'walk100a:w`wv' s diff-walking 100 m"
label values s`wv'walk100a yesno


***no sita diff-sit for 2 hours***

***Difficult getting up after sitting**
gen r`wv'chaira =.
replace r`wv'chaira =.m if db004==. & inw`wv'==1
replace r`wv'chaira =.a if db004==. & ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'chaira = 0 if db004== 1
replace r`wv'chaira = 1 if inlist(db004,2,3,4)
label variable r`wv'chaira "r`wv'chaira:w`wv' r diff-getting up after sitting for a long period"
label values r`wv'chaira yesno

*Spouse difficult in getting up after sitting
gen s`wv'chaira =.
spouse r`wv'chaira, result(s`wv'chaira) wave(`wv')
label variable s`wv'chaira "s`wv'chaira:w`wv' s diff-getting up after sitting for a long period"
label values s`wv'chaira yesno

***Difficult climbing***
gen r`wv'climsa =.
replace r`wv'climsa =.m if db005==. & inw`wv'==1
replace r`wv'climsa =.a if db005==. & ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'climsa = 0 if db005== 1
replace r`wv'climsa = 1 if inlist(db005,2,3,4)
label variable r`wv'climsa "r`wv'climsa:w`wv' r diff-climbing sev flt stair"
label values r`wv'climsa yesno

*Spouse difficult in getting up after sitting
gen s`wv'climsa =.
spouse r`wv'climsa, result(s`wv'climsa) wave(`wv')
label variable s`wv'climsa "s`wv'climsa:w`wv' s diff-climbing sev flt stair"
label values s`wv'climsa yesno

***no clim1a diff-clmb 1 flt str***
***Difficult in stoop/kneel/crouch
gen r`wv'stoopa =.
replace r`wv'stoopa =.m if db006==. & inw`wv'==1
replace r`wv'stoopa =.a if db006==. & ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'stoopa = 0 if db006== 1
replace r`wv'stoopa = 1 if inlist(db006,2,3,4)
label variable r`wv'stoopa "r`wv'stoopa:w`wv' r diff-stoop/kneel/crouch"
label values r`wv'stoopa yesno

*Spouse difficult in stoop/kneel/crouch
gen s`wv'stoopa =.
spouse r`wv'stoopa, result(s`wv'stoopa) wave(`wv')
label variable s`wv'stoopa "s`wv'stoopa:w`wv' s diff-stoop/kneel/crouch"
label values s`wv'stoopa yesno

***Difficult in lifting/carry 10 jin**
gen r`wv'lifta =.
replace r`wv'lifta =.m if db008==. & inw`wv'==1
replace r`wv'lifta =.a if db008==. & ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'lifta = 0 if db008== 1
replace r`wv'lifta = 1 if inlist(db008,2,3,4)
label variable r`wv'lifta "r`wv'lifta:w`wv' r diff-lift/carry 10 jin"
label values r`wv'lifta yesno

*Spouse difficult in lifting/carry 10 jin**
gen s`wv'lifta =.
spouse r`wv'lifta, result(s`wv'lifta) wave(`wv')
label variable s`wv'lifta "s`wv'lifta:w`wv' s diff-lift/carry 10 jin"
label values r`wv'lifta yesno

***Difficult in picking up a coin
gen r`wv'dimea =.
replace r`wv'dimea =.m if db009==. & inw`wv'==1
replace r`wv'dimea =.a if db009==. & ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'dimea = 0 if db009== 1
replace r`wv'dimea = 1 if inlist(db009,2,3,4)
label variable r`wv'dimea "r`wv'dimea:w`wv' r diff-pick up a coin"
label values r`wv'dimea yesno

*Spouse difficult in lifting/carry 10 jin**
gen s`wv'dimea =.
spouse r`wv'dimea, result(s`wv'dimea) wave(`wv')
label variable s`wv'dimea "s`wv'dimea:w`wv' s diff-pick up a coin"
label values s`wv'dimea yesno

***Difficult in reaching/extending arms up
gen r`wv'armsa =.
replace r`wv'armsa =.m if db007==. & inw`wv'==1
replace r`wv'armsa =.a if db007==. & ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'armsa = 0 if db007== 1
replace r`wv'armsa = 1 if inlist(db007,2,3,4)
label variable r`wv'armsa "r`wv'armsa:w`wv' r diff-reach/extnd arms up"
label values r`wv'armsa yesno

*Spouse difficult in reaching/extending arms up
gen s`wv'armsa =.
spouse r`wv'armsa, result(s`wv'armsa) wave(`wv')
label variable s`wv'armsa "s`wv'armsa:w`wv' s diff-reach/extnd arms up"
label values s`wv'armsa yesno

***no pusha diff-push/pull 1g obj***

*******ADLs***************************
***no walka walking accross room***
***Difficult in dressing
gen r`wv'dressa =.
replace r`wv'dressa =.m if db010==. & inw`wv'==1
replace r`wv'dressa =.a if ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'dressa =0 if (db010==. & db001==1 & db004==1 & db005==1 & db006==1 & db007==1 & db008==1 & db009==1) | db010==1
replace r`wv'dressa =1 if inlist(db010,2,3,4)
label variable r`wv'dressa "r`wv'dressa:w`wv' r diff-dressing"
label values r`wv'dressa diff

*Spouse difficult in dressing
gen s`wv'dressa =.
spouse r`wv'dressa, result(s`wv'dressa) wave(`wv')
label variable s`wv'dressa "s`wv'dressa:w`wv' s diff-dressing"
label values s`wv'dressa diff

***difficult in taking bath or shower
gen r`wv'batha =.
replace r`wv'batha =.m if db011==. & inw`wv'==1
replace r`wv'batha =.a if ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'batha =0 if (db011==. & db001==1 & db004==1 & db005==1 & db006==1 & db007==1 & db008==1 & db009==1) | db011==1
replace r`wv'batha =1 if inlist(db011,2,3,4)
label variable r`wv'batha "r`wv'batha:w`wv' r diff-bathing or shower"
label values r`wv'batha diff

*Spouse difficult in taking bath or shower
gen s`wv'batha =.
spouse r`wv'batha, result(s`wv'batha) wave(`wv')
label variable s`wv'batha "s`wv'batha:w`wv' s diff-bathing or shower"
label values s`wv'batha diff

***difficult in eating
gen r`wv'eata =.
replace r`wv'eata =.m if db012==. & inw`wv'==1
replace r`wv'eata =.a if ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'eata =0 if (db012==. & db001==1 & db004==1 & db005==1 & db006==1 & db007==1 & db008==1 & db009==1) | db012==1
replace r`wv'eata =1 if inlist(db012,2,3,4)
label variable r`wv'eata "r`wv'eata:w`wv' r diff-eating"
label values r`wv'eata diff

*spouse difficult in eating
gen s`wv'eata =.
spouse r`wv'eata, result(s`wv'eata) wave(`wv')
label variable s`wv'eata "s`wv'eata:w`wv' s diff-eating"
label values s`wv'eata diff

***Difficult in getting in/out bed***
gen r`wv'beda =.
replace r`wv'beda =.m if db013==. & inw`wv'==1
replace r`wv'beda =.a if ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'beda =0 if (db013==. & db001==1 & db004==1 & db005==1 & db006==1 & db007==1 & db008==1 & db009==1) | db013==1
replace r`wv'beda =1 if inlist(db013,2,3,4)
label variable r`wv'beda "r`wv'beda:w`wv' r diff-getting in/out of bed"
label values r`wv'beda diff

*spouse difficult in getting in/out bed***
gen s`wv'beda =.
spouse r`wv'beda, result(s`wv'beda) wave(`wv')
label variable s`wv'beda "s`wv'beda:w`wv' s diff-getting in/out of bed"
label values s`wv'beda diff

***Difficult in using the toilet*** 
gen r`wv'toilta =.
replace r`wv'toilta =.m if db014==. & inw`wv'==1
replace r`wv'toilta =.a if ((`healthyandyoung_reintervew') | (`healthyandyoung_baseline'))
replace r`wv'toilta =0 if (db014==. & db001==1 & db004==1 & db005==1 & db006==1 & db007==1 & db008==1 & db009==1) | db014==1
replace r`wv'toilta =1 if inlist(db014,2,3,4)
label variable r`wv'toilta "r`wv'toilta:w`wv' r diff-using the toilet"
label values r`wv'toilta diff

*spouse difficult in using the toilet***
gen s`wv'toilta =.
spouse r`wv'toilta, result(s`wv'toilta) wave(`wv')
label variable s`wv'toilta "s`wv'toilta:w`wv' s diff-using the toilet"
label values s`wv'toilta diff

**********IADLs******************
****no use map ****
***Difficult in managing money
gen r`wv'moneya =.
replace r`wv'moneya =.m if db019==. & inw`wv'==1
replace r`wv'moneya = 0 if db019 ==1
replace r`wv'moneya = 1 if inlist(db019,2,3,4)
label variable r`wv'moneya "r`wv'moneya:w`wv' r diff-managing money"
label values r`wv'moneya diff

*Souse difficult in managing money
gen s`wv'moneya =.
spouse r`wv'moneya, result(s`wv'moneya) wave(`wv')
label variable s`wv'moneya "s`wv'moneya:w`wv' s diff-managing money"
label values s`wv'moneya diff

***Difficulty using a telephone***
*wave respondent difficulty using a telephone
gen r`wv'phonea =.
replace r`wv'phonea =.m if db035==. & inw`wv'==1
replace r`wv'phonea =.n if db035==5
replace r`wv'phonea = 0 if db035==1
replace r`wv'phonea = 1 if inlist(db035,2,3,4)
label variable r`wv'phonea "r`wv'phonea:w`wv' R diff-using a telephone"
label values r`wv'phonea diff

*wave spouse difficulty using a telephone
gen s`wv'phonea =.
spouse r`wv'phonea, result(s`wv'phonea) wave(`wv')
label variable s`wv'phonea "s`wv'phonea:w`wv' S diff-using a telephone"
label values s`wv'phonea diff

***Difficult in taking medication
gen r`wv'medsa =.
replace r`wv'medsa =.m if db020==. & inw`wv'==1
replace r`wv'medsa = 0 if db020 ==1
replace r`wv'medsa = 1 if inlist(db020,2,3,4)
label variable r`wv'medsa "r`wv'medsa:w`wv' r diff-taking medications"
label values r`wv'medsa diff

*Spouse difficult in taking medication
gen s`wv'medsa =.
spouse r`wv'medsa, result(s`wv'medsa) wave(`wv')
label variable s`wv'medsa "s`wv'medsa:w`wv' s diff-taking medications"
label values s`wv'medsa diff

***Difficult in shopping for groceries
gen r`wv'shopa =.
replace r`wv'shopa =.m if db018==. & inw`wv'==1
replace r`wv'shopa = 0 if db018 ==1
replace r`wv'shopa = 1 if inlist(db018,2,3,4)
label variable r`wv'shopa "r`wv'shopa:w`wv' r diff-shopping for groceries"
label values r`wv'shopa diff

*Spouse difficult in shopping for groceries
gen s`wv'shopa =.
spouse r`wv'shopa, result(s`wv'shopa) wave(`wv')
label variable s`wv'shopa "s`wv'shopa:w`wv' r diff-shopping for groceries"
label values s`wv'shopa diff

***Difficult in preparing hot meals
gen r`wv'mealsa =.
replace r`wv'mealsa =.m if db017==. & inw`wv'==1
replace r`wv'mealsa = 0 if db017==1
replace r`wv'mealsa = 1 if inlist(db017,2,3,4)
label variable r`wv'mealsa "r`wv'mealsa:w`wv' r diff-preparing hot meals"
label values r`wv'mealsa diff

*spouse difficult in preparing hot meals
gen s`wv'mealsa =.
spouse r`wv'mealsa, result(s`wv'mealsa) wave(`wv')
label variable s`wv'mealsa "s`wv'mealsa:w`wv' s diff-preparing hot meals"
label values s`wv'mealsa diff

***Difficult in cleaning house
gen r`wv'housewka =.
replace r`wv'housewka =.m if db016==. & inw`wv'==1
replace r`wv'housewka = 0 if db016== 1
replace r`wv'housewka = 1 if inlist(db016,2,3,4)
label variable r`wv'housewka "r`wv'housewka:w`wv' r diff-cleaning house"/***only for charls***/
label values r`wv'housewka diff

*Spouse difficult in cleanig house
gen s`wv'housewka =.
spouse r`wv'housewka, result(s`wv'housewka) wave(`wv')
label variable s`wv'housewka "s`wv'housewka:w`wv' s diff-cleaning house"
label values s`wv'housewka diff


*******************************************************
***Missings in ADL score
*respondent
egen r`wv'adlam_c= rowmiss(r`wv'batha r`wv'dressa r`wv'eata r`wv'beda) if inw`wv'==1
label variable r`wv'adlam_c "r`wv'adlam_c:w`wv' r missings in ADL summary"

*spouse
gen s`wv'adlam_c =.
spouse r`wv'adlam_c, result(s`wv'adlam_c) wave(`wv')
label variable s`wv'adlam_c "s`wv'adlam_c:w`wv' s missings in ADL summary" 

***ADL Score
*respondent
egen r`wv'adla_c= rowtotal(r`wv'batha r`wv'dressa r`wv'eata r`wv'beda) if inrange(r`wv'adlam_c,0,3)
replace r`wv'adla_c=.m if r`wv'batha==.m & r`wv'dressa==.m & r`wv'eata==.m & r`wv'beda==.m 
replace r`wv'adla_c=.a if r`wv'batha==.a & r`wv'dressa==.a & r`wv'eata==.a & r`wv'beda==.a
label variable r`wv'adla_c "r`wv'adla_c:w`wv' r some diff-ADLs / 0-4"

*spouse ADL summary
gen s`wv'adla_c =.
spouse r`wv'adla_c, result(s`wv'adla_c) wave(`wv')
label variable s`wv'adla_c "s`wv'adla_c:w`wv' s some diff-ADLs / 0-4"

***Missings in Wallace ADL score
*respondent
egen r`wv'adlwam= rowmiss(r`wv'batha r`wv'dressa r`wv'eata ) if inw`wv'==1
label variable r`wv'adlwam "r`wv'adlwam:w`wv' r missings in ADL Wallace Score"  

*spouse
gen s`wv'adlwam =.
spouse r`wv'adlwam, result(s`wv'adlwam) wave(`wv')
label variable s`wv'adlwam "s`wv'adlwam:w`wv' s missings in ADL Wallace Score" 

***ADL Wallace Summary 0-3**
*respondent
egen r`wv'adlwa = rowtotal(r`wv'batha r`wv'dressa r`wv'eata) if inrange(r`wv'adlwam,0,2)
replace r`wv'adlwa =.m if r`wv'batha==.m & r`wv'dressa==.m & r`wv'eata==.m 
replace r`wv'adlwa =.a if r`wv'batha==.a & r`wv'dressa==.a & r`wv'eata==.a
label variable r`wv'adlwa  "r`wv'adlwa :w`wv' r some diff-ADLs: Wallace / 0-3"

*spouse 
gen s`wv'adlwa  =.
spouse r`wv'adlwa , result(s`wv'adlwa) wave(`wv')
label variable s`wv'adlwa  "s`wv'adlwa :w`wv' s some diff-ADLs: Wallace / 0-3"

***Missings in IADL 0-3 summary score
egen r`wv'iadlam= rowmiss(r`wv'phonea r`wv'moneya r`wv'medsa) if inw`wv'==1
label variable r`wv'iadlam "r`wv'iadlam:w`wv' R Some difficulty-Missings in IADLs Score"  

gen s`wv'iadlam =.
spouse r`wv'iadlam, result(s`wv'iadlam) wave(`wv')
label variable s`wv'iadlam "s`wv'iadlam:w`wv' S Some difficulty-Missings in IADLs Score"  

**IADL Summary 0-3**
*respondent
egen r`wv'iadla= rowtotal(r`wv'phonea r`wv'moneya r`wv'medsa) if inrange(r`wv'iadlam,0,2)
replace r`wv'iadla=.m if r`wv'phonea==.m & r`wv'moneya==.m & r`wv'medsa==.m 
replace r`wv'iadla=.a if r`wv'phonea==.a & r`wv'moneya==.a & r`wv'medsa==.a
label variable r`wv'iadla "r`wv'iadla:w`wv' r summary diff-IADLs: / 0-3"

*Spouse 
gen s`wv'iadla =.
spouse r`wv'iadla, result(s`wv'iadla) wave(`wv')
label variable s`wv'iadla "s`wv'iadla:w`wv' s summary diff-IADLs: / 0-3"

***Missings in IADL 0-5 summary score
*respondent
egen r`wv'iadlzam= rowmiss(r`wv'phonea r`wv'moneya r`wv'medsa r`wv'shopa r`wv'mealsa) if inw`wv'==1
label variable r`wv'iadlzam "r`wv'iadlzam:w`wv' R Some difficulty-Missings in IADLs Score"  

*spouse
gen s`wv'iadlzam =.
spouse r`wv'iadlzam, result(s`wv'iadlzam) wave(`wv')
label variable s`wv'iadlzam "s`wv'iadlzam:w`wv' S Some difficulty-Missings in IADLs Score"  

***IADL Summary 0-5**
*respondent
egen r`wv'iadlza= rowtotal(r`wv'phonea r`wv'moneya r`wv'medsa r`wv'shopa r`wv'mealsa) if inrange(r`wv'iadlzam,0,4)
replace r`wv'iadlza=.m if r`wv'phonea==.m & r`wv'moneya==.m & r`wv'medsa==.m & r`wv'shopa==.m & r`wv'mealsa==.m 
replace r`wv'iadlza=.a if r`wv'phonea==.a & r`wv'moneya==.a & r`wv'medsa==.a & r`wv'shopa==.a & r`wv'mealsa==.a 
label variable r`wv'iadlza "r`wv'iadlza:w`wv' r summary diff-IADLs: 0-5"

**Spouse 
gen s`wv'iadlza =.
spouse r`wv'iadlza, result(s`wv'iadlza) wave(`wv')
label variable s`wv'iadlza "s`wv'iadlza:w`wv' s summary diff-IADLs: 0-5"

****CESD: Mental Health Problem***
***Feel depressed***
gen r`wv'depresl =.
replace r`wv'depresl =.m if dc011==. & inw`wv'==1
replace r`wv'depresl =.p if dc011==. & db032==4
replace r`wv'depresl = dc011 if inrange(dc011,1,4)
label variable r`wv'depresl "r`wv'depresl:w`wv' cesd: felt depressed"
label values r`wv'depresl cesdd

*Spouse feel depressed
gen s`wv'depresl =.
spouse r`wv'depresl, result(s`wv'depresl) wave(`wv')
label variable s`wv'depresl "s`wv'depresl:w`wv' cesd: felt depressed"
label values s`wv'depresl cesdd

***Everything an effort***
gen r`wv'effortl =.
replace r`wv'effortl =.m if dc012==. & inw`wv'==1
replace r`wv'effortl =.p if dc012==. & db032==4
replace r`wv'effortl = dc012 if inrange(dc012,1,4)
label variable r`wv'effortl "r`wv'effortl:w`wv' cesd: everything an effort"
label values r`wv'effortl cesdd

*Spouse Everything an effort***
gen s`wv'effortl =.
spouse r`wv'effortl, result(s`wv'effortl) wave(`wv')
label variable s`wv'effortl "s`wv'effortl:w`wv' cesd: everything an effort"
label values s`wv'effortl cesdd

***Sleep was restless***
gen r`wv'sleeprl =.
replace r`wv'sleeprl =.m if dc015==. & inw`wv'==1
replace r`wv'sleeprl =.p if dc015==. & db032==4
replace r`wv'sleeprl = dc015 if inrange(dc015,1,4)
label variable r`wv'sleeprl "r`wv'sleeprl:w`wv' cesd: sleep was restless"
label values r`wv'sleeprl cesdd

*Spouse Sleep was restless***
gen s`wv'sleeprl =.
spouse r`wv'sleeprl, result(s`wv'sleeprl) wave(`wv')
label variable s`wv'sleeprl "s`wv'sleeprl:w`wv' cesd: sleep was restless"
label values s`wv'sleeprl cesdd

***Happy***
gen r`wv'whappyl =.
replace r`wv'whappyl =.m if dc016==. & inw`wv'==1
replace r`wv'whappyl =.p if dc016==. & db032==4
replace r`wv'whappyl = dc016 if inrange(dc016,1,4)
label variable r`wv'whappyl "r`wv'whappyl:w`wv' cesd: was happy"
label values r`wv'whappyl cesdd

*Spouse happy***
gen s`wv'whappyl =.
spouse r`wv'whappyl, result(s`wv'whappyl) wave(`wv')
label variable s`wv'whappyl "r`wv'whappyl:w`wv' cesd: was happy"
label values s`wv'whappyl cesdd

***Felt Lonely**
gen r`wv'flonel =.
replace r`wv'flonel =.m if dc017==. & inw`wv'==1
replace r`wv'flonel =.p if dc017==. & db032==4
replace r`wv'flonel = dc017 if inrange(dc017,1,4)
label variable r`wv'flonel "r`wv'flonel:w`wv' cesd: felt lonely"
label values r`wv'flonel cesdd

*Spouse feel lonely
gen s`wv'flonel =.
spouse r`wv'flonel, result(s`wv'flonel) wave(`wv')
label variable s`wv'flonel "s`wv'flonel:w`wv' cesd: felt lonely"
label values s`wv'flonel cesdd

***Can't get going***
gen r`wv'goingl =.
replace r`wv'goingl =.m if dc018==. & inw`wv'==1
replace r`wv'goingl =.p if dc018==. & db032==4
replace r`wv'goingl = dc018 if inrange(dc018,1,4)
label variable r`wv'goingl "r`wv'goingl:w`wv' cesd: could not get going"
label values r`wv'goingl cesdd

*Spouse cant get going***
gen s`wv'goingl =.
spouse r`wv'goingl, result(s`wv'goingl) wave(`wv')
label variable s`wv'goingl "s`wv'goingl:w`wv' cesd: could not get going"
label values s`wv'goingl cesdd

***bothered by little things**/*charls only*/
gen r`wv'botherl =.
replace r`wv'botherl =.m if dc009==. & inw`wv'==1
replace r`wv'botherl =.p if dc009==. & db032==4
replace r`wv'botherl = dc009 if inrange(dc009,1,4)
label variable r`wv'botherl "r`wv'botherl:w`wv' cesd: bothered by little things"
label values r`wv'botherl cesdd

*spouse bothered by little thing
gen s`wv'botherl =.
spouse r`wv'botherl, result(s`wv'botherl) wave(`wv')
label variable s`wv'botherl "s`wv'botherl:w`wv' cesd: bothered by little things"
label values s`wv'botherl cesdd

***Trouble keeping mind on what is doing /*charls only*/
gen r`wv'mindtsl =.
replace r`wv'mindtsl =.m if dc010==. & inw`wv'==1
replace r`wv'mindtsl =.p if dc010==. & db032==4
replace r`wv'mindtsl = dc010 if inrange(dc010,1,4)
label variable r`wv'mindtsl "r`wv'mindtsl:w`wv' cesd: had trouble keeping mind on what is doing"
label values r`wv'mindtsl cesdd

*Spouse has trouble keeping mind on what is doing
gen s`wv'mindtsl =.
spouse r`wv'mindtsl, result(s`wv'mindtsl) wave(`wv')
label variable s`wv'mindtsl "s`wv'mindtsl:w`wv' cesd: had trouble keeping mind on what is doing"
label values s`wv'mindtsl cesdd

***Feel hopeful about the future/*charls only*/
gen r`wv'fhopel =.
replace r`wv'fhopel =.m if dc013==. & inw`wv'==1
replace r`wv'fhopel =.p if dc013==. & db032==4
replace r`wv'fhopel = dc013 if inrange(dc013,1,4)
label variable r`wv'fhopel "r`wv'fhopel:w`wv' cesd: feel hopeful about the future"
label values r`wv'fhopel cesdd

*Spouse feel hopeful about the future
gen s`wv'fhopel =.
spouse r`wv'fhopel, result(s`wv'fhopel) wave(`wv')
label variable s`wv'fhopel "s`wv'fhopel:w`wv' cesd: feel hopeful about the future"
label values s`wv'fhopel cesdd

***Feel fearful/*charls only*/
gen r`wv'fearll =.
replace r`wv'fearll =.m if dc014==. & inw`wv'==1
replace r`wv'fearll =.p if dc014==. & db032==4
replace r`wv'fearll = dc014 if inrange(dc014,1,4)
label variable r`wv'fearll "r`wv'fearll:w`wv' cesd: feel fearful"
label values r`wv'fearll cesdd

*Spouse feel fearful
gen s`wv'fearll =.
spouse r`wv'fearll, result(s`wv'fearll) wave(`wv')
label variable s`wv'fearll "s`wv'fearll:w`wv' cesd: feel fearful"
label values s`wv'fearll cesdd

***Missing in CESD Score
*respondent
egen r`wv'cesd10m = rowmiss(r`wv'depresl r`wv'effortl r`wv'sleeprl r`wv'whappyl r`wv'flonel r`wv'botherl r`wv'goingl r`wv'mindtsl r`wv'fhopel r`wv'fearll) if  inw`wv'==1
label variable r`wv'cesd10m "r`wv'cesd10m:w`wv' Missing in CESD Score"

*spouse
gen s`wv'cesd10m = .
spouse r`wv'cesd10m, result(s`wv'cesd10m) wave(`wv')
label variable s`wv'cesd10m "s`wv'cesd10m:w`wv' Missing in CESD Score"

*****cesd score****
***recode the reversed
recode r`wv'whappyl (1=4) (2=3) (3=2)(4=1), gen(xr`wv'whappyl)
recode r`wv'fhopel  (1=4) (2=3) (3=2)(4=1), gen(xr`wv'fhopel)	
	
*total CESD score value 
foreach var in r`wv'depresl  r`wv'effortl  r`wv'sleeprl  xr`wv'whappyl  r`wv'flonel r`wv'botherl r`wv'goingl r`wv'mindtsl xr`wv'fhopel r`wv'fearll {
	gen `var'_scale = `var' - 1
}
*respondent
egen r`wv'cesd10 = rowtotal(r`wv'depresl_scale r`wv'effortl_scale r`wv'sleeprl_scale xr`wv'whappyl_scale r`wv'flonel_scale r`wv'botherl_scale r`wv'goingl_scale r`wv'mindtsl_scale xr`wv'fhopel_scale r`wv'fearll_scale) if inrange(r`wv'cesd10m,0,9)
replace r`wv'cesd10 = .m if r`wv'depresl == .m & r`wv'effortl == .m & r`wv'sleeprl == .m & r`wv'whappyl == .m & r`wv'flonel == .m & r`wv'botherl == .m & r`wv'goingl == .m & r`wv'mindtsl == .m & r`wv'fhopel == .m & r`wv'fearll == .m
replace r`wv'cesd10 = .d if r`wv'depresl == .d & r`wv'effortl == .d & r`wv'sleeprl == .d & r`wv'whappyl == .d & r`wv'flonel == .d & r`wv'botherl == .d & r`wv'goingl == .d & r`wv'mindtsl == .d & r`wv'fhopel == .d & r`wv'fearll == .d
replace r`wv'cesd10 = .r if r`wv'depresl == .r & r`wv'effortl == .r & r`wv'sleeprl == .r & r`wv'whappyl == .r & r`wv'flonel == .r & r`wv'botherl == .r & r`wv'goingl == .r & r`wv'mindtsl == .r & r`wv'fhopel == .r & r`wv'fearll == .r
replace r`wv'cesd10 = .p if r`wv'depresl == .p & r`wv'effortl == .p & r`wv'sleeprl == .p & r`wv'whappyl == .p & r`wv'flonel == .p & r`wv'botherl == .p & r`wv'goingl == .p & r`wv'mindtsl == .p & r`wv'fhopel == .p & r`wv'fearll == .p
label variable r`wv'cesd10 "r`wv'cesd10:w`wv' CESD Score"

*Spouse
gen s`wv'cesd10 =. 
spouse r`wv'cesd10, result(s`wv'cesd10) wave(`wv')
label variable s`wv'cesd10 "s`wv'cesd10:w`wv' CESD Score"

drop r`wv'depresl_scale r`wv'effortl_scale r`wv'sleeprl_scale xr`wv'whappyl_scale r`wv'flonel_scale r`wv'botherl_scale r`wv'goingl_scale r`wv'mindtsl_scale xr`wv'fhopel_scale r`wv'fearll_scale

drop xr`wv'whappyl xr`wv'fhopel

******************Before doctor diagnosed**********************
****doctor diagnosed health problems****
**Ever have high blood pressure
gen r`wv'hibpe =.
replace r`wv'hibpe =.m if da007_1_==. & da007_w2_2_1_==. & inw`wv'==1
replace r`wv'hibpe = 0 if xrtype==1 & da007_1_==2 
replace r`wv'hibpe = 0 if xrtype==2 & da007_w2_2_1_==2
replace r`wv'hibpe = 1 if xrtype==1 & da007_1_==1 
replace r`wv'hibpe = 1 if xrtype==2 & da007_w2_2_1_==1
replace r`wv'hibpe = 1 if xrtype==2 & zda007_1_==1 & da007_w2_1_1_== 1
label variable r`wv'hibpe "r`wv'hibpe:w`wv' r ever had high blood pressure"
label values r`wv'hibpe doctor

**spouse ever have high blood pressure
gen s`wv'hibpe =.
spouse r`wv'hibpe, result(s`wv'hibpe) wave(`wv')
label variable s`wv'hibpe "s`wv'hibpe:w`wv' s ever had high blood pressure"
label values s`wv'hibpe doctor

***wave high blood pressire dispute flag****

***Diabetes this wave
gen r`wv'diabe =.
replace r`wv'diabe =.m if da007_3_==. & da007_w2_2_3_==. & inw`wv'==1
replace r`wv'diabe = 0 if xrtype==1 & da007_3_==2 
replace r`wv'diabe = 0 if xrtype==2 & da007_w2_2_3_==2
replace r`wv'diabe = 1 if xrtype==1 & da007_3_==1 
replace r`wv'diabe = 1 if xrtype==2 & da007_w2_2_3_==1
replace r`wv'diabe = 1 if xrtype==2 & zda007_3_==1 & da007_w2_1_3_ == 1
label variable r`wv'diabe "r`wv'diabe:w`wv' r ever had diabetes"
label values r`wv'diabe doctor

*Spouse diabetes this wave
gen s`wv'diabe =.
spouse r`wv'diabe, result(s`wv'diabe) wave(`wv')
label variable s`wv'diabe "s`wv'diabe:w`wv' s ever had diabetes"
label values s`wv'diabe doctor

***Report cancer this wave
gen r`wv'cancre =.
replace r`wv'cancre =.m if da007_4_==. & da007_w2_2_4_==. & inw`wv'==1
replace r`wv'cancre = 0 if xrtype==1 & da007_4_==2 
replace r`wv'cancre = 0 if xrtype==2 & da007_w2_2_4_==2
replace r`wv'cancre = 1 if xrtype==1 & da007_4_==1 
replace r`wv'cancre = 1 if xrtype==2 & da007_w2_2_4_==1
replace r`wv'cancre = 1 if xrtype==2 & zda007_4_==1 & da007_w2_1_4_ == 1
label variable r`wv'cancre "r`wv'cancre:w`wv' r ever had cancer"
label values r`wv'cancre doctor

*Spouse cancer this wave
gen s`wv'cancre =.
spouse r`wv'cancre, result(s`wv'cancre) wave(`wv')
label variable s`wv'cancre "s`wv'cancre:w`wv' s ever had cancer"
label values s`wv'cancre doctor

***Lung disease this wave
gen r`wv'lunge =.
replace r`wv'lunge =.m if da007_5_==. & da007_w2_2_5_==. & inw`wv'==1
replace r`wv'lunge = 0 if xrtype==1 & da007_5_==2 
replace r`wv'lunge = 0 if xrtype==2 & da007_w2_2_5_==2
replace r`wv'lunge = 1 if xrtype==1 & da007_5_==1 
replace r`wv'lunge = 1 if xrtype==2 & da007_w2_2_5_==1
replace r`wv'lunge = 1 if xrtype==2 & zda007_5_==1 & da007_w2_1_5_==1
label variable r`wv'lunge "r`wv'lunge:w`wv' r ever had lung disease"
label values r`wv'lunge doctor

*Spouse lung disease this wave
gen s`wv'lunge =.
spouse r`wv'lunge, result(s`wv'lunge) wave(`wv')
label variable s`wv'lunge "s`wv'lunge:w`wv' s ever had lung disease"
label values s`wv'lunge doctor

***Have heart problem this wave
gen r`wv'hearte =.
replace r`wv'hearte =.m if da007_7_==. & da007_w2_2_7_==. & inw`wv'==1
replace r`wv'hearte = 0 if xrtype==1 & da007_7_==2 
replace r`wv'hearte = 0 if xrtype==2 & da007_w2_2_7_==2
replace r`wv'hearte = 1 if xrtype==1 & da007_7_==1 
replace r`wv'hearte = 1 if xrtype==2 & da007_w2_2_7_==1
replace r`wv'hearte = 1 if xrtype==2 & zda007_7_==1 & da007_w2_1_7_==1
label variable r`wv'hearte "r`wv'hearte:w`wv' r ever had heart problem"
label values r`wv'hearte doctor

*Spouse heart problem
gen s`wv'hearte =.
spouse r`wv'hearte, result(s`wv'hearte) wave(`wv')
label variable s`wv'hearte "s`wv'hearte:w`wv' s ever had heart problem"
label values s`wv'hearte doctor

*Have report stroke this wave
gen r`wv'stroke =.
replace r`wv'stroke =.m if da007_8_==. & da007_w2_2_8_==. & inw`wv'==1
replace r`wv'stroke = 0 if xrtype==1 & da007_8_==2 
replace r`wv'stroke = 0 if xrtype==2 & da007_w2_2_8_==2
replace r`wv'stroke = 1 if xrtype==1 & da007_8_==1 
replace r`wv'stroke = 1 if xrtype==2 & da007_w2_2_8_==1
replace r`wv'stroke = 1 if xrtype==2 & zda007_8_==1 & da007_w2_1_8_==1
label variable r`wv'stroke "r`wv'stroke:w`wv' r ever had stroke"
label values r`wv'stroke doctor

*Spouse report stroke this wave
gen s`wv'stroke =.
spouse r`wv'stroke, result(s`wv'stroke) wave(`wv')
label variable s`wv'stroke "s`wv'stroke:w`wv' s ever had stroke"
label values s`wv'stroke doctor

**Report psych problem this wave
gen r`wv'psyche =.
replace r`wv'psyche =.m if da007_11_==. & da007_w2_2_11_==. & inw`wv'==1
replace r`wv'psyche = 0 if xrtype==1 & da007_11_==2 
replace r`wv'psyche = 0 if xrtype==2 & da007_w2_2_11_==2
replace r`wv'psyche = 1 if xrtype==1 & da007_11_==1 
replace r`wv'psyche = 1 if xrtype==2 & da007_w2_2_11_==1
replace r`wv'psyche = 1 if xrtype==2 & zda007_11_==1 & da007_w2_1_11_==1
label variable r`wv'psyche "r`wv'psyche:w`wv' r ever had psych problem"
label values r`wv'psyche doctor

*Spouse psych problem this wave
gen s`wv'psyche =.
spouse r`wv'psyche, result(s`wv'psyche) wave(`wv')
label variable s`wv'psyche "s`wv'psyche:w`wv' s ever had psych problem"
label values s`wv'psyche doctor

**Arthritis
gen r`wv'arthre =.
replace r`wv'arthre =.m if da007_13_==. & da007_w2_2_13_==. & inw`wv'==1
replace r`wv'arthre = 0 if xrtype==1 & da007_13_==2 
replace r`wv'arthre = 0 if xrtype==2 & da007_w2_2_13_==2
replace r`wv'arthre = 1 if xrtype==1 & da007_13_==1 
replace r`wv'arthre = 1 if xrtype==2 & da007_w2_2_13_==1
replace r`wv'arthre = 1 if xrtype==2 & zda007_13_==1 & da007_w2_1_13_==1
label variable r`wv'arthre "r`wv'arthre:w`wv' r ever had arthritis"
label values r`wv'arthre doctor

*Spouse arth problem this wave
gen s`wv'arthre =.
spouse r`wv'arthre, result(s`wv'arthre) wave(`wv')
label variable s`wv'arthre "s`wv'arthre:w`wv' s ever had arthritis"
label values s`wv'arthre doctor

**Dyslipidemia
gen r`wv'dyslipe =.
replace r`wv'dyslipe =.m if da007_2_==. & da007_w2_2_2_==. & inw`wv'==1
replace r`wv'dyslipe = 0 if xrtype==1 & da007_2_==2 
replace r`wv'dyslipe = 0 if xrtype==2 & da007_w2_2_2_==2
replace r`wv'dyslipe = 1 if xrtype==1 & da007_2_==1 
replace r`wv'dyslipe = 1 if xrtype==2 & da007_w2_2_2_==1
replace r`wv'dyslipe = 1 if xrtype==2 & zda007_2_==1 & da007_w2_1_2_==1
label variable r`wv'dyslipe "r`wv'dyslipe:w`wv' r ever had dyslipidemia"
label values r`wv'dyslipe doctor

*Spouse dyslip this wave
gen s`wv'dyslipe =.
spouse r`wv'dyslipe, result(s`wv'dyslipe) wave(`wv')
label variable s`wv'dyslipe "s`wv'dyslipe:w`wv' s ever had dyslipidemia"
label values s`wv'dyslipe doctor

**livere Disease
gen r`wv'livere =.
replace r`wv'livere =.m if da007_6_==. & da007_w2_2_6_==. & inw`wv'==1
replace r`wv'livere = 0 if xrtype==1 & da007_6_==2 
replace r`wv'livere = 0 if xrtype==2 & da007_w2_2_6_==2
replace r`wv'livere = 1 if xrtype==1 & da007_6_==1 
replace r`wv'livere = 1 if xrtype==2 & da007_w2_2_6_==1
replace r`wv'livere = 1 if xrtype==2 & zda007_6_==1 & da007_w2_1_6_==1
label variable r`wv'livere "r`wv'livere:w`wv' r ever had liver disease"
label values r`wv'livere doctor

*Spouse livere problem this wave
gen s`wv'livere =.
spouse r`wv'livere, result(s`wv'livere) wave(`wv')
label variable s`wv'livere "s`wv'livere:w`wv' s ever had liver disease"
label values s`wv'livere doctor


**kidneye disease
gen r`wv'kidneye =.
replace r`wv'kidneye =.m if da007_9_==. & da007_w2_2_9_==. & inw`wv'==1
replace r`wv'kidneye = 0 if xrtype==1 & da007_9_==2 
replace r`wv'kidneye = 0 if xrtype==2 & da007_w2_2_9_==2
replace r`wv'kidneye = 1 if xrtype==1 & da007_9_==1 
replace r`wv'kidneye = 1 if xrtype==2 & da007_w2_2_9_==1
replace r`wv'kidneye = 1 if xrtype==2 & zda007_9_==1 & da007_w2_1_9_==1
label variable r`wv'kidneye "r`wv'kidneye:w`wv' r ever had kidney disease"
label values r`wv'kidneye doctor

*Spouse arth problem this wave
gen s`wv'kidneye =.
spouse r`wv'kidneye, result(s`wv'kidneye) wave(`wv')
label variable s`wv'kidneye "s`wv'kidneye:w`wv' s ever had kidney disease"
label values s`wv'kidneye doctor

**Stomache or other digestive disease
gen r`wv'digeste =.
replace r`wv'digeste =.m if da007_10_==. & da007_w2_2_10_==. & inw`wv'==1
replace r`wv'digeste = 0 if xrtype==1 & da007_10_==2 
replace r`wv'digeste = 0 if xrtype==2 & da007_w2_2_10_==2
replace r`wv'digeste = 1 if xrtype==1 & da007_10_==1 
replace r`wv'digeste = 1 if xrtype==2 & da007_w2_2_10_==1
replace r`wv'digeste = 1 if xrtype==2 & zda007_10_==1 & da007_w2_1_10_==1
label variable r`wv'digeste "r`wv'digeste:w`wv' r ever had stomach or other digestive disease"
label values r`wv'digeste doctor

*Spouse digest problem this wave
gen s`wv'digeste =.
spouse r`wv'digeste, result(s`wv'digeste) wave(`wv')
label variable s`wv'digeste "s`wv'digeste:w`wv' s ever had stomach or other digestive disease"
label values s`wv'digeste doctor

**Asthma
gen r`wv'asthmae =.
replace r`wv'asthmae =.m if da007_14_==. & da007_w2_2_14_==. & inw`wv'==1
replace r`wv'asthmae = 0 if xrtype==1 & da007_14_==2 
replace r`wv'asthmae = 0 if xrtype==2 & da007_w2_2_14_==2
replace r`wv'asthmae = 1 if xrtype==1 & da007_14_==1 
replace r`wv'asthmae = 1 if xrtype==2 & da007_w2_2_14_==1
replace r`wv'asthmae = 1 if xrtype==2 & zda007_14_==1 & da007_w2_1_14_==1
label variable r`wv'asthmae "r`wv'asthmae:w`wv' r ever had asthma"
label values r`wv'asthmae doctor

*Spouse arth problem this wave
gen s`wv'asthmae =.
spouse r`wv'asthmae, result(s`wv'asthma) wave(`wv')
label variable s`wv'asthmae "s`wv'asthmae:w`wv' s ever had asthma"
label values s`wv'asthmae doctor

****Memory reltaed disease
***memory realted disease
gen r`wv'memrye =.
replace r`wv'memrye =.m if da007_12_==. & da007_w2_2_12_==. & inw`wv'==1
replace r`wv'memrye = 0 if xrtype==1 & da007_12_==2
replace r`wv'memrye = 0 if xrtype==2 & da007_w2_2_12_==2
replace r`wv'memrye = 1 if xrtype==1 & da007_12_==1 
replace r`wv'memrye = 1 if xrtype==2 & da007_w2_2_12_==1
replace r`wv'memrye = 1 if xrtype==2 & zda007_12_==1 & da007_w2_1_12_==1
label variable r`wv'memrye "r`wv'memrye:w`wv' r ever had memory problem"
label values r`wv'memrye doctor

*Spouse memory realted disease
gen s`wv'memrye =.
spouse r`wv'memrye, result(s`wv'memrye) wave(`wv')
label variable s`wv'memrye "s`wv'memrye:w`wv' s ever had memory problem"
label values s`wv'memrye doctor

**********bmi***********
**Height in meteres
gen r`wv'height=.
replace r`wv'height = .m if qi002==993 | (qi002==. & inw`wv'==1)
replace r`wv'height = .o if qi001s97 ==97
replace r`wv'height = .d if qi002==. & (qi001s1==1 | qi001s2 ==2 |qi001s4 ==4 | qi001s5 ==5 | qi001s6 ==6 | qi001s7 ==7 | qi001s8 == 8 )
replace r`wv'height = .r if qi002==. & qi001s3==3
replace r`wv'height = .i if inrange(qi002,10,99)
replace r`wv'height = qi002 if inrange(qi002,1,2) // assumed to be reported in meters
replace r`wv'height = qi002/100 if inrange(qi002,100,200) // reported in cm
label variable r`wv'height "r`wv'height:w`wv' height in meters"

*Spouse height in meteres
gen s`wv'height =.
spouse r`wv'height, result(s`wv'height) wave(`wv')
label variable s`wv'height "s`wv'height:w`wv' height in meters"

**Weight in kilograms
gen r`wv'weight=. 
replace r`wv'weight = .m if ql002 ==. & inw1==1
replace r`wv'weight = .o if ql001s97 ==97
replace r`wv'weight = .d if ql002 ==. & (ql001s1==1 | ql001s2 ==2 |ql001s4 ==4 | ql001s5 ==5 | ql001s6 ==6 | ql001s7 ==7 | ql001s8 == 8 )
replace r`wv'weight = .r if ql002 ==. & ql001s3 ==3
replace r`wv'weight = .i if inrange(ql002,0,20)
replace r`wv'weight = ql002 if inrange(ql002,21,200)
label variable r`wv'weight "r`wv'weight:w`wv' weight in kilograms"

*Spouse weight in kilograms
gen s`wv'weight =.
spouse r`wv'weight, result(s`wv'weight) wave(`wv')
label variable s`wv'weight "s`wv'weight:w`wv' weight in kilograms"

**BMI**
gen r`wv'bmi=.
missing_H r`wv'weight r`wv'height, result(r`wv'bmi)
replace r`wv'bmi=.i if r`wv'weight == .i | r`wv'height == .i
replace r`wv'bmi=r`wv'weight/(r`wv'height^2) if !mi(r`wv'weight) & !mi(r`wv'height)
label variable r`wv'bmi "r`wv'bmi:w`wv' body mass index=kg/m2"

*Spouse BMI
gen s`wv'bmi =.
spouse r`wv'bmi, result(s`wv'bmi) wave(`wv')
label variable s`wv'bmi "s`wv'bmi:w`wv' body mass index=kg/m2"

*****physical activity or exercise******
*vigorous physical activity
gen r`wv'vgact_c =.
replace r`wv'vgact_c =.m if da051_1_==. & inw`wv'==1
replace r`wv'vgact_c = 0 if da051_1_==2
replace r`wv'vgact_c = 1 if da051_1_==1
label variable r`wv'vgact_c "r`wv'vgact_c:w`wv' r any vigorous physical activity or exercise at least 10 minutes"
label values r`wv'vgact_c vgactx_c


*spouse vigorous physical activity
gen s`wv'vgact_c =.
spouse r`wv'vgact_c, result(s`wv'vgact_c) wave(`wv')
label variable s`wv'vgact_c "s`wv'vgact_c:w`wv' s any vigorous physical activity or exercise at least 10 minutes"
label values s`wv'vgact_c vgactx_c

****# days/wk ********
gen r`wv'vgactx_c =.
replace r`wv'vgactx_c =.m if da052_1_==. & inw`wv'==1
replace r`wv'vgactx_c = 0 if da051_1_==2
replace r`wv'vgactx_c = da052_1_ if inrange(da052_1_,1,7)
label variable r`wv'vgactx_c "r`wv'vgactx_c:w`wv' r # days/wk vigorous physical activity or exercise at least 10 minutes"

*spouse vigorous physical activity
gen s`wv'vgactx_c =.
spouse r`wv'vgactx_c, result(s`wv'vgactx_c) wave(`wv')
label variable s`wv'vgactx_c "s`wv'vgactx_c:w`wv' s # days/wk vigorous physical activity or exercise at least 10 minutes"


*moderate physical activity
gen r`wv'mdact_c =.
replace r`wv'mdact_c =.m if da051_2_==. & inw`wv'==1
replace r`wv'mdact_c = 0 if da051_2_==2
replace r`wv'mdact_c = 1 if da051_2_==1
label variable r`wv'mdact_c "r`wv'mdact_c:w`wv' r any moderate physical activity or exercise at least 10 minutes"
label values r`wv'mdact_c vgactx_c
/*ask only the second sampled household*/ 

*spouse moderate physical activity
gen s`wv'mdact_c =.
spouse r`wv'mdact_c, result(s`wv'mdact_c) wave(`wv')
label variable s`wv'mdact_c "s`wv'mdact_c:w`wv' s any moderate physical activity or exercise at least 10 minutes"
label values s`wv'mdact_c vgactx_c

******# of days/wk *****
gen r`wv'mdactx_c =.
replace r`wv'mdactx_c =.m if da052_2_==. & inw`wv'==1
replace r`wv'mdactx_c = 0 if da051_2_==2
replace r`wv'mdactx_c = da052_2_ if inrange(da052_2_,1,7)
label variable r`wv'mdactx_c "r`wv'mdactx_c:w`wv' r # days/wk moderate physical activity or exercise at least 10 minutes"

*spouse moderate physical activity
gen s`wv'mdactx_c =.
spouse r`wv'mdactx_c, result(s`wv'mdactx_c) wave(`wv')
label variable s`wv'mdactx_c "s`wv'mdactx_c:w`wv' s # days/wk moderate physical activity or exercise at least 10 minutes"


*light physical activity 
gen r`wv'ltact_c =.
replace r`wv'ltact_c =.m if da051_3_==. & inw`wv'==1
replace r`wv'ltact_c = 0 if da051_3_==2
replace r`wv'ltact_c = 1 if da051_3_==1
label variable r`wv'ltact_c "r`wv'ltact_c:w`wv' r any light physical activity or exercise at least 10 minutes"
label values r`wv'ltact_c vgactx_c
/*ask only the second sampled household*/

*spouse
gen s`wv'ltact_c =.
spouse r`wv'ltact_c, result(s`wv'ltact_c) wave(`wv')
label variable s`wv'ltact_c "s`wv'ltact_c:w`wv' s any light physical activity or exercise at least 10 minutes"
label values s`wv'ltact_c vgactx_c

******# of days/wk *****
gen r`wv'ltactx_c =.
replace r`wv'ltactx_c =.m if da052_3_==. & inw`wv'==1
replace r`wv'ltactx_c = 0 if da051_3_==2
replace r`wv'ltactx_c = da052_3_ if inrange(da052_3_,1,7)
label variable r`wv'ltactx_c "r`wv'ltactx_c:w`wv' r # days/wk light physical activity or exercise at least 10 minutes"

*spouse
gen s`wv'ltactx_c =.
spouse r`wv'ltactx_c, result(s`wv'ltactx_c) wave(`wv')
label variable s`wv'ltactx_c "s`wv'ltactx_c:w`wv' s # days/wk light physical activity or exercise at least 10 minutes"

********drink******************
***Ever drink alcohol last year***
gen r`wv'drinkl =.
replace r`wv'drinkl =.m if da067==. & inw`wv'==1
replace r`wv'drinkl = 0 if da067==3
replace r`wv'drinkl = 1 if inlist(da067,1,2) 
label values r`wv'drinkl drinkl

label variable r`wv'drinkl "r`wv'drinkl:w`wv' r ever drinks any alcohol last year"
tab r`wv'drinkl,m

*Spouse alcohol last year
gen s`wv'drinkl =.
spouse r`wv'drinkl, result(s`wv'drinkl) wave(`wv')
label variable s`wv'drinkl "s`wv'drinkl:w`wv' s ever drinks any alcohol last year"
label values s`wv'drinkl drinkl

***Ever drink alcohol before***
gen r`wv'drink =.
replace r`wv'drink =.m if da069==. & inw`wv'==1
replace r`wv'drink = 0 if da069==1
replace r`wv'drink = 1 if inlist(da069,2,3) | inlist(da067,1,2) 
label variable r`wv'drink "r`wv'drink:w`wv' r ever drinks any alcohol before"
label values r`wv'drink drinkl

*Spouse ever drink alcohol before
gen s`wv'drink =.
spouse r`wv'drink, result(s`wv'drink) wave(`wv')
label variable s`wv'drink "s`wv'drink:w`wv' s ever drinks any alcohol before"
label values s`wv'drink drinkl

***frequcny of drinking***
egen w`wv'drinkx = rowmax(da072 da074 da076)

gen r`wv'drinkx=. 
replace r`wv'drinkx = .m if inw`wv' == 1
replace r`wv'drinkx = 0 if inlist(da067,2,3) | w`wv'drink==0
replace r`wv'drinkx = 1 if inlist(w`wv'drinkx,1,2)
replace r`wv'drinkx = 2 if inlist(w`wv'drinkx,3,4)
replace r`wv'drinkx = 3 if inlist(w`wv'drinkx,5)
replace r`wv'drinkx = 4 if inlist(w`wv'drinkx,6,7,8)
label variable r`wv'drinkx "r`wv'drinkx:w`wv' r frequency of drinking last year"
label values r`wv'drinkx drinkx

drop w`wv'drinkx

*spouse drink frequency
gen s`wv'drinkx =.
spouse r`wv'drinkx, result(s`wv'drinkx) wave(`wv')
label variable s`wv'drinkx "s`wv'drinkx:w`wv' s frequency of drinking last year"
label values s`wv'drinkx drinkx

****smoke****
***Smoke Ever
gen r`wv'smokev =.
replace r`wv'smokev =.m if da059 ==. & inw`wv' == 1
replace r`wv'smokev = 0 if da059 == 2
replace r`wv'smokev = 1 if zda059 == 1 | da059 == 1
label variable r`wv'smokev "r`wv'smokev:w`wv' r smoke ever"
label values r`wv'smokev smokes

*Spouse smoke ever
gen s`wv'smokev =.
spouse r`wv'smokev, result(s`wv'smokev) wave(`wv')
label variable s`wv'smokev "s`wv'smokev:w`wv' s smoke ever"
label values s`wv'smokev smokes

*Smoking now
gen r`wv'smoken=. 
replace r`wv'smoken=.m if da061==. & inw`wv'==1
replace r`wv'smoken= 0 if da061==2 | r`wv'smokev == 0
replace r`wv'smoken= 1 if da061==1
label variable r`wv'smoken "r`wv'smoken:w`wv' r smoke now"
label values r`wv'smoken smokes

*Spouse smoke ever
gen s`wv'smoken =.
spouse r`wv'smoken, result(s`wv'smoken) wave(`wv')
label variable s`wv'smoken "s`wv'smoken:w`wv' s smoke now"
label values s`wv'smoken smokes

*****Health limit work******
gen r`wv'hlthlm_c=.
replace r`wv'hlthlm_c=.w if xf1==2 & mi(r`wv'hlthlm_c)
replace r`wv'hlthlm_c=.m if r`wv'hlthlm_c==. & inw`wv'==1
replace r`wv'hlthlm_c=0 if inlist(fb010,1,3,4,5) & mi(r`wv'hlthlm_c)
replace r`wv'hlthlm_c=0 if fc013==0 | fd030==0 | fh004==0 
replace r`wv'hlthlm_c=1 if inrange(fc013,1,365) | inrange(fd030,1,365) | inrange(fh004,1,365) | fb010==2 |fl020s7==7
label variable r`wv'hlthlm_c "r`wv'hlthlm_c:w`wv' r health problems limit work"
label values r`wv'hlthlm_c diff

*Spouse 
gen s`wv'hlthlm_c =.
spouse r`wv'hlthlm_c, result(s`wv'hlthlm_c) wave(`wv')
label variable s`wv'hlthlm_c "s`wv'hlthlm_c:w`wv' s health problems limit work"
label values s`wv'hlthlm_c diff



****drop CHARLS health raw variables***
drop `health_w2_health'

****drop CHARLS work raw variables***
drop `health_w2_work'

****drop CHARLS weight raw variables***
drop `health_w2_weight'

***drop CHARLS biomarker raw variables***
drop `health_w2_biomark'



*set wave number
*set wave number
local wv=2
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2


***merge with wave 2 ins data***
local ins_w2_hc ea001s1 ea001s2 ea001s3 ea001s4 ea001s5 ea001s6 ea001s7 ea001s8 ea001s9 ea001s10 ea001s11 ///
                ea006_?_ ea006_10_ ed005_total  ///
                ed001 ed002 ed005_1 ed005_?_ ed006_1 ed007_1 ed023_1 ed024_1 ///
	 							ee003 ee004 ee005 ee005_1 ee006 ee006_1 ee016 ee024_1 ee027_1 ///
						    ef006 eh001 eh002 eh003 eh003_1 eh004 eh004_1 
                

merge 1:1 ID using "`wave_2_healthcare'", keepusing(`ins_w2_hc') 

tab _merge

drop if _merge==2
drop _merge






***Medical care utilization: Hospital*************
**NEED ee04 to verify ee003 due to skip patten error****
***Hospital stay last year*************
*respondent
gen r`wv'hosp1y = . 
replace r`wv'hosp1y =.m if ee003==. & inw`wv'==1
replace r`wv'hosp1y =.p if ee003==. & ef006==4
replace r`wv'hosp1y = 0 if ee003==2 
replace r`wv'hosp1y = 1 if ee003==1 | inrange(ee004,1,30) 
label var r`wv'hosp1y "r`wv'hosp1y:w`wv' R hospital stay last year"
label val r`wv'hosp1y yesno

***spouse 
gen s`wv'hosp1y = .
spouse r`wv'hosp1y, result(s`wv'hosp1y) wave(`wv')
label var s`wv'hosp1y  "s`wv'hosp1y:w`wv' S hospital stay last year"
label val s`wv'hosp1y yesno

***# hospital stay last year*************
*respondent
gen r`wv'hsptim1y =.
replace r`wv'hsptim1y =.m if ee004==. & inw`wv'==1
replace r`wv'hsptim1y =.s if ee004==. & ee003==2
replace r`wv'hsptim1y =.p if ee004==. & ef006==4
replace r`wv'hsptim1y = 0 if r`wv'hosp1y == 0 
replace r`wv'hsptim1y =ee004 if inrange(ee004,1,30)
label var r`wv'hsptim1y "r`wv'hsptim1y:w`wv' R # hosp stays last year"

*spouse
gen s`wv'hsptim1y = .
spouse r`wv'hsptim1y, result(s`wv'hsptim1y) wave(`wv')
label var s`wv'hsptim1y "s`wv'hsptim1y:w`wv' S # hosp stays last year"

***# hosp nights last episode*************
*respondent
gen r`wv'hspnite =. 
replace r`wv'hspnite=.m if ee016==. & inw`wv'==1
replace r`wv'hspnite=.s if ee016==. & ee003==2
replace r`wv'hspnite=.p if ee016==. & ef006==4
replace r`wv'hspnite =0 if  r`wv'hosp1y == 0 
replace r`wv'hspnite = ee016 if inrange(ee016,0,365)
label var r`wv'hspnite "r`wv'hspnite:w`wv' R # hosp nights last episode"

*spouse	
gen s`wv'hspnite = .
spouse r`wv'hspnite, result(s`wv'hspnite) wave(`wv')
label var s`wv'hspnite "s`wv'hspnite:w`wv' S # hosp nights last episode"


***Doctor visit/outpatient last month*********
*respondent
gen r`wv'doctor1m =.
replace r`wv'doctor1m =.m if inw`wv'==1
replace r`wv'doctor1m =.p if ed001==. & ef006==4
replace r`wv'doctor1m = 0 if ed001==2
replace r`wv'doctor1m = 1 if ed001==1
label var r`wv'doctor1m   "r`wv'doctor1m:w`wv' R doctor visit/outpatient last month"
label val r`wv'doctor1m yesno

*spouse 
gen s`wv'doctor1m = .
spouse r`wv'doctor1m, result(s`wv'doctor1m) wave(`wv') 
label var s`wv'doctor1m  "s`wv'doctor1m:w`wv' S doctor visit/outpatient last month"
label val s`wv'doctor1m yesno

***# doctor visit/outpatient last month*********
egen doctim=rowtotal(ed005_1_ ed005_2_ ed005_3_ ed005_4_ ed005_5_ ed005_6_ ed005_7_),m

*respondent
gen r`wv'doctim1m=.  
replace r`wv'doctim1m = .m if inw`wv' == 1
replace r`wv'doctim1m = .p if ef006==4
replace r`wv'doctim1m = 0 if ed001 == 2
replace r`wv'doctim1m=doctim if inrange(doctim,0,30)
label var r`wv'doctim1m  "r`wv'doctim1m:w`wv' R # doctor visit/outpatient last month" 

*spouse
gen s`wv'doctim1m = .
spouse r`wv'doctim1m, result(s`wv'doctim1m) wave(`wv') 
label var s`wv'doctim1m  "s`wv'doctim1m:w`wv' S # doctor visit/outpatient last month"

drop doctim


***medical care utilization: dental care utilization********** 
***respondent
gen r`wv'dentst1y = .
replace r`wv'dentst1y =.m if eh001==. & inw`wv'==1
replace r`wv'dentst1y =.p if eh001==1 & ef006==4
replace r`wv'dentst1y =0 if eh001==2
replace r`wv'dentst1y =1 if eh001==1
label var r`wv'dentst1y "r`wv'dentst1y:w`wv' R dental care last year"
label val r`wv'dentst1y  yesno

***spouse 
gen s`wv'dentst1y = .
spouse r`wv'dentst1y, result(s`wv'dentst1y) wave(`wv')
label var s`wv'dentst1y "s`wv'dentst1y:w`wv' S dental care last year"
label val s`wv'dentst1y  yesno	

***# dental visit last year********** 
*respondent
gen r`wv'dentim1y =.
replace r`wv'dentim1y =.m if eh002==. 
replace r`wv'dentim1y =.p if eh002==. & ef006==4
replace r`wv'dentim1y =0 if eh001==2
replace r`wv'dentim1y =eh002 if inrange(eh002,0,100)
label var r`wv'dentim1y "r`wv'dentim1y:w`wv' R # dental visit last year"

*spouse
gen s`wv'dentim1y = .
spouse r`wv'dentim1y, result(s`wv'dentim1y) wave(`wv')
label var s`wv'dentim1y "s`wv'dentim1y:w`wv' S # dental visit last year"

***medical expenditures: out of pocket and total***************

****Inpatient expenditure****
***total cost****
gen r`wv'tothos1y=.
replace r`wv'tothos1y = .m if inw`wv'==1
replace r`wv'tothos1y = 0 if r`wv'hsptim1y == 0 | ee005 == 2
replace r`wv'tothos1y = ee024_1 if inrange(ee024_1,0,9999999) & r`wv'hsptim1y==1
replace r`wv'tothos1y = ee005_1 if inrange(ee005_1,0,9999999) & inrange(r`wv'hsptim1y,2,40)
label var r`wv'tothos1y "r`wv'tothos1y:w`wv' R hospitalization total expenditure last year"

**spouse 
gen s`wv'tothos1y = .
spouse r`wv'tothos1y, result(s`wv'tothos1y) wave(`wv')
label var s`wv'tothos1y "s`wv'tothos1y:w`wv' S hospitalization total expenditure last year"

****OOP ******
gen r`wv'oophos1y = .  
replace r`wv'oophos1y = .m if inw`wv'==1
replace r`wv'oophos1y = 0 if r`wv'hsptim1y == 0 | ee004 == 0 | (ee004 == 1 & ee027 == 2) 
replace r`wv'oophos1y = 0 if ee004==1 & ee027==2 
replace r`wv'oophos1y = 0 if mi(r`wv'oophos1y) & ee003==2
replace r`wv'oophos1y = .d if ee004==1 & ee027==1 & ee027_1 == -999
replace r`wv'oophos1y = ee006_1 if inrange(ee006_1,0,8000000) & inrange(ee004,2,30) & ee006==1 
replace r`wv'oophos1y = ee027_1 if inrange(ee027_1,0,8000000) & ee004 == 1 & ee027==1 
label var r`wv'oophos1y "r`wv'oophos1y:w`wv' R hospitalization out-of-pocket expenditure last year"

gen s`wv'oophos1y = .
spouse r`wv'oophos1y, result(s`wv'oophos1y) wave(`wv')
label var s`wv'oophos1y "s`wv'oophos1y:w`wv' S hospitalization out-of-pocket expenditure last year"


/***Outpatient expenditure***/
***total cost***
gen r`wv'totdoc1m = .
replace r`wv'totdoc1m = .m if inw`wv' == 1
replace r`wv'totdoc1m = .d if ed023_1==-9999
replace r`wv'totdoc1m = 0 if r`wv'doctim1m == 0
replace r`wv'totdoc1m = ed023_1 if inrange(ed023_1,0,999999) & r`wv'doctim1m == 1
replace r`wv'totdoc1m = ed006_1 if  inrange(r`wv'doctim1m,2,40) & inrange(ed006_1,0,99999999)
label var r`wv'totdoc1m "r`wv'totdoc1m:w`wv' R doctor visit total expenditure last month"	
 
***spouse 
gen s`wv'totdoc1m = .
spouse r`wv'totdoc1m, result(s`wv'totdoc1m) wave(`wv')
label var s`wv'totdoc1m "s`wv'totdoc1m:w`wv' S doctor visit total expenditure last month" 

***OOP****
gen r`wv'oopdoc1m =.
replace r`wv'oopdoc1m = .m if inw`wv' == 1
replace r`wv'oopdoc1m = .d if ed024_1 == -9999
replace r`wv'oopdoc1m = 0 if r`wv'doctim1m == 0 
replace r`wv'oopdoc1m = 0 if r`wv'totdoc1m ==0
replace r`wv'oopdoc1m = ed024_1 if inrange(ed024_1,0,999999) & r`wv'doctim1m==1
replace r`wv'oopdoc1m = ed007_1 if inrange(ed007_1,0,200000) & inrange(r`wv'doctim1m,2,40) 
label var r`wv'oopdoc1m "r`wv'oopdoc1m:w`wv' R doctor visit out-of-pocket expenditure last month"


gen s`wv'oopdoc1m = .
spouse r`wv'oopdoc1m , result(s`wv'oopdoc1m) wave(`wv')
label var s`wv'oopdoc1m "s`wv'oopdoc1m:w`wv' S doctor visit out-of-pocket expenditure last month"

/***dental care expenditure***/
****total cost****
gen r`wv'totden1y = .
replace r`wv'totden1y = .m if inw`wv' == 1
replace r`wv'totden1y = .p if eh003_1==. & ef006==4
replace r`wv'totden1y = 0 if eh003==2
replace r`wv'totden1y = 0 if r`wv'dentst1y == 0
replace r`wv'totden1y = eh003_1 if inrange(eh003_1,0,30000)
label var r`wv'totden1y "r`wv'totden1y:w`wv' R dental care total expenditure last year"

***spouse 
gen s`wv'totden1y = .
spouse r`wv'totden1y, result(s`wv'totden1y) wave(`wv')
label var s`wv'totden1y "s`wv'totden1y:w`wv' S dental care total expenditure last year"

***oop *****
gen r`wv'oopden1y = .
replace r`wv'oopden1y = .m if inw`wv' == 1
replace r`wv'oopden1y = .p if eh004_1==. & ef006==4
replace r`wv'oopden1y = 0  if eh004_1==. & eh004==2
replace r`wv'oopden1y = 0  if r`wv'dentst1y == 0
replace r`wv'oopden1y = eh004_1 if inrange(eh004_1,0,30000)
label var r`wv'oopden1y "r`wv'oopden1y:w`wv' R dental care out-of-pocket expenditure last year"

gen s`wv'oopden1y = .
spouse r`wv'oopden1y, result(s`wv'oopden1y) wave(`wv')
label var s`wv'oopden1y "s`wv'oopden1y:w`wv' S dental care out-of-pocket expenditure last year"


*********************************************************************
***cover by government Health insurance program ***
*wave 1 respondent cover by public Health insurance program
gen r`wv'higov=.
replace r`wv'higov= .m if  ea001s1==. & ea001s2==. & ea001s3==. & ea001s4==. & ea001s5==. & ea001s6==. & ea001s9==. & ea001s11==. & ea001s7==. & ea001s8==. & ea001s10==.
replace r`wv'higov= 0 if  ea001s11==11 | ea001s7==7 | ea001s8==8 | ea001s10==10
replace r`wv'higov= 1 if  ea001s1==1 | ea001s2==2 | ea001s3==3 | ea001s4==4 | ea001s5==5 | ea001s6==6 |ea001s9==9
label variable r`wv'higov "r`wv'higov:w`wv' r cover by public health insurance"
label values r`wv'higov ins

*wave 1 spouse cover by government health insurance program
gen s`wv'higov=.
spouse r`wv'higov, result(s`wv'higov) wave(`wv')
label variable s`wv'higov "s`wv'higov:w`wv' s cover by public health insurance"
label values s`wv'higov ins


***cover by private Health insurance program ***
*wave 1 respondent cover by private health insurance program
gen r`wv'hipriv=.
replace r`wv'hipriv= .m if  ea001s1==. & ea001s2==. & ea001s3==. & ea001s4==. & ea001s5==. & ea001s6==. & ea001s9==. & ea001s11==. & ea001s7==. & ea001s8==. & ea001s10==.
replace r`wv'hipriv= 0 if ea001s11==11 |ea001s1==1 | ea001s2==2 | ea001s3==3 | ea001s4==4 | ea001s5==5 | ea001s6==6 |ea001s9==9 | ea001s10==10
replace r`wv'hipriv= 1 if ea001s7==7 | ea001s8==8
label variable r`wv'hipriv "r`wv'hipriv:w`wv' R cover by Private Health Ins"
label values r`wv'hipriv insp

*wave 1 spouse cover by private health insurance program
gen s`wv'hipriv=.
spouse r`wv'hipriv, result(s`wv'hipriv) wave(`wv')
label variable s`wv'hipriv "s`wv'hipriv:w`wv' S cover by Private Health Ins"
label values s`wv'hipriv insp

***cover by other Health insurance program ***
*wave 1 respondent cover by other health insurance program
gen r`wv'hiothp=.
replace r`wv'hiothp= .m if  ea001s1==. & ea001s2==. & ea001s3==. & ea001s4==. & ea001s5==. & ea001s6==. & ea001s9==. & ea001s11==. & ea001s7==. & ea001s8==. & ea001s10==.
replace r`wv'hiothp= 0 if ea001s11==11 |ea001s1==1 | ea001s2==2 | ea001s3==3 | ea001s4==4 | ea001s5==5 | ea001s6==6 |ea001s9==9 | ea001s7==7 | ea001s8==8
replace r`wv'hiothp= 1 if ea001s10==10

label variable r`wv'hiothp "r`wv'hiothp:w`wv' r cover by other health ins"
label values r`wv'hiothp inso

*wave 1 spouse cover by other health insurance program
gen s`wv'hiothp=.
spouse r`wv'hiothp, result(s`wv'hiothp) wave(`wv')
label variable s`wv'hiothp "s`wv'hiothp:w`wv' s cover by other health ins"
label values s`wv'hiothp inso


***drop wave 2 file raw variables
drop `ins_w2_hc'



*set wave number
local wv=2
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2

***merge with health file***
local cog_w`wv'_health dc001s1 dc001s2 dc001s3 ///
                    dc002 dc004 ///
                    dc006_1_s* dc006_2_s* dc006_3_s* ///
                    dc019 dc020 dc021 dc022 dc023 dc025 ///
                    dc027s1 dc027s2 dc027s3 dc027s4 dc027s5 dc027s6 dc027s7 dc027s8 dc027s9 dc027s10 dc027s11 ///
                    db032
merge 1:1 ID using "`wave_2_health'", keepusing(`cog_w`wv'_health') 
drop if _merge==2
drop _merge



***Self-reported memory***
*wave 2 respondent self-reported memory
gen r`wv'slfmem = .
replace r`wv'slfmem = .m if dc004==. & inw`wv'==1
replace r`wv'slfmem = .p if dc004==. & db032==4
replace r`wv'slfmem = 1 if dc004==1
replace r`wv'slfmem = 2 if dc004==2
replace r`wv'slfmem = 3 if dc004==3
replace r`wv'slfmem = 4 if dc004==4
replace r`wv'slfmem = 5 if dc004==5
label variable r`wv'slfmem "r`wv'slfmem:w`wv' R Self-reported memory"
label values r`wv'slfmem memory
tab r`wv'slfmem,m

**wave 2 spouse Self-reported memory***
gen  s`wv'slfmem =.
spouse r`wv'slfmem, result(s`wv'slfmem) wave(`wv')
label variable  s`wv'slfmem "s`wv'slfmem:w`wv' S Self-reported memory"
label values s`wv'slfmem memory

***Recode Word listing scores***
forvalues i = 1 / 10 {
    recode dc006_1_s`i' (`i'=1), gen(dc006_1_s`i'_)
    recode dc006_2_s`i' (`i'=1), gen(dc006_2_s`i'_)
    recode dc006_3_s`i' (`i'=1), gen(dc006_3_s`i'_)
    recode dc027s`i'    (`i'=1), gen(dc027s`i'_)
}
recode dc006_1_s11 (11=0), gen(dc006_1_s11_)
recode dc006_2_s11 (11=0), gen(dc006_2_s11_)
recode dc006_3_s11 (11=0), gen(dc006_3_s11_)
recode dc027s11 (11=0), gen(dc027s11_)

forvalues i=1/3 {
    egen w`i'=rowtotal(dc006_`i'_s1_ dc006_`i'_s2_ dc006_`i'_s3_ dc006_`i'_s4_  dc006_`i'_s5_ dc006_`i'_s6_ dc006_`i'_s7_ dc006_`i'_s8_ dc006_`i'_s9_ dc006_`i'_s10_ dc006_`i'_s11_),m
}

***immediate word recall***
*wave 2 respondent immediate word recall  
egen r`wv'imrc =rowmax(w1 w2 w3)
replace r`wv'imrc= .m if mi(r`wv'imrc) & inw`wv'==1
replace r`wv'imrc= .p if mi(r`wv'imrc) & db032==4
label variable r`wv'imrc "r`wv'imrc:w`wv' R immediate word recall"

*wave 2 spouse immediate word recall
gen s`wv'imrc =.
spouse r`wv'imrc, result(s`wv'imrc) wave(`wv')
label variable s`wv'imrc "s`wv'imrc:w`wv' S immediate word recall"

drop dc006_?_s*_

**delayed word recall***
*wave 2 respondent delayed word recall
egen r`wv'dlrc =rowtotal(dc027s1_ dc027s2_ dc027s3_ dc027s4_ dc027s5_ dc027s6_ dc027s7_ dc027s8_ dc027s9_ dc027s10_ dc027s11_),m
replace r`wv'dlrc= .m if mi(r`wv'dlrc) & inw`wv'==1
replace r`wv'dlrc= .p if dc027s1==.& db032 == 4
label variable r`wv'dlrc "r`wv'dlrc:w`wv' R delayed word recall"


*wave 2 spouse delayed word recall
gen s`wv'dlrc =.
spouse r`wv'dlrc, result(s`wv'dlrc) wave(`wv')
label variable s`wv'dlrc "s`wv'dlrc:w`wv' S delayed word recall"

drop dc027s*_
drop w1 w2 w3

***cognition month naming*** it used to have .e for no but not anymore this wave
*wave 2 respondent cognition month naming
gen r`wv'mo= .
replace r`wv'mo = .m if dc001s1==. & dc001s2==. & dc001s3==. & inw`wv'==1
replace r`wv'mo = .p if dc001s2==. & db032==4
replace r`wv'mo = 0 if r`wv'mo==. & inw`wv'==1
replace r`wv'mo = 1 if dc001s2==2  
label variable r`wv'mo "r`wv'mo:w`wv' R cognition date naming-month"
label values r`wv'mo monthnaming


*wave 2 spouse month naming
gen s`wv'mo =.
spouse r`wv'mo, result(s`wv'mo) wave(`wv')
label variable s`wv'mo "s`wv'mo:w`wv' S cognition date naming-month"
label values s`wv'mo monthnaming

***cognition day naming***
*wave 2 respondent cognition day naming
gen r`wv'dy= .
replace r`wv'dy = .m if dc001s1==. & dc001s2==. & dc001s3==. & inw`wv'==1
replace r`wv'dy = .p if dc001s3==. & db032==4
replace r`wv'dy = 0 if r`wv'dy==.  & inw`wv'==1
replace r`wv'dy = 1 if dc001s3==3 
label variable r`wv'dy "r`wv'dy:w`wv' R cognition date naming-day of month"
label values r`wv'dy daynaming


*wave 2 spouse day naming
gen s`wv'dy =.
spouse r`wv'dy, result(s`wv'dy) wave(`wv')
label variable s`wv'dy "s`wv'dy:w`wv' S cognition date naming-day of month"
label values s`wv'dy daynaming

***cognition year naming***
*wave 2 respondent cognition year naming
gen r`wv'yr= .
replace r`wv'yr = .m if dc001s1==. & dc001s2==. & dc001s3==. & inw`wv'==1
replace r`wv'yr = .p if dc001s1==. & db032==4
replace r`wv'yr = 0 if r`wv'yr==.  & inw`wv'==1
replace r`wv'yr = 1 if dc001s1==1 
label variable r`wv'yr "r`wv'yr:w`wv' R cognition date naming-year"
label values r`wv'yr yeaernaming


*wave 2 spouse year naming
gen s`wv'yr =.
spouse r`wv'yr, result(s`wv'yr) wave(`wv')
label variable s`wv'yr "s`wv'yr:w`wv' S cognition date naming-year"
label values s`wv'yr yeaernaming


***cognition day of week naming***
*wave 2 respondent cognition day of week naming
gen r`wv'dw= .
replace r`wv'dw = .m if dc002==. & inw`wv'==1
replace r`wv'dw = .p if dc002==. & db032==4
replace r`wv'dw = 0 if dc002==2
replace r`wv'dw = 1 if dc002==1 
label variable r`wv'dw "r`wv'dw:w`wv' R cognition date naming-day of week"
label values r`wv'dw daywnaming


*wave 2 spouse day of week naming
gen s`wv'dw =.
spouse r`wv'dw, result(s`wv'dw) wave(`wv')
label variable s`wv'dw "s`wv'dw:w`wv' S cognition date naming-day of week"
label values s`wv'dw daywnaming

****cognition orient***
**wave 2 respondent cognition orient
egen r`wv'orient = rowtotal(r`wv'mo r`wv'dy r`wv'yr r`wv'dw),m
replace r`wv'orient= .m if (r`wv'mo== .m | r`wv'dy== .m | r`wv'yr== .m | r`wv'dw== .m) & mi(r`wv'orient)
replace r`wv'orient= .p if (r`wv'mo== .p | r`wv'dy== .p | r`wv'yr== .p | r`wv'dw== .p) & mi(r`wv'orient)
label variable r`wv'orient "r`wv'orient:w`wv' R cognition orient (summary date naming)"


**wave 2 spouse cognition orient
gen  s`wv'orient =.
spouse r`wv'orient, result(s`wv'orient) wave(`wv')
label variable  s`wv'orient "s`wv'orient:w`wv' S cognition orient (summary date naming)"


***recall summary  score***
*wave 2 respondent recall summary  score
gen r`wv'tr20 = .
missing_H r`wv'imrc r`wv'dlrc, result(r`wv'tr20)
replace r`wv'tr20 = .p if r`wv'imrc== .p & r`wv'dlrc== .p
replace r`wv'tr20 = r`wv'imrc + r`wv'dlrc if !mi(r`wv'imrc) & !mi(r`wv'dlrc)
label variable r`wv'tr20 "r`wv'tr20:w`wv' R recall summary  score"


*wave 2 spouse recall summary  score
gen s`wv'tr20 =.
spouse r`wv'tr20, result(s`wv'tr20) wave(`wv')
label variable s`wv'tr20 "s`wv'tr20:w`wv' S recall summary  score"

***serial 7s***
*wave 2 respondent serial 7s
gen r`wv'ser7=.
replace r`wv'ser7= .m if (dc019 ==. | dc020==. | dc021==. | dc022==.  | dc023==.) & inw`wv'==1
replace r`wv'ser7= .p if (dc019 ==. | dc020==. | dc021==. | dc022==.  | dc023==.) & db032==4
replace r`wv'ser7= 0 if inrange(dc019,0,200)
replace r`wv'ser7= r`wv'ser7+1 if dc019==93 & !mi(r`wv'ser7)
replace r`wv'ser7= r`wv'ser7+1 if dc020==86 & !mi(r`wv'ser7)
replace r`wv'ser7= r`wv'ser7+1 if dc021==79 & !mi(r`wv'ser7)
replace r`wv'ser7= r`wv'ser7+1 if dc022==72 & !mi(r`wv'ser7)
replace r`wv'ser7= r`wv'ser7+1 if dc023==65 & !mi(r`wv'ser7)
label variable r`wv'ser7  "r`wv'ser7:w`wv' R serial 7s"

*wave 2 spouse sserial 7s
gen s`wv'ser7 =.
spouse r`wv'ser7, result(s`wv'ser7) wave(`wv')
label variable s`wv'ser7 "s`wv'ser7:w`wv' S serial 7s"

***Drawing picture***
*wave 2 respondent able to draw a picture
gen r`wv'draw= .
replace r`wv'draw = .m if dc025==. & inw`wv'==1
replace r`wv'draw = .p if dc025==. & db032==4
replace r`wv'draw = 0 if dc025==2
replace r`wv'draw = 1 if dc025==1 
label variable r`wv'draw "r`wv'draw:w`wv' R cognition able to draw assign picture"
label values r`wv'draw daywnaming


*wave 2 spouse day of week naming
gen s`wv'draw =.
spouse r`wv'draw, result(s`wv'draw) wave(`wv')
label variable s`wv'draw "s`wv'draw:w`wv' S cognition able to draw assign picture"
label values s`wv'draw daywnaming



****drop CHARLS cog raw variables***
drop `cog_w`wv'_health'





*set wave number
local wv=2
local pre_wv=`wv'-1



***merge with demog file***
local asset_w2_demog be001 xrtype 
merge 1:1 ID using "`wave_2_demog'", keepusing(`asset_w2_demog')
drop if _merge==2
drop _merge

***merge with individual income file***
local asset_w2_indinc hc001 hc003_1 hc003_2 hc005 hc007 hc008 ///
                      hc010 hc013 hc015 hc018 hc021 ///
                      hc022 hc023 hc024 hc027 hc028 /// 
                      hc030 hc031 hc033 hc034 ///
                      hd001 hd002_w2_1 hd003 hd012 ///
                      hc002_bracket_min hc002_bracket_max hc006_bracket_min hc006_bracket_max ///
                      hc009_bracket_min hc009_bracket_max hc014_bracket_min hc014_bracket_max ///
                      hc019_bracket_min hc019_bracket_max hc025_bracket_min hc029_bracket_max ///
                      hc029_bracket_min hc032_bracket_max hc035_bracket_max hc035_bracket_min ///
                      hd002_bracket_min hd002_bracket_max hd002_w2_bracket_min hd002_w2_bracket_max ///
                      hd004_bracket_min hd004_bracket_max
merge 1:1 ID using "`wave_2_indinc'", keepusing(`asset_w2_indinc') 
drop if _merge==2
drop _merge

***merge with household income file***
local asset_w2_hhinc gb001 gb007 gb008 ///
                     gb008_bracket_min gb008_bracket_max ha001_w2 ///
                     ha007 ha009_?_ ha009_1?_ ///
                     ha011_1 ha011_2 ha013 ha014 ///
                     ha027 ha028 ha029_w2_1 ha029_w2 ///
                     ha031_?_s? ha031_?_s1? ///
                     ha034_1_1_ ha034_1_2_ ha034_1_3_ ha034_1_4_ ha034_2_1_ ha034_2_2_ ha034_2_3_ ha034_2_4_ ///
                     ha036_1_ ha036_2_ ha036_3_ ha036_4_ ///
                     ha037_1_ ha037_2_ ///
                     ha038_1_ ha038_2_ ///
                     ha051_1_ ha051_2_ ha051_3_ ha051_4_ ///
                     ha054s? ///
                     ha055_1_ ha055_2_ ha055_3_ ha055_4_ ///
                     ha057_1_ ha057_2_ ha057_3_ ha057_4_ ///
                     ha065_1_?_ ha065_1_1?_ ha065_w2_1 ha065_w2_16 ha065_w2_17 ha065s? ha065s1? ha066s? ///
                     ha066_1_1_ ha066_1_2_ ha066_1_3_ ha066_1_4_ ha066_1_5_ ///
                     ha067 ha068 ha068_1 ha069 ha073_bracket_max ha073_bracket_min ///
                     ha070 ha072 ha074_?_ ha074_1?_ ha075_?_ ha075_1?_ 
merge m:1 householdID using "`wave_2_hhinc'", keepusing(`asset_w2_hhinc') 
drop if _merge==2
drop _merge
foreach var of varlist `asset_w2_hhinc' {
    replace `var' = . if inw`wv' == 0 // *correct overassignmnet of household values to non-reponding hh members who respondend previously 
}

***merge with household characteristics file***
local asset_w2_house i001 i002
merge m:1 householdID using "`wave_2_house'", keepusing(`asset_w2_house') 
drop if _merge==2
drop _merge
foreach var of varlist `asset_w2_house' {
    replace `var' = . if inw`wv' == 0 // *correct overassignmnet of household values to non-reponding hh members who respondend previously 
}

****merge with psu data file*****
local asset_w2_psu urban_nbs
merge m:1 communityID using "`wave_2_psu'", keepusing (`asset_w1_psu') 
drop if _merge==2
drop _merge
foreach var of varlist `asset_w1_psu' {
    replace `var' = . if inw`wv' == 0 // *correct overassignmnet of community values to non-reponding hh members who respondend previously 
}

***merge with family information file***
local asset_w2_faminfo a002_?_ a002_1?_ /// 
						a006_?_ a006_1?_ ///
                        za002_?_ za002_1?_ /// 
                        za006_?_ za006_1?_
merge m:1 householdID using "`wave_2_faminfo'", keepusing(`asset_w2_faminfo') 
drop if _merge==2
drop _merge
foreach var of varlist `asset_w2_faminfo' {
    replace `var' = . if inw`wv' == 0 // *correct overassignmnet of household values to non-reponding hh members who respondend previously 
}

*****************************************
*************E:  ASSETS******************
*****************************************
***Create inflation multiplier variables

gen c2013cpindex = 114.7 // 2013
gen c2014cpindex = 117.6 // 2014
label variable c2013cpindex "2013 consumer price index, 2010=100"
label variable c2014cpindex "2014 consumer price index, 2010=100"

** ===================================================
* ***                                               **
* ***      Individual Assets (R & S)                **
* ***                                               **
** =================================================**


********************************************************************
**********1. Value of cash and other deposit financial institution**
********************************************************************

*****1.1 Cash at home****
*respondent
gen r`wv'acash=.
replace r`wv'acash = .m if inw`wv' == 1
replace r`wv'acash = hc001 if inrange(hc001,0,999999999) & !inlist(be001,1,2) 
replace r`wv'acash = 0 if hc001==0 & inlist(be001,1,2)
replace r`wv'acash = hc001*.5 if inrange(hc001,.01,50000000) & inlist(be001,1,2)
replace r`wv'acash = hc003_1 if inrange(hc003_1,0,99999999) & inlist(be001,1,2)
replace r`wv'acash = hc001*(hc003_2/100) if inrange(hc001,.01,50000000) & inrange(hc003_2,0,100) & inlist(be001,1,2)
label variable r`wv'acash "r`wv'acash:w`wv' Asset: cash"

*spouse
gen s`wv'acash=.
spouse r`wv'acash,result(s`wv'acash) wave(`wv')
label variable s`wv'acash "s`wv'acash:w`wv' Asset: cash"

***1.2 deposits **
***no ownership question hc004*****
****Amount of respondent
*respondent
gen r`wv'adepo=.
replace r`wv'adepo = .m if inw`wv' == 1
replace r`wv'adepo = hc005 if inrange(hc005,0,999999999)
label variable r`wv'adepo "r`wv'adepo:w`wv' Asset: total amount of deposit"

***Spouse
gen s`wv'adepo=.
spouse r`wv'adepo,result(s`wv'adepo) wave(`wv')
label variable s`wv'adepo "s`wv'adepo:w`wv' Asset total amount of deposit"

********************************************
*****Value of cash and financial deposit****
gen r`wv'achck = .
missing_H  r`wv'acash r`wv'adepo, result(r`wv'achck)
replace r`wv'achck=r`wv'acash + r`wv'adepo if !mi(r`wv'acash) & !mi(r`wv'adepo)
label variable r`wv'achck "r`wv'achck:w`wv' Asset: R cash, checking and saving acct"

gen s`wv'achck=.
spouse r`wv'achck,result(s`wv'achck) wave(`wv')
label variable s`wv'achck "s`wv'achck:w`wv' Asset: S cash, checking and saving acct"

gen h`wv'achck= .
household r`wv'achck s`wv'achck, result(h`wv'achck)
label variable h`wv'achck "h`wv'achck:w`wv' Asset: r+s cash, checking and saving acct"

drop r`wv'acash r`wv'adepo
drop s`wv'acash s`wv'adepo

***********************************************************
*****2.Total value of stocks, mutual funds*****************
**********************************************************
***Having stock****
gen r`wv'aostoc=.
replace r`wv'aostoc=.m if hc010==. & inw`wv' == 1
replace r`wv'aostoc= 0 if hc010==2
replace r`wv'aostoc= 1 if hc010==1
label variable r`wv'aostoc "r`wv'aostoc:w`wv' Asset: r having stock"
label value r`wv'aostoc own

*Spouse 
gen s`wv'aostoc=.
spouse r`wv'aostoc,result(s`wv'aostoc) wave(`wv')
label variable s`wv'aostoc "s`wv'aostoc:w`wv' Asset: s having stock"
label value s`wv'aostoc own

****Value of stock
gen r`wv'astoc=.
replace r`wv'astoc= .m if hc013==. & inw`wv' == 1
replace r`wv'astoc=  0 if r`wv'aostoc== 0 
replace r`wv'astoc=hc013 if inrange(hc013,0,50000000)
label variable r`wv'astoc "r`wv'astoc:w`wv' Asset: r stocks"

*Spouse 
gen s`wv'astoc=.
spouse r`wv'astoc,result(s`wv'astoc) wave(`wv')
label variable s`wv'astoc "s`wv'astoc:w`wv' Asset: s stocks"

drop r`wv'aostoc s`wv'aostoc

***Having mutual fund****
gen r`wv'aofund=.
replace r`wv'aofund=.m if hc015==. & inw`wv' == 1
replace r`wv'aofund= 0 if hc015==2
replace r`wv'aofund= 1 if hc015==1
label variable r`wv'aofund "r`wv'aofund:w`wv' Asset: having mutual fund"
label value r`wv'aofund own

*Spouse 
gen s`wv'aofund=.
spouse r`wv'aofund,result(s`wv'aofund) wave(`wv')
label variable s`wv'aofund "s`wv'aofund:w`wv' Asset: having mutual fund"
label value s`wv'aofund own

****Value of mutual fund
gen r`wv'afund=.
replace r`wv'afund= .m if hc018 == . & inw`wv' == 1
replace r`wv'afund=  0 if r`wv'aofund == 0
replace r`wv'afund=hc018 if inrange(hc018,0,9999999)
label variable r`wv'afund "r`wv'afund:w`wv' Asset: R mutual funds"

*Spouse 
gen s`wv'afund=.
spouse r`wv'afund,result(s`wv'afund) wave(`wv')
label variable s`wv'afund "s`wv'afund:w`wv' Asset: S mutual funds"

drop r`wv'aofund s`wv'aofund

*****Value of  stock and mutual fund****
*respondent
gen r`wv'astck=.
missing_H r`wv'afund r`wv'astoc, result(r`wv'astck)
replace r`wv'astck = r`wv'afund + r`wv'astoc if !mi(r`wv'afund) & !mi(r`wv'astoc)
label variable r`wv'astck "r`wv'astck:w`wv' Asset: R stocks and mutual funds"

*spouse
gen s`wv'astck=.
spouse r`wv'astck,result(s`wv'astck) wave(`wv')
label variable s`wv'astck "s`wv'astck:w`wv' Asset: S stocks and mutual funds"

*household
gen h`wv'astck=.
household r`wv'astck s`wv'astck, result(h`wv'astck)
label variable h`wv'astck "h`wv'astck:w`wv' Asset: r+s stocks and mutual funds"

drop r`wv'afund r`wv'astoc
drop s`wv'afund s`wv'astoc


**********************************************************
*****3.Value of government bonds*************************
*********************************************************
***Having government bonds****
gen r`wv'aobond=.
replace r`wv'aobond=.m if hc007==. & inw`wv' == 1
replace r`wv'aobond= 0 if hc007==2
replace r`wv'aobond= 1 if hc007==1
label variable r`wv'aobond "r`wv'aobond:w`wv' Asset: having government bond"
label value r`wv'aobond own

*Spouse 
gen s`wv'aobond=.
spouse r`wv'aobond,result(s`wv'aobond) wave(`wv')
label variable s`wv'aobond "s`wv'aobond:w`wv' Asset: having government bond"
label value s`wv'aobond own

****Value of government bond
gen r`wv'abond=.
replace r`wv'abond= .m if hc008==.  & inw`wv' == 1
replace r`wv'abond= 0  if r`wv'aobond== 0
replace r`wv'abond=hc008 if inrange(hc008,0,200000)
label variable r`wv'abond "r`wv'abond:w`wv' Asset: R government bonds"

*Spouse 
gen s`wv'abond=.
spouse r`wv'abond,result(s`wv'abond) wave(`wv')
label variable s`wv'abond "s`wv'abond:w`wv' Asset: S government bonds"

***Household level 
gen h`wv'abond = .
household r`wv'abond s`wv'abond, result(h`wv'abond)
label variable h`wv'abond "h`wv'abond:w`wv' Asset: r+s government bonds"

drop r`wv'aobond s`wv'aobond

****************************************************************************
**********5. R+S Other saving        ***************************************
****************************************************************************
** Other financial asset
** hc022: what is the total value of other assets?
***Having other financial asset****
*respondent
gen r`wv'aofino=.
replace r`wv'aofino=.m if hc021==. & inw`wv' == 1
replace r`wv'aofino=0 if (( hc007 != 2 | hc010 != 2 | hc015 != 2) & inw`wv' == 1) | hc021==2
replace r`wv'aofino=1 if hc021==1
label variable r`wv'aofino "r`wv'aofino:w`wv' Asset: having other financial asset"
label value r`wv'aofino own

*Spouse 
gen s`wv'aofino=.
spouse r`wv'aofino,result(s`wv'aofino) wave(`wv')
label variable s`wv'aofino "s`wv'aofino:w`wv' Asset: having other financial asset"
label value s`wv'aofino own

***Value of other financial assets****
*respondent
gen r`wv'afino=.
replace r`wv'afino=.m if hc022==. & inw`wv' == 1
replace r`wv'afino=0  if r`wv'aofino==0
replace r`wv'afino=hc022 if inrange(hc022,0,400000)
label variable r`wv'afino "r`wv'afino:w`wv' Asset: S other financial asset"

*Spouse 
gen s`wv'afino=.
spouse r`wv'afino,result(s`wv'afino) wave(`wv')
label variable s`wv'afino "s`wv'afino:w`wv' Asset: R other financial asset"

drop r`wv'aofino s`wv'aofino

***Having public housing fund****
*respondent
gen r`wv'aohpub=.
replace r`wv'aohpub=.m if hc027==. & inw`wv' == 1
replace r`wv'aohpub= 0 if hc027==2
replace r`wv'aohpub= 1 if hc027==1
label variable r`wv'aohpub "r`wv'aohpub:w`wv' Asset: having public housing fund"
label value r`wv'aohpub own

*Spouse 
gen s`wv'aohpub=.
spouse r`wv'aohpub,result(s`wv'aohpub) wave(`wv')
label variable s`wv'aohpub "s`wv'aohpub:w`wv' Asset: having public housing fund"
label value s`wv'aohpub own

****Value of public housing fund
*respondent
gen r`wv'ahpub=.
replace r`wv'ahpub=.m  if hc028 == . & inw`wv' == 1
replace r`wv'ahpub= 0  if r`wv'aohpub == 0
replace r`wv'ahpub=hc028 if inrange(hc028,0,4000000)
label variable r`wv'ahpub "r`wv'ahpub:w`wv' Asset: public housing fund"

*Spouse 
gen s`wv'ahpub=.
spouse r`wv'ahpub,result(s`wv'ahpub) wave(`wv')
label variable s`wv'ahpub "s`wv'ahpub:w`wv' Asset: public housing fund"

drop r`wv'aohpub s`wv'aohpub

***Having jizikuan***
*respondent
gen r`wv'aojizi=.
replace r`wv'aojizi=.m if hc030==. & inw`wv' == 1
replace r`wv'aojizi= 0 if hc030==2
replace r`wv'aojizi= 1 if hc030==1
label variable r`wv'aojizi "r`wv'aojizi:w`wv' Asset: having jizikuan"
label value r`wv'aojizi own

*Spouse 
gen s`wv'aojizi=.
spouse r`wv'aojizi,result(s`wv'aojizi) wave(`wv')
label variable s`wv'aojizi "s`wv'aojizi:w`wv' Asset: having jizikuan"
label value s`wv'aojizi own

****Value of jizikuan
*respondent
gen r`wv'ajizi=.
replace r`wv'ajizi=.m  if hc031==.  & inw`wv' == 1
replace r`wv'ajizi= 0  if r`wv'aojizi == 0 
replace r`wv'ajizi=hc031 if inrange(hc031,0,9999999999)
label variable r`wv'ajizi "r`wv'ajizi:w`wv' Asset: jizikuan"

*Spouse 
gen s`wv'ajizi=.
spouse r`wv'ajizi,result(s`wv'ajizi) wave(`wv')
label variable s`wv'ajizi "s`wv'ajizi:w`wv' Asset: jizikuan"

drop r`wv'aojizi s`wv'aojizi

***Having unpaid salary***
*respondent
gen r`wv'aounpay=.
replace r`wv'aounpay=.m if hc033==. & inw`wv' == 1
replace r`wv'aounpay= 0 if hc033==2
replace r`wv'aounpay= 1 if hc033==1
label variable r`wv'aounpay "r`wv'aounpay:w`wv' Asset: having unpaid salary"
label value r`wv'aounpay own

*Spouse 
gen s`wv'aounpay=.
spouse r`wv'aounpay,result(s`wv'aounpay) wave(`wv')
label variable s`wv'aounpay "s`wv'aounpay:w`wv' Asset: having unpaid salary"
label value s`wv'aounpay own

****Value of unpaid salary
gen r`wv'aunpay=.
replace r`wv'aunpay=.m  if hc034==. & inw`wv' == 1
replace r`wv'aunpay= 0 if r`wv'aounpay == 0
replace r`wv'aunpay=hc034 if inrange(hc034,0,8000000)
label variable r`wv'aunpay "r`wv'aunpay:w`wv' Asset: unpaid salary"

*Spouse 
gen s`wv'aunpay=.
spouse r`wv'aunpay,result(s`wv'aunpay) wave(`wv')
label variable s`wv'aunpay "s`wv'aunpay:w`wv' Asset: unpaid salary"

drop r`wv'aounpay s`wv'aounpay

*************************************
****Net value of all other saving***
*respondent
gen r`wv'aothr = .
missing_H r`wv'ahpub r`wv'ajizi r`wv'aunpay r`wv'afino, result(r`wv'aothr)
replace r`wv'aothr = r`wv'ahpub + r`wv'ajizi + r`wv'aunpay + r`wv'afino if !mi(r`wv'ahpub) & !mi(r`wv'ajizi) & !mi(r`wv'aunpay) & !mi(r`wv'afino)
label variable r`wv'aothr "r`wv'aothr:w`wv' Asset: R all other savings"

*spouse
gen s`wv'aothr=.
spouse r`wv'aothr,result(s`wv'aothr) wave(`wv')
label variable s`wv'aothr "s`wv'aothr:w`wv' Asset: S all other savings"

*household
gen h`wv'aothr=.
household r`wv'aothr s`wv'aothr, result(h`wv'aothr)
label variable h`wv'aothr "h`wv'aothr:w`wv' Asset: R+S all other savings"

drop r`wv'ahpub r`wv'ajizi r`wv'aunpay r`wv'afino
drop s`wv'ahpub s`wv'ajizi s`wv'aunpay s`wv'afino

**************************************************************
***********6. VAlue of other debt
**************************************************************
*****unpaid loan: Other than housing loan****
****amount of loan***
*respondent
gen r`wv'aloan=.
replace r`wv'aloan =.m if  inw`wv' == 1
replace r`wv'aloan = hd001 if inrange(hd001,0,9999999)
label variable r`wv'aloan "r`wv'aloan:w`wv' Asset: loan other than mortgage"

*Spouse 
gen s`wv'aloan=.
spouse r`wv'aloan,result(s`wv'aloan) wave(`wv')
label variable s`wv'aloan "s`wv'aloan:w`wv' Asset: loan other than mortgage"
label value s`wv'aloan own

****Credit Card debt****
*respondent
gen r`wv'accard=.
replace r`wv'accard= .m if hd003==. & inw`wv' == 1 
replace r`wv'accard=hd003 if inrange(hd003,0,2000000)
label variable r`wv'accard "r`wv'accard:w`wv' Asset: credit card debt"

*Spouse 
gen s`wv'accard=.
spouse r`wv'accard,result(s`wv'accard) wave(`wv')
label variable s`wv'accard "s`wv'accard:w`wv' Asset: credit card debt"

******************************
****Total value of debt
*respondent
gen r`wv'adebt = .
missing_H r`wv'accard r`wv'aloan, result(r`wv'adebt)
replace r`wv'adebt = r`wv'accard + r`wv'aloan if !mi(r`wv'accard) & !mi(r`wv'aloan)
label variable r`wv'adebt "r`wv'adebt:w`wv' Asset: R debt" 

*spouse
gen s`wv'adebt=.
spouse r`wv'adebt,result(s`wv'adebt) wave(`wv')
label variable s`wv'adebt "s`wv'adebt:w`wv' Asset: S debt" 

*household
gen h`wv'adebt=.
household r`wv'adebt s`wv'adebt, result(h`wv'adebt)
label variable h`wv'adebt "h`wv'adebt:w`wv' Asset: R+S debt" 

drop r`wv'accard r`wv'aloan
drop s`wv'accard s`wv'aloan

**************************************************
***************************************************
****SUMMARY: total individual financial asset 
***************************************************
gen r`wv'atotf = .
missing_H r`wv'achck r`wv'astck r`wv'abond r`wv'aothr r`wv'adebt, result(r`wv'atotf)
replace r`wv'atotf = r`wv'achck + r`wv'astck + r`wv'abond + r`wv'aothr - r`wv'adebt if ///
                      !mi(r`wv'achck) & !mi(r`wv'astck) & !mi(r`wv'abond) & !mi(r`wv'aothr) & !mi(r`wv'adebt)
label variable r`wv'atotf "r`wv'atotf:w`wv' Asset:r total individual financial assets" 

gen s`wv'atotf=.
spouse r`wv'atotf,result(s`wv'atotf) wave(`wv')
label variable s`wv'atotf "s`wv'atotf:w`wv' Asset:s total individual financial assets" 

gen h`wv'atotf=.
household r`wv'atotf s`wv'atotf, result(h`wv'atotf)
label variable h`wv'atotf "h`wv'atotf:w`wv' Asset:r+s total individual financial assets" 

drop r`wv'atotf s`wv'atotf

 
** ================================================================
**                                                               **
**                 HOUSEHOLD ASSET                               **
**                                                               **
** ==============================================================**


**********************************************************************
** value of other house***********
**********************************************************************
replace ha034_1_1_=4 if ha034_1_1_==4000 // *correct incorrect value

forvalues i=1/4 {
    ** correct house price variables that appear to be using wrong unit
    replace ha034_2_`i'_=ha034_2_`i'_/1000  if ha034_2_`i'_>=1000  & !mi(ha034_2_`i'_)
    replace ha034_1_`i'_=ha034_1_`i'_/10000 if ha034_1_`i'_>=10000 & !mi(ha034_1_`i'_)
    
    gen hh`wv'ahoub`i'=.
    replace hh`wv'ahoub`i'=.m if inw`wv'==1
    replace hh`wv'ahoub`i' = 0 if (((ha031_`i'_s1 != pn | ha031_`i'_s1 != s`wv'pn) & !mi(ha031_`i'_s1)) | mi(ha031_`i'_s1)) & ///
                                  (((ha031_`i'_s2 != pn | ha031_`i'_s2 != s`wv'pn) & !mi(ha031_`i'_s2)) | mi(ha031_`i'_s2)) & ///
                                  (((ha031_`i'_s3 != pn | ha031_`i'_s3 != s`wv'pn) & !mi(ha031_`i'_s3)) | mi(ha031_`i'_s3)) & ///
                                  (((ha031_`i'_s4 != pn | ha031_`i'_s4 != s`wv'pn) & !mi(ha031_`i'_s4)) | mi(ha031_`i'_s4)) & ///
                                  !(mi(ha031_`i'_s1) & mi(ha031_`i'_s2) & mi(ha031_`i'_s3) & mi(ha031_`i'_s4) & mi(ha031_`i'_s5) & mi(ha031_`i'_s6) & mi(ha031_`i'_s7) & mi(ha031_`i'_s8) & mi(ha031_`i'_s9))
    replace hh`wv'ahoub`i'= ha034_2_`i'_*ha051_`i'_*1000 if inrange(ha034_2_`i'_,0,99999) & inrange(ha051_`i'_,0,99999)
    replace hh`wv'ahoub`i'= ha034_1_`i'_*10000  if inrange(ha034_1_`i'_,0,999999)
}

***Total value of other houses***
gen hh`wv'ahoub = .
replace hh`wv'ahoub = .m if inw`wv' == 1
missing_H hh`wv'ahoub1 hh`wv'ahoub2 hh`wv'ahoub3 hh`wv'ahoub4, result(hh`wv'ahoub)
replace hh`wv'ahoub = 0 if ha027 == 2 | ha028 == 0 
replace hh`wv'ahoub = hh`pre_wv'ahoub if (ha029_w2_1==0 | ha029_w2==2) & inrange(hh`pre_wv'ahoub,0,99999999)
replace hh`wv'ahoub = hh`wv'ahoub1 if !mi(hh`wv'ahoub1) & (ha028 == 1 |  ha029_w2_1 == 1)
replace hh`wv'ahoub = hh`wv'ahoub1 + hh`wv'ahoub2 if !mi(hh`wv'ahoub1) & !mi(hh`wv'ahoub2) & (ha028 == 2 |  ha029_w2_1 == 2)
replace hh`wv'ahoub = hh`wv'ahoub1 + hh`wv'ahoub2 + hh`wv'ahoub3 if !mi(hh`wv'ahoub1) & !mi(hh`wv'ahoub2) & !mi(hh`wv'ahoub3) & (ha028 == 3 |  ha029_w2_1 == 3)
replace hh`wv'ahoub = hh`wv'ahoub1 + hh`wv'ahoub2 + hh`wv'ahoub3 + hh`wv'ahoub4 if !mi(hh`wv'ahoub1) & !mi(hh`wv'ahoub2) & !mi(hh`wv'ahoub3) & !mi(hh`wv'ahoub4) & (ha028 == 4 |  ha029_w2_1 == 4)
label variable hh`wv'ahoub "hh`wv'ahoub:w`wv' Asset: other real estate"

drop hh`wv'ahoub1 hh`wv'ahoub2 hh`wv'ahoub3 hh`wv'ahoub4


***whether have loan for other house
gen hh`wv'aoloanb1=.
replace hh`wv'aoloanb1=.m if ha036_1_==. & inw`wv' == 1
replace hh`wv'aoloanb1= 0 if ha036_1_==2 | ((((ha031_1_s1 != pn | ha031_1_s1 != s`wv'pn) & !mi(ha031_1_s1)) | mi(ha031_1_s1)) & ///
                                            (((ha031_1_s2 != pn | ha031_1_s2 != s`wv'pn) & !mi(ha031_1_s2)) | mi(ha031_1_s2)) & ///
                                            (((ha031_1_s3 != pn | ha031_1_s3 != s`wv'pn) & !mi(ha031_1_s3)) | mi(ha031_1_s3)) & ///
                                            (((ha031_1_s4 != pn | ha031_1_s4 != s`wv'pn) & !mi(ha031_1_s4)) | mi(ha031_1_s4)) & ///
                                            !(mi(ha031_1_s1) & mi(ha031_1_s2) & mi(ha031_1_s3) & mi(ha031_1_s4) & mi(ha031_1_s5) & mi(ha031_1_s6) & mi(ha031_1_s7) & mi(ha031_1_s8) & mi(ha031_1_s9)))
replace hh`wv'aoloanb1= 1 if ha036_1_==1
label var hh`wv'aoloanb1 "hh`wv'aoloanb1:w`wv' Asset: mortgage for secondary residence 1"
label value hh`wv'aoloanb1 own 

gen hh`wv'aoloanb2=.  
replace hh`wv'aoloanb2=.m if ha036_2_==. & inw`wv' == 1
replace hh`wv'aoloanb2= 0 if ha036_2_==2 | ((((ha031_2_s1 != pn | ha031_2_s1 != s`wv'pn) & !mi(ha031_2_s1)) | mi(ha031_2_s1)) & ///
                                            (((ha031_2_s2 != pn | ha031_2_s2 != s`wv'pn) & !mi(ha031_2_s2)) | mi(ha031_2_s2)) & ///
                                            (((ha031_2_s3 != pn | ha031_2_s3 != s`wv'pn) & !mi(ha031_2_s3)) | mi(ha031_2_s3)) & ///
                                            (((ha031_2_s4 != pn | ha031_2_s4 != s`wv'pn) & !mi(ha031_2_s4)) | mi(ha031_2_s4)) & ///
                                            !(mi(ha031_2_s1) & mi(ha031_2_s2) & mi(ha031_2_s3) & mi(ha031_2_s4) & mi(ha031_2_s5) & mi(ha031_2_s6) & mi(ha031_2_s7) & mi(ha031_2_s8) & mi(ha031_2_s9)))
replace hh`wv'aoloanb2= 1 if ha036_2_==1
label var hh`wv'aoloanb2 "hh`wv'aoloanb2:w`wv' Asset: mortgage for secondary residence 2"
label value hh`wv'aoloanb2 own

gen hh`wv'aoloanb3=.
replace hh`wv'aoloanb3=.m if ha036_3_==. & inw`wv' == 1
replace hh`wv'aoloanb3= 0 if ha036_3_==2 | ((((ha031_3_s1 != pn | ha031_3_s1 != s`wv'pn) & !mi(ha031_3_s1)) | mi(ha031_3_s1)) & ///
                                            (((ha031_3_s2 != pn | ha031_3_s2 != s`wv'pn) & !mi(ha031_3_s2)) | mi(ha031_3_s2)) & ///
                                            (((ha031_3_s3 != pn | ha031_3_s3 != s`wv'pn) & !mi(ha031_3_s3)) | mi(ha031_3_s3)) & ///
                                            (((ha031_3_s4 != pn | ha031_3_s4 != s`wv'pn) & !mi(ha031_3_s4)) | mi(ha031_3_s4)) & ///
                                            !(mi(ha031_3_s1) & mi(ha031_3_s2) & mi(ha031_3_s3) & mi(ha031_3_s4) & mi(ha031_3_s5) & mi(ha031_3_s6) & mi(ha031_3_s7) & mi(ha031_3_s8) & mi(ha031_3_s9)))
replace hh`wv'aoloanb3= 1 if ha036_3_==1
label var hh`wv'aoloanb3 "hh`wv'aoloanb3:w`wv' Asset: mortgage for secondary residence 3"
label value hh`wv'aoloanb3 own

gen hh`wv'aoloanb4=.
replace hh`wv'aoloanb4=.m if ha036_4_==. & inw`wv' == 1
replace hh`wv'aoloanb4= 0 if ha036_4_==2 | (((ha031_4_s1 != pn | ha031_4_s1 != s`wv'pn) & !mi(ha031_4_s1)) | mi(ha031_4_s1)) & ///
                                            (((ha031_4_s2 != pn | ha031_4_s2 != s`wv'pn) & !mi(ha031_4_s2)) | mi(ha031_4_s2)) & ///
                                            (((ha031_4_s3 != pn | ha031_4_s3 != s`wv'pn) & !mi(ha031_4_s3)) | mi(ha031_4_s3)) & ///
                                            (((ha031_4_s4 != pn | ha031_4_s4 != s`wv'pn) & !mi(ha031_4_s4)) | mi(ha031_4_s4)) & ///
                                            !(mi(ha031_4_s1) & mi(ha031_4_s2) & mi(ha031_4_s3) & mi(ha031_4_s4) & mi(ha031_4_s5) & mi(ha031_4_s6) & mi(ha031_4_s7) & mi(ha031_4_s8) & mi(ha031_4_s9))
replace hh`wv'aoloanb4= 1 if ha036_4_==1
label var hh`wv'aoloanb4 "hh`wv'aoloanb4:w`wv' Asset: mortgage for secondary residence 4"
label value hh`wv'aoloanb4 own

**********************************************
***total mortgages for other house****
forvalues i=1/2 {
    gen hh`wv'amrtb`i'=.
    replace hh`wv'amrtb`i'= .m if inw`wv' == 1
    replace hh`wv'amrtb`i'= 0 if hh`wv'aoloanb`i' == 0
    replace hh`wv'amrtb`i'= ha038_`i'_*12 if inrange(ha038_`i'_,0,999999)
    replace hh`wv'amrtb`i'= ha037_`i'_*10000 if inrange(ha037_`i'_,0,10000)
}
gen hh`wv'amrtb3=.
replace hh`wv'amrtb3= .m if inw`wv'==1
replace hh`wv'amrtb3= 0 if hh`wv'aoloanb3 == 0

gen hh`wv'amrtb4=.
replace hh`wv'amrtb4= .m if inw`wv'==1
replace hh`wv'amrtb4= 0 if hh`wv'aoloanb4 == 0

gen hh`wv'amrtb = .
replace hh`wv'amrtb = .m if inw`wv' == 1
replace hh`wv'amrtb = 0 if ha027 == 2 | ha028 == 0
replace hh`wv'amrtb = hh`pre_wv'amrtb if (ha029_w2==2 | ha029_w2_1==0 ) & inrange(hh`pre_wv'amrtb,0,999999)
replace hh`wv'amrtb = hh`wv'amrtb1 if !mi(hh`wv'amrtb1) & (ha028 == 1 |  ha029_w2_1 == 1)
replace hh`wv'amrtb = hh`wv'amrtb1 + hh`wv'amrtb2 if !mi(hh`wv'amrtb1) & !mi(hh`wv'amrtb2) & (ha028 == 2 |  ha029_w2_1 == 2)
replace hh`wv'amrtb = hh`wv'amrtb1 + hh`wv'amrtb2 + hh`wv'amrtb3 if !mi(hh`wv'amrtb1) & !mi(hh`wv'amrtb2) & !mi(hh`wv'amrtb3) & (ha028 == 3 |  ha029_w2_1 == 3)
replace hh`wv'amrtb = hh`wv'amrtb1 + hh`wv'amrtb2 + hh`wv'amrtb3 + hh`wv'amrtb4 if !mi(hh`wv'amrtb1) & !mi(hh`wv'amrtb2) & !mi(hh`wv'amrtb3) & !mi(hh`wv'amrtb4) & (ha028 == 4 |  ha029_w2_1 == 4)
label variable hh`wv'amrtb "hh`wv'amrtb:w`wv' Asset: mortgage other real estate"

drop hh`wv'aoloanb1 hh`wv'aoloanb2 hh`wv'aoloanb3 hh`wv'aoloanb4
drop hh`wv'amrtb1 hh`wv'amrtb2 hh`wv'amrtb3 hh`wv'amrtb4

***********************************************************
*************Net value of other residential property(not primary)
gen hh`wv'arles = .
missing_H hh`wv'ahoub hh`wv'amrtb, result(hh`wv'arles)
replace hh`wv'arles = hh`wv'ahoub - hh`wv'amrtb if !mi(hh`wv'ahoub) & !mi(hh`wv'amrtb)
label variable hh`wv'arles "hh`wv'arles:w`wv' Asset: hh Net value of other real estate (not primary)"

***********************************************************
****Create a Flag of where the value comes from************
gen hh`wv'arlfg=.
replace hh`wv'arlfg = 1 if (ha029_w2==2 | ha029_w2_1==0) & !mi(hh`wv'arles)
replace hh`wv'arlfg = 2 if (ha027 == 2 |inrange(ha028,1,4)) & !mi(hh`wv'arles)
replace hh`wv'arlfg = 3 if inrange(ha029_w2_1,1,4) & !mi(hh`wv'arles)
label value hh`wv'arlfg arlfg
label variable hh`wv'arlfg "hh`wv'arlfg:w`wv' Asset: hh other real estate flag"

** =================================================================
** Housing Ownership of Current Residence           *
** =================================================================

** ha007: whether the current residence is owned by household member

gen hh`wv'own_curr=.
replace hh`wv'own_curr=.m if ha007==. & inw`wv'==1
replace hh`wv'own_curr=0 if ha007==3
replace hh`wv'own_curr=ha007 if inlist(ha007,1,2)

** ha009_*_: share of the house owned by each household member
egen ratio_total=rowtotal(ha009_*_),m

gen hh`wv'curr_ratio=.
replace hh`wv'curr_ratio = .m if inw`wv' == 1
missing_H hh`wv'own_curr, result(hh`wv'curr_ratio)
replace hh`wv'curr_ratio = 0 if hh`wv'own_curr==0
replace hh`wv'curr_ratio = ratio_total if inrange(ratio_total,0,100)
replace hh`wv'curr_ratio = 100 if ratio_total>100 &!mi(ratio_total)  

drop ratio_total

gen hh`wv'ahrto=.
missing_H hh`wv'curr_ratio, result(hh`wv'ahrto)
replace hh`wv'ahrto=hh`wv'curr_ratio/100 if inrange(hh`wv'curr_ratio,0,100)
label variable hh`wv'ahrto "hh`wv'ahrto:w`wv' Asset: hh percent of ownership for primary residence"

drop hh`wv'curr_ratio

***************************************************************************
******** Value of primary residence**********************
***********************************************************

** Calculate currently owned house and current residece
** (1)currently owned housing value in yuan
* check price values that appear to be using wrong units
** generate dummy variables to keep track of the corrected values
gen change=0
replace change=1 if ha011_2>=1000 & !mi(ha011_2)  
replace change=1 if ha011_1>=10000 & !mi(ha011_1) 

** remove total value values which seems invalid
replace ha011_1=. if inlist(ha011_1,0.002,0.005,0.006)

** correct total value and value per m2 that appear to be using wrong unit. reason for including cases which equals to 10000/1000 pls see mem housing 3
replace ha011_2=ha011_2/1000 if ha011_2>=1000 & !mi(ha011_2)
replace ha011_1=ha011_1/10000 if ha011_1>=10000 & !mi(ha011_1) 


** 6.1.3 current residence value
** generate sqr meter area of current residence
** area_residence: i001_what is the construction area of your residence
** area_resident: ha001_w2 What is the construction area of the house?
** area_zhaijidi:i002_what is the total housing land area? (including b

gen area_residence = max(i001,ha001_w2)
gen area_zhaijidi  = i002
sum area_residence area_zhaijidi if !mi(area_residence) & !mi(area_zhaijidi)
gen ratio_area=area_residence/area_zhaijidi
egen meanr_area=mean(ratio_area)
gen area=area_residence

** use mean ratio to impute missing construction area
replace area=area_zhaijidi*meanr_area if mi(area) & !mi(area_zhaijidi)& area_zhaijidi~=0 
replace area=area_zhaijidi*meanr_area if area==0 & !mi(area_zhaijidi) & area_zhaijidi~=0  

bysort communityID:egen area_vmed=median(area)
replace area=area_vmed if mi(area)

** (1)currently owned housing value in yuan
gen hh`wv'cvalue_1=.
replace hh`wv'cvalue_1 = .m if inw`wv' ==1
missing_H hh`wv'own_curr hh`wv'ahrto, result(hh`wv'cvalue_1)
replace hh`wv'cvalue_1 = ha011_1*10000 if !mi(ha011_1) & hh`wv'own_curr==1 
replace hh`wv'cvalue_1 = ha011_1*10000*hh`wv'ahrto if !mi(ha011_1) & !mi(hh`wv'ahrto) & hh`wv'own_curr==2 

** calculate housing value in yuan using reported value 1000yuan per m2 in full and partial ownership
gen hh`wv'cvalue_2=.
replace hh`wv'cvalue_2 = .m if inw`wv' == 1
missing_H hh`wv'own_curr hh`wv'ahrto, result(hh`wv'cvalue_2)
replace hh`wv'cvalue_2=ha011_2*1000*area if !mi(ha011_2) & !mi(area) & hh`wv'own_curr==1 
replace hh`wv'cvalue_2=ha011_2*1000*area*hh`wv'ahrto if !mi(ha011_2) & !mi(area) & !mi(hh`wv'ahrto) & hh`wv'own_curr==2

gen hh`wv'cvalue_own=.
missing_H hh`wv'own_curr hh`wv'cvalue_1 hh`wv'cvalue_2, result(hh`wv'cvalue_own)
replace hh`wv'cvalue_own=0 if hh`wv'own_curr==0
replace hh`wv'cvalue_own=hh`wv'cvalue_1 if inrange(hh`wv'cvalue_1,0,9999999999)
replace hh`wv'cvalue_own=hh`wv'cvalue_2 if mi(hh`wv'cvalue_own) & inrange(hh`wv'cvalue_2,0,9999999999)

** NOTES: Check consistency: 37 cases when both values are reported
** 36 of these are full owned by the household member and 1 is not owned by the household member 

** for urban house, its value is set to the larger one; 
replace hh`wv'cvalue_own=max(hh`wv'cvalue_1, hh`wv'cvalue_2) if urban_nbs==1 & change==0 &!mi(hh`wv'cvalue_1) &!mi(hh`wv'cvalue_2) 

** for rural houses, for original value<1000, set to the larger value of the two; for original value>10000, set to the smaller one
replace hh`wv'cvalue_own=max(hh`wv'cvalue_1, hh`wv'cvalue_2) if urban_nbs==0 & hh`wv'cvalue_own<=1000 & change==0 & !mi(hh`wv'cvalue_1) &!mi(hh`wv'cvalue_2)
replace hh`wv'cvalue_own=min(hh`wv'cvalue_1, hh`wv'cvalue_2) if urban_nbs==0 & hh`wv'cvalue_own>=10000 & change==0 & !mi(hh`wv'cvalue_1) &!mi(hh`wv'cvalue_2)

gen hh`wv'ahous=.
missing_H hh`wv'cvalue_own, result(hh`wv'ahous)
replace hh`wv'ahous=hh`wv'cvalue_own if inrange(hh`wv'cvalue_own,0,999999999)
label variable hh`wv'ahous "hh`wv'ahous:w`wv' Asset: hh primary residence with % of ownership"

***********************************************************
** (2)Current residence value regardless of the ownership
gen hh`wv'cv2_house=.
replace hh`wv'cv2_house = .m if inw`wv' == 1
replace hh`wv'cv2_house = ha011_1*10000 if !mi(ha011_1)

gen hh`wv'cv1_house=.
replace hh`wv'cv1_house = .m if inw`wv' == 1
replace hh`wv'cv1_house = ha011_2*1000*area if !mi(ha011_2) & !mi(area)

gen hh`wv'cvalue_house=.
missing_H hh`wv'own_curr hh`wv'cv1_house hh`wv'cv2_house, result(hh`wv'cvalue_house)
replace hh`wv'cvalue_house=0  if hh`wv'own_curr==0
replace hh`wv'cvalue_house=hh`wv'cv1_house if inrange(hh`wv'cv1_house,0,9999999999)
replace hh`wv'cvalue_house=hh`wv'cv2_house if mi(hh`wv'cv1_house) & inrange(hh`wv'cv2_house,0,9999999999)

** for urban house, its value is set to the larger one; 
replace hh`wv'cvalue_house=max(hh`wv'cv1_house, hh`wv'cv2_house) if urban_nbs==1 & change==0 & !mi(hh`wv'cv1_house) &!mi(hh`wv'cv2_house)

** for rural houses, for original value<1000, set to the larger value of the two; for original value>10000, set to the smaller one
replace hh`wv'cvalue_house=max(hh`wv'cv1_house, hh`wv'cv2_house) if urban_nbs==0 & hh`wv'cvalue_house<=1000 & change==0 & !mi(hh`wv'cv1_house) &!mi(hh`wv'cv2_house)  
replace hh`wv'cvalue_house=min(hh`wv'cv1_house, hh`wv'cv2_house) if urban_nbs==0 & hh`wv'cvalue_house>=10000 & change==0 & !mi(hh`wv'cv1_house) &!mi(hh`wv'cv2_house)  

gen hh`wv'ahousa=.
missing_H hh`wv'cvalue_house, result(hh`wv'ahousa)
replace hh`wv'ahousa=hh`wv'cvalue_house if inrange(hh`wv'cvalue_house,0,999999999)
label variable hh`wv'ahousa "hh`wv'ahousa:w`wv' Asset: hh primary residence regardless of ownership"

**flag for area imputation
gen hh`wv'afhousar = .
replace hh`wv'afhousar = 0 if (!mi(i001) | !mi(ha011_1)) & !mi(hh`wv'ahousa)
replace hh`wv'afhousar = 1 if mi(i001) & !mi(i002) & mi(ha011_1) & !mi(hh`wv'ahousa)
replace hh`wv'afhousar = 2 if mi(i001) & mi(i002) & mi(ha011_1)  & !mi(hh`wv'ahousa)
label variable hh`wv'afhousar "hh`wv'afhousar:w`wv' Asset: hh imput flag for housing area"
label values hh`wv'afhousar areaimput

drop ratio_* area_* meanr_* hh`wv'cv* hh`wv'own_curr change area 

******************************************************************
****11 Value of all mortgage*************************
***Value of mortgages***
***whether have loan for primary
gen hh`wv'aohloan=.
replace hh`wv'aohloan=.m if ha013==. & inw`wv' == 1
replace hh`wv'aohloan= 0 if ha013==. & inlist(ha007,2,3)
replace hh`wv'aohloan= 0 if ha013==2 | ha014==0
replace hh`wv'aohloan= 1 if ha013==1
label variable hh`wv'aohloan "hh`wv'aohloan:w`wv' Asset: having mortgage for primary residence "
label value hh`wv'aohloan own

***total mortgages for primary residence****
gen hh`wv'amort=.
replace hh`wv'amort = .m if ha014==. & inw`wv' == 1
missing_H hh`wv'aohloan, result(hh`wv'amort)
replace hh`wv'amort = 0  if hh`wv'aohloan== 0
replace hh`wv'amort = ha014 if inrange(ha014,0,9999999)
label variable hh`wv'amort "hh`wv'amort:w`wv' Asset: hh total mortgage for primary residence"

drop hh`wv'aohloan

**************************************************
**** Net Value of primary residence***********
****Primary residence***
gen hh`wv'atoth=.
missing_H hh`wv'ahous hh`wv'amort, result(hh`wv'atoth)
replace hh`wv'atoth= hh`wv'ahous - hh`wv'amort if !mi(hh`wv'ahous) & !mi(hh`wv'amort)
label variable hh`wv'atoth "hh`wv'atoth:w`wv' Asset: hh net value of primary residence"


******value of consumer durable assets******************************
********************************************************************
********Value of vehicle       ***********************************
********************************************************************
***net value of vehicles***
*wave 1 household net value of vehicles
*whether has any vehicles 
gen hh`wv'aotran=.
replace hh`wv'aotran = .m if inw`wv'==1
forvalues a = 1/17 {
    replace hh`wv'aotran= 0 if ha065s`a' == `a' |  ha065s18 == 18
}
replace hh`wv'aotran= 1 if ha065s1==1 | ha065s2==2 | ha065s3==3
label variable hh`wv'aotran "hh`wv'aotran:w`wv' Asset: own vehicle"
label value hh`wv'aotran own

****Value of vehicle****
gen hh`wv'atran=.
replace hh`wv'atran = .m if inw`wv' == 1
missing_H hh`wv'aotran, result(hh`wv'atran)
replace hh`wv'atran = 0 if inlist(hh`wv'aotran,0,1)
replace hh`wv'atran = hh`wv'atran + ha065_1_1_ if inrange(ha065_1_1_,0,9999999) 
replace hh`wv'atran = hh`wv'atran + ha065_1_2_ if inrange(ha065_1_2_,0,9999999)
replace hh`wv'atran = hh`wv'atran + ha065_1_3_ if inrange(ha065_1_3_,0,9999999)
label variable hh`wv'atran "hh`wv'atran:w`wv' Asset: hh value of transportation"

drop hh`wv'aotran

*********************************************************************
*********14.Value of non-financial asset (Durable assets) ***********
*********************************************************************
*whether has any durable assets 
gen hh`wv'aodurbl=.
replace hh`wv'aodurbl = .m if inw`wv' == 1
forvalues a = 1/17 {
    replace hh`wv'aodurbl = 0 if ha065s`a' == `a' |  ha065s18 == 18
}
forvalues a = 4/17 {
    replace hh`wv'aodurbl = 1 if ha065s`a'==`a' 
}
label variable hh`wv'aodurbl "hh`wv'aodurbl:w`wv' Asset: own durable assests"
label value hh`wv'aodurbl own

*Value of durable assets
gen hh`wv'adurbl=.
replace hh`wv'adurbl = .m if inw`wv' == 1
missing_H hh`wv'aodurbl, result(hh`wv'adurbl)
replace hh`wv'adurbl = 0 if inlist(hh`wv'aodurbl,0,1)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_4_ if inrange(ha065_1_4_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_5_ if inrange(ha065_1_5_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_6_ if inrange(ha065_1_6_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_7_ if inrange(ha065_1_7_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_8_ if inrange(ha065_1_8_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_9_ if inrange(ha065_1_9_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_10_ if inrange(ha065_1_10_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_11_ if inrange(ha065_1_11_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_12_ if inrange(ha065_1_12_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_13_ if inrange(ha065_1_13_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_14_ if inrange(ha065_1_14_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_15_ if inrange(ha065_1_15_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_16_ if inrange(ha065_1_16_,0,9999999)
replace hh`wv'adurbl = hh`wv'adurbl + ha065_1_17_ if inrange(ha065_1_17_,0,9999999)
label variable hh`wv'adurbl "hh`wv'adurbl:w`wv' Assets: hh consumer durable assets "

drop hh`wv'aodurbl

**************************************************
***15 Value of fixed capital assets***************
**************************************************
*whether has any fixed capital assets 
gen hh`wv'aofixc=.
replace hh`wv'aofixc = .m if inw`wv' == 1
replace hh`wv'aofixc = 0 if ha066s6 == 6 & ha067 == 0 & ha068 == 2
forvalues a = 1 / 5 {
    replace hh`wv'aofixc = 1 if ha066s`a' == `a'
}
replace hh`wv'aofixc = 1 if inrange(ha067,1,9999999)
replace hh`wv'aofixc = 1 if ha068 == 1
label variable hh`wv'aofixc "hh`wv'aofixc:w`wv' Asset: own fixed capital assests"
label value hh`wv'aofixc own


*Value of fixed capital assets
gen hh`wv'afixc =.
missing_H hh`wv'aofixc, result(hh`wv'afixc)
replace hh`wv'afixc = .m if inw`wv' == 1
replace hh`wv'afixc = 0 if inlist(hh`wv'aofixc,0,1)
replace hh`wv'afixc = hh`wv'afixc + ha066_1_1_ if inrange(ha066_1_1_,0,999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha066_1_2_ if inrange(ha066_1_2_,0,999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha066_1_3_ if inrange(ha066_1_3_,0,999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha066_1_4_ if inrange(ha066_1_4_,0,999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha066_1_5_ if inrange(ha066_1_5_,0,999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha067 if inrange(ha067,0,9999999) & !mi(hh`wv'afixc)
replace hh`wv'afixc = hh`wv'afixc + ha068_1 if inrange(ha068_1,0,999999) & !mi(hh`wv'afixc)
label variable hh`wv'afixc "hh`wv'afixc:w`wv' Asset: hh fixed capital assets"

drop hh`wv'aofixc

**********************************************************************
****16. Value of irrigable land*************************************
**********************************************************************
*whether has any irrigable land
gen hh`wv'aoland=.
replace hh`wv'aoland = .m if inw`wv' == 1
replace hh`wv'aoland = 0 if ha054s5 == 5
forvalues l = 1/4 {
    replace hh`wv'aoland = 1 if ha054s`l' == `l'
}
label variable hh`wv'aoland "hh`wv'aoland:w`wv' Asset: own irrigable land"
label value hh`wv'aoland own

gen land_value=.
replace land_value =.m if inw`wv' == 1
replace land_value = ha057_1_*ha055_1_ if inrange(ha057_1_,0,100000) & inrange(ha055_1_,0,99999)
replace land_value = .i if ha057_1_==-30

gen forest_value=.
replace forest_value =.m if inw`wv' == 1
replace forest_value = ha057_2_*ha055_2_ if inrange(ha057_2_,0,100000) & inrange(ha055_2_,0,99999)

gen ranch_value=.
replace ranch_value =.m if inw`wv' == 1
replace ranch_value = ha057_3_*ha055_3_ if inrange(ha057_3_,0,10000) & inrange(ha055_3_,0,99999)

gen pond_value=.
replace pond_value =.m if inw`wv' == 1
replace pond_value = ha057_4_*ha055_4_ if inrange(ha057_4_,0,200000) & inrange(ha055_4_,0,99999)

*****Total value of irrigable land*****
gen hh`wv'aland =.
replace hh`wv'aland = .m if inw`wv' == 1
replace hh`wv'aland = .i if land_value == .
replace hh`wv'aland = 0 if inlist(hh`wv'aoland,0,1)
replace hh`wv'aland = hh`wv'aland + land_value if !mi(land_value)
replace hh`wv'aland = hh`wv'aland + forest_value if !mi(forest_value)
replace hh`wv'aland = hh`wv'aland + ranch_value if !mi(ranch_value)
replace hh`wv'aland = hh`wv'aland + pond_value if !mi(pond_value)
label variable hh`wv'aland "hh`wv'aland:w`wv' Asset: hh value of irrigable land"

drop  hh`wv'aoland land_value forest_value ranch_value pond_value

***********************************************************************
****17 Agricultural Asset- livestock & fisheries*********************
***********************************************************************
*whether has any livestock or fisheres
gen hh`wv'aoagri=.
replace hh`wv'aoagri = .m if inw`wv' == 1
replace hh`wv'aoagri = 0 if gb001 == 2 | gb007 == 2
replace hh`wv'aoagri = 1 if gb007 == 1
label variable hh`wv'aoagri "hh`wv'aoagri:w`wv' Asset: own livestock or fisheries"
label value hh`wv'aoagri own

gen hh`wv'aagri=.
replace hh`wv'aagri = .m if inw`wv' == 1
replace hh`wv'aagri= 0 if hh`wv'aoagri == 0
replace hh`wv'aagri= gb008 if inrange(gb008,0,99999999)
label variable hh`wv'aagri "hh`wv'aagri:w`wv' Asset: Agricultural asset: hh livestock & fisheries"

drop hh`wv'aoagri

**************************************************
****Cash lending & borrowing ********************
** ha070_what is the total amount of loans that have not been paid by others?
gen hh`wv'alend=.
replace hh`wv'alend = .m if inw`wv' == 1
replace hh`wv'alend = 0 if ha069==2
replace hh`wv'alend = ha070 if inrange(ha070,0,500000)
replace hh`wv'alend = .i if ha070>500000 & !mi(ha070)
label variable hh`wv'alend "hh`wv'alend:w`wv' Asset: hh total amount of personal loans that have not been paid"

** borrowing: ha072_what is the total amout of loans that you are still owing to others?
gen hh`wv'aborr=.
replace hh`wv'aborr = .m if inw`wv' == 1
replace hh`wv'aborr = ha072 if inrange(ha072,0,500000)
replace hh`wv'aborr = .i if ha072>500000 & !mi(ha072)
label variable hh`wv'aborr "hh`wv'aborr:w`wv' Asset: hh total amount of money owing to others"

****personal loans******
gen hh`wv'aploan=.
missing_H hh`wv'alend hh`wv'aborr, result(hh`wv'aploan)
replace hh`wv'aploan = .i if hh`wv'alend == .i | hh`wv'aborr == .i
replace hh`wv'aploan = hh`wv'alend- hh`wv'aborr if !mi(hh`wv'alend) & !mi(hh`wv'aborr)
label variable hh`wv'aploan "hh`wv'aploan:w`wv' Asset: hh net value of personal loan"

**********************************************
****                                     *****
****   5. Other hh Member Assets         *****
****                                     *****
**********************************************


********************************************************************
****                                                              **
****5.1 Value of other HH members (individual-based) fiancial asset**
****                                                              **
*********************************************************************
gen za002_15_ = .
gen za002_16_ = .

** ha074_what is the value of all financial assets of household member?
forvalues x=1/16 {
    gen hh`wv'hhmasset_`x' =.
    replace hh`wv'hhmasset_`x' = .m if inw`wv' == 1
    replace hh`wv'hhmasset_`x' = 0 if (((mi(a002_`x'_) & mi(a006_`x'_)) | (mi(za002_`x'_) & mi(za006_`x'_))) & inw`wv' == 1) | pn == `x' | s1pn == `x'
    replace hh`wv'hhmasset_`x' = ha074_`x'_ if inrange(ha074_`x'_,-9999999,9999999)
}
gen hh`wv'afsst = .
missing_H hh`wv'hhmasset_1 hh`wv'hhmasset_2 hh`wv'hhmasset_3 hh`wv'hhmasset_4 hh`wv'hhmasset_5 hh`wv'hhmasset_6 hh`wv'hhmasset_7 hh`wv'hhmasset_8 hh`wv'hhmasset_9 hh`wv'hhmasset_10 hh`wv'hhmasset_11 hh`wv'hhmasset_12 hh`wv'hhmasset_13 hh`wv'hhmasset_14 hh`wv'hhmasset_15 hh`wv'hhmasset_16, result(hh`wv'afsst)
replace hh`wv'afsst = hh`wv'hhmasset_1 + hh`wv'hhmasset_2 + hh`wv'hhmasset_3 + hh`wv'hhmasset_4 + hh`wv'hhmasset_5 + hh`wv'hhmasset_6 + hh`wv'hhmasset_7 + hh`wv'hhmasset_8 + hh`wv'hhmasset_9 + hh`wv'hhmasset_10 + hh`wv'hhmasset_11 + hh`wv'hhmasset_12 + hh`wv'hhmasset_13 + hh`wv'hhmasset_14 + hh`wv'hhmasset_15 + hh`wv'hhmasset_16 if ///
                     !mi(hh`wv'hhmasset_1) & !mi(hh`wv'hhmasset_2) & !mi(hh`wv'hhmasset_3) & !mi(hh`wv'hhmasset_4) & !mi(hh`wv'hhmasset_5) & !mi(hh`wv'hhmasset_6) & !mi(hh`wv'hhmasset_7) & !mi(hh`wv'hhmasset_8) & !mi(hh`wv'hhmasset_9) & !mi(hh`wv'hhmasset_10) & !mi(hh`wv'hhmasset_11) & !mi(hh`wv'hhmasset_12) & !mi(hh`wv'hhmasset_13) & !mi(hh`wv'hhmasset_14) & !mi(hh`wv'hhmasset_15) & !mi(hh`wv'hhmasset_16)
label variable hh`wv'afsst "hh`wv'afsst:w`wv' Asset: value of other HH members financial asset"

drop hh`wv'hhmasset_1 hh`wv'hhmasset_2 hh`wv'hhmasset_3 hh`wv'hhmasset_4 hh`wv'hhmasset_5 hh`wv'hhmasset_6 hh`wv'hhmasset_7 hh`wv'hhmasset_8 hh`wv'hhmasset_9 hh`wv'hhmasset_10 hh`wv'hhmasset_11 hh`wv'hhmasset_12 hh`wv'hhmasset_13 hh`wv'hhmasset_14 hh`wv'hhmasset_15 hh`wv'hhmasset_16

********************************************************************
****                                                              **
****5.2 Value of other HH members (individual-based) fiancial debt*
****                                                              **
********************************************************************
** ha075_what is the value of all unpaid loans from banks or financial institutions of household member?

forvalues x=1/16 {
    gen hh`wv'hhmdebt_`x' =.
    replace hh`wv'hhmdebt_`x' = .m if inw`wv' == 1
    replace hh`wv'hhmdebt_`x' = 0 if (((mi(a002_`x'_) & mi(a006_`x'_)) | (mi(za002_`x'_) & mi(za006_`x'_))) & inw`wv' == 1) | pn == `x' | s1pn == `x'
    replace hh`wv'hhmdebt_`x' = ha075_`x'_ if inrange(ha075_`x'_,0,9999999)
}

gen hh`wv'afloa = .
missing_H hh`wv'hhmdebt_1 hh`wv'hhmdebt_2 hh`wv'hhmdebt_3 hh`wv'hhmdebt_4 hh`wv'hhmdebt_5 hh`wv'hhmdebt_6 hh`wv'hhmdebt_7 hh`wv'hhmdebt_8 hh`wv'hhmdebt_9 hh`wv'hhmdebt_10 hh`wv'hhmdebt_11 hh`wv'hhmdebt_12 hh`wv'hhmdebt_13 hh`wv'hhmdebt_14 hh`wv'hhmdebt_15 hh`wv'hhmdebt_16, result(hh`wv'afloa)
replace hh`wv'afloa = hh`wv'hhmdebt_1 + hh`wv'hhmdebt_2 + hh`wv'hhmdebt_3 + hh`wv'hhmdebt_4 + hh`wv'hhmdebt_5 + hh`wv'hhmdebt_6 + hh`wv'hhmdebt_7 + hh`wv'hhmdebt_8 + hh`wv'hhmdebt_9 + hh`wv'hhmdebt_10 + hh`wv'hhmdebt_11 + hh`wv'hhmdebt_12 + hh`wv'hhmdebt_13 + hh`wv'hhmdebt_14 + hh`wv'hhmdebt_15 + hh`wv'hhmdebt_16 if ///
                     !mi(hh`wv'hhmdebt_1) & !mi(hh`wv'hhmdebt_2) & !mi(hh`wv'hhmdebt_3) & !mi(hh`wv'hhmdebt_4) & !mi(hh`wv'hhmdebt_5) & !mi(hh`wv'hhmdebt_6) & !mi(hh`wv'hhmdebt_7) & !mi(hh`wv'hhmdebt_8) & !mi(hh`wv'hhmdebt_9) & !mi(hh`wv'hhmdebt_10) & !mi(hh`wv'hhmdebt_11) & !mi(hh`wv'hhmdebt_12) & !mi(hh`wv'hhmdebt_13) & !mi(hh`wv'hhmdebt_14) & !mi(hh`wv'hhmdebt_15) & !mi(hh`wv'hhmdebt_16)
label variable hh`wv'afloa "hh`wv'afloa:w`wv' Asset: value of other HH members financial debt"

drop hh`wv'hhmdebt_1 hh`wv'hhmdebt_2 hh`wv'hhmdebt_3 hh`wv'hhmdebt_4 hh`wv'hhmdebt_5 hh`wv'hhmdebt_6 hh`wv'hhmdebt_7 hh`wv'hhmdebt_8 hh`wv'hhmdebt_9 hh`wv'hhmdebt_10 hh`wv'hhmdebt_11 hh`wv'hhmdebt_12 hh`wv'hhmdebt_13 hh`wv'hhmdebt_14 hh`wv'hhmdebt_15 hh`wv'hhmdebt_16
drop za002_15_ za002_16_

*****************************************************
****NET value of other HH members of financial asset
gen hh`wv'afhhm = .
missing_H hh`wv'afsst hh`wv'afloa, result(hh`wv'afhhm)
replace hh`wv'afhhm = hh`wv'afsst - hh`wv'afloa if !mi(hh`wv'afsst) & !mi(hh`wv'afloa)
label variable hh`wv'afhhm "hh`wv'afhhm:w`wv' Asset: net value of other HH members financial asset"

****************************************************************
***SUMMARY *****************************************************
****************************************************************

***************************************************
****18. Net value of non-housing financial wealth
***************************************************
gen hh`wv'atotf = .
missing_H h`wv'atotf hh`wv'aploan hh`wv'afhhm, result(hh`wv'atotf)
replace hh`wv'atotf = .i if hh`wv'aploan == .i
replace hh`wv'atotf = .b if h`wv'atotf == .b
replace hh`wv'atotf = h`wv'atotf + hh`wv'aploan + hh`wv'afhhm if !mi(h`wv'atotf) & !mi(hh`wv'aploan) & !mi(hh`wv'afhhm)
label variable hh`wv'atotf "hh`wv'atotf:w`wv' Asset: hh net value of non-housing financial wealth"

**************************************************
****19. Total wealth*****************************
gen hh`wv'atotb = .
missing_H hh`wv'arles hh`wv'atoth hh`wv'atran hh`wv'adurbl hh`wv'afixc hh`wv'aland hh`wv'aagri hh`wv'atotf, result(hh`wv'atotb)
replace hh`wv'atotb = .i if hh`wv'atotf == .i | hh`wv'aland == .i
replace hh`wv'atotb = .b if hh`wv'atotf == .b
replace hh`wv'atotb = hh`wv'arles + hh`wv'atoth + hh`wv'atran + hh`wv'adurbl + hh`wv'afixc + hh`wv'aland + hh`wv'aagri + hh`wv'atotf if ///
                    !mi(hh`wv'arles) & !mi(hh`wv'atoth) & !mi(hh`wv'atran) & !mi(hh`wv'adurbl) & !mi(hh`wv'afixc) & !mi(hh`wv'aland) & !mi(hh`wv'aagri) & !mi(hh`wv'atotf)
label variable hh`wv'atotb "hh`wv'atotb:w`wv' Asset: hh total wealth"



****drop CHARLS individual income raw variables***
drop `asset_w2_indinc'

***drop CHARLS demog raw variables***
drop `asset_w2_demog'

****drop CHARLS household income raw variables***
drop `asset_w2_hhinc'

****drop CHARLS household characteristics raw variables***
drop `asset_w2_house'

****drop CHARLS psu data file raw variables***
drop `asset_w2_psu'

****drop CHARLS family data file raw variables***
drop `asset_w2_faminfo'


*set wave number
local wv=2
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2
 
***merge with work file***
local employ_w2_work fa001 fa002 fa003 fa005 fa006 fa006_w2_5 fa007 fa008 ///
                     fb002 fb011 fb012 ///
                     fc001 fc004 fc005 fc006 fc008 fc009 fc010 ///
                     fc011 fc014 fc015 fc017 fc019 fc020 fc021 ///
                     fd001 fd011_1 ///
                     fe001 fe002 fe003 ///
                     fh001 fh002 fh003 fh008_1 ///
                     fj001 fj002 fk002 ///
                     zf1 xf1 xf2 zf13 zf14 zf15 zf16
merge 1:1 ID using "`wave_2_work'", keepusing(`employ_w2_work')
drop if _merge==2
drop _merge


 

****Working status***
*respondent employment 
gen r`wv'wstat=. 
replace r`wv'wstat = 1 if fa001 == 1     // engage in agricultural work for more than 10 days in the past year

replace r`wv'wstat = 7 if fa001 == 2 & fa002 == 2 & (fa003 == 2 | fa005 == 2)  // currently not working
replace r`wv'wstat = 5 if fa001 == 2 & fa002 == 2 & (fa003 == 2 | fa005 == 2) & fk002 == 1 // currently not working, reports looking for work
replace r`wv'wstat = 6 if fa001 == 2 & fa002 == 2 & (fa003 == 2 | fa005 == 2) & (zf15 ==1 | fb011 == 1) // currently not working, reports retirement

replace r`wv'wstat = 4 if fc020 == 3     // with more than one job, main job : (3) unpaid family business 
replace r`wv'wstat = 3 if fc020 == 2     // with more than one job, main job : (2) self employed 
replace r`wv'wstat = 2 if fc020 == 1     // with more than one job, main job : (1) employed (regardless of fa001)

replace r`wv'wstat = 4 if fc021 == 3     // with only one job, main job : (3) unpaid family business
replace r`wv'wstat = 3 if fc021 == 2     // with only one job, main job : (2) self employed 
replace r`wv'wstat = 2 if fc021 == 1     // with only one job, main job : (1) employed (regardless of fa001)

***Labor Force Status***
*respondent
gen r`wv'lbrf_c =.
replace r`wv'lbrf_c=.m if inw`wv' == 1
replace r`wv'lbrf_c = 1  if r`wv'wstat == 1
replace r`wv'lbrf_c = 2  if r`wv'wstat == 2
replace r`wv'lbrf_c = 3  if r`wv'wstat == 3 
replace r`wv'lbrf_c = 4  if r`wv'wstat == 4  
replace r`wv'lbrf_c = 5  if r`wv'wstat == 5
replace r`wv'lbrf_c = 6  if r`wv'wstat == 6
replace r`wv'lbrf_c = 7  if r`wv'wstat == 7
label variable r`wv'lbrf_c "r`wv'lbrf_c:w`wv' R labor force status" 
label value    r`wv'lbrf_c status   

*spouse
gen s`wv'lbrf_c =.
spouse r`wv'lbrf_c, result(s`wv'lbrf_c) wave(`wv')
label variable s`wv'lbrf_c "s`wv'lbrf_c:w`wv' S labor force status"
label value    s`wv'lbrf_c status

***Currently working***
*respondent
gen r`wv'work=.
missing_H r`wv'wstat, result(r`wv'work)
replace r`wv'work=0 if inlist(r`wv'wstat,5,6,7)
replace r`wv'work=1 if inlist(r`wv'wstat,1,2,3,4)
label variable r`wv'work "r`wv'work:w2 r currently working"
label value r`wv'work work

*spouse 
gen s`wv'work =.
spouse r`wv'work, result(s`wv'work) wave(`wv')
label variable s`wv'work "s`wv'work:w`wv' S currently working"
label value s`wv'work work

*** currently working FOR PAY
*respondent
gen r`wv'workpay=.
missing_H r`wv'wstat, result(r`wv'workpay)
replace r`wv'workpay = 0 if inlist(r`wv'wstat,4, 5,6,7)
replace r`wv'workpay = 1 if inlist(r`wv'wstat,1,2,3)
label variable r`wv'workpay "r`wv'work:w1 r currently working for pay"
label value r`wv'workpay workpay

*spouse 
gen s`wv'workpay =.
spouse r`wv'workpay, result(s`wv'workpay) wave(`wv')
label variable s`wv'workpay "s`wv'work:w`wv' S currently working for pay"
label value s`wv'workpay workpay

***Works 2nd Job****
*respondent
gen r`wv'work2=.
replace r`wv'work2=.m if inw`wv'==1
replace r`wv'work2=.w if r`wv'work==0
replace r`wv'work2=0  if fc019 == 2 | (fc014 == 2  & (fc015 == 1 & fc017 == 2) | fc015 == 2)
replace r`wv'work2=1 if (fc019==1 | inrange(fj001,1,5))
label variable r`wv'work2 "r`wv'work2:w`wv' R works more than one job"
label values r`wv'work2 work

*spouse 
gen s`wv'work2 =.
spouse r`wv'work2, result(s`wv'work2) wave(`wv')
label variable s`wv'work2 "s`wv'work2:w`wv' S works more than one job"
label values s`wv'work2 work

***Whether self-employed***
*respondent
gen r`wv'slfemp=.
replace r`wv'slfemp=.m if inw`wv' == 1
replace r`wv'slfemp=0 if inlist(r`wv'wstat,1,2,4,5,6,7)
replace r`wv'slfemp=1 if r`wv'wstat==3
label variable r`wv'slfemp "r`wv'slfemp:w`wv' R whether self-employed"
label values r`wv'slfemp slfemp

*spouse 
gen s`wv'slfemp =.
spouse r`wv'slfemp, result(s`wv'slfemp) wave(`wv')
label variable s`wv'slfemp "s`wv'slfemp:w`wv' S whether self-employed"
label values s`wv'slfemp work
     
***Whether retired***
*respondent
gen r`wv'retemp=.
replace r`wv'retemp=.m if inw`wv' == 1
replace r`wv'retemp=0  if inlist(r`wv'lbrf_c,1,2,3,4,5,7)
replace r`wv'retemp=1  if r`wv'lbrf_c==6
label variable r`wv'retemp "r`wv'retemp:w`wv' R whether retired"
label value r`wv'retemp work

*spouse 
gen s`wv'retemp =.
spouse r`wv'retemp, result(s`wv'retemp) wave(`wv')
label variable s`wv'retemp "s`wv'retemp:w`wv' S whether retired"
label value s`wv'retemp work   

***Months worked per year (employed by others)***
*respondent
gen r`wv'wmemp=.
replace r`wv'wmemp=.m if fe001==. & inw`wv' == 1
replace r`wv'wmemp=.w if r`wv'work == 0
replace r`wv'wmemp = 0 if inlist(r`wv'wstat,1,3,4)
replace r`wv'wmemp = fe001 if inrange(fe001,0,12) 
label variable r`wv'wmemp "r`wv'wmemp:w`wv' R work how many months per year (employed by other)"/*for the work place not dispatch work unit*/

*spouse
gen s`wv'wmemp =.
spouse r`wv'wmemp, result(s`wv'wmemp) wave(`wv')
label variable s`wv'wmemp "s`wv'wmemp:w`wv' S work how many months per year (employed by other)"

****Days worked per week (employed by others)*****
*respondent
gen r`wv'wdemp=.
replace r`wv'wdemp=.m if fe002==. & inw`wv' == 1
replace r`wv'wdemp=.w if r`wv'work == 0
replace r`wv'wdemp = 0 if inlist(r`wv'wstat,1,3,4)
replace r`wv'wdemp=fe002 if inrange(fe002,0,7) 
label variable r`wv'wdemp "r`wv'wdemp:w`wv' R work how many days per week (employed by other)"

*spouse 
gen s`wv'wdemp =.
spouse r`wv'wdemp, result(s`wv'wdemp) wave(`wv')
label variable s`wv'wdemp "s`wv'wdemp:w`wv' S work how many days per week (employed by other)"

****Hours worked per day (employed by others)****
*respondent
gen r`wv'whemp=.
replace r`wv'whemp=.m if fe003==. & inw`wv' == 1
replace r`wv'whemp=.w if r`wv'work == 0
replace r`wv'whemp = 0 if inlist(r`wv'wstat,1,3,4)
replace r`wv'whemp=fe003 if inrange(fe003,0,24)                                                               
label variable r`wv'whemp "r`wv'whemp:w`wv' R work how many hours per day (employed by other)"/*for the work place not dispatch work unit*/

*spouse 
gen s`wv'whemp =.
spouse r`wv'whemp, result(s`wv'whemp) wave(`wv')
label variable s`wv'whemp "s`wv'whemp:w`wv' S work how many hours per day"

****hours worked per week (employed by others)*******
*respondent
gen r`wv'emphw=.
missing_H r`wv'wdemp r`wv'whemp, result(r`wv'emphw)
replace r`wv'emphw=.w if r`wv'work == 0
replace r`wv'emphw=r`wv'wdemp*r`wv'whemp if !mi(r`wv'wdemp) & !mi(r`wv'whemp)
label variable r`wv'emphw "r`wv'emphw:w`wv' R hours worked per week:employed"

*spouse 
gen s`wv'emphw =.
spouse r`wv'emphw, result(s`wv'emphw) wave(`wv')
label variable s`wv'emphw "s`wv'emphw:w`wv' S hours worked per week:employed"

drop r`wv'wdemp r`wv'whemp
drop s`wv'wdemp s`wv'whemp

****Months worked per year (self-employed)****
*respondent
local timese_cond (fa007 !=1 & fa001 != 1 & fa002 != 1 & fa005 != 1 & fa006 != 1) | (fa007 ==1 |fa008==2) | (fa001!=1 |(fc014!= 1 & fc017!=1) & (fa001 != 2| (fa002!= 1 &( fa002 !=2 | fa003 !=1 | fa005!=1))))
gen r`wv'wmsef=.
replace r`wv'wmsef= .m if fh001==. & inw`wv' == 1
replace r`wv'wmsef=.w if r`wv'work == 0
replace r`wv'wmsef = 0 if inlist(r`wv'wstat,1,2,4)
replace r`wv'wmsef=fh001 if inrange(fh001,0,12)
label variable r`wv'wmsef "r`wv'wmsef:w`wv' R work how many months per year"

*spouse 
gen s`wv'wmsef =.
spouse r`wv'wmsef, result(s`wv'wmsef) wave(`wv')
label variable s`wv'wmsef "s`wv'wmsef:w`wv' S work how many months per year"

****Days worked per week (self-employed)*****
*respondent
gen r`wv'wdsef=.
replace r`wv'wdsef=.m  if fh002==. & inw`wv' == 1
replace r`wv'wdsef=.w if r`wv'work == 0
replace r`wv'wdsef = 0 if inlist(r`wv'wstat,1,2,4)
replace r`wv'wdsef = fh002 if inrange(fh002,0,7)
replace r`wv'wdsef = 7 if inrange(fh002,8,30)
label variable r`wv'wdsef "r`wv'wdsef:w`wv' R work how many days per week "

*spouse 
gen s`wv'wdsef =.
spouse r`wv'wdsef, result(s`wv'wdsef) wave(`wv')
label variable s`wv'wdsef "s`wv'wdsef:w`wv' S work how many days per week "

****hours worked per day (self-employed)***
*respondent
gen r`wv'whsef=.
replace r`wv'whsef=.m  if fh003==. & inw`wv' == 1
replace r`wv'whsef=.w if r`wv'work == 0
replace r`wv'whsef = 0 if inlist(r`wv'wstat,1,2,4)
replace r`wv'whsef=fh003 if inrange(fh003,0,24)
label variable r`wv'whsef "r`wv'whsef:w`wv' R self-employed how many hours a day"

*spouse 
gen s`wv'whsef =.
spouse r`wv'whsef, result(s`wv'whsef) wave(`wv')
label variable s`wv'whsef "s`wv'whsef:w`wv' S self-employed how many hours a day"

****hours worked per week (self-employed)*****
*respondent
gen r`wv'sefhw=.
missing_H r`wv'wdsef r`wv'whsef, result(r`wv'sefhw)
replace r`wv'sefhw=.w if r`wv'work == 0
replace r`wv'sefhw = r`wv'wdsef*r`wv'whsef if !mi(r`wv'wdsef) & !mi(r`wv'whsef)
label variable r`wv'sefhw "r`wv'sefhw:w`wv' R hours worked per week:self-employed"

*spouse 
gen s`wv'sefhw =.
spouse r`wv'sefhw, result(s`wv'sefhw) wave(`wv')
label variable s`wv'sefhw "s`wv'sefhw:w`wv' S hours worked per week:self-employed"

drop r`wv'wdsef r`wv'whsef
drop s`wv'wdsef s`wv'whsef

****Months worked per year (other farm work)****
*respondent
gen r`wv'wmofam=.
replace r`wv'wmofam=.m if fc004==. & inw`wv' == 1
replace r`wv'wmofam=.w if r`wv'work == 0
replace r`wv'wmofam = 0 if fc001 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'wmofam=fc004 if inrange(fc004,0,12)
label variable r`wv'wmofam "r`wv'wmofam:w`wv' R work how many months per year"

*spouse 
gen s`wv'wmofam =.
spouse r`wv'wmofam, result(s`wv'wmofam) wave(`wv')
label variable s`wv'wmofam "s`wv'wmofam:w`wv' S work how many months per year"

****Days worked per week (other farm work)*****
*respondent
gen r`wv'wdofam=.
replace r`wv'wdofam=.m if fc005==. & inw`wv' == 1
replace r`wv'wdofam=.w if r`wv'work == 0
replace r`wv'wdofam = 0 if fc001 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'wdofam=fc005 if inrange(fc005,0,7)
label variable r`wv'wdofam "r`wv'wdofam:w`wv' R work how many days per week "

*spouse 
gen s`wv'wdofam =.
spouse r`wv'wdofam, result(s`wv'wdofam) wave(`wv')
label variable s`wv'wdofam "s`wv'wdofam:w`wv' S work how many days per week "

*****Hours worked per day (other farm work)****
*respondent
gen r`wv'whofam=.
replace r`wv'whofam=.m if fc006==. & inw`wv' == 1
replace r`wv'whofam=.w if r`wv'work == 0
replace r`wv'whofam = 0 if fc001 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'whofam=fc006 if inrange(fc006,0,24)
label variable r`wv'whofam "r`wv'whofam:w`wv' R farming at other farm how many hours a day"

*spouse 
gen s`wv'whofam =.
spouse r`wv'whofam, result(s`wv'whofam) wave(`wv')
label variable s`wv'whofam "s`wv'whofam:w`wv' S farming at farm other how many hours a day"

****hours worked per week (other farm work)*****
*respondent
gen r`wv'ofamhw=.
missing_H r`wv'wdofam r`wv'whofam, result(r`wv'ofamhw)
replace r`wv'ofamhw=.w if r`wv'work == 0
replace r`wv'ofamhw=r`wv'wdofam*r`wv'whofam if !mi(r`wv'wdofam) & !mi(r`wv'whofam)
label variable r`wv'ofamhw "r`wv'ofamhw:w`wv' R hours worked per week:other farm"

*spouse 
gen s`wv'ofamhw =.
spouse r`wv'ofamhw, result(s`wv'ofamhw) wave(`wv')
label variable s`wv'ofamhw "s`wv'ofamhw:w`wv' S hours worked per week:other farm"

drop r`wv'wdofam r`wv'whofam
drop s`wv'wdofam s`wv'whofam

****Months worked per year (own farm)***
*respondent
gen r`wv'wmsfam=.
replace r`wv'wmsfam=.m if fc009==. & inw`wv' == 1
replace r`wv'wmsfam=.w if r`wv'work == 0
replace r`wv'wmsfam = 0 if fc008 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'wmsfam=fc009 if inrange(fc009,0,12)
label variable r`wv'wmsfam "r`wv'wmsfam:w`wv' R work how many months per year"

*spouse 
gen s`wv'wmsfam =.
spouse r`wv'wmsfam, result(s`wv'wmsfam) wave(`wv')
label variable s`wv'wmsfam "s`wv'wmsfam:w`wv' S work how many months per year"

****Days worked per week (own farm) *****
*respondent
gen r`wv'wdsfam=.
replace r`wv'wdsfam=.m if fc010==. & inw`wv' == 1
replace r`wv'wdsfam=.w if r`wv'work == 0
replace r`wv'wdsfam = 0 if fc008 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'wdsfam=fc010 if inrange(fc010,0,7)
label variable r`wv'wdsfam "r`wv'wdsfam:w`wv' R work how many days per week "

*spouse 
gen s`wv'wdsfam =.
spouse r`wv'wdsfam, result(s`wv'wdsfam) wave(`wv')
label variable s`wv'wdsfam "s`wv'wdsfam:w`wv' S work how many days per week "

*****Hours worked per day (own farm)*****
*respondent
gen r`wv'whsfam=.
replace r`wv'whsfam =.m if fc011==. & inw`wv' == 1
replace r`wv'whsfam =.w if r`wv'work == 0
replace r`wv'whsfam = 0 if fc008 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'whsfam = fc011 if inrange(fc011,0,24) 
label variable r`wv'whsfam "r`wv'whsfam:w`wv' R farming at other farm how many hours a day"

*spouse 
gen s`wv'whsfam =.
spouse r`wv'whsfam, result(s`wv'whsfam) wave(`wv')
label variable s`wv'whsfam "s`wv'whsfam:w`wv' S farming at farm other how many hours a day"

****Days worked per week (own farm)*****
*respondent
gen r`wv'sfamhw=.
missing_H r`wv'wdsfam r`wv'whsfam, result(r`wv'sfamhw)
replace r`wv'sfamhw=.w if r`wv'work == 0
replace r`wv'sfamhw = r`wv'wdsfam*r`wv'whsfam if !mi(r`wv'wdsfam) & !mi(r`wv'whsfam)
label variable r`wv'sfamhw "r`wv'sfamhw:w`wv' R hours worked per week:own farm"

*spouse 
gen s`wv'sfamhw =.
spouse r`wv'sfamhw, result(s`wv'sfamhw) wave(`wv')
label variable s`wv'sfamhw "s`wv'sfamhw:w`wv' S hours worked per week:own farm"

drop r`wv'wdsfam r`wv'whsfam
drop s`wv'wdsfam s`wv'whsfam

***Hours worked per week (all farm work)***
*respondent
gen r`wv'farmhw =.
missing_H r`wv'ofamhw r`wv'sfamhw, result(r`wv'farmhw)
replace r`wv'farmhw =.w if r`wv'work == 0
replace r`wv'farmhw = r`wv'ofamhw if !mi(r`wv'ofamhw) & mi(r`wv'sfamhw)
replace r`wv'farmhw = r`wv'sfamhw if !mi(r`wv'sfamhw) & mi(r`wv'ofamhw)
replace r`wv'farmhw = r`wv'sfamhw if r`wv'sfamhw == r`wv'ofamhw & !mi(r`wv'ofamhw) & !mi(r`wv'sfamhw)
replace r`wv'farmhw = r`wv'sfamhw if r`wv'sfamhw > r`wv'ofamhw & !mi(r`wv'ofamhw) & !mi(r`wv'sfamhw)
replace r`wv'farmhw = r`wv'ofamhw if r`wv'ofamhw > r`wv'sfamhw & !mi(r`wv'ofamhw) & !mi(r`wv'sfamhw)

drop r`wv'ofamhw r`wv'sfamhw 
drop s`wv'ofamhw s`wv'sfamhw 

***Hours worked per week (summary for main job)***
*respondent
gen r`wv'jhours_c=.
missing_H r`wv'emphw r`wv'sefhw r`wv'farmhw, result(r`wv'jhours_c)
replace r`wv'jhours_c = .w if r`wv'work == 0 
replace r`wv'jhours_c = .f if r`wv'wstat == 4
replace r`wv'jhours_c = r`wv'emphw if r`wv'wstat == 2 & !mi(r`wv'emphw)
replace r`wv'jhours_c = r`wv'sefhw if r`wv'wstat == 3 & !mi(r`wv'sefhw)
replace r`wv'jhours_c = r`wv'farmhw if r`wv'wstat == 1 & !mi(r`wv'farmhw)
label variable r`wv'jhours_c "r`wv'jhours_c:w`wv' R total hours worked per week on main job"

*spouse 
gen s`wv'jhours_c =.
spouse r`wv'jhours_c, result(s`wv'jhours_c) wave(`wv')
label variable s`wv'jhours_c "s`wv'jhours_c:w`wv' S total hours worked per week on main job"

drop r`wv'emphw r`wv'sefhw 
drop s`wv'emphw s`wv'sefhw  
drop r`wv'farmhw

****Hours worked per week (summary for other jobs)***
*respondent
gen r`wv'jhour2=.
replace r`wv'jhour2= .m if fj002==. & inw`wv'==1  
replace r`wv'jhour2= .w if r`wv'work == 0 | r`wv'work2 == 0
replace r`wv'jhour2= fj002 if inrange(fj002,0,168)
label variable r`wv'jhour2"r`wv'jhour2:w`wv' R hours worked/week on other jobs"

*spouse 
gen s`wv'jhour2=.
spouse r`wv'jhour2, result(s`wv'jhour2) wave(`wv')
label variable s`wv'jhour2"s`wv'jhour2:w`wv' S hours worked/week on other jobs"

*** Hours worked per week (main job + other jobs) *** 
gen r`wv'jhourstot=. 
missing_H r`wv'jhours_c r`wv'jhour2, result(r`wv'jhourstot)
replace r`wv'jhourstot = r`wv'jhours_c if !mi(r`wv'jhours_c) & mi(r`wv'jhour2) 
replace r`wv'jhourstot = r`wv'jhour2   if !mi(r`wv'jhour2) & mi(r`wv'jhours_c)
replace r`wv'jhourstot = r`wv'jhours_c + r`wv'jhour2 if !mi(r`wv'jhours_c) & !mi(r`wv'jhour2)
label variable r`wv'jhourstot "r`wv'jhourstot:w`wv' R total hours worked per week on main job and side jobs"

***Weeks worked per year (all farm work)***
*respondent
gen r`wv'wmfarm =.
missing_H r`wv'wmofam r`wv'wmsfam, result(r`wv'wmfarm)
replace r`wv'wmfarm =.w if r`wv'work == 0
replace r`wv'wmfarm = r`wv'wmofam if !mi(r`wv'wmofam) & mi(r`wv'wmsfam)
replace r`wv'wmfarm = r`wv'wmsfam if !mi(r`wv'wmsfam) & mi(r`wv'wmofam)
replace r`wv'wmfarm = r`wv'wmsfam if r`wv'wmsfam == r`wv'wmofam & !mi(r`wv'wmsfam) & !mi(r`wv'wmofam)
replace r`wv'wmfarm = r`wv'wmsfam if r`wv'wmsfam > r`wv'wmofam & !mi(r`wv'wmsfam) & !mi(r`wv'wmofam)
replace r`wv'wmfarm = r`wv'wmofam if r`wv'wmofam > r`wv'wmsfam & !mi(r`wv'wmsfam) & !mi(r`wv'wmofam)

drop r`wv'wmofam
drop s`wv'wmofam

drop r`wv'wmsfam
drop s`wv'wmsfam

*weeks worked per year (summary for main job)
*respondent
gen r`wv'jweeks_c=.
missing_H r`wv'wmemp r`wv'wmsef r`wv'wmfarm, result(r`wv'jweeks_c)
replace r`wv'jweeks_c = .w if r`wv'work == 0 
replace r`wv'jweeks_c = .f if r`wv'wstat == 4
replace r`wv'jweeks_c = r`wv'wmemp*4.33 if r`wv'wstat==2 & !mi(r`wv'wmemp)
replace r`wv'jweeks_c = r`wv'wmsef*4.33 if r`wv'wstat == 3 & !mi(r`wv'wmsef)
replace r`wv'jweeks_c = r`wv'wmfarm*4.33 if r`wv'wstat == 1 & !mi(r`wv'wmfarm)
label variable r`wv'jweeks_c "r`wv'jweeks_c:w`wv' R weeks worked per year on main job"

*spouse 
gen s`wv'jweeks_c =.
spouse r`wv'jweeks_c, result(s`wv'jweeks_c) wave(`wv')
label variable s`wv'jweeks_c "s`wv'jweeks_c:w`wv' S weeks worked per year on main job"

drop r`wv'wmemp
drop s`wv'wmemp
drop r`wv'wmsef
drop s`wv'wmsef
drop r`wv'wmfarm

drop r`wv'wstat


****drop CHARLS work raw variables***
drop `employ_w2_work'

*set wave number
local wv=2
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2

***merge with demog file***
local inc_w2_demog be001 xrtype 
merge 1:1 ID using "`wave_2_demog'", keepusing(`inc_w2_demog')
drop if _merge==2
drop _merge


***merge with household income file***
local inc_w2_hhinc ga005_?_  ga005_1?_ ///
                   ga006_1_?_ ga006_1_1?_  ga006_2_?_ ga006_2_1?_ ///
	               ga007_?_s? ga007_?_s1? ///
	               ga007_1?_s? ga007_1?_s1? ///
                   ga008_1b_?_ ga008_1b_1?_ ga008_1c_?_ ga008_1c_1?_ ///
                   ga008_2b_?_ ga008_2b_1?_ ga008_2c_?_ ga008_2c_1?_ ///
                   ga008_3b_?_ ga008_3b_1?_ ga008_3c_?_ ga008_3c_1?_ ///
                   ga008_4b_?_ ga008_4b_1?_ ga008_4c_?_ ga008_4c_1?_ ///
                   ga008_5b_?_ ga008_5b_1?_ ga008_5c_?_ ga008_5c_1?_ ///   
                   ga008_6b_?_ ga008_6b_1?_ ga008_6c_?_ ga008_6c_1?_ ///
                   ga008_7b_?_ ga008_7b_1?_ ga008_7c_?_ ga008_7c_1?_ ///
                   ga008_8b_?_ ga008_8b_1?_ ga008_8c_?_ ga008_8c_1?_ ///
                   ga008_9b_?_ ga008_9b_1?_ ga008_9c_?_ ga008_9c_1?_ ///
                   gb001 gb002s1 gb002s2 gb002s3 gb002s4 gb002s5 gb002s6 ///
                   gb002s7 gb002s8 gb002s9 gb002s10 gb002s11 gb002s12 ///
                   gb002s13 gb002s14 ///
                   gb003 gb005_bracket_min gb005_bracket_max gb006_bracket_min gb006_bracket_max ///
                   gb005_1 gb006 gb007 gb008 gb009 ///
                   gb010 gb011_1 gb012_1 gb013 ///
                   gc001 gc002 ///
                   gc005_1_ gc005_2_ gc005_3_ gc005_4_ ///
                   gd001 gd002_1 gd002_2 gd002_3 gd002_4 gd002_5 gd002_6 gd002_7 ///
                   gd002s1 gd002s2 gd002s3 gd002s4 gd002s5 gd002s6 gd002s7 gd002s8 ///
                   gd003_1 gd003s1 gd003_2 gd003s2 gd003_3 gd003s3 gd003s4 ///
                   ge004 ge006 ge007 ge008 ge006_w2_1 ge006_w2 ///
                   ge009_1 ge009_2 ge009_3 ge009_4 ge009_5 ge009_6 ge009_7 ///
                   ge010_1 ge010_2 ge010_3 ge010_4 ge010_5 ge010_6 ge010_7 ///
                   ge010_8 ge010_9 ge010_10 ge010_11 ge010_12 ge010_13 ///
                   ha052 ha052_1 ///
                   ha053 ha053_1 ha054s1 ha054s2 ha054s3 ha054s4 ha054s5 ///
                   ha058_?_ ha060_1_ ha060_2_ ha060_3_ ha060_4_ ///  
                   ha064 ha064_1 ha069 ///
                   ha071 ha027
                             
merge m:1 householdID using "`wave_2_hhinc'", keepusing(`inc_w2_hhinc') 
drop if _merge==2
drop _merge
foreach var of varlist `inc_w2_hhinc' {
    replace `var' = . if inw`wv' == 0 // *correct overassignmnet of household values to non-reponding hh members who respondend previously 
}

***merge with individual income file***
local inc_w2_indinc ga001 ga002 ga002_1 ga002_2 ga002_bracket_max ga002_bracket_min ///
                    ga003s1 ga003s2 ga003s3 ga003s4 ga003s5 ga003s6 ga003s7 ga003s8 ga003s9 ga003s10  ///
                    ga004_1_1_ ga004_1_2_ ga004_1_3_ ga004_1_4_ ga004_1_5_ ga004_1_6_ ga004_1_7_ ga004_1_8_ ga004_1_9_ ///
                    ga004_2_1_ ga004_2_2_ ga004_2_3_ ga004_2_4_ ga004_2_5_ ga004_2_6_ ga004_2_7_ ga004_2_8_ ga004_2_9_ ///   
                    hc013 hc018 hc023 hc024 hc025_bracket_min hd012
merge 1:1 ID using "`wave_2_indinc'", keepusing(`inc_w2_indinc') 
drop if _merge==2
drop _merge

***merge with work file***
local inc_w2_work    fa001 fa007 fa008 fa006_w2_5 ///
                     fb011 fb012 ///
                     fc001 fc004 fc005 fc006 fc007 fc008 fc009 fc010 ///
                     fc011 fc014 fc019 fc020 fc021 ///
                     fd001 fd011_1 ///
                     fe001 fe002 fe003 ///
                     ff001 ff002_1 ff004_1 ff006 ff008 ff010 ff012_1 ff014 ///
                     ff003bracket_min ff003bracket_max ff003_w2bracket_min ff003_w2bracket_max ///
                     ff005bracket_min ff005bracket_max ff005_w2bracket_min ff005_w2bracket_max ///
                     ff009bracket_min ff009bracket_max ///
                     ff013bracket_min ff013bracket_max ff013_w2bracket_min ff013_w2bracket_max ff015bracket_min ff015bracket_max ///
                     fg001s1 fg001s2 fg001s3 fg001s4 fg001s5 fg001s6 fg001s7 fg001s8 fg001s9 fg001s10 fg001s11 ///
                     fg002_?_ fg002_1?_ ///
                     fh001 fh002 fh003 fh009 fh010 ///
                     fj001 fj002 fj003 fj004bracket_min fj004bracket_max fk002 ///
                     fm014_1 fm014_2 fm030_1 fm030_2 ///
                     fn002_w2s1 fn002_w2s2 fn002_w2s3 fn002_w2s4 ///
                     fn003_w2_1_?_ fn003_w2_2_?_ fn004_w2_?_ ///
                     fn005_w2_1_ fn005_w2_2_ fn005_w2_3_ ///
                     fn030_w2 fn041_w2_* fn042_w2 fn043_w2 fn055_w2_* fn056_w2 ///
                     fn067_w2_1_1_ fn067_w2_2_1_ fn057_w2s? fn058_w2_1_ fn068_w2_1_ ///
                     fn067_w2_1_2_ fn067_w2_2_2_ fn058_w2_2_ fn068_w2_2_  ///
                     fn067_w2_1_3_ fn067_w2_2_3_ fn058_w2_3_ fn068_w2_3_  ///
                     fn069_w2 fn075_w2  fn076_w2_1 fn076_w2_2 fn077_w2   ///
                     fn079_w2_10_1  fn079_w2_10_2 fn079_w2_3 fn079_w2_1 fn079_w2_11  ///
                     fn081_w2_1 fn081_w2_2  fn080_w2 fn082_w2 ///
                     fn095_w2_1 fn095_w2_2  fn083_w2 fn096_w2 ///
                     xf1 zf13 zf14 zf15 zf16 
merge 1:1 ID using "`wave_2_work'", keepusing(`inc_w2_work') 
drop if _merge==2
drop _merge

***merge with weight file***
local inc_w2_faminfo a002_?_ a002_1?_ /// 
                     a006_?_ a006_1?_ ///
                     za002_?_ za002_1?_ /// 
                     za006_?_ za006_1?_
merge m:1 householdID using "`wave_2_faminfo'", keepusing(`inc_w2_faminfo') 
drop if _merge==2
drop _merge
foreach var of varlist `inc_w2_faminfo' {
    replace `var' = . if inw`wv' == 0 // *correct overassignmnet of household values to non-reponding hh members who respondend previously 
}

***merge with weight file***
local inc_w2_weight iyear imonth
merge 1:1 ID using "`wave_2_weight_'", keepusing(`inc_w2_weight') 
drop if _merge==2
drop _merge



******************************************************************************************
****************************************
****                               *****     
**** INDIVIDUAL INCOME r+s       *****
****                               *****
****************************************


***************************************
***                                 ***
*** 1. R+S INDIVIDUAL WAGE INCOME   ***
***                                 ***
***************************************

*** 1.1.1  Respondent&Spouse Wage Income From Income Module  ***

*******Individual Earnings***** 
*wave 2 respondent earnings
gen r`wv'iowagei=.
replace r`wv'iowagei = .m if ga001==. & inw`wv' == 1
replace r`wv'iowagei = 0 if ga001==2 
replace r`wv'iowagei = 1 if ga001==1
label variable r`wv'iowagei "r`wv'iowagei:w`wv' income: r wage and bonus from income module"
label value r`wv'iowagei income

*wave 2 spouse earnings
gen s`wv'iowagei =.
spouse r`wv'iowagei, result(s`wv'iowagei) wave(`wv')
label variable s`wv'iowagei "s`wv'iowagei:w`wv' income: s wage and bonus from income module"
label value s`wv'iowagei income

*wave 2 respondent earnings
gen r`wv'iwagei=.
replace r`wv'iwagei= .m if inw`wv' == 1
replace r`wv'iwagei=0 if r`wv'iowagei== 0
replace r`wv'iwagei=ga002_2 * 12 if inrange(ga002_2,0,9999999)
replace r`wv'iwagei=ga002_1 if inrange(ga002_1,0,9999999)
label variable r`wv'iwagei "r`wv'iwagei:w`wv' income: r wage and bonus from income module"

*wave 2 spouse earnings
gen s`wv'iwagei =.
spouse r`wv'iwagei, result(s`wv'iwagei) wave(`wv')
label variable s`wv'iwagei "s`wv'iwagei:w`wv' income: s wage and bonus from income module"

**H earnings
gen h`wv'iwagei= .
household r`wv'iwagei s`wv'iwagei, result(h`wv'iwagei)
label variable h`wv'iwagei "h`wv'iwagei:w`wv' income: hhold wage and bonus from income module(couple level)"

drop r`wv'iowagei s`wv'iowagei

**********************************************
** 1.2 Respondent & Spouse Income From Work Module   **
** 1.2.1 Income from Agricultural-related Activities **
*respondent
gen r`wv'ifmemp=.
replace r`wv'ifmemp = .m if inw`wv' == 1
replace r`wv'ifmemp = 0 if r`wv'work == 0 | fc001 == 2 | (fa001 == 2 & r`wv'work == 1)
replace r`wv'ifmemp=fc007*fc004 if inrange(fc007,0,99999) & inrange(fc004,0,12)
label variable r`wv'ifmemp "r`wv'ifmemp:w`wv' income: r agricultural-related activities income from work module"

*spouse
gen s`wv'ifmemp =.
spouse r`wv'ifmemp, result(s`wv'ifmemp) wave(`wv')
label variable s`wv'ifmemp "s`wv'ifmemp:w`wv' income: s agricultural-related activities income from work module"

*household
gen h`wv'ifmemp= .
household r`wv'ifmemp s`wv'ifmemp, result(h`wv'ifmemp)
label variable h`wv'ifmemp "h`wv'ifmemp:w`wv' income: hhold agricultural-related activities income from work module"

**==1.2.2 Income from Non-agricultural Job==*
**Wage payment by year
*respondent
gen r`wv'iwagea=.
replace r`wv'iwagea = .m if inw`wv' == 1
replace r`wv'iwagea = 0 if r`wv'work == 0 | inlist(r`wv'lbrf_c,1,3,4)
replace r`wv'iwagea = ff002_1 if inrange(ff002_1,0,1000000)
replace r`wv'iwagea = ff004_1*fe001 if inrange(ff004_1,0,99999) & inrange(fe001,0,12)
replace r`wv'iwagea = (ff006*52)/12*fe001 if inrange(ff006,0,99999) & inrange(fe001,0,12)
replace r`wv'iwagea = (ff008*fe002*52)/12*fe001 if inrange(ff008,0,9999) & inrange(fe002,0,7) & inrange(fe001,0,12)
replace r`wv'iwagea = (ff010*fe003*fe002*52)/12*fe001 if inrange(ff010,0,999) & inrange(fe003,0,24) & inrange(fe002,0,7) & inrange(fe001,0,12)
replace r`wv'iwagea = ff012_1*fe001 if inrange(ff012_1,0,999999) & inrange(fe001,0,12)
label variable r`wv'iwagea "r`wv'iwagea:w`wv' income: r wage from work module"

*spouse
gen s`wv'iwagea =.
spouse r`wv'iwagea, result(s`wv'iwagea) wave(`wv')
label variable s`wv'iwagea "s`wv'iwagea:w`wv' income: s wage from work module"

*household
gen h`wv'iwagea =.
household r`wv'iwagea s`wv'iwagea, result(h`wv'iwagea)
label variable h`wv'iwagea "h`wv'iwagea:w`wv' income: hhold wage from work module"

**==Yearly bonus from non-agricultural job==*
***all other bonus***
*respondent
gen r`wv'ibonus=.
replace r`wv'ibonus = .m if inw`wv' == 1
replace r`wv'ibonus = 0 if r`wv'work == 0 | inlist(r`wv'lbrf_c,1,3,4)
replace r`wv'ibonus = ff014 if inrange(ff014,0,9999999)
label variable r`wv'ibonus "r`wv'ibonus:w`wv' income: r earning from bonus"

*wave 2 spouse bonus
gen s`wv'ibonus =.
spouse r`wv'ibonus, result(s`wv'ibonus) wave(`wv')
label variable s`wv'ibonus "s`wv'ibonus:w`wv' income: s earning from bonus"

*household
gen h`wv'ibonus= .
household r`wv'ibonus s`wv'ibonus, result(h`wv'ibonus)
label variable h`wv'ibonus "h`wv'ibonus:w`wv' income: hhold earning from bonus"

** Wage Income from Side Jobs
** fe001: how many months did you work in the past year?
***side job
*wave 2 respondent side job
gen r`wv'isjob=.
replace r`wv'isjob =.m if inw`wv' == 1
replace r`wv'isjob = 0 if r`wv'work == 0 | r`wv'work2 == 0
replace r`wv'isjob = fj003 * fe001 if inrange(fj003,0,2000000) & inrange(fe001,0,12)
replace r`wv'isjob = fj003 * fh001 if inrange(fj003,0,2000000) & inrange(fh001,0,12)
label variable r`wv'isjob "r`wv'isjob:w`wv' income: r earning from side job"

*wave 2 spouse sjobings
gen s`wv'isjob =.
spouse r`wv'isjob, result(s`wv'isjob) wave(`wv')
label variable s`wv'isjob "s`wv'isjob:w`wv' income: s earning from side job"

*household
gen h`wv'isjob= .
household r`wv'isjob s`wv'isjob, result(h`wv'isjob)
label variable h`wv'isjob "h`wv'isjob:w`wv' income: hhold earning from side job"

**********************************************
** Total Wage Income from main jobs and side jobs
gen r`wv'iwagew=.
missing_H r`wv'iwagea r`wv'ibonus r`wv'isjob r`wv'ifmemp, result(r`wv'iwagew)
replace r`wv'iwagew = r`wv'iwagea + r`wv'ibonus + r`wv'isjob + r`wv'ifmemp if !mi(r`wv'iwagea) & !mi(r`wv'ibonus) & !mi(r`wv'isjob) & !mi(r`wv'ifmemp)
label variable r`wv'iwagew "r`wv'iwagew:w`wv' income: r earning from work module"

gen s`wv'iwagew =.
spouse r`wv'iwagew, result(s`wv'iwagew) wave(`wv')
label variable s`wv'iwagew "s`wv'iwagew:w`wv' income: s earning from work module"

**take the maximum of wage values from income and work module
gen r`wv'iearn=.
max_h_value r`wv'iwagei r`wv'iwagew, result(r`wv'iearn)
label variable r`wv'iearn "r`wv'iearn:w`wv' income: r earning from income or work module"

*wave 2 spouse 
gen s`wv'iearn =.
spouse r`wv'iearn, result(s`wv'iearn) wave(`wv')
label variable s`wv'iearn "s`wv'iearn:w`wv' income: s earning from income or work module"

*household
gen h`wv'iearn = .
household r`wv'iearn s`wv'iearn, result(h`wv'iearn)
label variable h`wv'iearn "h`wv'iearn:w`wv' income: r+s earning from income or work module(couple level)"

drop h`wv'iwagei
**************************************************
***                                            ***
*** 2. R+S Individual INCOME           ***
***                             
**************************************************

**==2.1 public transfer from income module==*
******************************************
**2.1.1 pension
***2.1.9 having other income source(couple level)
gen r`wv'iopeni=.
replace r`wv'iopeni = .m if ga003s1==. & inw`wv' == 1
replace r`wv'iopeni = 0 if ga003s9 == 9 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 |  ga003s10 == 10
replace r`wv'iopeni = 1 if ga003s1 == 1
label variable r`wv'iopeni "r`wv'iopeni:w`wv' income: r pension income from income module"
label value r`wv'iopeni income


gen r`wv'ipeni=.
replace r`wv'ipeni =.m if inw`wv' == 1
replace r`wv'ipeni = 0 if r`wv'iopeni == 0
replace r`wv'ipeni = ga004_2_1_*12 if inrange(ga004_2_1_,0,999999) 
replace r`wv'ipeni = ga004_1_1_ if inrange(ga004_1_1_,0,999999) 
label variable r`wv'ipeni "r`wv'ipeni:w`wv' income: r pension income from income module"

gen s`wv'ipeni=.
spouse r`wv'ipeni, result(s`wv'ipeni) wave(`wv')
label variable s`wv'ipeni "s`wv'ipeni:w`wv' income: s pension income from income module"

*****************************************************
****total pension use only from income section********
*household
gen h`wv'ipeni= .
household r`wv'ipeni s`wv'ipeni, result(h`wv'ipeni)
label variable h`wv'ipeni "h`wv'ipeni:w`wv' income: r+s pension income from income module(couple level)"

drop r`wv'iopeni

******************************************************
*******PENSION from work module **********************
**== 2.2 pension income from work module for retirees==*
***fm018, fm022, fm034not asked in w2
***whole FN section is new*******


destring imonth, gen(imonth_)
**recode one outlier
replace fn005_w2_2_=fn005_w2_2_/10 if fn005_w2_2_==50000

***work pension 1: goverment employee
gen tw1=.
replace tw1=12 if fn003_w2_1_1_ < 2012
replace tw1=12 if fn003_w2_1_1_ ==2012 & fn003_w2_2_1_ < imonth_
replace tw1 = 12 + imonth_ - fn003_w2_2_1_ if fn003_w2_1_1_ == 2012 & fn003_w2_2_1_ >= imonth_
replace tw1 = imonth_ - fn003_w2_2_1_ if inlist(fn003_w2_1_1_,2013) // *the respondent retired in 2013

gen pensionw1=.
replace pensionw1=0  if fn002_w2s2==2 | fn002_w2s3==3 | fn002_w2s4==4 | fb011==2 | fb012==2
replace pensionw1=fn005_w2_1_ *tw1  if inrange(fn005_w2_1_,0,999999)

***work pension 2:institutions
gen tw2=.
replace tw2=12 if fn003_w2_1_2_ < 2012
replace tw2=12 if fn003_w2_1_2_ ==2012 & fn003_w2_2_2_ < imonth_
replace tw2 = 12 + imonth_ - fn003_w2_2_2_ if fn003_w2_1_2_ == 2012 & fn003_w2_2_2_ >= imonth_
replace tw2 = imonth_ - fn003_w2_2_2_ if inlist(fn003_w2_1_2_,2013) // *the respondent retired in 2013
replace tw2 = 0 if inrange(tw2,-5,0)

gen pensionw2=.
replace pensionw2=0  if fn002_w2s1==1 | fn002_w2s3==3 | fn002_w2s4==4 | fb011==2 | fb012==2
replace pensionw2=fn005_w2_2_ *tw2  if inrange(fn005_w2_2_,0,999999)

***work pension 3: firm
gen tw3=.
replace tw3=12 if fn003_w2_1_3_ < 2012
replace tw3=12 if fn003_w2_1_3_ ==2012 & fn003_w2_2_3_ < imonth_
replace tw3 = 12 + imonth_ - fn003_w2_2_3_ if fn003_w2_1_3_ == 2012 & fn003_w2_2_3_ >= imonth_
replace tw3 = imonth_ - fn003_w2_2_3_ if inlist(fn003_w2_1_3_,2013) // *the respondent retired in 2013
replace tw3 = 0 if inrange(tw3,-5,0)

gen pensionw3=.
replace pensionw3=0  if fn002_w2s1==1 | fn002_w2s2==2 | fn002_w2s4==4 | fb011==2 | fb012==2
replace pensionw3=fn005_w2_3_ *tw3  if inrange(fn005_w2_3_,0,999999)

*** supplemental pension insurance of the firm
gen t1=.
replace t1 = 12 if fn041_w2_1 < 2012
replace t1 = 12 if fn041_w2_1 ==2012 & fn041_w2_2 < imonth_
replace t1 = 12 + imonth_ - fn041_w2_2 if fn041_w2_1 == 2012 & fn041_w2_2 >= imonth_
replace t1 = imonth_ - fn041_w2_2 if inlist(fn041_w2_1,2013)

gen pension1 =.
replace pension1 = 0 if inlist(fn030_w2,1,3) 
replace pension1 = fn042_w2 * t1 if inrange(fn042_w2,0,99999) 

*** commercial pension
gen t2=.
replace t2 = 12 if fn055_w2_1 < 2012
replace t2 = 12 if fn055_w2_1 ==2012 & fn055_w2_2 < imonth_
replace t2 = 12 + imonth_ - fn055_w2_2 if fn055_w2_1 == 2012 & fn055_w2_2 >= imonth_
replace t2 = imonth_ - fn055_w2_2 if inlist(fn055_w2_1,2013)

gen pension2 =.
replace pension2 = 0 if inlist(fn043_w2,1,3) 
replace pension2 = fn056_w2 * t2 if inrange(fn056_w2,0,99999) 

*** rural pension
gen t3a=.
replace t3a =12 if fn067_w2_1_1_ < 2012
replace t3a =12 if fn067_w2_1_1_ ==2012 & fn067_w2_2_1_ < imonth_
replace t3a = 12 + imonth_ - fn067_w2_2_1_ if fn067_w2_1_1_ == 2012 & fn067_w2_2_1_ >= imonth_
replace t3a = imonth_ - fn067_w2_2_1_ if inlist(fn067_w2_1_1_,2013) 
replace t3a = 0 if inrange(t3a,-5,0)

gen pension3a =.
replace pension3a = 0 if fn057_w2s2==2 | fn057_w2s3==3 | fn057_w2s4==4 | fn058_w2_1_ == 1
replace pension3a = fn068_w2_1_ * t3a if inrange(fn068_w2_1_,0,99999) 

*** residents pension 
gen t3b=.
replace t3b =12 if fn067_w2_1_2_ < 2012
replace t3b =12 if fn067_w2_1_2_ ==2012 & fn067_w2_2_2_ < imonth_
replace t3b = 12 + imonth_ - fn067_w2_2_2_ if fn067_w2_1_2_ == 2012 & fn067_w2_2_2_ >= imonth_
replace t3b = imonth_ - fn067_w2_2_2_ if inlist(fn067_w2_1_2_,2013) 

gen pension3b =.
replace pension3b = 0 if fn057_w2s1==1 | fn057_w2s3==3 | fn057_w2s4==4 | fn058_w2_2_ == 1
replace pension3b = fn068_w2_2_ * t3b if inrange(fn068_w2_2_,0,99999) 

*** urban residents pension
gen t3c=.
replace t3c =12 if fn067_w2_1_3_ < 2012
replace t3c =12 if fn067_w2_1_3_ ==2012 & fn067_w2_2_3_ < imonth_
replace t3c = 12 + imonth_ - fn067_w2_2_3_ if fn067_w2_1_3_ == 2012 & fn067_w2_2_3_ >= imonth_
replace t3c = imonth_ - fn067_w2_2_3_ if inlist(fn067_w2_1_3_,2013) 

gen pension3c =.
replace pension3c = 0 if fn057_w2s1==1 | fn057_w2s2==2 | fn057_w2s4==4 | fn058_w2_3_ == 1
replace pension3c = fn068_w2_3_ * t3c if inrange(fn068_w2_3_,0,99999) 

*** new rural social pension insurance
gen t4=.
replace t4 = 12 if fn076_w2_1 < 2012
replace t4 = 12 if fn076_w2_1==2012 & fn076_w2_2 < imonth_
replace t4 = 12 + imonth_ - fn076_w2_2 if fn076_w2_1 == 2012 & fn076_w2_2 >= imonth_
replace t4 = imonth_ - fn076_w2_2 if inlist(fn076_w2_1,2013) 
replace t4 = 0 if inrange(t4,-5,0)

gen pension4 =.
replace pension4 = 0 if fn069_w2 == 2 | fn075_w2 == 2
replace pension4 = fn077_w2 * 12 if inrange(fn077_w2,0,99999)
replace pension4 = fn077_w2 * t4 if inrange(fn077_w2,0,99999)  & inrange(t4,0,12)

*** land expropriation pension insurance
gen t5 =.
replace t5 =12 if fn079_w2_10_1 < 2012
replace t5 =12 if fn079_w2_10_1 ==2012 & fn079_w2_10_2 < imonth_
replace t5 = 12 + imonth_ - fn079_w2_10_2 if fn079_w2_10_1 == 2012 & fn079_w2_10_2 >= imonth_
replace t5 = imonth_ - fn079_w2_10_2 if inlist(fn079_w2_10_1,2013) 

gen pension5 =.
replace pension5 = 0 if fn079_w2_1==2 | inlist(fn079_w2_3,1,3)
replace pension5 = fn079_w2_11 * t5 if inrange(fn079_w2_11,0,99999) 

*** old age pension allowance
gen t6=.
replace t6 = 12 if fn081_w2_1 < 2012
replace t6 = 12 if fn081_w2_1 ==2012 & fn081_w2_2 < imonth_
replace t6 = 12 + imonth_ - fn081_w2_2 if fn081_w2_1 == 2012 & fn081_w2_2 >= imonth_
replace t6 = imonth_ - fn081_w2_2 if inlist(fn081_w2_1,2013)
replace t6 = 0 if inrange(t6,-5,0)

gen pension6 =.
replace pension6 = 0 if fn080_w2 == 2 
replace pension6 = fn082_w2 * t6 if inrange(fn082_w2,0,99999) 

*** others
***fn095_w2_1 fn095_w2_2 are wrong
gen t7=.
replace t7 = 12 if fn095_w2_1 < 2012
replace t7 = 12 if fn095_w2_1 ==2012 & fn095_w2_2 < imonth_
replace t7 = 12 + imonth_ - fn095_w2_2 if fn095_w2_1 == 2012 & fn095_w2_2 >= imonth_
replace t7 = imonth_ - fn095_w2_2 if inlist(fn095_w2_1,2013)

gen pension7 =.
replace pension7 = 0 if inlist(fn083_w2,1,3) 
replace pension7 = fn096_w2 * 12 if inrange(fn096_w2,0,99999) 

*********TOTAL PENSION from WORK SECTION*****
*respondent
gen r`wv'ipenw = .
replace r`wv'ipenw = .m if inw`wv' == 1
replace r`wv'ipenw = pensionw1 + pensionw2 + pensionw3 + pension1 + pension2 + pension3a + pension3b + pension3c + pension4 + pension5 + pension6 + pension7 if ///
                    !mi(pensionw1) & !mi(pensionw2) & !mi(pensionw3) & !mi(pension1) & !mi(pension2) & !mi(pension3a) & !mi(pension3b) & !mi(pension3c) & !mi(pension4) & !mi(pension5) & !mi(pension6) & !mi(pension7)
label variable r`wv'ipenw "r`wv'ipenw:w`wv' income: r pension income from work module"

*spouse
gen s`wv'ipenw=.
spouse r`wv'ipenw, result(s`wv'ipenw) wave(`wv')
label variable s`wv'ipenw "s`wv'ipenw:w`wv' income: s pension income from work module"

*household
gen h`wv'ipenw= .
household r`wv'ipenw s`wv'ipenw, result(h`wv'ipenw)
label variable h`wv'ipenw "h`wv'ipenw:w`wv' income: r+s pension income from work module (couple level)"

drop pension* t*

******************************************************
*******max of pension from income and work module****
*respondent
gen r`wv'ipen =.
max_h_value r`wv'ipeni r`wv'ipenw, result(r`wv'ipen)
label variable r`wv'ipen "r`wv'ipen:w`wv' income: r pension income from income or work module"

*spouse
gen s`wv'ipen=.
spouse r`wv'ipen, result(s`wv'ipen) wave(`wv')
label variable s`wv'ipen "s`wv'ipen:w`wv' income: s pension income from income or work module"

*household
gen h`wv'ipen = .
household r`wv'ipen s`wv'ipen, result(h`wv'ipen)
label variable h`wv'ipen "h`wv'ipen:w`wv' income: r+s pension income from work module (couple level)"


*******income related to working subsides*************
*****calculate yearly (not monthly)
***2.1.2 having unemployment compensation 
gen r`wv'iounec=.
replace r`wv'iounec = .m if ga003s2 ==. & inw`wv' == 1
replace r`wv'iounec = 0 if ga003s1 == 1 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'iounec = 1 if ga003s2 == 2
label variable r`wv'iounec "r`wv'iounec:w`wv' income: r unemployment compensation"
label value r`wv'iounec income

*wave 2 spouse 
gen s`wv'iounec =.
spouse r`wv'iounec, result(s`wv'iounec) wave(`wv')
label variable s`wv'iounec "s`wv'iounec:w`wv' income: s unemployment compensation"
label value s`wv'iounec income

***Value of unemployment compensation
gen r`wv'iunec=.
replace r`wv'iunec = .m if inw`wv' == 1
replace r`wv'iunec = 0 if r`wv'iounec == 0
replace r`wv'iunec = ga004_2_2_ * 12 if inrange(ga004_2_2_,0,20000)
replace r`wv'iunec = ga004_1_2_ if inrange(ga004_1_2_,0,100000)
label variable r`wv'iunec "r`wv'iunec:w`wv' income: r value of unemployment compensation"

**wave 2 spouse
gen s`wv'iunec=.
spouse r`wv'iunec, result(s`wv'iunec) wave(`wv')
label variable s`wv'iunec "s`wv'iunec:w`wv' income: s value of unemployment compensation"

***household value
gen h`wv'iunec= .
household r`wv'iunec s`wv'iunec, result(h`wv'iunec)
label variable h`wv'iunec "h`wv'iunec:w`wv' income: r+s value of unemployment compensation"

drop r`wv'iounec s`wv'iounec

***2.1.3 having pension subsidy
gen r`wv'iopens=.
replace r`wv'iopens = .m if ga003s3==. & inw`wv' == 1
replace r`wv'iopens = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'iopens = 1 if ga003s3 == 3
label variable r`wv'iopens "r`wv'iopens:w`wv' income: r pension subsidy"
label value r`wv'iopens income

*wave 2 spouse 
gen s`wv'iopens =.
spouse r`wv'iopens, result(s`wv'iopens) wave(`wv')
label variable s`wv'iopens "s`wv'iopens:w`wv' income: s pension subsidy"
label value s`wv'iopens income

***Value of pension subsidy
gen r`wv'ipens=.
replace r`wv'ipens = .m if inw`wv' == 1
replace r`wv'ipens = 0 if r`wv'iopens == 0
replace r`wv'ipens = ga004_2_3_*12 if inrange(ga004_2_3_,0,20000) 
replace r`wv'ipens = ga004_1_3_ if inrange(ga004_1_3_,0,100000) 
label variable r`wv'ipens "r`wv'ipens:w`wv' income: r value of pension subsidy"

**wave 2 spouse
gen s`wv'ipens=.
spouse r`wv'ipens, result(s`wv'ipens) wave(`wv')
label variable s`wv'ipens "s`wv'ipens:w`wv' income: s value of pension subsidy"

***household value
gen h`wv'ipens= .
household r`wv'ipens s`wv'ipens, result(h`wv'ipens)
label variable h`wv'ipens "h`wv'ipens:w`wv' income: r+s value of pension subsidy"

drop r`wv'iopens s`wv'iopens

***2.1.4 having worker compensation
gen r`wv'ioworkc=.
replace r`wv'ioworkc = .m if ga003s4==. & inw`wv' == 1
replace r`wv'ioworkc = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'ioworkc = 1 if ga003s4==4
label variable r`wv'ioworkc "r`wv'ioworkc:w`wv' income: r worker compensation"
label value r`wv'ioworkc income

*wave 2 spouse 
gen s`wv'ioworkc =.
spouse r`wv'ioworkc, result(s`wv'ioworkc) wave(`wv')
label variable s`wv'ioworkc "s`wv'ioworkc:w`wv' income: s worker compensation"
label value s`wv'ioworkc income


***Value of worker compensation
gen r`wv'iworkc=.
replace r`wv'iworkc = .m if inw`wv' == 1
replace r`wv'iworkc = 0 if r`wv'ioworkc == 0 
replace r`wv'iworkc = ga004_2_4_*12 if inrange(ga004_2_4_,0,20000) 
replace r`wv'iworkc = ga004_1_4_ if inrange(ga004_1_4_,0,100000) 
label variable r`wv'iworkc "r`wv'iworkc:w`wv' income: r value of worker compensation"

**wave 2 spouse
gen s`wv'iworkc=.
spouse r`wv'iworkc, result(s`wv'iworkc) wave(`wv')
label variable s`wv'iworkc "s`wv'iworkc:w`wv' income: s value of worker compensation"

***household value
gen h`wv'iworkc= .
household r`wv'iworkc s`wv'iworkc, result(h`wv'iworkc)
label variable h`wv'iworkc "h`wv'iworkc:w`wv' income: r+s value of worker compensation"

drop r`wv'ioworkc s`wv'ioworkc

***having elderly family planning subsides
gen r`wv'ioefps=.
replace r`wv'ioefps = .m if ga003s5==. & inw`wv' == 1
replace r`wv'ioefps = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'ioefps = 1 if ga003s5==5
label variable r`wv'ioefps "r`wv'ioefps:w`wv' income: r elderly family planning subsides"
label value r`wv'ioefps income

*wave 2 spouse 
gen s`wv'ioefps =.
spouse r`wv'ioefps, result(s`wv'ioefps) wave(`wv')
label variable s`wv'ioefps "s`wv'ioefps:w`wv' income: s elderly family planning subsides"
label value s`wv'ioefps income

***2.1.5 Value of elderly family planning subsides
gen r`wv'iefps=.
replace r`wv'iefps = .m if inw`wv' == 1
replace r`wv'iefps = 0 if r`wv'ioefps == 0 
replace r`wv'iefps = ga004_2_5_*12 if inrange(ga004_2_5_,0,20000)
replace r`wv'iefps = ga004_1_5_ if inrange(ga004_1_5_,0,100000) 
label variable r`wv'iefps "r`wv'iefps:w`wv' income: r value of elderly family planning subsides"

**wave 2 spouse
gen s`wv'iefps=.
spouse r`wv'iefps, result(s`wv'iefps) wave(`wv')
label variable s`wv'iefps "s`wv'iefps:w`wv' income: s value of elderly family planning subsides"

***household value
gen h`wv'iefps= .
household r`wv'iefps s`wv'iefps, result(h`wv'iefps)
label variable h`wv'iefps "h`wv'iefps:w`wv' income: r+s value of elderly family planning subsides"

drop r`wv'ioefps s`wv'ioefps

***2.1.6 having medical aid
gen r`wv'iomed=.
replace r`wv'iomed = .m if ga003s6==. & inw`wv' == 1
replace r`wv'iomed = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s7 == 7 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'iomed = 1 if ga003s6==6
label variable r`wv'iomed "r`wv'iomed:w`wv' income: r medical aid"
label value r`wv'iomed income

*wave 2 spouse 
gen s`wv'iomed =.
spouse r`wv'iomed, result(s`wv'iomed) wave(`wv')
label variable s`wv'iomed "s`wv'iomed:w`wv' income: s medical aid"
label value s`wv'iomed income

*** Value of medical aid
gen r`wv'imed=.
replace r`wv'imed = .m if inw`wv' == 1
replace r`wv'imed = 0 if r`wv'iomed == 0
replace r`wv'imed = ga004_2_6_*12 if inrange(ga004_2_6_,0,20000)
replace r`wv'imed = ga004_1_6_ if inrange(ga004_1_6_,0,100000) 
label variable r`wv'imed "r`wv'imed:w`wv' income: r value of medical aid"

**wave 2 spouse
gen s`wv'imed=.
spouse r`wv'imed, result(s`wv'imed) wave(`wv')
label variable s`wv'imed "s`wv'imed:w`wv' income: s value of medical aid"

***household value
gen h`wv'imed= .
household r`wv'imed s`wv'imed, result(h`wv'imed)
label variable h`wv'imed "h`wv'imed:w`wv' income: r+s value of medical aid"

drop r`wv'iomed s`wv'iomed

***2.1.7 having other government subsidies
gen r`wv'iogovs=.
replace r`wv'iogovs = .m if ga003s7==. & inw`wv' == 1
replace r`wv'iogovs = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s8 == 8 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'iogovs = 1 if ga003s7 == 7
label variable r`wv'iogovs "r`wv'iogovs:w`wv' income: r other government subsidies"
label value r`wv'iogovs income

*wave 2 spouse 
gen s`wv'iogovs =.
spouse r`wv'iogovs, result(s`wv'iogovs) wave(`wv')
label variable s`wv'iogovs "s`wv'iogovs:w`wv' income: s other government subsidies"
label value s`wv'iogovs income

*** Value of other government subsidies
gen r`wv'igovs=.
replace r`wv'igovs = .m if inw`wv' == 1 
replace r`wv'igovs = 0 if r`wv'iogovs == 0
replace r`wv'igovs = ga004_2_7_*12 if inrange(ga004_2_7_,0,999999) 
replace r`wv'igovs = ga004_1_7_ if inrange(ga004_1_7_,0,9999999) 
label variable r`wv'igovs "r`wv'igovs:w`wv' income: r value of other government subsidies"

**wave 2 spouse
gen s`wv'igovs=.
spouse r`wv'igovs, result(s`wv'igovs) wave(`wv')
label variable s`wv'igovs "s`wv'igovs:w`wv' income: s value of other government subsidies"

***household value
gen h`wv'igovs= .
household r`wv'igovs s`wv'igovs, result(h`wv'igovs)
label variable h`wv'igovs "h`wv'igovs:w`wv' income: r+s value of other government subsidies"

drop r`wv'iogovs s`wv'iogovs

***2.1.8 having social assistance
gen r`wv'iosoca=.
replace r`wv'iosoca = .m if ga003s8==. & inw`wv' == 1
replace r`wv'iosoca = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s9 == 9 |  ga003s10 == 10
replace r`wv'iosoca = 1 if ga003s8 == 8
label variable r`wv'iosoca "r`wv'iosoca:w`wv' income: r social assistance"
label value r`wv'iosoca income

*wave 2 spouse 
gen s`wv'iosoca =.
spouse r`wv'iosoca, result(s`wv'iosoca) wave(`wv')
label variable s`wv'iosoca "s`wv'iosoca:w`wv' income: s social assistance"
label value s`wv'iosoca income

***Value of social assistance
gen r`wv'isoca=.
replace r`wv'isoca = .m if inw`wv' == 1
replace r`wv'isoca = 0 if r`wv'iosoca == 0
replace r`wv'isoca = ga004_2_8_*12 if inrange(ga004_2_8_,0,20000)
replace r`wv'isoca = ga004_1_8_ if inrange(ga004_1_8_,0,100000) 
label variable r`wv'isoca "r`wv'isoca:w`wv' income: r value of social assistance"

**wave 2 spouse
gen s`wv'isoca=.
spouse r`wv'isoca, result(s`wv'isoca) wave(`wv')
label variable s`wv'isoca "s`wv'isoca:w`wv' income: s value of social assistance"

***household value
gen h`wv'isoca= .
household r`wv'isoca s`wv'isoca, result(h`wv'isoca)
label variable h`wv'isoca "h`wv'isoca:w`wv' income: r+s value of social assistance"

drop r`wv'iosoca s`wv'iosoca

***2.1.9 having other income source(couple level)
gen r`wv'ioothr=.
replace r`wv'ioothr = .m if ga003s9==. & inw`wv' == 1
replace r`wv'ioothr = 0 if ga003s1 == 1 | ga003s2 == 2 | ga003s3 == 3 | ga003s4 == 4 | ga003s5 == 5 | ga003s6 == 6 | ga003s7 == 7 | ga003s8 == 8 |  ga003s10 == 10
replace r`wv'ioothr = 1 if ga003s9 == 9
label variable r`wv'ioothr "r`wv'ioothr:w`wv' income: r other income source (alimony or child support)"
label value r`wv'ioothr income

*wave 2 spouse 
gen s`wv'ioothr =.
spouse r`wv'ioothr, result(s`wv'ioothr) wave(`wv')
label variable s`wv'ioothr "s`wv'ioothr:w`wv' income: s other income source (alimony or child support)"
label value s`wv'ioothr income

******************************
***Value of other income source (alimony or child support)
gen r`wv'iothr=.
replace r`wv'iothr = .m if inw`wv' == 1
replace r`wv'iothr = 0 if r`wv'ioothr == 0 
replace r`wv'iothr = ga004_2_9_*12 if inrange(ga004_2_9_,0,9999999) 
replace r`wv'iothr = ga004_1_9_ if inrange(ga004_1_9_,0,99999999) 
label variable r`wv'iothr "r`wv'iothr:w`wv' income: r other income (alimony or child support)"

**wave 2 spouse
gen s`wv'iothr=.
spouse r`wv'iothr, result(s`wv'iothr) wave(`wv')
label variable s`wv'iothr "s`wv'iothr:w`wv' income: s other income (alimony or child support)"

***household value
gen h`wv'iothr= .
household r`wv'iothr s`wv'iothr, result(h`wv'iothr)
label variable h`wv'iothr "h`wv'iothr:w`wv' income: r+s other income(alimony or child support) (couple level)"

drop r`wv'ioothr s`wv'ioothr

******************************************************
*****R+S Goverment Transfer  not include rwiothr
*******************************************************
*respondent
gen r`wv'igxfr = .
missing_H r`wv'iunec r`wv'ipens r`wv'iworkc r`wv'iefps r`wv'imed r`wv'igovs r`wv'isoca, result(r`wv'igxfr)
replace r`wv'igxfr = r`wv'iunec + r`wv'ipens + r`wv'iworkc + r`wv'iefps + r`wv'imed + r`wv'igovs + r`wv'isoca if ///
                    !mi(r`wv'iunec) & !mi(r`wv'ipens) & !mi(r`wv'iworkc) & !mi(r`wv'iefps) & !mi(r`wv'imed) & !mi(r`wv'igovs) & !mi(r`wv'isoca)
label variable r`wv'igxfr "r`wv'igxfr:w`wv' income: r government transfer"

*spouse
gen s`wv'igxfr =.
spouse r`wv'igxfr, result(s`wv'igxfr) wave(`wv')
label variable s`wv'igxfr "s`wv'igxfr:w`wv' income: s government transfer"

*household
gen h`wv'igxfr = .
household r`wv'igxfr s`wv'igxfr, result(h`wv'igxfr)
label variable h`wv'igxfr "h`wv'igxfr:w`wv' income: r+s government transfer (couple level)"

drop r`wv'iunec r`wv'ipens r`wv'iworkc r`wv'iefps r`wv'imed r`wv'igovs r`wv'isoca s`wv'iunec s`wv'ipens s`wv'iworkc s`wv'iefps s`wv'imed s`wv'igovs s`wv'isoca h`wv'iunec h`wv'ipens h`wv'iworkc h`wv'iefps h`wv'imed h`wv'igovs h`wv'isoca 


**********************************************************
***                                                    ***
***       3. Fringe Benefits from work module          ***
***                                                    ***
**********************************************************

**==3.1 income from monthly fringe benefits==*
forvalues x = 1/10 {
    gen fringe_`x' = .
    replace fringe_`x' = 0 if r`wv'work == 0 | inlist(r`wv'lbrf_c,1,3,4)
    replace fringe_`x' = 0 if fg001s1 == 1 | fg001s2 == 2 | fg001s3 == 3 | fg001s4 == 4 | fg001s5 == 5 | fg001s6 == 6 | fg001s7 == 7 | fg001s8 == 8 | fg001s9 == 9 | fg001s10 == 10 | fg001s11 == 11
    replace fringe_`x' = fg002_`x'_ * fe001 if inrange(fg002_`x'_,0,999999)
}
gen r`wv'ifring =.
replace r`wv'ifring = .m if inw`wv' == 1
replace r`wv'ifring = fringe_1 + fringe_2 + fringe_3 + fringe_4 + fringe_5 + fringe_6 + fringe_7 + fringe_8 + fringe_9 + fringe_10 if !mi(fringe_1) & ///
                                                                                                                                      !mi(fringe_2) & ///
                                                                                                                                      !mi(fringe_3) & ///
                                                                                                                                      !mi(fringe_4) & ///
                                                                                                                                      !mi(fringe_5) & ///
                                                                                                                                      !mi(fringe_6) & ///
                                                                                                                                      !mi(fringe_7) & ///
                                                                                                                                      !mi(fringe_8) & ///
                                                                                                                                      !mi(fringe_9) & ///
                                                                                                                                      !mi(fringe_10)
label variable r`wv'ifring "r`wv'ifring:w`wv' income: r fringe benefits"

**wave 2 spouse
gen s`wv'ifring=.
spouse r`wv'ifring, result(s`wv'ifring) wave(`wv')
label variable s`wv'ifring "s`wv'ifring:w`wv' income: s fringe benefits"

***household value
gen h`wv'ifring= .
household r`wv'ifring s`wv'ifring, result(h`wv'ifring)
label variable h`wv'ifring "h`wv'ifring:w`wv' income: r+s fringe benefits(couple level)"

drop fringe_1 fringe_2 fringe_3 fringe_4 fringe_5 fringe_6 fringe_7 fringe_8 fringe_9 fringe_10

**********************************************************
***                                                    ***
***      4. Other Self-employed Activity Income  from work module       ***
***                                                   ***
**********************************************************
gen r`wv'isemp=.
replace r`wv'isemp = .m if inw`wv' == 1
replace r`wv'isemp = 0  if r`wv'work == 0 | inlist(r`wv'lbrf_c,1,2,4) | fh009 == 1
replace r`wv'isemp = fh010 if inrange(fh010,0,20000000)
label variable r`wv'isemp "r`wv'isemp:w`wv' income: r self-employment w/o other hh members"

**wave 2 spouse
gen s`wv'isemp=.
spouse r`wv'isemp, result(s`wv'isemp) wave(`wv')
label variable s`wv'isemp "s`wv'isemp:w`wv' income: s self-employment w/o other hh members"

***household value
gen h`wv'isemp=.
household r`wv'isemp s`wv'isemp, result(h`wv'isemp)
label variable h`wv'isemp "h`wv'isemp:w`wv' income: r+s self-employment w/o other hh members (couple level)"


*********************************************
**                                        ***                   
** 5. R+S  Capital Income                 ****               
****                                        ***                    
*********************************************
****Income  from all financial asset investments*******
*respondent
gen r`wv'iovest=.
replace r`wv'iovest = .m if hc023==. & inw`wv' == 1
replace r`wv'iovest = 0  if hc023== 2 
replace r`wv'iovest = 1  if hc023== 1  
label variable r`wv'iovest "r`wv'iovest:w`wv' income: R having other investment"
label value r`wv'iovest income

*spouse
gen s`wv'iovest=.
spouse r`wv'iovest, result(s`wv'iovest) wave(`wv')
label variable s`wv'iovest "s`wv'iovest:w`wv' income: S having other investment"
label value s`wv'iovest income

****Value of income from investment
*respondent
gen r`wv'ivest=.
replace r`wv'ivest = .m if inw`wv' == 1
replace r`wv'ivest = 0  if r`wv'iovest == 0
replace r`wv'ivest = hc024 if inrange(hc024,0,10000000)
label variable r`wv'ivest "r`wv'ivest:w`wv' income: r amount of income receive from other investment"

*spouse
gen s`wv'ivest=.
spouse r`wv'ivest, result(s`wv'ivest) wave(`wv')
label variable s`wv'ivest "s`wv'ivest:w`wv' income: s amount of income receive from other investment"

drop r`wv'iovest s`wv'iovest

****************************************
****TOTAL R+S capital income*****
*respondent
gen r`wv'icap = .
missing_H r`wv'ivest, result(r`wv'icap)
replace r`wv'icap = r`wv'ivest if !mi(r`wv'ivest)
label variable r`wv'icap "r`wv'icap:w`wv' income: R capital income"

*spouse
gen s`wv'icap=.
spouse r`wv'icap, result(s`wv'icap) wave(`wv')
label variable s`wv'icap "s`wv'icap:w`wv' income: S capital income"

*household
gen h`wv'icap = .
household r`wv'icap s`wv'icap, result(h`wv'icap)
label variable h`wv'icap "h`wv'icap:w`wv' income: r+s capital income (couple level)"

drop r`wv'ivest s`wv'ivest



*********************************************************************************
*********************************************************************************
****5.Other household members' wage income and transfer (Individual based)*******
*********************************************************************************
*********************************************************************************
*SANDY review, household roster issue
*****5.1 other HH member wage icnome ****

***Value of other household member income
forvalues x=1/12 {
    gen hhmwage_`x' =.
    replace hhmwage_`x' = 0 if((mi(a002_`x'_) & mi(a006_`x'_) | mi(za002_`x'_) & mi(za006_`x'_)) & inw`wv' == 1) | ga005_`x'_ == 2
    replace hhmwage_`x' = ga006_2_`x'_ * 12 if inrange(ga006_2_`x'_,0,99999)
    replace hhmwage_`x' = ga006_1_`x'_ if inrange(ga006_1_`x'_,0,999999)
}

gen hh`wv'iwageo = .
missing_c_w1 ga006_2_?_ ga006_2_1?_ ga006_1_?_ ga006_1_1?_, result(hh`wv'iwageo)
replace hh`wv'iwageo = hhmwage_1 + hhmwage_2 + hhmwage_3 + hhmwage_4 + hhmwage_5 + hhmwage_6 + hhmwage_7 + hhmwage_8 + hhmwage_9 + hhmwage_10 + hhmwage_11 + hhmwage_12 if ///
                     !mi(hhmwage_1) & !mi(hhmwage_2) & !mi(hhmwage_3) & !mi(hhmwage_4) & !mi(hhmwage_5) & !mi(hhmwage_6) & !mi(hhmwage_7) & !mi(hhmwage_8) & !mi(hhmwage_9) & !mi(hhmwage_10) & !mi(hhmwage_11) & !mi(hhmwage_12)
label variable hh`wv'iwageo "hh`wv'iwageo:w`wv' income: other household member wage income"

drop hhmwage_1 hhmwage_2 hhmwage_3 hhmwage_4 hhmwage_5 hhmwage_6 hhmwage_7 hhmwage_8 hhmwage_9 hhmwage_10 hhmwage_11 hhmwage_12

***************************************************
** 5.2 Other hhmembers' Individual-based transfers  
***************************************************

******5.2.1 HH member pension (yearly)
**Value of pension 
forvalues x=1/12 {
    gen hpension_`x' =. 
    replace hpension_`x' = 0 if ((mi(a002_`x'_) & mi(a006_`x'_) | mi(za002_`x'_) & mi(za006_`x'_)) & inw`wv' == 1) | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hpension_`x'= ga008_1c_`x'_ * 12 if inrange(ga008_1c_`x'_,0,100000)
    replace hpension_`x'= ga008_1b_`x'_ if inrange(ga008_1b_`x'_,0,100000) 
}

gen hh`wv'ipeno = .
replace hh`wv'ipeno =.m if inw`wv' == 1
replace hh`wv'ipeno = hpension_1 + hpension_2 + hpension_3 + hpension_4 + hpension_5 + hpension_6 + hpension_7 + hpension_8 + hpension_9 + hpension_10 + hpension_11 + hpension_12 if ///
                    !mi(hpension_1) & !mi(hpension_2) & !mi(hpension_3) & !mi(hpension_4) & !mi(hpension_5) & !mi(hpension_6) & !mi(hpension_7) & !mi(hpension_8) & !mi(hpension_9) & !mi(hpension_10) & !mi(hpension_11) & !mi(hpension_12)
label variable hh`wv'ipeno "hh`wv'ipeno:w`wv' income: other hhold member pension income"

drop hpension_1 hpension_2 hpension_3 hpension_4 hpension_5 hpension_6 hpension_7 hpension_8 hpension_9 hpension_10 hpension_11 hpension_12

*************************************************************
*******Other HHmember goveremnt transfer Individual-based******
***********************************************
** 5.2.2 unemployment  compensation
forvalues x=1/12 {
    gen hunem_`x'=.
    replace hunem_`x' = 0 if ((mi(a002_`x'_) & mi(a006_`x'_) | mi(za002_`x'_) & mi(za006_`x'_)) & inw`wv' == 1)  | ga007_`x'_s1 == 1 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hunem_`x'= ga008_2c_`x '_ * 12 if inrange(ga008_2c_`x'_,0,10000) 
    replace hunem_`x'= ga008_2b_`x'_ if inrange(ga008_2b_`x'_,0,200000) 
}

gen hh`wv'iunec = .
replace hh`wv'iunec = .m if inw`wv' == 1
replace hh`wv'iunec = hunem_1 + hunem_2 + hunem_3 + hunem_4 + hunem_5 + hunem_6 + hunem_7 + hunem_8 + hunem_9 + hunem_10 + hunem_11 + hunem_12 if ///
                    !mi(hunem_1) & !mi(hunem_2) & !mi(hunem_3) & !mi(hunem_4) & !mi(hunem_5) & !mi(hunem_6) & !mi(hunem_7) & !mi(hunem_8) & !mi(hunem_9) & !mi(hunem_10) & !mi(hunem_11) & !mi(hunem_12)
label variable hh`wv'iunec "hh`wv'iunec:w`wv' income:other hhold member unemployment income"

drop hunem_1-hunem_12

** 5.2.3 pension subsidy
forvalues x=1/12  {
    gen psub_`x' =.
    replace psub_`x' = 0 if ((mi(a002_`x'_) & mi(a006_`x'_) | mi(za002_`x'_) & mi(za006_`x'_)) & inw`wv' == 1)  | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace psub_`x'= ga008_3c_`x'_ * 12 if inrange(ga008_3c_`x'_,0,10000) 
    replace psub_`x'= ga008_3b_`x'_ if inrange(ga008_3b_`x'_,0,200000) 
} 

gen hh`wv'ipens = .
replace hh`wv'ipens = .m if inw`wv' == 1
replace hh`wv'ipens = psub_1 + psub_2 + psub_3 + psub_4 + psub_5 + psub_6 + psub_7 + psub_8 + psub_9 + psub_10 + psub_11 + psub_12 if ///
                    !mi(psub_1) & !mi(psub_2) & !mi(psub_3) & !mi(psub_4) & !mi(psub_5) & !mi(psub_6) & !mi(psub_7) & !mi(psub_8) & !mi(psub_9) & !mi(psub_10) & !mi(psub_11) & !mi(psub_12)
label variable hh`wv'ipens "hh`wv'ipens:w`wv' income:other hhold member pension subsidy income"

drop psub_1-psub_12


** 5.2.4 work compensation
forvalues x=1/12 {
    gen wcomp_`x'= .
    replace wcomp_`x' = 0 if ((mi(a002_`x'_) & mi(a006_`x'_) | mi(za002_`x'_) & mi(za006_`x'_)) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace wcomp_`x'= ga008_4c_`x'_*12 if inrange(ga008_4c_`x'_,0,10000) 
    replace wcomp_`x'= ga008_4b_`x'_ if inrange(ga008_4b_`x'_,0,200000) 
}

gen hh`wv'iworkc = .
replace hh`wv'iworkc = .m if inw`wv' == 1
replace hh`wv'iworkc = wcomp_1 + wcomp_2 + wcomp_3 + wcomp_4 + wcomp_5 + wcomp_6 + wcomp_7 + wcomp_8 + wcomp_9 + wcomp_10 + wcomp_11 + wcomp_12 if ///
                    !mi(wcomp_1) & !mi(wcomp_2) & !mi(wcomp_3) & !mi(wcomp_4) & !mi(wcomp_5) & !mi(wcomp_6) & !mi(wcomp_7) & !mi(wcomp_8) & !mi(wcomp_9) & !mi(wcomp_10) & !mi(wcomp_11) & !mi(wcomp_12)
label variable hh`wv'iworkc "hh`wv'iworkc:w`wv' income:other hhold member workers compensation income"

drop wcomp_1  wcomp_2  wcomp_3  wcomp_4  wcomp_5  wcomp_6  wcomp_7  wcomp_8  wcomp_9  wcomp_10  wcomp_11  wcomp_12


** 5.2.5 elderly family planning
forvalues x=1/12  {
    gen hfsub_`x'=.
    replace hfsub_`x' = 0 if ((mi(a002_`x'_) & mi(a006_`x'_) | mi(za002_`x'_) & mi(za006_`x'_)) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
		replace hfsub_`x'= ga008_5c_`x'_*12 if inrange(ga008_5c_`x'_,0,10000) 
    replace hfsub_`x'= ga008_5b_`x'_ if inrange(ga008_5b_`x'_,0,200000) 
}

gen hh`wv'iefps = .
replace hh`wv'iefps = .m if inw`wv' == 1
replace hh`wv'iefps = hfsub_1 + hfsub_2 + hfsub_3 + hfsub_4 + hfsub_5 + hfsub_6 + hfsub_7 + hfsub_8 + hfsub_9 + hfsub_10 + hfsub_11 + hfsub_12 if ///
                    !mi(hfsub_1) & !mi(hfsub_2) & !mi(hfsub_3) & !mi(hfsub_4) & !mi(hfsub_5) & !mi(hfsub_6) & !mi(hfsub_7) & !mi(hfsub_8) & !mi(hfsub_9) & !mi(hfsub_10) & !mi(hfsub_11) & !mi(hfsub_12)
label variable hh`wv'iefps "hh`wv'iefps:w`wv' income:other hhold member elderly family planning income"

drop hfsub_1 - hfsub_12


** 5.2.6 medical aid
forvalues x=1/12  {
    gen hmed_`x'=.
    replace hmed_`x' = 0 if ((mi(a002_`x'_) & mi(a006_`x'_) | mi(za002_`x'_) & mi(za006_`x'_)) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hmed_`x'= ga008_6c_`x'_*12 if inrange(ga008_6c_`x'_,0,10000)
    replace hmed_`x'= ga008_6b_`x'_ if inrange(ga008_6b_`x'_,0,200000) 
}


gen hh`wv'imed = .
replace hh`wv'imed = .m if inw`wv' == 1
replace hh`wv'imed = hmed_1 + hmed_2 + hmed_3 + hmed_4 + hmed_5 + hmed_6 + hmed_7 + hmed_8 + hmed_9 + hmed_10 + hmed_11 + hmed_12 if ///
                    !mi(hmed_1) & !mi(hmed_2) & !mi(hmed_3) & !mi(hmed_4) & !mi(hmed_5) & !mi(hmed_6) & !mi(hmed_7) & !mi(hmed_8) & !mi(hmed_9) & !mi(hmed_10) & !mi(hmed_11) & !mi(hmed_12)
label variable hh`wv'imed "hh`wv'imed:w`wv' income:other hhold member medical aid income"

drop hmed_1-hmed_12


** 5.2.7 other government subsidy
forvalues x=1/12  {
    gen hgsub_`x'=.
    replace hgsub_`x' = 0 if ((mi(a002_`x'_) & mi(a006_`x'_) | mi(za002_`x'_) & mi(za006_`x'_)) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s8 == 8 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hgsub_`x'= ga008_7c_`x'_*12 if inrange(ga008_7c_`x'_,0,200000)
    replace hgsub_`x'= ga008_7b_`x'_ if inrange(ga008_7b_`x'_,0,200000) 
}

gen hh`wv'igovs = .
replace hh`wv'igovs = .m if inw`wv' == 1
replace hh`wv'igovs = hgsub_1 + hgsub_2 + hgsub_3 + hgsub_4 + hgsub_5 + hgsub_6 + hgsub_7 + hgsub_8 + hgsub_9 + hgsub_10 + hgsub_11 + hgsub_12 if ///
                    !mi(hgsub_1) & !mi(hgsub_2) & !mi(hgsub_3) & !mi(hgsub_4) & !mi(hgsub_5) & !mi(hgsub_6) & !mi(hgsub_7) & !mi(hgsub_8) & !mi(hgsub_9) & !mi(hgsub_10) & !mi(hgsub_11) & !mi(hgsub_12)
label variable hh`wv'igovs "hh`wv'igovs:w`wv' income:other hhold member other goverment income"

drop hgsub_1-hgsub_12

** 5.2.8 social assistance
forvalues x=1/12  {
    gen hass_`x'=.
    replace hass_`x' = 0 if ((mi(a002_`x'_) & mi(a006_`x'_) | mi(za002_`x'_) & mi(za006_`x'_)) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s9 == 9 | ga007_`x'_s10 == 10
    replace hass_`x'= ga008_8c_`x'_*12 if inrange(ga008_8c_`x'_,0,200000)
    replace hass_`x'= ga008_8b_`x'_ if inrange(ga008_8b_`x'_,0,200000) 
}

gen hh`wv'isoca = .
replace hh`wv'isoca = .m if inw`wv' == 1
replace hh`wv'isoca = hass_1 + hass_2 + hass_3 + hass_4 + hass_5 + hass_6 + hass_7 + hass_8 + hass_9 + hass_10 + hass_11 + hass_12 if ///
                    !mi(hass_1) & !mi(hass_2) & !mi(hass_3) & !mi(hass_4) & !mi(hass_5) & !mi(hass_6) & !mi(hass_7) & !mi(hass_8) & !mi(hass_9) & !mi(hass_10) & !mi(hass_11) & !mi(hass_12)
label variable hh`wv'isoca "hh`wv'isoca:w`wv' income:other hhold member social assistance income"

drop hass_1 - hass_12

** 5.2.9 other income- (alimony or child support)
forvalues x=1/12  {
    gen hothers_`x'=.
    replace hothers_`x' = 0 if ((mi(a002_`x'_) & mi(a006_`x'_) | mi(za002_`x'_) & mi(za006_`x'_)) & inw`wv' == 1) | ga007_`x'_s1 == 1 | ga007_`x'_s2 == 2 | ga007_`x'_s3 == 3 | ga007_`x'_s4 == 4 | ga007_`x'_s5 == 5 | ga007_`x'_s6 == 6 | ga007_`x'_s7 == 7 | ga007_`x'_s8 == 8 | ga007_`x'_s10 == 10
    replace hothers_`x'= ga008_9c_`x'_*12 if inrange(ga008_9c_`x'_,0,200000)
    replace hothers_`x'= ga008_9b_`x'_ if inrange(ga008_9b_`x'_,0,200000) 
}

gen hh`wv'iothro = .
replace hh`wv'iothro = .m if inw`wv' == 1
replace hh`wv'iothro = hothers_1 + hothers_2 + hothers_3 + hothers_4 + hothers_5 + hothers_6 + hothers_7 + hothers_8 + hothers_9 + hothers_10 + hothers_11 + hothers_12 if ///
                    !mi(hothers_1) & !mi(hothers_2) & !mi(hothers_3) & !mi(hothers_4) & !mi(hothers_5) & !mi(hothers_6) & !mi(hothers_7) & !mi(hothers_8) & !mi(hothers_9) & !mi(hothers_10) & !mi(hothers_11) & !mi(hothers_12)
label var hh`wv'iothro "hh`wv'iothro:w`wv' income: other hhold member other income (alimony or child support)"

drop hothers_1-hothers_12

******************************************************
*****Total other HHmember Individual-based goverment transfer income
*******************************************************
gen hh`wv'igxfro = .
missing_H hh`wv'iunec hh`wv'ipens hh`wv'iworkc hh`wv'iefps hh`wv'imed hh`wv'igovs hh`wv'isoca, result(hh`wv'igxfro)
replace hh`wv'igxfro = hh`wv'iunec + hh`wv'ipens + hh`wv'iworkc + hh`wv'iefps + hh`wv'imed + hh`wv'igovs + hh`wv'isoca if ///
                    !mi(hh`wv'iunec) & !mi(hh`wv'ipens) & !mi(hh`wv'iworkc) & !mi(hh`wv'iefps) & !mi(hh`wv'imed) & !mi(hh`wv'igovs) & !mi(hh`wv'isoca)
label var hh`wv'igxfro "hh`wv'igxfro:w`wv' income: other hhold member government transfer"

drop hh`wv'iunec  hh`wv'ipens hh`wv'iworkc hh`wv'iefps hh`wv'imed hh`wv'igovs hh`wv'isoca



********************************************************
***************Household Level Income*******************
********************************************************


**********************************************************
*****HH Agricultural income from crop and livestock***
**********************************************************

************************************
***Engaging in agricultural work***
recode gb001 (2=0), gen(gb001_)
egen ansone = rownonmiss (gb002s1 gb002s2 gb002s3 gb002s4 gb002s5 gb002s6 gb002s7 gb002s8 gb002s9 gb002s10 gb002s11 gb002s12 gb002s13 gb002s14)
local n = 1
foreach v in gb002s1 gb002s2 gb002s3 gb002s4 gb002s5 gb002s6 gb002s7 gb002s8 gb002s9 gb002s10 gb002s11 gb002s12 gb002s13 gb002s14 {
    gen `v'_ =.
    replace `v'_ = 0 if ansone >= 1
    replace `v'_ = 1 if `v' == `n'
    local `n++'
}
drop ansone

egen hh`wv'ioagri =rowmax(gb001_ gb002s1_ gb002s2_ gb002s3_ gb002s4_ gb002s5_ gb002s6_ gb002s7_ gb002s8_ gb002s9_ gb002s10_ gb002s11_ gb002s12_ gb002s13_ gb002s14_)
label variable hh`wv'ioagri "hh`wv'ioagri:w`wv' income: engaging in agricultural work "
label value hh`wv'ioagri income

drop gb001_ gb002s1_ gb002s2_ gb002s3_ gb002s4_ gb002s5_ gb002s6_ gb002s7_ gb002s8_ gb002s9_ gb002s10_ gb002s11_ gb002s12_ gb002s13_ gb002s14_
drop hh`wv'ioagri

***Engaging in cropping***
gen hh`wv'iocrop=.
replace hh`wv'iocrop = .m if gb003==. & inw`wv' == 1
replace hh`wv'iocrop = 0  if gb001 == 2 | gb003 == 2
replace hh`wv'iocrop = 1  if gb003 == 1
label variable hh`wv'iocrop "hh`wv'iocrop:w`wv' income: engaging in cropping or forestry"
label value hh`wv'iocrop income

***Value of all crop and forestry product***
gen hh`wv'icrop1=.
replace hh`wv'icrop1 = .m if inw`wv' == 1
replace hh`wv'icrop1 = 0  if hh`wv'iocrop == 0
replace hh`wv'icrop1 = gb005_1 if inrange(gb005_1,0,10000000)
label variable hh`wv'icrop1 "hh`wv'icrop1:w`wv' income: value of cropping or forestry"

***Cost of all crop and forestry product
gen hh`wv'icrop2=.
replace hh`wv'icrop2 = .m if inw`wv' == 1
replace hh`wv'icrop2 =  0 if hh`wv'iocrop == 0
replace hh`wv'icrop2 = gb006 if inrange(gb006,0,10000000)
label variable hh`wv'icrop2 "hh`wv'icrop2:w`wv' income: cost of cropping or forestry"

***Net of all crop and forestry product***
gen hh`wv'icrop =.
missing_H hh`wv'icrop1 hh`wv'icrop2, result(hh`wv'icrop)
replace hh`wv'icrop = hh`wv'icrop1 - hh`wv'icrop2 if !mi(hh`wv'icrop1) & !mi(hh`wv'icrop2)
label variable hh`wv'icrop "hh`wv'icrop:w`wv' income: net value of cropping or forestry"

drop hh`wv'icrop1 hh`wv'icrop2
drop hh`wv'iocrop

**********************************
***Grow any livestock or aquatic
gen hh`wv'iolive=.
replace hh`wv'iolive = .m if gb007 ==. & inw`wv' == 1
replace hh`wv'iolive = 0 if gb001 == 2 | gb007 == 2
replace hh`wv'iolive = 1 if gb007 == 1
label variable hh`wv'iolive "hh`wv'iolive:w`wv' income: growing livestock or aquatic life"
label value hh`wv'iolive income

***Value of any livestock or aquatic***
gen hh`wv'ilive1 =.
replace hh`wv'ilive1 = .m if inw`wv' == 1
replace hh`wv'ilive1 = 0 if gb001 == 2 | gb007 == 2
replace hh`wv'ilive1 = gb011_1 + gb012_1 + gb008 - gb009 if !mi(gb011_1) & !mi(gb012_1) & !mi(gb009) & !mi(gb008)
label variable hh`wv'ilive1 "hh`wv'ilive1:w`wv' income: value of growing livestock or aquatic life and side product"

***Cost of any livestock or aquatic
gen hh`wv'ilive2 =.
replace hh`wv'ilive2 = .m if inw`wv' == 1
replace hh`wv'ilive2 = 0 if gb001 == 2 | gb007 == 2
replace hh`wv'ilive2 = gb010 + gb013 if !mi(gb010) & !mi(gb013)
label variable hh`wv'ilive2 "hh`wv'ilive2:w`wv' income: value of growing livestock or aquatic life and side product"

***Net of any livestock or aquatic***
gen hh`wv'ilive =.
missing_H hh`wv'ilive1 hh`wv'ilive2, result(hh`wv'ilive)
replace hh`wv'ilive = hh`wv'ilive1 - hh`wv'ilive2 if !mi(hh`wv'ilive1) & !mi(hh`wv'ilive2)
label variable hh`wv'ilive "hh`wv'ilive:w`wv' income: net value of growing livestock or aquatic life and side product"

drop hh`wv'ilive1 hh`wv'ilive2
drop hh`wv'iolive

******************************************************************
**** Total Net Agricultural income from crop and livestock********
gen hh`wv'iagri = .
missing_H hh`wv'icrop hh`wv'ilive, result(hh`wv'iagri)
replace hh`wv'iagri = hh`wv'icrop + hh`wv'ilive if !mi(hh`wv'icrop) & !mi(hh`wv'ilive)
label variable hh`wv'iagri "hh`wv'iagri:w`wv' income: hhold net agricultural income"

drop hh`wv'icrop hh`wv'ilive

******************************************************
****non-agricultural income household level**********
******************************************************

********************************
***HH Self-employed activities*****
********************************
gen hh`wv'iosemp =.
replace hh`wv'iosemp =.m if gc001 ==. & inw`wv' == 1
replace hh`wv'iosemp = 0 if gc001 == 2
replace hh`wv'iosemp = 1 if gc001 == 1
label variable hh`wv'iosemp "hh`wv'iosemp:w`wv' income: self-employed activities"
label value hh`wv'iosemp income

***Value of self-employed activities***
***Total household income from self-employed activities********
gen hh`wv'isemp =.
missing_c_w1 gc001 gc002 gc005_1_ gc005_2_ gc005_3_ gc005_4_, result(hh`wv'isemp)
replace hh`wv'isemp = .m if inw`wv' == 1
replace hh`wv'isemp = 0 if hh`wv'iosemp == 0 | gc002 == 0
replace hh`wv'isemp = gc005_1_ if gc002 == 1 & !mi(gc005_1_)
replace hh`wv'isemp = gc005_1_ + gc005_2_ if gc002 == 2 & !mi(gc005_1_) & !mi(gc005_2_)
replace hh`wv'isemp = gc005_1_ + gc005_2_ + gc005_3_ if gc002 == 3 & !mi(gc005_1_) & !mi(gc005_2_) & !mi(gc005_3_)
replace hh`wv'isemp = gc005_1_ + gc005_2_ + gc005_3_ + gc005_4_ if gc002 == 4 & !mi(gc005_1_) & !mi(gc005_2_) & !mi(gc005_3_) & !mi(gc005_4_)
label variable hh`wv'isemp "hh`wv'isemp:w`wv' income: hhold self-employed activities"

drop hh`wv'iosemp

*****************************************************************
*******HH Goverment Transfer income      ************************
*****************************************************************

******income from government subsides*****
***Dibao assistance***
*not availiable
*label variable hh`wv'iodiabo "hh`wv'iodiabo_c:w`wv' income: receiving Dibao assistance "
*label value hh`wv'iodiabo income

***value of Dibao
gen hh`wv'idibao=.
replace hh`wv'idibao = .m if inw`wv' == 1
replace hh`wv'idibao = gd001 if inrange(gd001,0,100000)
label variable hh`wv'idibao "hh`wv'idibao:w`wv' income: amount of Dibao assistance"

***having reforestation
gen hh`wv'iorefo=.
replace hh`wv'iorefo =.m if gd002s1 ==. & inw`wv' == 1
replace hh`wv'iorefo = 0 if gd002s2 == 2 | gd002s3 == 3 | gd002s4 == 4 | gd002s5 == 5 | gd002s6 == 6 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'iorefo = 1 if gd002s1 == 1
label variable hh`wv'iorefo "hh`wv'iorefo:w`wv' income: receiving government subsidies in reforestation"
label value hh`wv'iorefo income

***Value of reforestation
gen hh`wv'irefo=.
replace hh`wv'irefo = .m if inw`wv' == 1
replace hh`wv'irefo = 0 if hh`wv'iorefo == 0
replace hh`wv'irefo = gd002_1 if inrange(gd002_1,0,999999)
label variable hh`wv'irefo "hh`wv'irefo:w`wv' income: amount government subsidies in reforestation"

drop hh`wv'iorefo
***having agriculture subsidy
gen hh`wv'ioagris=.
replace hh`wv'ioagris =.m if gd002s2==. & inw`wv' == 1
replace hh`wv'ioagris = 0 if gd002s1 == 1 | gd002s3 == 3 | gd002s4 == 4 | gd002s5 == 5 | gd002s6 == 6 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'ioagris = 1 if gd002s2==2
label variable hh`wv'ioagris "hh`wv'ioagris:w`wv' income: receiving government subsidies in agricultural work"
label value hh`wv'ioagris income

***Value of agriculture subsidy
gen hh`wv'iagris=.
replace hh`wv'iagris = .m if inw`wv' == 1
replace hh`wv'iagris = 0 if hh`wv'ioagris == 0
replace hh`wv'iagris = gd002_2 if inrange(gd002_2,0,9999999)
label variable hh`wv'iagris "hh`wv'iagris:w`wv' income: amount government subsidies in agricultural work"

drop hh`wv'ioagris

***having Wubaohu
gen hh`wv'iowuba=.
replace hh`wv'iowuba =.m if gd002s3 ==. & inw`wv' == 1
replace hh`wv'iowuba = 0 if gd002s1 == 1 | gd002s2 == 2 | gd002s4 == 4 | gd002s5 == 5 | gd002s6 == 6 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'iowuba = 1 if gd002s3 == 3
label variable hh`wv'iowuba "hh`wv'iowuba:w`wv' income: receiving government subsidies in Wubaohu"
label value hh`wv'iowuba income


***Value of Wubaohu
gen hh`wv'iwuba=.
replace hh`wv'iwuba = .m if inw`wv' == 1
replace hh`wv'iwuba = 0 if hh`wv'iowuba == 0
replace hh`wv'iwuba = gd002_3 if inrange(gd002_3,0,9999999)
label variable hh`wv'iwuba "hh`wv'iwuba:w`wv' income: amount government subsidies in Wubaohu"

drop hh`wv'iowuba

***having Tekunhu
gen hh`wv'ioteku=.
replace hh`wv'ioteku =.m if gd002s4==. & inw`wv' == 1
replace hh`wv'ioteku = 0 if gd002s1 == 1 | gd002s2 == 2 | gd002s3 == 3 | gd002s5 == 5 | gd002s6 == 6 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'ioteku = 1 if gd002s4 == 4
label variable hh`wv'ioteku "hh`wv'ioteku:w`wv' income: receiving government subsidies in Tekunhu"
label value hh`wv'ioteku income

***Value of Tekunhu 
gen hh`wv'iteku=. 
replace hh`wv'iteku = .m if inw`wv' == 1
replace hh`wv'iteku = 0 if hh`wv'ioteku == 0
replace hh`wv'iteku = gd002_4 if inrange(gd002_4,0,9999999) 
label variable hh`wv'iteku "hh`wv'iteku:w`wv' income: amount government subsidies in Tekunhu"

drop hh`wv'ioteku

***having work injury
gen hh`wv'iowinju=.
replace hh`wv'iowinju =.m if gd002s5 ==. & inw`wv' == 1
replace hh`wv'iowinju = 0 if gd002s1 == 1 | gd002s2 == 2 | gd002s3 == 3 | gd002s4 == 4 | gd002s6 == 6 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'iowinju = 1 if gd002s5 == 5
label variable hh`wv'iowinju "hh`wv'iowinju:w`wv' income: receiving government subsidies in work injury"
label value hh`wv'iowinju income

***Value of work injury 
gen hh`wv'iwinju=.
replace hh`wv'iwinju = .m if inw`wv' == 1
replace hh`wv'iwinju = 0 if hh`wv'iowinju == 0
replace hh`wv'iwinju = gd002_5 if inrange(gd002_5,0,9999999)
label variable hh`wv'iwinju "hh`wv'iwinju:w`wv' income: amount government subsidies in work injury"

drop hh`wv'iowinju

***having emergency or disaster relief
gen hh`wv'ioreli=.
replace hh`wv'ioreli =.m if gd002s6 ==. & inw`wv' == 1
replace hh`wv'ioreli = 0 if gd002s1 == 1 | gd002s2 == 2 | gd002s3 == 3 | gd002s4 == 4 | gd002s5 == 5 | gd002s7 == 7 | gd002s8 == 8 
replace hh`wv'ioreli = 1 if gd002s6 == 6
label variable hh`wv'ioreli "hh`wv'ioreli:w`wv' income: receiving government subsidies in emergency or disaster relief"
label value hh`wv'ioreli income


***Value of emergency or disaster relief 
gen hh`wv'ireli=.
replace hh`wv'ireli = .m if inw`wv' == 1
replace hh`wv'ireli = 0 if hh`wv'ioreli == 0
replace hh`wv'ireli = gd002_6 if inrange(gd002_6,0,9999999)
label variable hh`wv'ireli "hh`wv'ireli:w`wv' income: amount government subsidies in emergency or disaster relief"

drop hh`wv'ioreli

***having other subsidies
gen hh`wv'iogothe=.
replace hh`wv'iogothe =.m if gd002s7 ==. & inw`wv' == 1
replace hh`wv'iogothe = 0 if gd002s1 == 1 | gd002s2 == 2 | gd002s3 == 3 | gd002s4 == 4 | gd002s5 == 5 | gd002s6 == 6 | gd002s8 == 8 
replace hh`wv'iogothe = 1 if gd002s7 == 7
label variable hh`wv'iogothe "hh`wv'iogothe:w`wv' income: receiving other government subsidies"
label value hh`wv'iogothe income

***Value of other subsidies 
gen hh`wv'igothe=.
replace hh`wv'igothe = .m if inw`wv' == 1
replace hh`wv'igothe = 0 if hh`wv'iogothe == 0
replace hh`wv'igothe = gd002_7 if inrange(gd002_7,0,100000) 
label variable hh`wv'igothe "hh`wv'igothe:w`wv' income: amount in other government subsidies"

drop hh`wv'iogothe

****************************************************************************************
********************Total goverment Transfer Income ************************
gen hh`wv'igxfrh = .
missing_H hh`wv'idibao hh`wv'irefo hh`wv'iagris hh`wv'iwuba hh`wv'iteku hh`wv'iwinju hh`wv'ireli hh`wv'igothe, result(hh`wv'igxfrh)
replace hh`wv'igxfrh = hh`wv'idibao + hh`wv'irefo + hh`wv'iagris + hh`wv'iwuba + hh`wv'iteku + hh`wv'iwinju + hh`wv'ireli + hh`wv'igothe if ///
                    !mi(hh`wv'idibao) & !mi(hh`wv'irefo) & !mi(hh`wv'iagris) & !mi(hh`wv'iwuba) & !mi(hh`wv'iteku) & !mi(hh`wv'iwinju) & !mi(hh`wv'ireli) & !mi(hh`wv'igothe)
label variable hh`wv'igxfrh "hh`wv'igxfrh:w`wv' income: hhold other government transfer income"

drop hh`wv'idibao hh`wv'irefo hh`wv'iagris hh`wv'iwuba hh`wv'iteku hh`wv'iwinju hh`wv'ireli hh`wv'igothe

***************************************
******Other public transfer income ********************
***************************************

***************************************
*****related to donation
***having donation***
gen hh`wv'iodona=.
replace hh`wv'iodona =.m if gd003s1 ==. & inw`wv' == 1
replace hh`wv'iodona = 0 if gd003s2 == 2 | gd003s3 == 3 | gd003s4 == 4 
replace hh`wv'iodona = 1 if gd003s1 == 1
label variable hh`wv'iodona "hh`wv'iodona:w`wv' income: receiving donation from the society"
label value hh`wv'iodona income

***Value of donation***
gen hh`wv'idona=.
replace hh`wv'idona = .m if inw`wv' == 1
replace hh`wv'idona = 0 if hh`wv'iodona == 0
replace hh`wv'idona = gd003_1 if inrange(gd003_1,0,100000000) 
label variable hh`wv'idona "hh`wv'idona:w`wv' income: amount of receiving donation from the society"
drop hh`wv'iodona

***having compensation for land seizure***
gen hh`wv'iolands=.
replace hh`wv'iolands = .m if gd003s2 ==. & inw`wv' == 1
replace hh`wv'iolands = 0 if gd003s1 == 1 | gd003s3 == 3 | gd003s4 == 4 
replace hh`wv'iolands = 1 if gd003s2 == 2
label variable hh`wv'iolands "hh`wv'iolands:w`wv' income: receiving compensation for land seizure"
label value hh`wv'iolands income

***Value of compensation for land seizure***
gen hh`wv'ilands=.
replace hh`wv'iland = .m if inw`wv' == 1
replace hh`wv'iland = 0 if hh`wv'ioland == 0
replace hh`wv'iland = gd003_2 if inrange(gd003_2,0,10000000)
label variable hh`wv'ilands "hh`wv'ilands:w`wv' income: amount of receiving compensation for land seizure"

drop hh`wv'iolands

***having house compensation ***
gen hh`wv'iopull=.
replace hh`wv'iopull =.m if gd003s3 ==. & inw`wv' == 1
replace hh`wv'iopull = 0 if gd003s1 == 1 | gd003s2 == 2 | gd003s4 == 4 
replace hh`wv'iopull = 1 if gd003s3 == 3
label variable hh`wv'iopull "hh`wv'iopull:w`wv' income: receiving compensation for pulling down house or apartment"
label value hh`wv'iopull income


***Value of pulling***
gen hh`wv'ipull=.
replace hh`wv'ipull = .m if inw`wv' == 1
replace hh`wv'ipull = 0 if hh`wv'iopull == 0
replace hh`wv'ipull = gd003_3 if inrange(gd003_3,0,20000000) 
label variable hh`wv'ipull "hh`wv'ipull:w`wv' income: amount of receiving compensation for pulling down house or apartment"


***********************************************************************
********************Total other Income ********************************
gen hh`wv'igxfrt = .
missing_H hh`wv'idona hh`wv'ilands hh`wv'ipull, result(hh`wv'igxfrt)
replace hh`wv'igxfrt = hh`wv'idona + hh`wv'ilands + hh`wv'ipull if !mi(hh`wv'idona) & !mi(hh`wv'ilands) & !mi(hh`wv'ipull)
label variable hh`wv'igxfrt "hh`wv'igxfrt:w`wv' income: hhold other public transfer income"

drop hh`wv'idona hh`wv'ilands hh`wv'ipull hh`wv'iopull

****************************************
**************Capital Income************
****************************************

** household housing rental income 
gen h`wv'iorent=.
replace h`wv'iorent =.m if ha052 ==. & inw`wv' == 1
replace h`wv'iorent = 0 if ha027 == 2 | ha052 == 2
replace h`wv'iorent = 1 if ha052 == 1 
label variable h`wv'iorent "h`wv'iorent:w`wv' income: cpl having rental income"
label value h`wv'iorent income


***Value of rental income***
gen h`wv'irent=.
replace h`wv'irent = .m if inw`wv' == 1 
replace h`wv'irent = 0 if h`wv'iorent== 0
replace h`wv'irent = ha052_1 * 12 if inrange(ha052_1,0,99999)
label variable h`wv'irent "h`wv'irent:w`wv' income: cpl amount of rental income annually"

drop h`wv'iorent

*****************************
****monthly Rental income by other household members***
gen hh`wv'iorento=.
replace hh`wv'iorento =.m if ha053==. & inw`wv' == 1
replace hh`wv'iorento = 0 if ha027 == 2 | ha053 == 2
replace hh`wv'iorento = 1 if ha053 == 1 
label variable hh`wv'iorento "hh`wv'iorento:w`wv' income: othr hh mems having rental income"
label value hh`wv'iorento income

***Value of rental income by other household members***
gen hh`wv'irento=.  
replace hh`wv'irento = .m if inw`wv' == 1
replace hh`wv'irento = 0 if hh`wv'iorento == 0
replace hh`wv'irento = ha053_1*12 if inrange(ha053_1,0,10000) & ha053 == 1 
label variable hh`wv'irento "hh`wv'irento:w`wv' income: othr hh mems amount of rental income annually"

drop  hh`wv'iorento

********************
****income from land
****first type of land:cultivated land
gen hh`wv'ioclan=.
replace hh`wv'ioclan =.m if ha054s1 ==. & inw`wv' == 1 
replace hh`wv'ioclan = 0 if ha054s2 == 2 | ha054s3 == 3 | ha054s4 == 4 | ha054s5 == 5 | ha058_1_ == 2
replace hh`wv'ioclan = 1 if ha058_1_ == 1
label variable hh`wv'ioclan "hh`wv'ioclan:w`wv' income: having cultivated land"
label value hh`wv'ioclan income


***Value of cultivated land***
gen hh`wv'iclan=.
replace hh`wv'iclan = .m if inw`wv' == 1
replace hh`wv'iclan = 0 if hh`wv'ioclan == 0 
replace hh`wv'iclan = 0 if inlist(ha060_1_,-180,-200)
replace hh`wv'iclan = ha060_1_ if inrange(ha060_1_,0,100000)
label variable hh`wv'iclan "hh`wv'iclan:w`wv' income: amount of income receive from cultivated land"

drop hh`wv'ioclan

****second type of land:forest
****income from forest
gen hh`wv'iofore=.
replace hh`wv'iofore =.m if ha054s2 ==.  & inw`wv' == 1  
replace hh`wv'iofore = 0 if ha054s1 == 1 | ha054s3 == 3 | ha054s4 == 4 | ha054s5 == 5 | ha058_2_ == 2
replace hh`wv'iofore = 1 if ha058_2_ == 1  
label variable hh`wv'iofore "hh`wv'iofore:w`wv' income: having forest land"
label value hh`wv'iofore income

***Value of forest land***
gen hh`wv'ifore=.
replace hh`wv'ifore = .m if inw`wv' == 1
replace hh`wv'ifore = 0 if hh`wv'iofore == 0 
replace hh`wv'ifore = ha060_2_ if inrange(ha060_2_,0,100000)
label variable hh`wv'ifore "hh`wv'ifore:w`wv' income: amount of income receive from forest land"

drop hh`wv'iofore

****third type of land
****income from pasture
gen hh`wv'iopast=.
replace hh`wv'iopast =.m if ha054s3 ==. & inw`wv' == 1
replace hh`wv'iopast = 0 if ha054s1 == 1 | ha054s2 == 2 | ha054s4 == 4 | ha054s5 == 5 | ha058_3_ == 2
replace hh`wv'iopast = 1 if ha058_3_ == 1
label variable hh`wv'iopast "hh`wv'iopast:w`wv' income: having a pasture"
label value hh`wv'iopast income

***Value of pasture land***
gen hh`wv'ipast=.
replace hh`wv'ipast = .m if inw`wv' == 1
replace hh`wv'ipast = 0 if hh`wv'iopast == 0 
replace hh`wv'ipast = ha060_3_ if inrange(ha060_3_,0,100000)
label variable hh`wv'ipast "hh`wv'ipast:w`wv' income: amount of income receive from pasture"

drop hh`wv'iopast

***fourth type of land
****income from pond
gen hh`wv'iopond=.
replace hh`wv'iopond =.m if ha054s4 ==. & inw`wv' == 1 
replace hh`wv'iopond = 0 if ha054s1 == 1 | ha054s2 == 2 | ha054s3 == 3 | ha054s5 == 5 | ha058_4_ == 2
replace hh`wv'iopond = 1 if ha058_4_ == 1  
label variable hh`wv'iopond "hh`wv'iopond:w`wv' income: having a pond"
label value hh`wv'iopond income

***Value of pond***
gen hh`wv'ipond=.
replace hh`wv'ipond = .m if inw`wv' == 1
replace hh`wv'ipond = 0 if hh`wv'iopond == 0 
replace hh`wv'ipond = ha060_4_ if inrange(ha060_4_,0,100000)
label variable hh`wv'ipond "hh`wv'ipond:w`wv' income: amount of income receive from pond"

drop hh`wv'iopond

*******************************
***TOTAL household land rent***
gen hh`wv'iland = .
missing_H hh`wv'iclan hh`wv'ifore hh`wv'ipast hh`wv'ipond, result(hh`wv'iland)
replace hh`wv'iland = hh`wv'iclan + hh`wv'ifore + hh`wv'ipast + hh`wv'ipond if ///
                    !mi(hh`wv'iclan) & !mi(hh`wv'ifore) & !mi(hh`wv'ipast) & !mi(hh`wv'ipond)
label variable hh`wv'iland "hh`wv'iland:w`wv' income: total amount of income receive from land"

drop hh`wv'iclan hh`wv'ifore hh`wv'ipast hh`wv'ipond

*************************************
****Other capital asset income*******
*************************************

**Income not from land and housing***
gen hh`wv'ioasst=. 
replace hh`wv'ioasst = .m if inw`wv' == 1
replace hh`wv'ioasst = 0 if ha064 == 2 
replace hh`wv'ioasst = 1 if ha064 == 1  
label variable hh`wv'ioasst "hh`wv'ioasst:w`wv' income: having other income from assets"
label value hh`wv'ioasst income

***Value of asst***
gen hh`wv'ioast=.
replace hh`wv'ioast = .m if inw`wv' == 1
replace hh`wv'ioast = 0 if hh`wv'ioasst == 0 
replace hh`wv'ioast = ha064_1 if inrange(ha064_1,0,9999999)
label variable hh`wv'ioast "hh`wv'ioast:w`wv' income: amount of income receive from other assets"

*Income value from interest
gen hh`wv'ioitrest=. 
replace hh`wv'ioitrest = .m if inw`wv' == 1
replace hh`wv'ioitrest = 0 if ha069 == 2 
replace hh`wv'ioitrest = 1 if ha069 == 1  
label variable hh`wv'ioitrest "hh`wv'ioitrest:w`wv' income: having other income from interest"
label value hh`wv'ioitrest income

***Value of asst***
gen hh`wv'iitrest=.
replace hh`wv'iitrest = .m if inw`wv' == 1
replace hh`wv'iitrest = 0 if hh`wv'ioitrest == 0
replace hh`wv'iitrest = ha071 if inrange(ha071,0,4000000)
label variable hh`wv'iitrest "hh`wv'iitrest:w`wv' income: amount of income receive from interest"

drop hh`wv'ioasst hh`wv'ioitrest

*****************************************************
*******total household capital income**********
gen hh`wv'icaph = .
missing_H h`wv'irent hh`wv'irento hh`wv'iland hh`wv'ioast hh`wv'iitrest, result(hh`wv'icaph)
replace hh`wv'icaph = h`wv'irent + hh`wv'irento + hh`wv'iland + hh`wv'ioast + hh`wv'iitrest if ///
                    !mi(h`wv'irent) & !mi(hh`wv'irento) & !mi(hh`wv'iland) & !mi(hh`wv'ioast) & !mi(hh`wv'iitrest)
label variable hh`wv'icaph "hh`wv'icaph:w`wv' income: hhold other capital income"

drop h`wv'irent hh`wv'irento hh`wv'iland hh`wv'ioast hh`wv'iitrest

**********************************************
****calculate total household income ***
gen hh`wv'iearn = .
missing_H hh`wv'iagri hh`wv'isemp hh`wv'iwageo h`wv'iearn h`wv'isemp h`wv'ifring, result(hh`wv'iearn)
replace hh`wv'iearn = .b if h`wv'iearn == .b | h`wv'isemp == .b | h`wv'ifring == .b
replace hh`wv'iearn = hh`wv'iagri + hh`wv'isemp + hh`wv'iwageo + h`wv'iearn + h`wv'isemp + h`wv'ifring if ///
                  !mi(hh`wv'iagri) & !mi(hh`wv'isemp) & !mi(hh`wv'iwageo) & !mi(h`wv'iearn) & !mi(h`wv'isemp) & !mi(h`wv'ifring)
label variable hh`wv'iearn "hh`wv'iearn:w`wv' income: hhold total earnings"

gen hh`wv'ipen =.
missing_H h`wv'ipen hh`wv'ipeno, result(hh`wv'ipen)
replace hh`wv'ipen = .b if h`wv'ipen == .b
replace hh`wv'ipen = h`wv'ipen + hh`wv'ipeno if !mi(h`wv'ipen) & !mi(hh`wv'ipeno)
label variable hh`wv'ipen "hh`wv'ipen:w`wv' income: hhold total pension income "

gen hh`wv'igxfr = .
missing_H h`wv'igxfr hh`wv'igxfro hh`wv'igxfrh hh`wv'igxfrt, result(hh`wv'igxfr)
replace hh`wv'igxfr = .b if h`wv'igxfr == .b
replace hh`wv'igxfr = h`wv'igxfr + hh`wv'igxfro + hh`wv'igxfrh + hh`wv'igxfrt if ///
                   !mi(h`wv'igxfr) & !mi(hh`wv'igxfro) & !mi(hh`wv'igxfrh) & !mi(hh`wv'igxfrt)
label variable hh`wv'igxfr "hh`wv'igxfr:w`wv' income: hhold total government transfers "

gen hh`wv'iothr =.
missing_H  h`wv'iothr hh`wv'iothro, result(hh`wv'iothr)
replace hh`wv'iothr = .b if h`wv'iothr == .b
replace hh`wv'iothr = h`wv'iothr + hh`wv'iothro if !mi(h`wv'iothr) & !mi(hh`wv'iothro)
label variable hh`wv'iothr "hh`wv'iothrr:w`wv' income: hhold other household income"

gen hh`wv'icap =.
missing_H h`wv'icap hh`wv'icaph, result(hh`wv'icap)
replace hh`wv'icap = .b if h`wv'icap == .b
replace hh`wv'icap = h`wv'icap + hh`wv'icaph if !mi(h`wv'icap) & !mi(hh`wv'icaph)
label variable hh`wv'icap "hh`wv'icap:w`wv' income: hhold total capital income"

*****************************************************************
***TOTAL HH INCOME (HH MEMBER + R+S)  ***************************
*****************************************************************
gen hh`wv'itot = .
missing_H hh`wv'iearn hh`wv'ipen hh`wv'igxfr hh`wv'iothr hh`wv'icap, result(hh`wv'itot)
replace hh`wv'itot = .b if hh`wv'iearn == .b | hh`wv'ipen == .b | hh`wv'igxfr == .b | hh`wv'iothr == .b | hh`wv'icap == .b
replace hh`wv'itot = hh`wv'iearn + hh`wv'ipen + hh`wv'igxfr + hh`wv'iothr + hh`wv'icap if ///
                    !mi(hh`wv'iearn) & !mi(hh`wv'ipen) & !mi(hh`wv'igxfr) & !mi(hh`wv'iothr) & !mi(hh`wv'icap)
label variable hh`wv'itot "hh`wv'itot:w`wv' income: hhold total household income" 

**************************************************************************************************

*****************************************************************
***********                                      ****************
*********** EXPENDITURE MODULE **********************************
*********************************************************************

* ***********************************
* ****                          *****
* ****  HOUSEHODLE EXPENDITURE  *****
* ****                          *****
* ***********************************
* *==1. Food expenditure==*

* 1.1 Last week buy food, outdinning, alcohol, cigars, cigarettes and tobacco
gen hh`wv'cbfood=.
replace hh`wv'cbfood = .m if inw`wv' == 1
replace hh`wv'cbfood = ge006 if inrange(ge006,0,200000) 

gen hh`wv'cgfood=.
replace hh`wv'cgfood = .m if inw`wv' == 1
replace hh`wv'cgfood = 0 if ge006_w2==2
replace hh`wv'cgfood = ge006_w2_1 if inrange(ge006_w2_1,0,200000) 
*2 people answer no but report value

gen hh`wv'codinn=.
replace hh`wv'codinn = .m if inw`wv' == 1
replace hh`wv'codinn = ge007 if inrange(ge007,0,200000)

gen hh`wv'cacct=.
replace hh`wv'cacct = .m if inw`wv' == 1
replace hh`wv'cacct = ge008 if inrange(ge008,0,200000)

*****==========================******
**total household food consumption****
*****==========================*******
gen hh`wv'cfood =.
missing_H hh`wv'cbfood hh`wv'cgfood hh`wv'codinn hh`wv'cacct, result(hh`wv'cfood)
replace hh`wv'cfood = hh`wv'cbfood + hh`wv'cgfood + hh`wv'codinn + hh`wv'cacct if ///
                    !mi(hh`wv'cbfood) & !mi(hh`wv'cgfood) & !mi(hh`wv'codinn) & !mi(hh`wv'cacct)
label variable hh`wv'cfood "hh`wv'cfood:w`wv' hhold food consumption, past 7 days"

drop hh`wv'cbfood hh`wv'codinn hh`wv'cacct hh`wv'cgfood


****===========================******
****Number of people at the household*****

gen hh`wv'cnump=.
replace hh`wv'cnump = .m if inw`wv' == 1
replace hh`wv'cnump = ge004 if inrange(ge004,0,100)
label variable hh`wv'cnump "hh`wv'cnump:w`wv' number of people having meal at the household "

* *==2. non-food daily expenditure fees monthly report== 
gen hh`wv'ccomu=. 
replace hh`wv'ccomu = .m if inw`wv' == 1
replace hh`wv'ccomu =.d if inlist(ge009_1,9999,999)
replace hh`wv'ccomu = ge009_1 if inrange(ge009_1,0,1000000) & !inlist(ge009_1,9999,999)

gen hh`wv'cutil=.
replace hh`wv'cutil = .m if inw`wv' == 1
replace hh`wv'cutil =.d if inlist(ge009_2,9999,999)
replace hh`wv'cutil = ge009_2 if inrange(ge009_2,0,1000000) & !inlist(ge009_2,9999,999)

gen hh`wv'cfuel=.
replace hh`wv'cfuel = .m if inw`wv' == 1
replace hh`wv'cfuel =.d if inlist(ge009_3,9999,999)
replace hh`wv'cfuel = ge009_3 if inrange(ge009_3,0,1000000) & !inlist(ge009_3,9999,999)

gen hh`wv'cserv=.
replace hh`wv'cserv = .m if inw`wv' == 1
replace hh`wv'cserv =.d if inlist(ge009_4,9999,999)
replace hh`wv'cserv = ge009_4 if inrange(ge009_4,0,100000) & !inlist(ge009_4,9999,999)

gen hh`wv'ctran=.
replace hh`wv'ctran = .m if inw`wv' == 1
replace hh`wv'ctran =.d if ge009_5 == 9999
replace hh`wv'ctran = ge009_5 if inrange(ge009_5,0,100000) & ge009_5 != 9999

gen hh`wv'cday=.
replace hh`wv'cday = .m if inw`wv' == 1
replace hh`wv'cday =.d if inlist(ge009_6,9999,999)
replace hh`wv'cday = ge009_6 if inrange(ge009_6,0,9998) & ge009_6 ! = 999

gen hh`wv'centa=.
replace hh`wv'centa = .m if inw`wv' == 1
replace hh`wv'centa =.d if ge009_7==9999
replace hh`wv'centa = ge009_7 if inrange(ge009_7,0,9998)

**********************************
******Total non food expediture***
**********************************
gen hh`wv'cnf1m =.
missing_H hh`wv'ccomu hh`wv'cutil hh`wv'cfuel hh`wv'cserv hh`wv'ctran hh`wv'cday hh`wv'centa, result(hh`wv'cnf1m)
replace hh`wv'cnf1m = hh`wv'ccomu + hh`wv'cutil + hh`wv'cfuel + hh`wv'cserv + hh`wv'ctran + hh`wv'cday + hh`wv'centa if ///
                    !mi(hh`wv'ccomu) & !mi(hh`wv'cutil) & !mi(hh`wv'cfuel) & !mi(hh`wv'cserv) & !mi(hh`wv'ctran) & !mi(hh`wv'cday) & !mi(hh`wv'centa)
label variable hh`wv'cnf1m "hh`wv'cnf1m:w`wv' hhold non-food consumption, last month" 

drop hh`wv'ccomu hh`wv'cutil hh`wv'cfuel hh`wv'cserv hh`wv'ctran hh`wv'cday hh`wv'centa

* ==3. non-food expenditure==*
** Notes: exclude durable purchases (cars, appliances, electronics) and taxes

gen hh`wv'cbedd =.
replace hh`wv'cbedd = .m if inw`wv' == 1
replace hh`wv'cbedd = ge010_1 if inrange(ge010_1,0,9999999)

gen hh`wv'ctravel =.
replace hh`wv'ctravel = .m if inw`wv' == 1
replace hh`wv'ctravel = ge010_2 if inrange(ge010_2,0,999999)

gen hh`wv'cheat =.
replace hh`wv'cheat = .m if inw`wv' == 1
replace hh`wv'cheat = ge010_3 if inrange(ge010_3,0,999999)

gen hh`wv'cfurn =.
replace hh`wv'cfurn = .m if inw`wv' == 1
replace hh`wv'cfurn = ge010_4 if inrange(ge010_4,0,999999)

gen hh`wv'ceduc =.
replace hh`wv'ceduc = .m if inw`wv' == 1
replace hh`wv'ceduc = ge010_5 if inrange(ge010_5,0,999999)

gen hh`wv'cmedi =. 
replace hh`wv'cmedi = .m if inw`wv' == 1
replace hh`wv'cmedi = ge010_6 if inrange(ge010_6,0,9999999)

gen hh`wv'cfit =.
replace hh`wv'cfit = .m if inw`wv' == 1
replace hh`wv'cfit = ge010_7 if inrange(ge010_7,0,9999999)

gen hh`wv'cbeau =.
replace hh`wv'cbeau = .m if inw`wv' == 1
replace hh`wv'cbeau = ge010_8 if inrange(ge010_8,0,9999999)

gen hh`wv'cauto=.
replace hh`wv'cauto = .m if inw`wv' == 1
replace hh`wv'cauto = ge010_9 if inrange(ge010_9,0,9999999)

gen hh`wv'crepa =.
replace hh`wv'crepa = .m if inw`wv' == 1
replace hh`wv'crepa = ge010_10 if inrange(ge010_10,0,9999999)

gen hh`wv'cprop =.
replace hh`wv'cprop = .m if inw`wv' == 1
replace hh`wv'cprop = ge010_11 if inrange(ge010_11,0,9999999)

gen hh`wv'ctax =.
replace hh`wv'ctax = .m if inw`wv' == 1
replace hh`wv'ctax = ge010_12 if inrange(ge010_12,0,9999999)

gen hh`wv'cdona=.
replace hh`wv'cdona = .m if inw`wv' == 1
replace hh`wv'cdona = ge010_13 if inrange(ge010_13,0,9999999)


**********************************
******Total non food expediture***
**********************************
gen hh`wv'cnf1y =.
missing_H hh`wv'cbedd hh`wv'ctravel hh`wv'cheat hh`wv'cfit hh`wv'cbeau hh`wv'crepa hh`wv'ceduc hh`wv'cmedi hh`wv'cprop hh`wv'cdona hh`wv'cfurn hh`wv'ctax hh`wv'cauto, result(hh`wv'cnf1y)
replace hh`wv'cnf1y = hh`wv'cbedd + hh`wv'ctravel + hh`wv'cheat + hh`wv'cfit + hh`wv'cbeau + hh`wv'crepa + hh`wv'ceduc + hh`wv'cmedi + hh`wv'cprop + hh`wv'cdona + hh`wv'cfurn + hh`wv'ctax + hh`wv'cauto if ///
                !mi(hh`wv'cbedd) & !mi(hh`wv'ctravel) & !mi(hh`wv'cheat) & !mi(hh`wv'cfit) & !mi(hh`wv'cbeau) & !mi(hh`wv'crepa) & !mi(hh`wv'ceduc) & !mi(hh`wv'cmedi) & !mi(hh`wv'cprop) & !mi(hh`wv'cdona) & !mi(hh`wv'cfurn) & !mi(hh`wv'ctax) & !mi(hh`wv'cauto)
label variable hh`wv'cnf1y "hh`wv'cnf1y:w`wv' hhold other non-food consumption, past year" 

drop hh`wv'cbedd hh`wv'ctravel hh`wv'cheat hh`wv'cfit hh`wv'cbeau hh`wv'crepa hh`wv'ceduc hh`wv'cmedi hh`wv'cprop hh`wv'cdona hh`wv'cfurn hh`wv'ctax hh`wv'cauto 

* ===total household expenditure===****
***make all the consumption to annual***
gen hh`wv'cfooda =.
missing_H hh`wv'cfood, result(hh`wv'cfooda)
replace hh`wv'cfooda = hh`wv'cfood*52 if !mi(hh`wv'cfood)

gen hh`wv'cnf1ma =.
missing_H hh`wv'cnf1m, result(hh`wv'cnf1ma)
replace hh`wv'cnf1ma = hh`wv'cnf1m*12 if !mi(hh`wv'cnf1m)

gen hh`wv'ctot =.
missing_H hh`wv'cfooda hh`wv'cnf1ma hh`wv'cnf1y, result(hh`wv'ctot)
replace hh`wv'ctot = hh`wv'cfooda + hh`wv'cnf1ma + hh`wv'cnf1y if ///
                !mi(hh`wv'cfooda) & !mi(hh`wv'cnf1ma) & !mi(hh`wv'cnf1y)
label variable hh`wv'ctot "hh`wv'ctot:w`wv' total household consumption"

drop hh`wv'cfooda hh`wv'cnf1ma hh`wv'cnump

*******=======Total household per capita consumption=====**************
gen hh`wv'cperc = .
missing_H hh`wv'ctot h`wv'hhres, result(hh`wv'cperc)
replace hh`wv'cperc = hh`wv'ctot / h`wv'hhres if !mi(hh`wv'ctot) & !mi(h`wv'hhres)
label variable hh`wv'cperc "hh`wv'cperc:w`wv' total household per capita consumption"

drop r`wv'ifmemp s`wv'ifmemp h`wv'ifmemp r`wv'iwagea s`wv'iwagea h`wv'iwagea r`wv'ibonus s`wv'ibonus h`wv'ibonus r`wv'isjob s`wv'isjob h`wv'isjob
drop h`wv'ipeni h`wv'ipenw
drop imonth_


***drop CHARLS demog raw variables***
drop `inc_w2_demog'

****drop CHARLS household income raw variables***
drop `inc_w2_hhinc'

****drop CHARLS individual income raw variables***
drop `inc_w2_indinc'

****drop CHARLS work pension raw variables***
drop `inc_w2_work'

****drop CHARLS family raw variables***
drop `inc_w2_faminfo'

****drop CHARLS weight raw variables***
drop `inc_w2_weight'

********************create wave 2 family variables*********************


*ret program name
local program H_CHARLS_family_w2

*ret wave number
local wv=2
local pre_wv=`wv'-1
local pre_pre_wv=`wv'-2


***merge with family information file***
local family_w2_faminfo ca001_1_ ca001_2_ ca001_3_ ca001_4_  ///
 						ca001_?_ zca001_?_ /// 
                        ca007_?_ zca007_?_ /// 
                        ca008_1_?_ ca008_2_?_ ///
                        zca001_?_ ///
                        ca000_w2_1_?_ ///
                        cb001 cb003 cb006_?_ ///
                        cb009 cb011 cb014_?_ cb017 cb019 ///
                        cb022_?_ cb025 cb027 ///
                        cb030_?_ cb033 cb035 cb038_?_ cb041 cb043 cb046_?_  ///
                        cb049_?_ cb049_1?_ ///
                        cc002_1_?_ cc002_2_?_ cc002_3_?_ cc002_4_?_ ///
                        cc004_1_?_ cc004_2_?_ cc004_3_?_ cc004_4_?_ ///                      
                        a002_?_ a002_1?_ /// 
                        a003_?_?_ a003_?_1?_ /// 
                        a006_?_ a006_1?_ ///
                        za002_?_ za002_1?_ /// 
                        za003_?_?_ za003_?_1?_ /// 
                        za006_?_ za006_1?_ ///                        
                        xhtype cm001* cm002*
                       
merge m:1 householdID using "`wave_2_faminfo'", keepusing(`family_w2_faminfo') 
drop if _merge==2
drop _merge
foreach var of varlist `family_w2_faminfo' {
    replace `var' = . if inw`wv' == 0 // *correct overassignmnet of household values to non-reponding hh members who respondend previously 
}

***merge with demog file***
local family_w2_demog be001
merge 1:1 ID using "`wave_2_demog'", keepusing(`family_w2_demog') 
drop if _merge==2
drop _merge

***merge with family transfer file***
local family_w2_famtran ce002_?  ///
                        ce005_?  ///
                        ce009_?_?_ ce009_?_1?_ ///
                        ce012s? ce012s?? ce013_?_?_ ce013_?_1?_ ///
                        ce016 ///
                        ce022_? ///
                        ce025_? ///
                        ce029_?_?_ ce029_?_1?_ ///
                        ce031_?_?_ ce031_?_1?_  ///
                        ce036 cf007_w2 ce072_w2 ce074_w2 
merge m:1 householdID using "`wave_2_famtran'", keepusing(`family_w2_famtran') 
drop if _merge==2
drop _merge
foreach var of varlist `family_w2_famtran' {
    replace `var' = . if inw`wv' == 0 // *correct overassignmnet of household values to non-reponding hh members who respondend previously 
}

*****************# people living in the household*****************

gen hhmsize =0 if inw`wv' == 1
forvalues i=1/16 {
	replace hhmsize = hhmsize +1 if !mi(a002_`i'_) 
	replace hhmsize = hhmsize +1 if mi(a002_`i'_) & !mi(a006_`i'_)
	}
	
forvalues i=1/14 {
	replace hhmsize =hhmsize +1 if mi(a006_`i'_) & !mi(za002_`i'_) & mi(a002_`i'_)
}	

gen h`wv'hhres=hhmsize + h`wv'hhresp
replace h`wv'hhres=.m if h`wv'hhres==. & inw`wv'==1
drop hhmsize

label variable h`wv'hhres "h`wv'hhres:w`wv' number of people living in this household"

******************number of living sons and daughters ***************************
******************first, calculate the number in the household************
gen za002_15_=.
gen za002_16_=.

gen h`wv'cson=0  if inw`wv'==1
gen h`wv'cdau=0  if inw`wv'==1
forvalues i =1/16 {   
  replace h`wv'cson = h`wv'cson + 1 if ((a006_`i'_ == 7) & (a002_`i'_ == 1))   
  replace h`wv'cdau = h`wv'cdau + 1 if ((a006_`i'_ == 7) & (a002_`i'_ == 2))
  replace h`wv'cson = h`wv'cson + 1 if ((za006_`i'_ == 7) & (za002_`i'_ == 1)) & mi(a002_`i'_ )
  replace h`wv'cdau = h`wv'cdau + 1 if ((za006_`i'_ == 7) & (za002_`i'_ == 2)) & mi(a002_`i'_ )
}


label variable h`wv'cson "h`wv'cson:w`wv' Number of son co-reside with respondents"
label variable h`wv'cdau "h`wv'cdau:w`wv' Number of daughter co-reside with respondents"

drop za002_15_ za002_16_


***********then, calculate the number outside the household************************
***very high non-resident child
gen h`wv'ncson=0 if inw`wv'==1
gen h`wv'ncdau=0 if inw`wv'==1

forvalues i =1/11 { 
replace h`wv'ncson = h`wv'ncson + (cb049_`i'_ == 1) if inw`wv'==1   
replace h`wv'ncdau = h`wv'ncdau + (cb049_`i'_ == 2) if inw`wv'==1  
}

label variable h`wv'ncson "h`wv'ncson:w`wv' Number of son not co-reside with respondents"
label variable h`wv'ncdau "h`wv'ncdau:w`wv' Number of daughter not co-reside with respondents"

***calculate the total number of living children********
gen h`wv'cchild = h`wv'cson + h`wv'cdau
label variable h`wv'cchild "h`wv'cchild:w`wv' Number of co-residing children"

gen h`wv'ncchild = h`wv'ncson + h`wv'ncdau
label variable h`wv'ncchild "h`wv'ncchild:w`wv' Number of non-coresiding children"

gen h`wv'dau = h`wv'cdau + h`wv'ncdau
label variable h`wv'dau "h`wv'dau:w`wv' Number of living daughters"

gen h`wv'son = h`wv'cson + h`wv'ncson
label variable h`wv'son "h`wv'son:w`wv' Number of living sons"

gen h`wv'child = h`wv'cchild + h`wv'ncchild
label variable h`wv'child "h`wv'child:w`wv' Number of living children"

drop h?cson h?cdau h?ncson h?ncdau h?cchild 

****Try to create deceased
gen h`wv'dson1=0 if inw`wv'==1
gen h`wv'ddau1=0 if inw`wv'==1

forvalues i =1/5 { 
		replace h`wv'dson1 = h`wv'dson1 + (cb006_`i'_ == 1)
    replace h`wv'ddau1 = h`wv'ddau1 + (cb006_`i'_ == 2) 
}

gen h`wv'dson2=0 if inw`wv'==1
gen h`wv'ddau2=0 if inw`wv'==1

forvalues i =1/4 { 
    replace h`wv'dson2 = h`wv'dson2 + (cb014_`i'_ == 1) 
    replace h`wv'ddau2 = h`wv'ddau2 + (cb014_`i'_ == 2)
}

gen h`wv'dson3=0 if inw`wv'==1
gen h`wv'ddau3=0 if inw`wv'==1

forvalues i =1/5 { 
    replace h`wv'dson3 = h`wv'dson3 + (cb022_`i'_ == 1) 
    replace h`wv'ddau3 = h`wv'ddau3 + (cb022_`i'_ == 2)
}

gen h`wv'dson4=0 if inw`wv'==1
gen h`wv'ddau4=0 if inw`wv'==1
forvalues i =1/3 { 
    replace h`wv'dson4 = h`wv'dson4 + (cb030_`i'_ == 1)
    replace h`wv'ddau4 = h`wv'ddau4 + (cb030_`i'_ == 2)
}

gen h`wv'dson5=0 if inw`wv'==1
gen h`wv'ddau5=0 if inw`wv'==1

forvalues i =1/3 { 
    replace h`wv'dson5 = h`wv'dson5 + (cb038_`i'_ == 1) 
    replace h`wv'ddau5 = h`wv'ddau5 + (cb038_`i'_ == 2)
}

gen h`wv'dson6=0 if inw`wv'==1
gen h`wv'ddau6=0 if inw`wv'==1

		replace h`wv'dson6 = h`wv'dson6 + (cb046_1_ == 1)
    replace h`wv'ddau6 = h`wv'ddau6 + (cb046_1_ == 2)


***Nmber of deceased sons***
gen h`wv'dson= h`wv'dson1 + h`wv'dson2 + h`wv'dson3 + h`wv'dson4 + h`wv'dson5 + h`wv'dson6
label variable h`wv'dson "h`wv'dson:w`wv' Number of deceased sons"

***Number of deceased daughters***
gen h`wv'ddau=h`wv'ddau1 + h`wv'ddau2 + h`wv'ddau3 + h`wv'ddau4 + h`wv'ddau5 + h`wv'ddau6
label variable h`wv'ddau "h`wv'ddau:w`wv' Number of deceased daughters"

***Number of deceased children
gen h`wv'dchild=h`wv'dson + h`wv'ddau
label variable h`wv'dchild "h`wv'dchild:w`wv' Total number of deceased children"

drop h`wv'dson1 h`wv'dson2 h`wv'dson3 h`wv'dson4 h`wv'dson5 h`wv'dson6
drop h`wv'ddau1 h`wv'ddau2 h`wv'ddau3 h`wv'ddau4 h`wv'ddau5 h`wv'ddau6


****Number of Sibling*****
****Number of Alive older brother****
gen r`wv'livob=.
replace r`wv'livob= .m if cc002_1_1_==. & inw`wv'==1
replace r`wv'livob= .p if cc002_1_1_==. & cf007_w2==4
replace r`wv'livob=cc002_1_1_ if inrange(cc002_1_1_,0,20) 

gen s`wv'livob=.
replace s`wv'livob=.m if cc002_1_2_==. & inw`wv'==1
replace s`wv'livob=.p if cc002_1_2_==. & cf007_w2==4
replace s`wv'livob=cc002_1_2_ if inrange(cc002_1_2_,0,20)

label variable r`wv'livob "r`wv'livob:w`wv' R Number of living older brothers"
label variable s`wv'livob "s`wv'livob:w`wv' S Number of living older brothers"

****Number of Alive younger brother****
gen r`wv'livyb=.
replace r`wv'livyb= .m if cc002_2_1_==. & inw`wv'==1
replace r`wv'livyb= .p if cc002_2_1_==. & cf007_w2==4
replace r`wv'livyb=cc002_2_1_ if inrange(cc002_2_1_,0,20)

gen s`wv'livyb=.
replace s`wv'livyb=.m if cc002_2_2_==. & inw`wv'==1
replace s`wv'livyb=.p if cc002_2_2_==. & cf007_w2==4
replace s`wv'livyb=cc002_2_2_ if inrange(cc002_2_2_,0,20)

label variable r`wv'livyb "r`wv'livyb:w`wv' R Number of living younger brothers"
label variable s`wv'livyb "s`wv'livyb:w`wv' S Number of living younger brothers"

****Number of Alive older brother****
gen r`wv'livos=.
replace r`wv'livos= .m if cc002_3_1_==. & inw`wv'==1
replace r`wv'livos= .p if cc002_3_1_==. & cf007_w2==4
replace r`wv'livos=cc002_3_1_ if inrange(cc002_3_1_,0,20)

gen s`wv'livos=.
replace s`wv'livos=.m if cc002_3_2_==. & inw`wv'==1
replace s`wv'livos=.p if cc002_3_2_==. & cf007_w2==4
replace s`wv'livos=cc002_3_2_ if inrange(cc002_3_2_,0,20)

label variable r`wv'livos "r`wv'livos:w`wv' R Number of living older sisters"
label variable s`wv'livos "s`wv'livos:w`wv' S Number of living older sisters"

****Number of Alive younger sister****
gen r`wv'livys=.
replace r`wv'livys= .m if cc002_4_1_==. & inw`wv'==1
replace r`wv'livys= .p if cc002_4_1_==. & cf007_w2==4
replace r`wv'livys= cc002_4_1_ if inrange(cc002_4_1_,0,20)

gen s`wv'livys=.
replace s`wv'livys=.m if cc002_4_2_==. & inw`wv'==1
replace s`wv'livys=.p if cc002_4_2_==. & cf007_w2==4
replace s`wv'livys= cc002_4_2_ if inrange(cc002_4_2_,0,20)

label variable r`wv'livys "r`wv'livys:w`wv' R Number of living younger sisters"
label variable s`wv'livys "s`wv'livys:w`wv' S Number of living younger sisters"

**********************************************************
**********summary of living brother, sister and siblings

gen r`wv'livsis=.
replace r`wv'livsis= .m if r`wv'livos==.m | r`wv'livys==.m
replace r`wv'livsis= .p if r`wv'livos==.p | r`wv'livys==.p
replace r`wv'livsis= r`wv'livos + r`wv'livys if !mi(r`wv'livos) & !mi(r`wv'livys)
replace r`wv'livsis=.i if inrange(r`wv'livsis,10,24) // two outlier reporting error
label variable r`wv'livsis "r`wv'livsis:w`wv' r Number of living sisters"

gen s`wv'livsis=.
replace s`wv'livsis= .m if s`wv'livos==.m | s`wv'livys==.m
replace s`wv'livsis= .p if s`wv'livos==.p | s`wv'livys==.p
replace s`wv'livsis= s`wv'livos + s`wv'livys if !mi(s`wv'livos) & !mi(s`wv'livys)
replace s`wv'livsis=.i if inrange(s`wv'livsis,10,24) // two outlier reporting error
label variable s`wv'livsis "s`wv'livsis:w`wv' s Number of living sisters"

gen r`wv'livbro=.
replace r`wv'livbro= .m if r`wv'livob==.m | r`wv'livyb==.m
replace r`wv'livbro= .p if r`wv'livob==.p | r`wv'livyb==.p
replace r`wv'livbro= r`wv'livob + r`wv'livyb if !mi(r`wv'livob) & !mi(r`wv'livyb)
replace r`wv'livbro=.i if inrange(r`wv'livbro,10,24) // two outlier reporting error
label variable r`wv'livbro "r`wv'livbro:w`wv' r Number of living brothers"

gen s`wv'livbro=.
replace s`wv'livbro= .m if s`wv'livob==.m | s`wv'livyb==.m
replace s`wv'livbro= .p if s`wv'livob==.p | s`wv'livyb==.p
replace s`wv'livbro= s`wv'livob + s`wv'livyb if !mi(s`wv'livob) & !mi(s`wv'livyb)
replace s`wv'livbro=.i if inrange(s`wv'livbro,10,24) // two outlier reporting error
label variable s`wv'livbro "s`wv'livbro:w`wv' s Number of living brothers"

gen r`wv'livsib=.
replace r`wv'livsib= .m if r`wv'livsis==.m | r`wv'livbro==.m 
replace r`wv'livsib= .p if r`wv'livsis==.p | r`wv'livbro==.p 
replace r`wv'livsib= .i if r`wv'livsis==.i | r`wv'livbro==.i
replace r`wv'livsib= r`wv'livsis + r`wv'livbro if !mi(r`wv'livsis) & !mi(r`wv'livbro)
replace r`wv'livsib=.i if inrange(r`wv'livsib,10,24) // two outlier reporting error
label variable r`wv'livsib "r`wv'livsib:w`wv' r Number of living siblings"

gen s`wv'livsib=.
replace s`wv'livsib= .m if s`wv'livsis==.m | s`wv'livbro==.m
replace s`wv'livsib= .p if s`wv'livsis==.p | s`wv'livbro==.p
replace s`wv'livsib= .i if s`wv'livsis==.i | s`wv'livbro==.i
replace s`wv'livsib= s`wv'livsis + s`wv'livbro if !mi(s`wv'livsis) & !mi(s`wv'livbro)
replace s`wv'livsib=.i if inrange(s`wv'livsib,10,24) // two outlier reporting error
label variable s`wv'livsib "s`wv'livsib:w`wv' s Number of living siblings"

drop r`wv'livob r`wv'livyb r`wv'livos r`wv'livys s`wv'livob s`wv'livyb s`wv'livos s`wv'livys

***Number of deceased sibling***
****Number of Dead older brother****
gen r`wv'decob=.
replace r`wv'decob= .m if cc004_1_1_==. & inw`wv'==1
replace r`wv'decob= .p if cc004_1_1_==. & cf007_w2==4
replace r`wv'decob=cc004_1_1_ if inrange(cc004_1_1_,0,20)
label variable r`wv'decob "r`wv'decob:w`wv' R Number of deceased older brothers"

gen s`wv'decob=.
replace s`wv'decob= .m if cc004_1_2_==. & inw`wv'==1
replace s`wv'decob= .p if cc004_1_2_==. & cf007_w2==4
replace s`wv'decob=cc004_1_2_ if inrange(cc004_1_2_,0,20)
label variable s`wv'decob "s`wv'decob:w`wv' s number of deceased older brothers"

****Number of Dead younger brother****
gen r`wv'decyb=.
replace r`wv'decyb= .m if cc004_2_1_==. & inw`wv'==1
replace r`wv'decyb= .p if cc004_2_1_==. & cf007_w2==4
replace r`wv'decyb=cc004_2_1_ if inrange(cc004_2_1_,0,20)
label variable r`wv'decyb "r`wv'decyb:w`wv' r Number of deceased younger brothers"

gen s`wv'decyb=.
replace s`wv'decyb= .m if cc004_2_2_==. & inw`wv'==1
replace s`wv'decyb= .p if cc004_2_2_==. & cf007_w2==4
replace s`wv'decyb=cc004_2_2_ if inrange(cc004_2_2_,0,20)
label variable s`wv'decyb "s`wv'decyb:w`wv' s Number of deceased younger brothers"

****Number of Dead older sister****
gen r`wv'decos=.
replace r`wv'decos= .m if cc004_3_1_==. & inw`wv'==1
replace r`wv'decos= .p if cc004_3_1_==. & cf007_w2==4
replace r`wv'decos=cc004_3_1_ if inrange(cc004_3_1_,0,20)

label variable r`wv'decos "r`wv'decos:w`wv' R Number of deceased older sisters"

gen s`wv'decos=.
replace s`wv'decos= .m if cc004_3_2_==. & inw`wv'==1
replace s`wv'decos= .p if cc004_3_2_==. & cf007_w2==4
replace s`wv'decos=cc004_3_2_ if inrange(cc004_3_2_,0,20)
label variable s`wv'decos "s`wv'decos:w`wv' S Number of deceased older sisters"

****Number of Dead younger sister****
gen r`wv'decys=.
replace r`wv'decys= .m if cc004_4_1_==. & inw`wv'==1
replace r`wv'decys= .p if cc004_4_1_==. & cf007_w2==4
replace r`wv'decys=cc004_4_1_ if inrange(cc004_4_1_,0,20)
label variable r`wv'decys "r`wv'decys:w`wv' R Number of deceased younger sisters"

gen s`wv'decys=.
replace s`wv'decys= .m if cc004_4_2_==. & inw`wv'==1
replace s`wv'decys= .p if cc004_4_2_==. & cf007_w2==4
replace s`wv'decys=cc004_4_2_ if inrange(cc004_4_2_,0,20)
label variable s`wv'decys "s`wv'decys:w`wv' S Number of deceased younger sisters"

***Number of deceased sisters***
gen r`wv'decsis=.
replace r`wv'decsis= .m if r`wv'decos==.m | r`wv'decys==.m
replace r`wv'decsis= .p if r`wv'decos==.p | r`wv'decys==.p
replace r`wv'decsis= r`wv'decos + r`wv'decys if !mi(r`wv'decos) & !mi(r`wv'decys)
label variable r`wv'decsis "r`wv'decsis:w`wv' r Number of deceased sisters"

gen s`wv'decsis=.
replace s`wv'decsis= .m if s`wv'decos==.m | s`wv'decys==.m
replace s`wv'decsis= .p if s`wv'decos==.p | s`wv'decys==.p
replace s`wv'decsis= s`wv'decos + s`wv'decys if !mi(s`wv'decos) & !mi(s`wv'decys)
label variable s`wv'decsis "s`wv'decsis:w`wv' s Number of deceased sisters"

gen r`wv'decbro=.
replace r`wv'decbro= .m if r`wv'decob==.m | r`wv'decyb==.m
replace r`wv'decbro= .p if r`wv'decob==.p | r`wv'decyb==.p
replace r`wv'decbro= r`wv'decob + r`wv'decyb if !mi(r`wv'decob) & !mi(r`wv'decyb)
label variable r`wv'decbro "r`wv'decbro:w`wv' r Number of deceased brothers"

gen s`wv'decbro=.
replace s`wv'decbro= .m if s`wv'decob==.m | s`wv'decyb==.m
replace s`wv'decbro= .p if s`wv'decob==.p | s`wv'decyb==.p
replace s`wv'decbro= s`wv'decob + s`wv'decyb if !mi(s`wv'decob) & !mi(s`wv'decyb)
label variable s`wv'decbro "s`wv'decbro:w`wv' s Number of deceased brothers"

gen r`wv'decsib=.
replace r`wv'decsib= .m if r`wv'decsis==.m | r`wv'decbro==.m 
replace r`wv'decsib= .p if r`wv'decsis==.p | r`wv'decbro==.p 
replace r`wv'decsib=r`wv'decsis + r`wv'decbro if !mi(r`wv'decsis) & !mi(r`wv'decbro)
label variable r`wv'decsib "r`wv'decsib:w`wv' r Number of deceased siblings"

gen s`wv'decsib=.
replace s`wv'decsib= .m if s`wv'decsis==.m | s`wv'decbro==.m
replace s`wv'decsib= .p if s`wv'decsis==.p | s`wv'decbro==.p
replace s`wv'decsib=s`wv'decsis + s`wv'decbro if !mi(s`wv'decsis) & !mi(s`wv'decbro)
label variable s`wv'decsib "s`wv'decsib:w`wv' s Number of deceased siblings"

drop r`wv'decob r`wv'decyb r`wv'decos r`wv'decys s`wv'decob s`wv'decyb s`wv'decos s`wv'decys

***Parental Mortality: Mother Alive***
***Parents are HH members****
gen w`wv'rmom=0 if inw`wv'==1
gen w`wv'smom=0 if inw`wv'==1
gen w`wv'rdad=0 if inw`wv'==1
gen w`wv'sdad=0 if inw`wv'==1
forvalues i =1/16 { 
    replace w`wv'rmom = w`wv'rmom + 1 if a006_`i'_ == 1 | za006_`i'_ ==1
    replace w`wv'smom = w`wv'smom + 1 if a006_`i'_ == 3 | za006_`i'_ ==3
    replace w`wv'rdad = w`wv'rdad + 1 if a006_`i'_ == 2 | za006_`i'_ ==2
    replace w`wv'sdad = w`wv'sdad + 1 if a006_`i'_ == 4 | za006_`i'_ ==4
}

gen r`wv'momliv=.
replace r`wv'momliv = .m if inw`wv'==1
replace r`wv'momliv = .m if (ca001_1_ == . & ca001_2_ == . & ca001_3_ == . & ca001_4_ == .) |(zca001_1_ == . & zca001_2_ == . & zca001_3_ == . & zca001_4_ == .)
replace r`wv'momliv = 1 if inrange(w`wv'rmom,1,2)
replace r`wv'momliv = 0 if ca000_w2_1_2_ == 1 & ca001_2_==2 | (ca001_2_==. & zca001_2_==2) 
replace r`wv'momliv = 0 if ca000_w2_1_2_ == 2 & ca001_2_==2 | (ca001_2_==. & zca001_2_==2) 
replace r`wv'momliv = 1 if ca000_w2_1_2_ == 2 & ca001_2_==1 | (ca001_2_==. & zca001_2_==1) 
replace r`wv'momliv = 0 if ca000_w2_1_2_ == . & ca001_2_==2 | (ca001_2_==. & zca001_2_==2) 
replace r`wv'momliv = 1 if ca000_w2_1_2_ == . & ca001_2_==1 | (ca001_2_==. & zca001_2_==1) 

label variable r`wv'momliv "r`wv'momliv:w`wv' r mother alive"
label values r`wv'momliv momliv

*spoure parental motality mother alive
gen s`wv'momliv=.
replace s`wv'momliv = .m if inw`wv'==1
replace s`wv'momliv = .m if (ca001_1_ == . & ca001_2_ == . & ca001_3_ == . & ca001_4_ == .) |(zca001_1_ == . & zca001_2_ == . & zca001_3_ == . & zca001_4_ == .)
replace s`wv'momliv = 1 if inrange(w`wv'smom,1,2)
replace s`wv'momliv = 0 if ca000_w2_1_4_ == 1 & ca001_4_==2 | (ca001_4_==. & zca001_4_==2) 
replace s`wv'momliv = 1 if ca000_w2_1_4_ == 1 & ca001_4_==1 | (ca001_4_==. & zca001_4_==1) 
replace s`wv'momliv = 0 if ca000_w2_1_4_ == 2 & ca001_4_==2 | (ca001_4_==. & zca001_4_==2) 
replace s`wv'momliv = 1 if ca000_w2_1_4_ == 2 & ca001_4_==1 | (ca001_4_==. & zca001_4_==1) 
replace s`wv'momliv = 0 if ca000_w2_1_4_ == . & ca001_4_==2 | (ca001_4_==. & zca001_4_==2)
replace s`wv'momliv = 1 if ca000_w2_1_4_ == . & ca001_4_==1 | (ca001_4_==. & zca001_4_==1) 

label variable s`wv'momliv "s`wv'momliv:w`wv' s mother alive"
label values s`wv'momliv momliv

***Parental Mortality: Father Alive***
gen r`wv'dadliv=.
replace r`wv'dadliv = .m if inw`wv'==1
replace r`wv'dadliv = .m if (ca001_1_ == . & ca001_2_ == . & ca001_3_ == . & ca001_4_ == .) |(zca001_1_ == . & zca001_2_ == . & zca001_3_ == . & zca001_4_ == .) 
replace r`wv'dadliv = 1 if inrange(w`wv'rdad,1,2)
replace r`wv'dadliv = 0 if ca000_w2_1_1_ == 1 & ca001_1_==2 | (ca001_1_==. & zca001_1_==2) 
replace r`wv'dadliv = 1 if ca000_w2_1_1_ == 1 & ca001_1_==1 | (ca001_1_==. & zca001_1_==1) 
replace r`wv'dadliv = 0 if ca000_w2_1_1_ == 2 & ca001_1_==2 | (ca001_1_==. & zca001_1_==2) 
replace r`wv'dadliv = 1 if ca000_w2_1_1_ == 2 & ca001_1_==1 | (ca001_1_==. & zca001_1_==1) 
replace r`wv'dadliv = 0 if ca000_w2_1_1_ == . & ca001_1_==2 | (ca001_1_==. & zca001_1_==2) 
replace r`wv'dadliv = 1 if ca000_w2_1_1_ == . & ca001_1_==1 | (ca001_1_==. & zca001_1_==1) 

label variable r`wv'dadliv "r`wv'dadliv:w`wv' r father alive"
label values r`wv'dadliv dadliv

**spoure parental motality father alive
gen s`wv'dadliv=.
replace s`wv'dadliv = .m if inw`wv'==1
replace s`wv'dadliv = .m if (ca001_1_ == . & ca001_2_ == . & ca001_3_ == . & ca001_4_ == .) |(zca001_1_ == . & zca001_2_ == . & zca001_3_ == . & zca001_4_ == .)
replace s`wv'dadliv = 1 if inrange(w`wv'sdad,1,2)
replace s`wv'dadliv = 0 if ca000_w2_1_3_ == 1 & ca001_3==2 | (ca001_3_==. & zca001_3_==2) 
replace s`wv'dadliv = 1 if ca000_w2_1_3_ == 1 & ca001_3==1 | (ca001_3_==. & zca001_3_==1) 
replace s`wv'dadliv = 0 if ca000_w2_1_3_ == 2 & ca001_3==2 | (ca001_3_==. & zca001_3_==2) 
replace s`wv'dadliv = 1 if ca000_w2_1_3_ == 2 & ca001_3==1 | (ca001_3_==. & zca001_3_==1) 
replace s`wv'dadliv = 0 if ca000_w2_1_3_ == . & ca001_3==2 | (ca001_3_==. & zca001_3_==2) 
replace s`wv'dadliv = 1 if ca000_w2_1_3_ == . & ca001_3==1 | (ca001_3_==. & zca001_3_==1) 

label variable s`wv'dadliv "s`wv'dadliv:w`wv' s father alive"
label values s`wv'dadliv dadliv

***Number of living parents***
gen r`wv'livpar=.
replace r`wv'livpar = .m if r`wv'dadliv == .m | r`wv'momliv == .m
replace r`wv'livpar = 0  if r`wv'dadliv == 0 & r`wv'momliv == 0
replace r`wv'livpar = 1  if r`wv'momliv == 1 & r`wv'dadliv == 0
replace r`wv'livpar = 1  if r`wv'momliv == 0 & r`wv'dadliv == 1
replace r`wv'livpar = 2  if r`wv'momliv == 1 & r`wv'dadliv == 1

label variable r`wv'livpar "r`wv'livpar:w`wv' r Number of living parents"

gen s`wv'livpar=.
replace s`wv'livpar = .m if s`wv'dadliv == .m | s`wv'momliv == .m
replace s`wv'livpar = 0  if s`wv'dadliv == 0 & s`wv'momliv == 0
replace s`wv'livpar = 1  if s`wv'momliv == 1 & s`wv'dadliv == 0
replace s`wv'livpar = 1  if s`wv'momliv == 0 & s`wv'dadliv == 1
replace s`wv'livpar = 2  if s`wv'momliv == 1 & s`wv'dadliv == 1
label variable s`wv'livpar "s`wv'livpar:w`wv' s Number of living parents"



****Mother's age ****
gen w`wv'rmomy=0 if inw`wv'==1
gen w`wv'smomy=0 if inw`wv'==1
gen w`wv'rdady=0 if inw`wv'==1
gen w`wv'sdady=0 if inw`wv'==1
forvalues i =1/16 { 
    replace w`wv'rmomy = a003_1_`i'_   if a006_`i'_  == 1 & inrange(a003_1_`i'_,1900,1990) 
    replace w`wv'rmomy = za003_1_`i'_  if za006_`i'_ == 1 & inrange(za003_1_`i'_,1900,1990) 
    replace w`wv'smomy = a003_1_`i'_   if a006_`i'_  == 3 & inrange(a003_1_`i'_,1900,1990)  
    replace w`wv'smomy = za003_1_`i'_  if za006_`i'_ == 3 & inrange(za003_1_`i'_,1900,1990)
    replace w`wv'rdady = a003_1_`i'_   if a006_`i'_  == 2 & inrange(a003_1_`i'_,1900,1990)  
    replace w`wv'rdady = za003_1_`i'_  if za006_`i'_ == 2 & inrange(za003_1_`i'_,1900,1990) 
    replace w`wv'sdady = a003_1_`i'_   if a006_`i'_  == 4 & inrange(a003_1_`i'_,1900,1990)  
    replace w`wv'sdady = za003_1_`i'_  if za006_`i'_ == 4 & inrange(za003_1_`i'_,1900,1990) 
} 

gen w2ca007_2_=max(ca007_2_, zca007_2_) 
replace w2ca007_2_=.d if w2ca007_2==9999
replace w2ca007_2_ = w1armomy if mi(w2ca007_2_) & inrange(w1armomy,1000,2030) & inw2==1

gen w2ca007_4_=max(ca007_4_, zca007_4_) 
replace w2ca007_4_=.d if w2ca007_4==9999
replace w2ca007_4_ = w1asmomy if mi(w2ca007_4_) & inrange(w1asmomy,1000,2030) & inw2==1

gen w2ca007_1_=max(ca007_1_, zca007_1_) 
replace w2ca007_1_=.d if w2ca007_1==9999
replace w2ca007_1_ = w1ardady if mi(w2ca007_1_) & inrange(w1ardady,1000,2030) & inw2==1

gen w2ca007_3_=max(ca007_3_, zca007_3_) 
replace w2ca007_3_=.d if w2ca007_3==9999
replace w2ca007_3_ = w1asdady if mi(w2ca007_3_) & inrange(w1asdady,1000,2030) & inw2==1


****Mother's deceased age ****
gen r`wv'momage=.
replace r`wv'momage=.m if ( ca007_2_==. & ca008_2_2_==. ) & inw`wv'==1
replace r`wv'momage=.i if !inrange(w2ca007_2_,1850,1990) | !inrange(ca008_1_2_,1900,2013)
replace r`wv'momage=.d if w2ca007_2_==.d | r`pre_wv'momage == .d
replace r`wv'momage=r`pre_wv'momage          if r`wv'momliv==0 & r`pre_wv'momliv==0 & inrange(r`pre_wv'momage,0,120) 
replace r`wv'momage=(r`wv'iwy-w`wv'rmomy)    if r`wv'momliv==1 & mi(r`wv'momage) & inrange(w`wv'rmomy,1900,1990)  
replace r`wv'momage=(r`wv'iwy-w2ca007_2_)    if r`wv'momliv==1 & inrange(w2ca007_2_,1850,1990)
replace r`wv'momage=(ca008_1_2_-w2ca007_2_)  if r`wv'momliv==0 & inrange(ca008_1_2_,1900,2020) & inrange(w2ca007_2_,1850,1950)  & w2ca007_2_~=ca008_1_2_
replace r`wv'momage=ca008_2_2_               if r`wv'momliv==0 & ca008_1_2_==. & inrange(ca008_2_2_,1,120)
replace r`wv'momage=r`pre_wv'momage + 2      if r`wv'momliv==1 & mi(r`wv'momage) & inrange(r`pre_wv'momage,0,120) 
label variable r`wv'momage "r`wv'momage:w`wv' r mother's age current/at death "

*spoure parental mother age
gen s`wv'momage=.
replace s`wv'momage=.m if ( ca007_4_==. & ca008_2_4_==. ) & inw`wv'==1
replace s`wv'momage=.i if !inrange(w2ca007_4_,1850,1990) | !inrange(ca008_1_4_,1900,2013)
replace s`wv'momage=.d if w2ca007_4_ ==.d  | s`pre_wv'momage ==.d
replace s`wv'momage=s`pre_wv'momage          if s`wv'momliv==0 & s`pre_wv'momliv==0 & inrange(s`pre_wv'momage,0,120) 
replace s`wv'momage=(r`wv'iwy-w`wv'smomy)    if s`wv'momliv==1 & mi(s`wv'momage) & inrange(w`wv'smomy,1900,1990)  
replace s`wv'momage=(r`wv'iwy-w2ca007_4_)    if s`wv'momliv==1 & inrange(w2ca007_4_,1850,1990)
replace s`wv'momage=(ca008_1_4_-w2ca007_4_)  if s`wv'momliv==0 & inrange(ca008_1_4_,1900,2020) & inrange(w2ca007_4_,1850,1950)  & w2ca007_4_~=ca008_1_4_
replace s`wv'momage=ca008_2_4_               if s`wv'momliv==0 & ca008_1_4_==. & inrange(ca008_2_4_,1,120)
replace s`wv'momage=s`pre_wv'momage + 2      if s`wv'momliv==1 & mi(s`wv'momage) & inrange(s`pre_wv'momage,0,120)
label variable s`wv'momage "s`wv'momage:w`wv' s mother's age current/at death"

****Father deceased age***
gen r`wv'dadage=.
replace r`wv'dadage=.m if ( ca007_1_==. & ca008_2_1_==. ) & inw`wv'==1
replace r`wv'dadage=.i if !inrange(w2ca007_1_,1850,1990) | !inrange(ca008_1_1_,1900,2013)
replace r`wv'dadage=.d if w2ca007_1_ == .d | r`pre_wv'dadage == .d 
replace r`wv'dadage=r`pre_wv'dadage          if r`wv'dadliv==0 & r`pre_wv'dadliv==0 & inrange(r`pre_wv'dadage,0,120) 
replace r`wv'dadage=(r`wv'iwy-w`wv'rdady)    if r`wv'dadliv==1 & mi(r`wv'dadage) & inrange(w`wv'rdady,1900,1990)  
replace r`wv'dadage=(r`wv'iwy-w2ca007_1_)    if r`wv'dadliv==1 & inrange(w2ca007_1_,1850,1990)
replace r`wv'dadage=(ca008_1_1_-w2ca007_1_)  if r`wv'dadliv==0 & inrange(ca008_1_1_,1900,2020) & inrange(w2ca007_1_,1850,1950)  & w2ca007_1_~=ca008_1_1_
replace r`wv'dadage=ca008_2_1_               if r`wv'dadliv==0 & ca008_1_2_==. & inrange(ca008_2_1_,1,120)
replace r`wv'dadage=r`pre_wv'dadage + 2      if r`wv'dadliv==1 & mi(r`wv'dadage) & inrange(r`pre_wv'dadage,0,120) 
label variable r`wv'dadage "r`wv'dadage:w`wv' r father's age current/at death"

*spoure parental motality father age
gen s`wv'dadage=.
replace s`wv'dadage=.m if ( ca007_3_==. & ca008_2_3_==. ) & inw`wv'==1
replace s`wv'dadage=.i if !inrange(w2ca007_3_,1850,1990) | !inrange(ca008_1_3_,1900,2013)
replace s`wv'dadage=.d if w2ca007_3_ == .d |  s`pre_wv'dadage == .d
replace s`wv'dadage=s`pre_wv'dadage          if s`wv'dadliv==0 & s`pre_wv'dadliv==0 & inrange(s`pre_wv'dadage,0,120) 
replace s`wv'dadage=(r`wv'iwy-w`wv'sdady)    if s`wv'dadliv==1 & mi(s`wv'dadage) & inrange(w`wv'sdady,1900,1990)  
replace s`wv'dadage=(r`wv'iwy-w2ca007_3_)    if s`wv'dadliv==1 & inrange(w2ca007_3_,1850,1990)
replace s`wv'dadage=(ca008_1_3_-w2ca007_3_)  if s`wv'dadliv==0 & inrange(ca008_1_3_,1900,2020) & inrange(w2ca007_3_,1850,1950)  & w2ca007_3_~=ca008_1_3_
replace s`wv'dadage=ca008_2_3_               if s`wv'dadliv==0 & ca008_1_3_==. & inrange(ca008_2_3_,1,120)
replace s`wv'dadage=s`pre_wv'dadage + 2      if s`wv'dadliv==1 & mi(s`wv'dadage) & inrange(s`pre_wv'dadage,0,120) 
label variable s`wv'dadage "s`wv'dadage:w`wv' s father's age current/at death"



*******************************************************************************
**                                                                          ***
** 6. Private Transfer Variables between parents and children  ***
**                                                                          ***
********************************************************************************

*****************************************
* help from parents ce002 no ce001
*skip if both or one of parents died before 2010 or both are hhmember

gen w2ce001s=0 if inw`wv' == 1
replace w2ce001s=1 if ca001_1_==1 | (ca001_1_==2 & inrange(ca008_1_1,2010,2020) ) | ca001_2_==1 |  (ca001_2_==2 & inrange(ca008_1_2,2010,2020) )

egen h`wv'par=rowtotal(ce002_1 ce002_2 ce002_3 ce002_4),m
replace h`wv'par=.m if h`wv'par==. & inw`wv' == 1
replace h`wv'par=.p if mi(h`wv'par) & cf007_w2==4
replace h`wv'par= 0 if mi(h`wv'par) & w2ce001s==0 

*****************************************
* help from  parents-in-law ce005 no ce004

gen w2ce004s=0 if inw`wv' == 1
replace w2ce004s=1 if ca001_4_==1 | (ca001_4_==2 & inrange(ca008_1_4_,2010,2020) ) | ca001_3_==1 |  (ca001_3_==2 & inrange(ca008_1_3,2010,2020) )

egen h`wv'parlaw=rowtotal(ce005_1 ce005_2 ce005_3 ce005_4 ),m
replace h`wv'parlaw=.m if h`wv'parlaw==. & inw`wv' == 1
replace h`wv'parlaw=.p if mi(h`wv'parlaw) & cf007_w2==4
replace h`wv'parlaw= 0 if mi(h`wv'parlaw) & w2ce004s==0 

*************************************
* help to parents ce022 no ce021

egen h`wv'2par=rowtotal(ce022_1 ce022_2 ce022_3 ce022_4 ),m
replace h`wv'2par=.m if h`wv'2par ==. & inw`wv' == 1
replace h`wv'2par=.p if mi(h`wv'2par) & cf007_w2==4
replace h`wv'2par= 0 if mi(h`wv'2par) & w2ce001s==0 

***********************************
* help to parents-in-law ce025 no ce024

egen h`wv'2parlaw=rowtotal(ce025_1 ce025_2 ce025_3 ce025_4),m
replace h`wv'2parlaw=.m if h`wv'2parlaw==. & inw`wv' == 1
replace h`wv'2parlaw=.p if mi(h`wv'2parlaw) & cf007_w2==4
replace h`wv'2parlaw= 0 if mi(h`wv'2parlaw) & w2ce004s==0 

*****************************************
********===Parents Transfer===**********
*****************************************
gen h`wv'fpamt=.
replace h`wv'fpamt =.m if h`wv'par==.m | h`wv'parlaw==.m
replace h`wv'fpamt =.p if h`wv'par==.p | h`wv'parlaw==.p
replace h`wv'fpamt = h`wv'par + h`wv'parlaw if !mi(h`wv'par) & !mi(h`wv'parlaw) 
la var h`wv'fpamt "h`wv'fpamt:w`wv' amount of transfers from parents/parents-in-law"

gen h`wv'fpany=0 if inw`wv' == 1
replace h`wv'fpany =.m if h`wv'par==.m | h`wv'parlaw==.m
replace h`wv'fpany =.p if h`wv'par==.p | h`wv'parlaw==.p
replace h`wv'fpany=1 if inrange(h`wv'fpamt,1,9999999)
la var h`wv'fpany "h`wv'fpany:w`wv' any transfer from parents/parents-in-law"
label val h`wv'fpany yesno

gen h`wv'tpamt=.
replace h`wv'tpamt =.m if h`wv'2par==.m | h`wv'2parlaw==.m
replace h`wv'tpamt =.p if h`wv'2par==.p | h`wv'2parlaw==.p
replace h`wv'tpamt = h`wv'2par + h`wv'2parlaw if !mi(h`wv'2par) & !mi(h`wv'2parlaw)
la var h`wv'tpamt "h`wv'tpamt:w`wv' amount of transfers to parents/parents-in-law"

gen h`wv'tpany=0 if inw`wv' == 1
replace h`wv'tpany =.m if h`wv'2par==.m | h`wv'2parlaw==.m
replace h`wv'tpany =.p if h`wv'2par==.p | h`wv'2parlaw==.p
replace h`wv'tpany=1 if inrange(h`wv'tpamt,1,99999999)
la var h`wv'tpany "h`wv'tpany:w`wv' any transfer to parents/parents-in-law"
label val h`wv'tpany yesno



**********************************************
**********************************************
* help from children ce009 no ce007

egen h`wv'ichild=rowtotal(ce009* ),m
replace h`wv'ichild=.m if h`wv'ichild==. & inw`wv' == 1
replace h`wv'ichild=.p if mi(h`wv'ichild) & cf007_w2==4
replace h`wv'ichild= 0 if mi(h`wv'ichild) & h`wv'ncchild==0
replace h`wv'ichild= 0 if mi(h`wv'ichild) & h`wv'child==0

******************************
* help from grandchildren ce013 no ce011
egen h`wv'gchild=rowtotal(ce013* ),m
replace h`wv'gchild=.m if h`wv'gchild==. & inw`wv' == 1
replace h`wv'gchild=.p if mi(h`wv'gchild) & cf007_w2==4
replace h`wv'gchild= 0 if mi(h`wv'gchild) & h`wv'ncchild==0
replace h`wv'gchild= 0 if mi(h`wv'gchild) & h`wv'child==0
replace h`wv'gchild= 0 if mi(h`wv'gchild) & ce012s99==99


******************************
* help to children ce02 no ce027
egen h`wv'2child=rowtotal(ce029_* ),m
replace h`wv'2child=.m if h`wv'2child==. & inw`wv' == 1
replace h`wv'2child=.p if mi(h`wv'2child) & cf007_w2==4
replace h`wv'2child= 0 if mi(h`wv'2child) & h`wv'ncchild==0
replace h`wv'2child= 0 if mi(h`wv'2child) & h`wv'child==0


******************************
* help to grandchildren ce031
egen h`wv'2gchild=rowtotal(ce031_*),m
replace h`wv'2gchild=.m if h`wv'2gchild==. & inw`wv' == 1
replace h`wv'2gchild=.p if mi(h`wv'2gchild) & cf007_w2==4
replace h`wv'2gchild= 0 if mi(h`wv'2gchild) & h`wv'ncchild==0
replace h`wv'2gchild= 0 if mi(h`wv'2gchild) & h`wv'child==0
replace h`wv'2gchild= 0 if mi(h`wv'2gchild) & ce012s99==99

*****************************************
********===Children Transfer===**********
*****************************************
gen h`wv'fcamt=.
replace h`wv'fcamt =0 if h`wv'ichild==.m | h`wv'gchild==.m
replace h`wv'fcamt =.p if h`wv'ichild==.p | h`wv'gchild==.p
replace h`wv'fcamt = h`wv'ichild + h`wv'gchild if !mi(h`wv'ichild) & !mi(h`wv'gchild)
la var h`wv'fcamt "h`wv'fcamt:w`wv' amount of transfers from children/grandchildren"

gen h`wv'fcany=.
replace h`wv'fcany =0 if h`wv'fcamt == 0 | h`wv'ichild==.m | h`wv'gchild==.m
replace h`wv'fcany =.p if h`wv'ichild==.p | h`wv'gchild==.p
replace h`wv'fcany = 1 if inrange(h`wv'fcamt,1,999999999)
la var h`wv'fcany "h`wv'fcany:w`wv' any transfer from children/grandchildren"
label val h`wv'fcany yesno

gen h`wv'tcamt=.
replace h`wv'tcamt =0 if h`wv'2child==.m | h`wv'2gchild==.m
replace h`wv'tcamt =.p if h`wv'2child==.p | h`wv'2gchild==.p
replace h`wv'tcamt = h`wv'2child + h`wv'2gchild if !mi(h`wv'2child) & !mi(h`wv'2gchild)
la var h`wv'tcamt "h`wv'tcamt:w`wv' amount of transfers to children/grandchildren"

gen h`wv'tcany=.
replace h`wv'tcany =0 if h`wv'tcamt == 0 | h`wv'ichild==.m | h`wv'gchild==.m
replace h`wv'tcany =.p if h`wv'2child==.p | h`wv'2gchild==.p
replace h`wv'tcany = 1 if inrange(h`wv'tcamt,1,999999999)
la var h`wv'tcany "h`wv'tcany:w`wv' any transfer to children/grandchildren"
label val h`wv'tcany yesno

drop h?ncchild


****************************************
****************************************
* help from relatives ce016 no ce015

gen h`wv'rela=ce016
replace h`wv'rela=.m if h`wv'rela==. & inw`wv' == 1
replace h`wv'rela=.p if mi(h`wv'rela) & cf007_w2==4

***************************
* help to relatives ce036 no ce035

gen h`wv'2rela=ce036
replace h`wv'2rela=.m if h`wv'2rela==.  & inw`wv' == 1
replace h`wv'2rela=.p if mi(h`wv'2rela) & cf007_w2==4

**************************
*****no help from/to other

******************************
****help from sibling

gen h`wv'other=ce072_w2
replace h`wv'other=.m if h`wv'other==. & inw`wv' == 1
replace h`wv'other=.p if mi(h`wv'other) & cf007_w2==4

******************************
****help to sibling

gen h`wv'2other=ce074_w2
replace h`wv'2other=.m if h`wv'2other==. & inw`wv' == 1
replace h`wv'2other=.p if mi(h`wv'2other) & cf007_w2==4


*****************************************
********===Relative Transfer/other transfer===**********
*****************************************

gen h`wv'foamt=.
replace h`wv'foamt =.m if h`wv'rela==.m | h`wv'other==.m
replace h`wv'foamt =.p if h`wv'rela==.p | h`wv'other==.p
replace h`wv'foamt = h`wv'rela + h`wv'other if !mi(h`wv'rela) & !mi(h`wv'other)
la var h`wv'foamt "h`wv'foamt:w`wv' amount of transfers from others"

gen h`wv'foany=0 if inw`wv' == 1
replace h`wv'foany =.m if h`wv'rela==.m | h`wv'other==.m
replace h`wv'foany =.p if h`wv'rela==.p | h`wv'other==.p
replace h`wv'foany = 1 if inrange(h`wv'foamt,1,999999999)
la var h`wv'foany "h`wv'foany:w`wv' any transfer from others"
label val h`wv'foany yesno

gen h`wv'toamt=.
replace h`wv'toamt =.m if h`wv'2rela==.m | h`wv'2other==.m
replace h`wv'toamt =.p if h`wv'2rela==.p | h`wv'2other==.p
replace h`wv'toamt =h`wv'2rela + h`wv'2other if !mi(h`wv'2rela) & !mi(h`wv'2other)
la var h`wv'toamt "h`wv'toamt:w`wv' amount of transfers to others"

gen h`wv'toany=0 if inw`wv' == 1
replace h`wv'toany =.m if h`wv'2rela==.m | h`wv'2other==.m
replace h`wv'toany =.p if h`wv'2rela==.p | h`wv'2other==.p
replace h`wv'toany = 1 if inrange(h`wv'toamt,1,999999999)
la var h`wv'toany "h`wv'toany:w`wv' any transfer to others"
label val h`wv'toany yesno

******************************
*****TOTAL Family transfer****
******************************
gen h`wv'frec=.
missing_H h`wv'par h`wv'parlaw h`wv'ichild h`wv'gchild h`wv'rela h`wv'other, result(h`wv'frec)
replace h`wv'frec = .p if h`wv'par == .p | h`wv'parlaw == .p | h`wv'ichild == .p | h`wv'gchild == .p | h`wv'rela == .p | h`wv'other == .p
replace h`wv'frec = h`wv'par + h`wv'parlaw + h`wv'ichild + h`wv'gchild + h`wv'rela + h`wv'other if !mi(h`wv'par) & !mi(h`wv'parlaw) & !mi(h`wv'ichild) & !mi(h`wv'gchild) & !mi(h`wv'rela) & !mi(h`wv'other)
label variable h`wv'frec "h`wv'frec:w`wv' total amount of transfers received"

gen h`wv'tgiv=.
missing_H h`wv'2par h`wv'2parlaw h`wv'2child h`wv'2gchild h`wv'2rela h`wv'2other, result(h`wv'tgiv)
replace h`wv'tgiv = .p if h`wv'2par == .p | h`wv'2parlaw == .p | h`wv'2child == .p | h`wv'2gchild == .p | h`wv'2rela == .p | h`wv'2other == .p
replace h`wv'tgiv = h`wv'2par + h`wv'2parlaw + h`wv'2child + h`wv'2gchild + h`wv'2rela + h`wv'2other if !mi(h`wv'2par) & !mi(h`wv'2parlaw) & !mi(h`wv'2child) & !mi(h`wv'2gchild) & !mi(h`wv'2rela) & !mi(h`wv'2other)
label variable h`wv'tgiv "h`wv'tgiv:w`wv' total amount of transfers given"

gen h`wv'ftot=.
missing_H h`wv'frec h`wv'tgiv, result(h`wv'ftot)
replace h`wv'ftot = .p if h`wv'frec == .p | h`wv'tgiv == .p
replace h`wv'ftot = h`wv'frec - h`wv'tgiv if !mi(h`wv'frec) & !mi(h`wv'tgiv)
label variable h`wv'ftot "h`wv'ftot:w`wv' net value of financial transfers"

drop w1* w2*
drop h`wv'par h`wv'parlaw h`wv'ichild h`wv'gchild h`wv'rela h`wv'other
drop h`wv'2par h`wv'2parlaw h`wv'2child h`wv'2gchild h`wv'2rela h`wv'2other




****drop CHARLS family information raw variables***
drop `family_w2_faminfo'

****drop CHARLS demog raw variables***
drop `family_w2_demog'

****drop CHARLS family transfer raw variables***
drop `family_w2_famtran'



label variable ID "id:person identifier/12-char"
label variable householdID "householdid:hhold id /10-char"

********************************************************************************************************************
***drop variables not using
drop hh?ahoub
drop hh?amrtb

***Update all value labels***
foreach v of var * {
	local vlabel : value label `v'
	if "`vlabel'" != "" {
		label define `vlabel' ///
			.v ".v:sp nr" ///
			.u ".u:unmar" ///
			.r ".r:refuse" ///
			.m ".m:missing" ///
			.s ".s:skip" ///
			.p ".p:proxy" ///
			.a ".a:age less 50" ///
			.d ".d:dk", modify
	}
}


***define variable order
order  ID ///
    householdID ///
    communityID ///
    hhidc ///
    hhid ///
    pnc ///
	pn ///
	id_w1 ///
	hhid_w1 ///
	s?id ///
	s?pn ///
	raspid? ///
	h?coupid ///
	inw? ///
	r?iwstat ///
	s?iwstat ///
	r?wthh ///
	r?wthhl ///
	r?wthha ///
	r?wtresp ///
	s?wtresp ///
	r?wtrespl ///
	s?wtrespl ///
	r?wtrespa ///
	s?wtrespa ///
	r?wtrespb ///
	s?wtrespb ///
	r?wtrespbioa ///
	s?wtrespbioa ///
	r?wtrespbiob ///
	s?wtrespbiob ///
	h?hhresp ///
	h?cpl ///
	r?iwy ///
	s?iwy ///
	r?iwm ///
	s?iwm ///
	rabday ///
	s?byear ///
	rabmonth ///
	s?bmonth ///
	rabyear ///
	s?bday ///
	rafbdate ///
	s?fbdate ///
	r?agey ///
	s?agey ///
	ragender ///
	s?gender ///
	rafgendr ///
	s?fgendr ///
	raeduc_c ///
	s?educ_c ///
	raedisced ///
	s?edisced ///
	r?mstat ///
	s?mstat ///
	r?mstath ///
	s?mstath ///
	r?mrct ///
	s?mrct ///
	r?mcurln ///
	s?mcurln ///
	rabplace_c ///
	s?bplace_c ///
	r?hukou ///
	s?hukou ///
	r?rural ///
	s?rural ///
	r?rural2 ///
	s?rural2 ///
   ///
	r?shlt ///
	s?shlt ///
	r?shltf ///
	s?shltf ///
	r?shlta ///
	s?shlta ///
	r?shltaf ///
	s?shltaf ///
	r?hlthlm_c ///
	s?hlthlm_c ///
	r?dressa ///
	s?dressa ///
	r?batha ///
	s?batha ///
	r?eata ///
	s?eata ///
	r?beda ///
	s?beda ///
	r?toilta ///
	s?toilta ///
	r?phonea ///
	s?phonea ///
	r?moneya ///
	s?moneya ///
	r?medsa ///
    s?medsa ///
	r?shopa ///
	s?shopa ///
	r?mealsa ///
	s?mealsa ///
	r?housewka ///
	s?housewka ///
	r?joga ///
	s?joga ///
	r?walk1kma ///
    s?walk1kma ///
	r?walk100a ///
	s?walk100a ///
	r?chaira ///
	s?chaira ///
	r?climsa ///
	s?climsa ///
	r?stoopa ///
	s?stoopa ///
	r?lifta ///
	s?lifta ///
	r?dimea ///
	s?dimea ///
	r?armsa ///
	s?armsa ///
	r?adla_c ///
	s?adla_c ///
	r?adlwa ///
	s?adlwa ///
	r?adlwam ///
	s?adlwam ///
	r?adlam_c ///
	s?adlam_c ///
	r?iadla ///
	s?iadla ///
	r?iadlam ///
	s?iadlam ///
	r?iadlza ///
	s?iadlza ///
	r?iadlzam ///
	s?iadlzam ///
	r?depresl ///
    s?depresl ///
	r?effortl ///
	s?effortl ///
	r?sleeprl ///
	s?sleeprl ///
	r?whappyl ///
	s?whappyl ///
	r?flonel ///
	s?flonel ///
	r?botherl ///
	s?botherl ///
	r?goingl ///
	s?goingl ///
	r?mindtsl ///
	s?mindtsl ///
	r?fhopel ///
	s?fhopel ///
	r?fearll ///
	s?fearll ///
	r?cesd10 ///
	s?cesd10 ///
	r?cesd10m ///
	s?cesd10m ///
	r?hibpe ///
	s?hibpe ///
	r?diabe ///
	s?diabe ///
	r?cancre ///
	s?cancre ///
	r?lunge ///
	s?lunge ///
	r?hearte ///
	s?hearte ///
	r?stroke ///
	s?stroke ///
	r?psyche ///
	s?psyche ///
	r?arthre ///
	s?arthre ///
	r?dyslipe ///
	s?dyslipe ///
	r?livere ///
	s?livere ///
	r?kidneye ///
	s?kidneye ///
	r?digeste ///
	s?digeste ///
	r?asthmae ///
	s?asthmae ///
	r?memrye ///
    s?memrye ///
    r?bmi ///
    s?bmi ///
	r?height ///
	s?height ///
	r?weight ///
	s?weight ///
	r?vgact_c ///
	s?vgact_c ///
	r?vgactx_c ///
	s?vgactx_c ///
	r?mdact_c ///
	s?mdact_c ///
	r?mdactx_c ///
	s?mdactx_c ///
	r?ltact_c ///
	s?ltact_c ///
	r?ltactx_c ///
	s?ltactx_c ///
	r?drink ///
	s?drink ///
	r?drinkl ///
	s?drinkl ///
	r?drinkx ///
	s?drinkx ///
	r?smokev ///
	s?smokev ///
	r?smoken ///
	s?smoken ///
    ///   
  r?hosp1y ///
  s?hosp1y ///
  r?hsptim1y ///
  s?hsptim1y ///
  r?hspnite ///
  s?hspnite ///
  r?doctor1m ///
  s?doctor1m ///
  r?doctim1m ///
  s?doctim1m ///
  r?dentst1y ///
  s?dentst1y ///
  r?dentim1y ///
  s?dentim1y ///
  r?oophos1y ///
  s?oophos1y ///
  r?tothos1y ///
  s?tothos1y ///
  r?oopdoc1m ///
  s?oopdoc1m ///
  r?totdoc1m ///
  s?totdoc1m ///
  r?oopden1y ///
  s?oopden1y ///
  r?totden1y ///
  s?totden1y ///
  r?higov ///
  s?higov ///
  r?hipriv ///
  s?hipriv ///
  r?hiothp ///
  s?hiothp /// 
    ///
  r?slfmem ///
  s?slfmem ///
  r?imrc ///
  s?imrc ///
  r?dlrc ///
  s?dlrc ///
  r?ser7 ///
  s?ser7 ///
  r?mo ///
  s?mo ///
  r?dy ///
  s?dy ///
  r?yr ///
  s?yr ///
  r?dw ///
  s?dw ///
  r?orient ///
  s?orient ///
  r?draw ///
  s?draw ///
  r?tr20 ///
  s?tr20 ///
  ///
  c????cpindex ///
  r?achck ///
  s?achck ///
  h?achck ///
  r?astck ///
  s?astck ///
  h?astck ///
  r?abond ///
  s?abond ///
  h?abond ///
  r?aothr ///
  s?aothr ///
  h?aothr ///
  r?adebt ///
  s?adebt ///
  h?adebt ///
  h?atotf ///
  hh?arles ///
  hh?arlfg  ///
  hh?atran ///
  hh?ahous ///
  hh?ahousa ///
  hh?afhousar ///
  hh?ahrto ///
  hh?amort ///
  hh?atoth ///
  hh?adurbl ///
  hh?afixc ///
  hh?aland ///
  hh?aagri ///
  hh?alend ///
  hh?aborr ///
  hh?aploan ///
  hh?afsst ///
  hh?afloa ///
  hh?afhhm ///
  hh?atotf ///
  hh?atotb ///
  ///
  r?iwagei ///
  s?iwagei ///
  r?iwagew ///
  s?iwagew ///
  r?iearn ///
  s?iearn ///
  h?iearn ///
  r?ifring ///
  s?ifring ///
  h?ifring ///
  r?isemp ///
  s?isemp ///
  h?isemp ///
  hh?iwageo ///
  hh?iagri ///
  hh?isemp ///
  hh?iearn ///
  r?ipeni ///
  s?ipeni ///
  r?ipenw ///
  s?ipenw ///
  r?ipen ///
  s?ipen ///
  h?ipen ///
  hh?ipeno ///
  hh?ipen ///
  r?igxfr ///
  s?igxfr ///
  h?igxfr ///
  hh?igxfro ///
  hh?igxfrh ///
  hh?igxfrt ///
  hh?igxfr ///
  r?iothr ///
  s?iothr ///
  h?iothr ///
  hh?iothro ///
  hh?iothr ///
  r?icap ///
  s?icap ///
  h?icap ///
  hh?icaph ///
  hh?icap ///
  hh?itot ///
  hh?cfood ///
  hh?cnf1m ///
  hh?cnf1y ///
  hh?ctot ///
  hh?cperc ///
  ///
  h?hhres ///
  h?son ///
  h?dau ///
  h?child ///
  h?dson ///
  h?ddau ///
  h?dchild ///
  r?livbro ///
  s?livbro ///
  r?livsis ///
  s?livsis ///
  r?livsib ///
  s?livsib ///
  r?decbro ///
  s?decbro ///
  r?decsis ///
  s?decsis ///
  r?decsib ///
  s?decsib ///
	r?momliv ///
	s?momliv ///
	r?dadliv ///
	s?dadliv ///
	r?livpar ///
	s?livpar ///
	r?momage ///
	s?momage ///
	r?dadage ///
	s?dadage ///
	h?fcany ///
	h?fcamt ///
	h?tcany ///
	h?tcamt ///
	h?fpany ///
	h?fpamt ///
	h?tpany ///
	h?tpamt ///
	h?foany ///
	h?foamt ///
	h?toany ///
	h?toamt ///
	h?frec ///
	h?tgiv ///
	h?ftot ///
	///
	r?work ///
	s?work ///
	r?work2 ///
	s?work2 ///
	r?lbrf_c ///
	s?lbrf_c ///
	r?slfemp ///
	s?slfemp ///
	r?retemp ///
	s?retemp ///
	r?jhours_c ///
	s?jhours_c ///
	r?jhour2 ///
	s?jhour2 ///
	r?jweeks_c ///
	s?jweeks_c
	
***compress dataset
compress	

***save output dataset
*save "`output'/H_CHARLS", replace
