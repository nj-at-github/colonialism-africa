/*
*******************************************************************
***  .do file for Appendix Colonization- Africa paper ***
*******************************************************************

base data - dv sheet from main-data_2.xlsx

*/

set more off
cap log close

log using "C:\Users\LIBDL-7\Documents\nj\colonialism\latest-no2020-appendix-latest-an-all-tables.txt", t replace

cap mkdir "C:\Users\LIBDL-7\Documents\nj\colonialism\results\appendix\"
cap mkdir "C:\Users\LIBDL-7\Documents\nj\colonialism\results\appendix\no2020\"
*******************
*** Load data   ***
*******************
// main data
*import excel "C:\Users\Nikhil Jha\Documents\nj-folder\research\colonisation\main-data_2.xlsx", sheet("dv") first clear
import excel "C:\Users\LIBDL-7\Documents\nj\colonialism\data\main-data_2.xlsx", ///
sheet("dv") first clear
cap drop O
cap drop P
*tolower COUNTRY BritishColony-Polityscorewithnoimputations
rename *, lower
* drop if year missing
count
count if year == .
cap drop if year == .


*******************
*** Modify data ***
*******************

*development aid in millions
replace netofficialdevelopmentassista = netofficialdevelopmentassista /1000000
 
* shorter names
rename gdppercapita gdp_pc                
rename governmentexpenditureoneducat govt_exp  	
rename primaryenrollmentratio enroll_ratio		         
rename employmentinindustryasaperc	empl_ind
rename netofficialdevelopmentassista dev_aid   		
rename numberofindividualsusingthe internet    	               		
             
foreach v of varlist alr-internet{
	g log_`v' = log(`v')
}
 
*for xt
cap drop cid
encode country, g(cid)
xtset cid year, delta(10)

************* drop 2020
drop if year == 2020
 

* govt_exp fewer data
global levelcontrols lag_alr gdp_pc enroll_ratio empl_ind dev_aid
global logcontrols log_lag_alr log_gdp_pc log_enroll_ratio log_empl_ind log_dev_aid

*******************
*** Main Tables ***
*******************

/*
*Table 1. Summary Statistics

outreg2 using "C:\Users\LIBDL-7\Documents\nj\colonialism\results\appendix\no2020\summary_stat", sum(log) see excel replace

*/

*Table 2. Main results
*Level*************

xtreg alr lag_alr french british , re vce(clus country)
est sto level_main0

xtreg alr $levelcontrols govt_exp french british , re vce(clus country)
est sto level_main1

xtreg alr $levelcontrols govt_exp polityscore  french british , re vce(clus country)
est sto level_main2

xtreg alr $levelcontrols govt_exp polityscore internet french british , re vce(clus country)
est sto level_main3

xtreg alr $levelcontrols govt_exp polityscore internet french british i.year, re vce(clus country)
est sto level_main4

est table level_main?, p(%9.2f)

outreg2 [level_main?] using "C:\Users\LIBDL-7\Documents\nj\colonialism\results\appendix\no2020\appendix-table2_level",  see word replace

*** Pooled or RE
reg alr $levelcontrols govt_exp polityscore internet french british , vce(clus country)
xtreg alr $levelcontrols govt_exp polityscore internet french british , re vce(clus country)
xttest0


*Log*************

xtreg log_alr log_lag_alr french british , re vce(clus country)
est sto log_main0

xtreg log_alr $logcontrols log_govt_exp french british , re vce(clus country)
est sto log_main1

xtreg log_alr $logcontrols log_govt_exp polityscore  french british , re vce(clus country)
est sto log_main2

xtreg log_alr $logcontrols log_govt_exp polityscore log_internet french british , re vce(clus country)
est sto log_main3

xtreg log_alr $logcontrols log_govt_exp polityscore log_internet french british i.year , re vce(clus country)
est sto log_main4

est table log_main?, p(%9.2f)

outreg2 [log_main?] using "C:\Users\LIBDL-7\Documents\nj\colonialism\results\appendix\no2020\table2_log",  see word replace

*** Pooled or RE
reg log_alr $logcontrols log_govt_exp polityscore internet french british , vce(clus country)
xtreg log_alr $logcontrols log_govt_exp polityscore internet french british , re vce(clus country)
xttest0

* Table Pooled or RE***************

reg alr $levelcontrols govt_exp polityscore internet french british , vce(clus country)
est sto level_pooled
xtreg alr $levelcontrols govt_exp polityscore internet french british , re vce(clus country)
est sto level_RE

reg log_alr $logcontrols log_govt_exp polityscore internet french british , vce(clus country)
est sto log_pooled
xtreg log_alr $logcontrols log_govt_exp polityscore internet french british , re vce(clus country) 
est sto log_RE
outreg2 [level_pooled level_RE log_pooled log_RE] using "C:\Users\LIBDL-7\Documents\nj\colonialism\results\appendix\no2020\Pooled_RE_level_log",  see word replace


*Table 3. Mundalk

tabulate year, generate(year_dum)

mundlak log_alr $logcontrols log_govt_exp polityscore log_internet french british year_dum*,  use( log_gdp_pc log_enroll_ratio log_govt_exp log_empl_ind log_dev_aid polityscore log_internet) se nocomp


est sto log_mundalk

est table log_main3 log_mundalk, p(%9.2f)

outreg2 [log_main3 log_mundalk] using "C:\Users\LIBDL-7\Documents\nj\colonialism\results\appendix\no2020\table3",  see word replace

*Table 4. Model for Internet and ALR
 
// need to drop all internet values of 0 in the long data + merge ALR and RE, FE, FE interactions

* merge internet data
g name_from_main = country 
cap drop internet
merge 1:1 name_from_main year using "C:\Users\LIBDL-7\Documents\nj\colonialism\data\ready_alr_internet.dta", keepusing(internet)

*** drop 2020
drop if year == 2020

reg log_alr log_internet c.log_internet#britishcolony c.log_internet#frenchcolony , vce(clus cid)
est sto ols

xtreg log_alr log_internet c.log_internet#britishcolony c.log_internet#frenchcolony , re vce(clus cid)
est sto logre

xtreg log_alr log_internet c.log_internet#britishcolony c.log_internet#frenchcolony  , fe vce(clus cid)
est sto logfe

est table *ols *re *fe, p(%9.2f)



*code for internet
// not working - xtset cid year

xtreg log_alr log_lag_alr log_internet britishcolony frenchcolony i.year, re vce(clus cid)
est sto no_inte_re_log_internet

xtreg log_alr log_lag_alr log_internet britishcolony frenchcolony c.log_internet#i.britishcolony c.log_internet#i.frenchcolony i.year, re vce(clus cid)
est sto re_log_internet

// need these for Mundalk models - but Mundalk complains when trying to xtset after this since interactions will be 0 for interactions
cap drop bri_net
g bri_net = log_internet*britishcolony
cap drop fre_net
g fre_net = log_internet*frenchcolony

xtreg log_alr $logcontrols log_govt_exp polityscore log_internet britishcolony frenchcolony c.log_internet#i.britishcolony c.log_internet#i.frenchcolony , vce(clus cid )
est sto recontrols_log_internet

/*
mundlak log_alr $logcontrols log_govt_exp polityscore log_internet britishcolony frenchcolony  bri_net fre_net year_dum*,  use( log_gdp_pc log_enroll_ratio log_govt_exp log_empl_ind log_dev_aid polityscore log_internet ) se nocomp
est sto mundlak_log_internet
*/

// keep only those observations that get used with controls
preserve
qui xtreg log_alr $logcontrols log_govt_exp polityscore log_internet  britishcolony frenchcolony c.log_internet#i.britishcolony c.log_internet#i.frenchcolony i.year, fe vce(clus cid )
keep if e(sample) 

xtreg log_alr /*$logcontrols log_govt_exp polityscore */ log_internet britishcolony frenchcolony c.log_internet#i.britishcolony c.log_internet#i.frenchcolony i.year , fe vce(clus cid )
est sto fe_log_internet

xtreg log_alr $logcontrols log_govt_exp polityscore log_internet  britishcolony frenchcolony c.log_internet#i.britishcolony c.log_internet#i.frenchcolony i.year, fe vce(clus cid )
est sto fecontrols_log_internet

est table no_inte_re_log_internet re_log_internet recontrols_log_internet   fe_log_internet  fecontrols_log_internet , p(%9.2f)

outreg2 [re_log_internet recontrols_log_internet  fe_log_internet  fecontrols_log_internet] using "C:\Users\LIBDL-7\Documents\nj\colonialism\results\appendix\no2020\internet_interactions",  see word replace

restore


* diff do file
preserve

use "C:\Users\LIBDL-7\Documents\nj\colonialism\data\ready_alr_internet.dta", clear
xtset cid year

************* drop 2020
drop if year == 2020
 
cap drop interFr
g interFr = internet*frenchcolony
cap drop interBr
g interBr = internet*britishcolony

cap drop lalr
g lalr = log(alr)
cap drop linternet
g linternet = log(internet)

cap drop colonizer
g colonizer = "British" if britishcolony
replace colonizer = "French" if colonizer == ""

// get alr in the nearest year in the data for each country
// then use this to fill for all years
bys cid: g lag_alr = alr[_n-1]
bys cid: egen initial_alr = min(lag_alr)

xtreg lalr /*initial_alr*/ linternet britishcolony frenchcolony  i.year , re vce(clus cid)
est sto no_interaction_re

xtreg lalr /*initial_alr*/  linternet britishcolony frenchcolony  c.linternet#britishcolony c.linternet#frenchcolony i.year, re vce(clus cid)
est sto linternet_re

// keep only those observations that get used with controls
keep if e(sample)

xtreg lalr /*initial_alr*/  linternet i.year, fe vce(clus cid)
est sto linternet_fe

xtreg lalr /*initial_alr*/  linternet britishcolony frenchcolony  c.linternet#britishcolony c.linternet#frenchcolony i.year, fe vce(clus cid)
est sto linternet_interact_fe

est table no_interaction_re linternet_re linternet_fe linternet_interact_fe, p(%9.2f)

outreg2 [no_interaction_re linternet_re linternet_fe linternet_interact_fe] using "C:\Users\LIBDL-7\Documents\nj\colonialism\results\appendix\no2020\L-internet_interactions",  see word replace

restore
********************************************
*** Supplementary Online Appendix Tables ***
********************************************

/*



* with polityscore lose lot of obsv - and so replace log_polityscore = log(polityscore + 1) if log_polityscore == .
* put in appendix
xtreg alr $levelcontrols govt_exp polityscore  french british , re vce(clus country)
est sto level_nogovexp

xtreg alr $loglevelcontrols log_govt_exp polityscore french british , re vce(clus country)
est sto log_nogovexp

est table level_nogovexp log_nogovexp, p(%9.2f)

outreg2 [level_nogovexp log_nogovexp] using "C:\Users\LIBDL-7\Documents\nj\colonialism\results\appendix_1.1",  see word replace
*/

cap log close
*eof
