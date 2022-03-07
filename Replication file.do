
* ols 
** ols+interaction variable 
gen intra_inter = w_b * b_any14
gen intra_inter2 = w_b*b_avjump
gen intra_inter3 = w_b*b_i0u

reg tax_pcap b_any14, cluster(prov8)
outreg2 using output2.doc, replace ctitle (Tax per capita)


reg tax_pcap b_any14 w_b intra_inter, cluster(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita)

reg tavoid_rate b_any14, cluster(prov08)
outreg2 using output2.doc, append ctitle (Tax Avoidance)

reg tavoid_rate b_any14 w_b intra_inter, cluster(prov08)
outreg2 using output2.doc, append ctitle (Tax Avoidance)


reg tax_pcap b_avjump, cluster(prov8)
outreg2 using output2.doc, replace ctitle (Tax per capita)

reg tax_pcap b_avjump w_b intra_inter2, cluster(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita)

reg tavoid_rate b_avjump, cluster(prov08)
outreg2 using output2.doc, append ctitle (Tax Avoidance)

reg tavoid_rate b_avjump w_b intra_inter2, cluster(prov08)
outreg2 using output2.doc, append ctitle (Tax Avoidance)


reg tax_pcap b_i0u, cluster(prov8)
outreg2 using output2.doc, replace ctitle (Tax per capita)

reg tax_pcap b_i0u w_b intra_inter3, cluster(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita)

reg tavoid_rate b_i0u, cluster(prov08)
outreg2 using output2.doc, append ctitle (Tax Avoidance)

reg tavoid_rate b_i0u w_b intra_inter3, cluster(prov08)
outreg2 using output2.doc, append ctitle (Tax Avoidance)



** FE with interaction variables 
ssc install reghdfe
ssc install ftools

reghdfe tax_pcap b_any14, absorb(prov08)
outreg2 using output2.doc, replace ctitle (Tax per capita) addtext(FE, province)

reghdfe tax_pcap b_any14 w_b intra_inter, absorb(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita) addtext(FE, province)

reghdfe tavoid_rate b_any14, absorb(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita) addtext(FE, province)

reghdfe tavoid_rate b_any14 w_b intra_inter, absorb(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita) addtext(FE, province)


reghdfe tax_pcap b_avjump, absorb(prov08)
outreg2 using output2.doc, replace ctitle (Tax per capita) addtext(FE, province)

reghdfe tax_pcap b_avjump w_b intra_inter2, absorb(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita) addtext(FE, province)

reghdfe tavoid_rate b_avjump, absorb(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita) addtext(FE, province)

reghdfe tavoid_rate b_avjump w_b intra_inter2, absorb(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita) addtext(FE, province)


reghdfe tax_pcap b_i0u, absorb(prov08)
outreg2 using output2.doc, replace ctitle (Tax per capita) addtext(FE, province)

reghdfe tax_pcap b_i0u w_b intra_inter3, absorb(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita) addtext(FE, province)

reghdfe tavoid_rate b_i0u, absorb(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita) addtext(FE, province)

reghdfe tavoid_rate b_i0u w_b intra_inter3, absorb(prov08)
outreg2 using output2.doc, append ctitle (Tax per capita) addtext(FE, province)



* summary statistics 
sum b_any14 b_avjump b_i0u w_any14 w_avjump w_i0u w_b tax_pcap tavoid_rate if treatment == 1 

bysort treatment: 

outreg2 using output3.doc, word replace sum(log) eqkeep(N mean sd) keep(b_any14 b_avjump b_i0u w_any14 w_avjump w_i0u w_b tax_pcap tavoid_rate)

twoway scatter b_i0u b_avjump b_any14, title(Relationship between Three Measurements)



* ols + fe - mlm 
grstyle init
grstyle set plain, horizontal grid
sysuse auto, clear

reg b_any14 w_b
predict yhat, xb 
twoway (scatter b_any14 w_b)(line yhat w_b), title (Within Group and Between Group Inequality) ytitle(Intra-Black Inequality) xtitle(Racial Inequality between Black and White)

* rd - plot 

twoway (scatter treatment b_any14), xline(.255) title (Probability Distribution) ytitle (Treatment) xtitle(Intra-Black ANY(1,4))
graph save rd1,  replace

twoway (scatter treatment b_avjump), xline(.17) title (Probability Distribution) ytitle (Treatment) xtitle(Intra-Black Average Jump)

twoway (scatter treatment b_i0u), xline(.62) title (Probability Distribution) ytitle (Treatment) xtitle(Intra-Black Cowell Flachair(0))


separate tax_pcap, by(treatment)
separate tavoid_rate, by(treatment)

twoway scatter tax_pcap0 tax_pcap1 b_any14, xline(.255)

twoway scatter tavoid_rate0 tavoid_rate1 b_any14, xline(.255)

**tax per capita 
gen treatment = 1 
replace treatment = 0 if homeland == 1 

gen intrab = b_any14 -0.255 
gen intrabh = 1 if intrab >=0 
replace intrabh = 0 if intrabh < 0 

gen inter_intra = intrab * w_b 

rdplot tax_pcap intrab, c(0) p(1) ci(95) graph_options(title(Parametric Method)) 
graph save rd1,  replace
rdplot tax_pcap intrab, c(0) p(2) ci(95) graph_options(title(Second-Order))
graph save rd2,  replace
rdplot tax_pcap intrab, c(0) p(3) ci(95) graph_options(title(Third-Order))
graph save rd3,  replace
rdplot tax_pcap intrab, c(0) p(4) ci(95) graph_options(title(Forth-Order))
graph save rd4,  replace
graph  combine rd1.gph rd2.gph rd3.gph rd4.gph 


** tavoid_rate
twoway scatter tavoid_rate intrab
rdplot tavoid_rate intrab, c(0) p(1) graph_options(title(Parametric Method)) 
graph save rd1,  replace

rdplot tavoid_rate intrab, c(0) p(2) graph_options(title(Second-Order))
graph save rd2,  replace

rdplot tavoid_rate intrab, c(0) p(3) graph_options(title(Third-Order))
graph save rd3,  replace

rdplot tavoid_rate intrab, c(0) p(4) graph_options(title(Fourth-Order))
graph save rd4,  replace

graph  combine rd1.gph rd2.gph rd3.gph rd4.gph 


* rdrobust
ssc install st0435.pkg

rdrobust tavoid_rate intrab, fuzzy(treatment) kernel(uniform) p(1) bwselect(mserd) vce(cluster provid) covs(prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, replace ctitle (tax avoidance rate) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tax_pcap intrab, fuzzy(treatment) kernel(uniform) p(1) bwselect(mserd) vce(cluster provid) covs(prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, append ctitle (tax per capita) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tavoid_rate intrab, fuzzy(treatment) kernel(uniform) h(0.2) vce(cluster provid) covs(w_b intra_inter prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, append ctitle (tax avoidance rate) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tax_pcap intrab, fuzzy(treatment) kernel(uniform) h(0.2) vce(cluster provid) covs(w_b intra_inter prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, append ctitle (tax per capita) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))


*** i0u 

gen intrab2 = b_i0u - 0.624
gen intrabh2 = 1 if intrab2 >=0 
replace intrabh2 = 0 if intrab2 < 0 

gen inter_intra2 = intrab2 * w_b 

rdrobust tavoid_rate intrab2, fuzzy(treatment) kernel(uniform) p(1) h(1) vce(cluster provid) covs(prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output2.doc, replace ctitle (tax avoidance rate) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tax_pcap intrab2, fuzzy(treatment) kernel(uniform) p(1) bwselect(mserd) vce(cluster provid) covs(prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output2.doc, append ctitle (tax per capita) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tavoid_rate intrab2, fuzzy(treatment) kernel(uniform) p(1) h(1) bwselect(mserd) vce(cluster provid) covs(w_b inter_intra2 prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output2.doc, append ctitle (tax avoidance rate) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tax_pcap intrab2, fuzzy(treatment) kernel(uniform) p(1) h(1) bwselect(mserd) vce(cluster provid) covs(w_b w_b inter_intra2 prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output2.doc, append ctitle (tax per capita) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

*** avjump

gen intrab3 = b_avjump - 0.17
gen intrabh3 = 1 if intrab3 >=0 
replace intrabh3 = 0 if intrab3 < 0 

gen inter_intra3 = intrab3 * w_b 

rdrobust tavoid_rate intrab3, fuzzy(treatment) kernel(uniform) p(1) h(1) bwselect(mserd) vce(cluster provid) covs(prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output2.doc, replace ctitle (tax avoidance rate) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tax_pcap intrab3, fuzzy(treatment) kernel(uniform) p(1) h(1) bwselect(mserd) vce(cluster provid) covs(prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output2.doc, append ctitle (tax per capita) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tavoid_rate intrab3, fuzzy(treatment) kernel(uniform) p(1) h(1) bwselect(mserd) vce(cluster provid) covs(w_b inter_intra3 prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output2.doc, append ctitle (tax avoidance rate) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tax_pcap intrab3, fuzzy(treatment) kernel(uniform) p(1) h(1) bwselect(mserd) vce(cluster provid) covs(w_b w_b inter_intra3 prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output2.doc, append ctitle (tax per capita) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))


rdplot tavoid_rate intrab, c(0) p(1) graph_options(title(ANY(1,4))) 
graph save rd1,  replace

rdplot tavoid_rate intrab2, c(0) p(1) graph_options(title(Cowell Flachair(0)))
graph save rd2,  replace

rdplot tavoid_rate intrab3, c(0) p(1) graph_options(title(Average Jump))
graph save rd3,  replace

graph  combine rd1.gph rd2.gph rd3.gph

* robustness check 
rdrobust tavoid_rate intrab, fuzzy(treatment) kernel(uniform) p(1) h(0.5) vce(cluster provid) covs(prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, replace ctitle (tax avoidance rate) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tax_pcap intrab, fuzzy(treatment) kernel(uniform) p(1) h(0.5) vce(cluster provid) covs(prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, append ctitle (tax per capita) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tavoid_rate intrab, fuzzy(treatment) kernel(uniform) h(0.5) vce(cluster provid) covs(w_b intra_inter prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, append ctitle (tax avoidance rate) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tax_pcap intrab, fuzzy(treatment) kernel(uniform) h(0.5) vce(cluster provid) covs(w_b intra_inter prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, append ctitle (tax per capita) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))


//
rdrobust tavoid_rate intrab, fuzzy(treatment) kernel(uniform) p(1) h(0.05) vce(cluster provid) covs(prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, replace ctitle (tax avoidance rate) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tax_pcap intrab, fuzzy(treatment) kernel(uniform) p(1) h(0.05) vce(cluster provid) covs(prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, append ctitle (tax per capita) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tavoid_rate intrab, fuzzy(treatment) kernel(uniform) h(0.05) vce(cluster provid) covs(w_b intra_inter prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, append ctitle (tax avoidance rate) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))

rdrobust tax_pcap intrab, fuzzy(treatment) kernel(uniform) h(0.05) vce(cluster provid) covs(w_b intra_inter prov1 prov2 prov3 prov4 prov5 prov6 prov7 prov8)
outreg2 using output1.doc, append ctitle (tax per capita) addtext(Kernel, uniform, FE, province) addstat(Mean dep. var., r(mean), Observations, e(N), Bandwidth, e(h_l), Order polyn., e(p))
