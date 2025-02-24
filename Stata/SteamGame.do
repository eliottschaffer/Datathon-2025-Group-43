***** gain some intuitions
tabulate price owners, chi2
spearman price owners

***** partial cleaning
misstable summarize owners price developer publisher
drop if missing(owners, price, developer, publisher)
tab dev_id
tab pub_id
encode developer, gen(dev_id)
encode publisher, gen(pub_id)
list developer dev_id if dev_id == .
gen r_price = price/100
order r_price, before(price)
gen n_owners =.
order n_owners, before(owners)
destring positive, replace
destring negative, replace
** method from https://greyaliengames.com/blog/how-to-estimate-how-many-sales-a-steam-game-has-made/
replace n_owners = 106 * (positive + negative) if price > 0
replace n_owners = 201 * (positive + negative) if price == 0
** make the predictions align with original intervals
replace n_owners = 50000 if (owners == "20,000 .. 50,000" & n_owners > 50000)
replace n_owners = 100000 if (owners == "50,000 .. 100,000" & n_owners > 100000)
replace n_owners = 200000 if (owners == "100,000 .. 200,000" & n_owners > 200000)
replace n_owners = 500000 if (owners == "200,000 .. 500,000" & n_owners > 500000)
replace n_owners = 1000000 if (owners == "500,000 .. 1,000,000" & n_owners > 1000000)
replace n_owners = 2000000 if (owners == "1,000,000 .. 2,000,000" & n_owners > 2000000)
replace n_owners = 5000000 if (owners == "2,000,000 .. 5,000,000" & n_owners > 5000000)
replace n_owners = 20000000 if (owners == "10,000,000 .. 20,000,000" & n_owners > 20000000)
replace n_owners = 50000000 if (owners == "20,000,000 .. 50,000,000" & n_owners > 50000000)
replace n_owners = 100000000 if (owners == "50,000,000 .. 100,000,000" & n_owners > 100000000)
replace n_owners = 200000000 if (owners == "100,000,000 .. 200,000,000" & n_owners > 200000000)
replace n_owners = positive + negative if price > 100
scatter n_owners n_owners
    xlabel() ylabel(, angle(0)) ///
    msymbol(o)
bysort price: appid

reg n_owners initialprice, beta
scatter n_owners r_price
reg n_owners r_price if r_price <= 120, beta

drop if name == "NA"
drop if english == "NA"
drop if ccu == "NA"
bysort crossplatformmultiplayer: appid
replace english = 1 if english == "1"
destring screenshots, replace
destring english, replace
destring indie, replace
destring german, replace
destring french, replace
destring russian, replace
destring japanese, replace
destring italian, replace
destring korean, replace
destring coop, replace
destring pvp, replace
destring casual, replace
destring ccu, replace
destring metacriticscore, replace
destring achievements, replace
destring recommendations, replace
destring movies english simplifiedchinese, replace
destring spanishspain traditionalchinese singleplayer familysharing steamachievements, replace
destring vronly, replace
destring onlinecoop, replace
destring fullcontrollersupport steamtradingcards inapppurchases multiplayer, replace
destring sharedsplitscreenpvp sharedsplitscreencoop sharedsplitscreen remoteplaytogether, replace
destring trackedcontrollersupport partialcontrollersupport lanpvp steamcloud steamleaderboards, replace
destring lancoop remoteplayontablet vrsupported valveanticheatenabled stats onlinepvp mmo, replace
destring crossplatformmultiplayer captionsavailable commentaryavailable steamworkshop, replace
destring remoteplayontv includesleveleditor remoteplayonphone vrsupport steamturnnotifications, replace

***** regression
reg n_owners average_forever average_2weeks median_forever median_2weeks r_price discount /// 
 metacriticscore achievements i.singleplayer i.familysharing i.steamachievements ///
 i.fullcontrollersupport i.steamtradingcards i.inapppurchases i.multiplayer i.onlinecoop i.pvp ///  
 i.sharedsplitscreenpvp i.sharedsplitscreencoop i.sharedsplitscreen i.remoteplaytogether /// 
 i.trackedcontrollersupport i.vronly i.partialcontrollersupport i.steamcloud i.steamleaderboards ///
 i.lancoop i.remoteplayontablet i.vrsupported i.valveanticheatenabled i.stats i.onlinepvp ///
 i.mmo i.crossplatformmultiplayer i.captionsavailable i.commentaryavailable i.steamworkshop ///
 i.remoteplayontv i.includesleveleditor i.remoteplayonphone ///
 i.vrsupport i.steamturnnotifications i.includessourcesdk i.hdravailable i.steamtimeline ///
 i. mods i.steamvrcollectibles i.modsrequirehl2 i.adventure i.casual i.indie i.rpg ///
 i.freetoplay i.action i.strategy i.earlyaccess i.simulation i.racing i.massivelymultiplayer ///
 i.education i.gamedevelopment i.audioproduction i.gore i.designillustration i.videoproduction ///
 i.sexualcontent i.nudity i.webpublishing i.softwaretraining i.movie language_n platform_n


***** random forest 1 failed
frame create train1
frame change train1
use "/Users/Mahiru/Downloads/Steam_training.dta", clear

frame create test
frame change test
use "/Users/Mahiru/Downloads/Steam_testing.dta", clear

net install rforest, from("https://raw.github.com/mdroste/stata-rforest/main/")
net search rforest

frame change train1
rforest n_owners r_price, type(reg)

frame change test
predict rf_n_owners

***** random forest 2 - cleaned some data
frame create train2
frame change train2
use "/Users/Mahiru/Downloads/Steam_training.dta", clear
bysort pvp: appid
drop if recommendations == "NA"
drop if pvp == "NA"
describe n_owners r_price recommendations pvp
destring pvp, replace
destring recommendations, replace

tab recommendations, generate(rec_)
tab pvp, generate(pvp_)

use "/Users/Mahiru/Downloads/Steam_testing.dta", clear
describe n_owners r_price recommendations pvp
drop if recommendations == "NA"
drop if pvp == "NA"
destring pvp, replace
destring recommendations, replace

frame create train2
frame change train2
use "/Users/Mahiru/Downloads/Steam_training.dta", clear
rforest n_owners r_price pvp recommendations, type(class) depth(7)


frame create test2
frame change test2
use "/Users/Mahiru/Downloads/Steam_testing.dta", clear
predict rf_n_owners2

bysort rf_n_owners2: appid

gen error = n_owners - rf_n_owners2
gen error_sq = error^2
sum error_sq
di "MSE = " r(mean)

***** random forest 3
frame create train3
frame change train3
use "/Users/Mahiru/Downloads/Steam_training.dta", clear
bysort pvp: appid
drop if recommendations == "NA"
drop if pvp == "NA"
destring pvp, replace
destring recommendations, replace
describe n_owners r_price recommendations pvp
rforest n_owners r_price pvp recommendations, type(class) depth(7)

set java_heapmax 8g
keep n_owners r_price pvp recommendations
keep if r_price < 120
keep if _n <= 10000

frame create test3
frame change test3
use "/Users/Mahiru/Downloads/Steam_testing.dta", clear
drop if recommendations == "NA"
drop if pvp == "NA"
destring pvp, replace
destring recommendations, replace
describe n_owners r_price recommendations pvp
predict rf_n_owners3
bysort rf_n_owners3: appid

gen error = n_owners - rf_n_owners3
gen error_sq = error^2
sum error_sq
di "MSE = " r(mean) 

describe

scatter n_owners n_owners

***** random forest 4 - cleaned dataset & rforest regression
frame create train_lasso
frame change train_lasso
use "/Users/Mahiru/Documents/Stata/lasso_selected_training.dta", clear
describe
ds
rforest n_owners average_forever average_2weeks median_forever median_2weeks r_price discount /// 
 metacriticscore achievements singleplayer familysharing steamachievements fullcontrollersupport ///
 steamtradingcards inapppurchases multiplayer onlinecoop pvp sharedsplitscreenpvp /// 
 sharedsplitscreencoop sharedsplitscreen remoteplaytogether trackedcontrollersupport vronly ///
 partialcontrollersupport steamcloud steamleaderboards lancoop remoteplayontablet vrsupported ///
 valveanticheatenabled stats onlinepvp mmo crossplatformmultiplayer captionsavailable ///
 commentaryavailable steamworkshop remoteplayontv includesleveleditor remoteplayonphone ///
 vrsupport steamturnnotifications includessourcesdk hdravailable steamtimeline mods ///
 steamvrcollectibles modsrequirehl2 adventure casual indie rpg freetoplay action strategy ///
 earlyaccess simulation racing massivelymultiplayer education gamedevelopment audioproduction ///
 gore designillustration videoproduction sexualcontent nudity webpublishing softwaretraining ///
 movie language_n platform_n, type(reg)

frame create test_lasso
frame change test_lasso
use "/Users/Mahiru/Documents/Stata/lasso_selected_testing.dta", clear
describe
predict owners

gen error = n_owners - owners
gen error_sq = error^2 
sum error_sq
di "MSE = " r(mean)

scatter n_owners owners 

***** random forest 5 - control n_owners <= 50,000
*** MSE = 73520141 R-squared = -.08805414
frame create train_lasso2
frame change train_lasso2
use "/Users/Mahiru/Documents/Stata/lasso_selected_training.dta", clear
describe
drop if n_owners > 50000
ds
rforest n_owners average_forever average_2weeks median_forever median_2weeks r_price discount /// 
 metacriticscore achievements singleplayer familysharing steamachievements fullcontrollersupport ///
 steamtradingcards inapppurchases multiplayer onlinecoop pvp sharedsplitscreenpvp /// 
 sharedsplitscreencoop sharedsplitscreen remoteplaytogether trackedcontrollersupport vronly ///
 partialcontrollersupport steamcloud steamleaderboards lancoop remoteplayontablet vrsupported ///
 valveanticheatenabled stats onlinepvp mmo crossplatformmultiplayer captionsavailable ///
 commentaryavailable steamworkshop remoteplayontv includesleveleditor remoteplayonphone ///
 vrsupport steamturnnotifications includessourcesdk hdravailable steamtimeline mods ///
 steamvrcollectibles modsrequirehl2 adventure casual indie rpg freetoplay action strategy ///
 earlyaccess simulation racing massivelymultiplayer education gamedevelopment audioproduction ///
 gore designillustration videoproduction sexualcontent nudity webpublishing softwaretraining ///
 movie language_n platform_n, type(reg) depth(10)

frame create test_lasso2
frame change test_lasso2
use "/Users/Mahiru/Documents/Stata/lasso_selected_testing.dta", clear
drop if n_owners > 50000
predict owners

gen error = n_owners - owners
gen error_sq = error^2 
sum error_sq
di "MSE = " r(mean)
generate residual = n_owners - owners
summarize residual, meanonly
scalar MSE = r(mean)^2
generate sq_resid = residual^2
summarize sq_resid, meanonly
scalar MSE = r(mean)
display "MSE = " MSE
summarize n_owners, detail
scalar var_y = 6.64e+07
display "Variance of y = " var_y
scalar R2 = 1 - (MSE/var_y)
display "R-squared = " R2

scatter n_owners owners 

***** random forest 6 - log version
*** MSE = 75985107 R-squared = -.1456714
frame create train_lasso3
frame change train_lasso3
use "/Users/Mahiru/Documents/Stata/lasso_selected_training.dta", clear
drop if n_owners > 50000
gen log_n_owners = log(n_owners)
drop if log_n_owners ==.
rforest log_n_owners average_forever average_2weeks median_forever median_2weeks r_price discount /// 
 metacriticscore achievements singleplayer familysharing steamachievements fullcontrollersupport ///
 steamtradingcards inapppurchases multiplayer onlinecoop pvp sharedsplitscreenpvp /// 
 sharedsplitscreencoop sharedsplitscreen remoteplaytogether trackedcontrollersupport vronly ///
 partialcontrollersupport steamcloud steamleaderboards lancoop remoteplayontablet vrsupported ///
 valveanticheatenabled stats onlinepvp mmo crossplatformmultiplayer captionsavailable ///
 commentaryavailable steamworkshop remoteplayontv includesleveleditor remoteplayonphone ///
 vrsupport steamturnnotifications includessourcesdk hdravailable steamtimeline mods ///
 steamvrcollectibles modsrequirehl2 adventure casual indie rpg freetoplay action strategy ///
 earlyaccess simulation racing massivelymultiplayer education gamedevelopment audioproduction ///
 gore designillustration videoproduction sexualcontent nudity webpublishing softwaretraining ///
 movie language_n platform_n, type(reg) depth(10)
frame create test_lasso3
frame change test_lasso3
use "/Users/Mahiru/Documents/Stata/lasso_selected_testing.dta", clear
drop if n_owners > 50000
predict pred_log_n_owners
gen pred_n_owners = exp(pred_log_n_owners) - 1

gen error = n_owners - pred_n_owners
gen error_sq = error^2 
sum error_sq
di "MSE = " r(mean)

generate residual = n_owners - pred_n_owners
summarize residual, detail
scalar MSE = r(mean)^2
generate sq_resid = residual^2
summarize sq_resid, meanonly
scalar MSE = r(mean)
display "MSE = " MSE
summarize n_owners, detail
scalar var_y = 6.63e+07
display "Variance of y = " var_y
scalar R2 = 1 - (MSE/var_y)
display "R-squared = " R2

****** random forest 7 -  cross validation ver
*** MSE = 6989959
frame change test_lasso3
use "/Users/Mahiru/Documents/Stata/lasso_selected.dta", clear
gen log_n_owners = log(n_owners + 1)
gen rand_num = runiform()
gen train = rand_num < 0.8   // 80% training, 20% testing
drop if log_n_owners ==.
rforest log_n_owners average_forever average_2weeks median_forever median_2weeks r_price discount /// 
 metacriticscore achievements singleplayer familysharing steamachievements fullcontrollersupport ///
 steamtradingcards inapppurchases multiplayer onlinecoop pvp sharedsplitscreenpvp /// 
 sharedsplitscreencoop sharedsplitscreen remoteplaytogether trackedcontrollersupport vronly ///
 partialcontrollersupport steamcloud steamleaderboards lancoop remoteplayontablet vrsupported ///
 valveanticheatenabled stats onlinepvp mmo crossplatformmultiplayer captionsavailable ///
 commentaryavailable steamworkshop remoteplayontv includesleveleditor remoteplayonphone ///
 vrsupport steamturnnotifications includessourcesdk hdravailable steamtimeline mods ///
 steamvrcollectibles modsrequirehl2 adventure casual indie rpg freetoplay action strategy ///
 earlyaccess simulation racing massivelymultiplayer education gamedevelopment audioproduction ///
 gore designillustration videoproduction sexualcontent nudity webpublishing softwaretraining ///
 movie language_n platform_n if train == 1, type(reg)
predict owners if train == 0
gen pred_n_owners = exp(owners) - 1
gen error_sq = (n_owners - pred_n_owners)^2 if train == 0
sum error_sq
di "MSE = " r(mean)

***** predict categories but laptop crashed..
use "/Users/Mahiru/Documents/Stata/lasso_selected.dta"
gen c_owners =.
replace c_owners = 1 if (n_owners >= 0 & n_owners <= 20000)
replace c_owners = 2 if (n_owners >= 20001 & n_owners <= 50000)
replace c_owners = 3 if (n_owners >= 50001 & n_owners <= 100000)
replace c_owners = 4 if (n_owners >= 100001 & n_owners <= 200000)
replace c_owners = 5 if (n_owners >= 200001 & n_owners <= 500000)
replace c_owners = 6 if (n_owners >= 500001 & n_owners <= 1000000)
replace c_owners = 7 if (n_owners >= 1000001 & n_owners <= 20000000)
replace c_owners = 8 if (n_owners >= 20000001 & n_owners <= 50000000)
replace c_owners = 9 if (n_owners >= 50000000 & n_owners <= 100000000)
table c_owners
replace c_owners = 3 if (n_owners >= 50001 & n_owners <= 200000)
replace c_owners = 4 if (n_owners >= 200001 & n_owners <= 1000000)
replace c_owners = 5 if (n_owners >= 1000001 & n_owners <= 100000000)
label define owners_lb 1 "0-20000" 2 "20001-50000" 3 "50001-200000" 4 "200001-1000000" /// 
 5 "1000001-100000000"
label values c_owners owners_lb
 
frame create train_cate2
frame change train_cate2
set java_heapmax 64g
rforest n_owners metacriticscore achievements singleplayer familysharing steamachievements ///   
 fullcontrollersupport ///
 steamtradingcards inapppurchases multiplayer onlinecoop pvp sharedsplitscreenpvp /// 
 sharedsplitscreencoop sharedsplitscreen remoteplaytogether trackedcontrollersupport vronly ///
 partialcontrollersupport steamcloud steamleaderboards lancoop remoteplayontablet vrsupported ///
 valveanticheatenabled stats onlinepvp mmo crossplatformmultiplayer captionsavailable ///
 commentaryavailable steamworkshop remoteplayontv includesleveleditor remoteplayonphone ///
 vrsupport steamturnnotifications includessourcesdk hdravailable steamtimeline mods ///
 steamvrcollectibles modsrequirehl2 adventure casual indie rpg freetoplay action strategy ///
 earlyaccess simulation racing massivelymultiplayer education gamedevelopment audioproduction ///
 gore designillustration videoproduction sexualcontent nudity webpublishing softwaretraining ///
 movie language_n platform_n, type(class)
frame create test_cate2
frame change test_cate2
use "/Users/Mahiru/Documents/Stata/lasso_selected_testing2.dta"
predict owners

gen error = n_owners - pred_n_owners
gen error_sq = error^2 
sum error_sq
di "MSE = " r(mean)

***** 
gen rand_num = runiform()
gen train = rand_num < 0.8
frame create train_cate3
frame change train_cate3
use "/Users/Mahiru/Documents/Stata/lasso_selected_testing2.dta"
rforest n_owners average_forever average_2weeks median_forever median_2weeks r_price discount /// 
 metacriticscore achievements singleplayer familysharing steamachievements fullcontrollersupport ///
 steamtradingcards inapppurchases multiplayer onlinecoop pvp sharedsplitscreenpvp /// 
 sharedsplitscreencoop sharedsplitscreen remoteplaytogether trackedcontrollersupport vronly ///
 partialcontrollersupport steamcloud steamleaderboards lancoop remoteplayontablet vrsupported ///
 valveanticheatenabled stats onlinepvp mmo crossplatformmultiplayer captionsavailable ///
 commentaryavailable steamworkshop remoteplayontv includesleveleditor remoteplayonphone ///
 vrsupport steamturnnotifications includessourcesdk hdravailable steamtimeline mods ///
 steamvrcollectibles modsrequirehl2 adventure casual indie rpg freetoplay action strategy ///
 earlyaccess simulation racing massivelymultiplayer education gamedevelopment audioproduction ///
 gore designillustration videoproduction sexualcontent nudity webpublishing softwaretraining ///
 movie language_n platform_n if train == 1, type(class)
