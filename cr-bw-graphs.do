clear all
set more off

use "C:\Users\LIBDL-7\Documents\nj\colonialism\data\ready_main_data.dta" 

preserve
keep year alr gdp_pc log_alr log_gdp_pc year country
g ev = log_alr if year == 1990
g dv = log_gdp_pc if year == 1990
collapse (max) ev dv, by(country)
drop if dv <2.25
graph twoway (scatter dv ev, mlabel(country)) (lfit dv ev) , ///
xtick(3(1)5) scheme(s2mono) ///
legend(off) ytitle("log GDP per capita ") xtitle("Log Adult Literacy Rate ")
graph export "C:\Users\LIBDL-7\Documents\nj\colonialism\graphs\log_gdp_alr_1990.png", as(png) replace
restore

/*
*gr with se
cap drop colony_of
g colony_of = 0
replace colony_of = 1 if french
replace colony_of = 2 if british

collapse (mean) meanalr= alr (sd) sdalr=alr (count) n=alr, by(colony_of)
generate hialr = meanalr + invttail(n-1,0.025)*(sdalr / sqrt(n))
generate loalr = meanalr - invttail(n-1,0.025)*(sdalr / sqrt(n))

graph twoway (bar meanalr colony_of) (rcap hialr loalr colony_of),  ///
scheme(s2mono)
* made changes using graph editor

