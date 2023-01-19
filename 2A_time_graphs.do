///////////////////////////////////////////
/////// *** Part A: Preamble  *** //////// 
/////////////////////////////////////////// 
clear all
di "current user: `c(username)'"
if "`c(username)'" == "matthewshaffer" {
	global dir "/Users/matthewshaffer/Dropbox" 
}
else if "`c(username)'" == "jackzhou" {
	global dir "/Users/jackzhou/Dropbox" 
}
else if "`c(username)'" == "davidcai" {
	global dir "/Users/davidcai/Dropbox" 
}
else if "`c(username)'" == "david" {
	global dir "C:\Users\david\Dropbox"
}
else if "`c(username)'" == "KSBruere" {
	global dir "C:\Users\KSBruere\Dropbox\Research\M&A with Matt"
}

else if "`c(username)'" == "kathe" {
	global dir "C:\Users\kathe\Dropbox\Research\M&A with Matt"
}
else if "`c(username)'" == "jason" {
	global dir "/Users/jason/Dropbox/Research"
}
    
cd "$dir/which multiples matter descriptive"              
global datadir "Data"                       
global tabdir "Tables" 	
global originaldata "Data/Original_Data"
global tempfiles "Data/tempfiles"	
global graphdir "Graphs"	

/////////////////////////////////////////// 
/////////////////////////////////////////// 



use "$datadir/2A_timegraph_dataset.dta", clear 

drop if year == 2020 //because there's not enough obs 
   
gen trading = 0
replace trading = 1 if v_type == "trading"
gen transaction = 0
replace transaction = 1 if v_type == "transaction"
bys year: gen tradingProportion = sum(trading) / _N
bys year: replace tradingProportion = tradingProportion[_N]
bys year: gen transactionProportion = sum(transaction) / _N
bys year: replace transactionProportion = transactionProportion[_N] + tradingProportion

label var transactionProportion "Transaction Multiple"
label var tradingProportion "Trading Multiple"

twoway (area transactionProportion year, color(gs13)) (area tradingProportion year, color(gs4)), xlabel(2000 (3) 2019) ylabel(0 (.2) 1) yscale(r(0 1))
graph export "$graphdir/transaction_vs_trading.jpg", as(jpg) name("Graph") quality(100) replace

   
   
   
   // valuation numerator (v_numerator): what % is enterprise value vs. equity value, 2000-2019. 

gen equity = 0
replace equity = 1 if v_numerator == "equity"
gen enterprise = 0
replace enterprise = 1 if v_numerator == "enterprise"
bys year: gen equityProportion = sum(equity) / _N
bys year: replace equityProportion = equityProportion[_N]
bys year: gen enterpriseProportion = sum(enterprise) / _N
bys year: replace enterpriseProportion = enterpriseProportion[_N] + equityProportion

label var equityProportion "Equity Value"
label var enterpriseProportion "Enterprise Value"

twoway (area enterpriseProportion year, color(gs13)) (area equityProportion year, color(gs4)), xlabel(2000 (3) 2019) ylabel(0 (.2) 1) yscale(r(0 1))
graph export "$graphdir/enterprise_vs_equity.jpg", as(jpg) name("Graph") quality(100) replace

   
   
   
   // valuation denominator: I bucketed all into: book equity | cash flow |  earnings |  ebit |  ebitda |  ebt |  gross profit | industry specific |  revenue

gen be = 0
replace be = 1 if v_acct_denom == "book equity"
gen cf = 0
replace cf = 1 if v_acct_denom == "cash flow"
gen earnings = 0
replace earnings = 1 if v_acct_denom == "earnings"
gen ebit = 0
replace ebit = 1 if v_acct_denom == "ebit"
gen ebitda = 0
replace ebitda = 1 if v_acct_denom == "ebitda"

gen gp = 0
replace gp = 1 if v_acct_denom == "gross profit"
gen is = 0
replace is = 1 if v_acct_denom == "industry specific"
gen revenue = 0
replace revenue = 1 if v_acct_denom == "revenue"
gen assets = 0
replace assets = 1 if v_acct_denom == "assets"

bys year: gen beProportion = sum(be) / _N
bys year: replace beProportion = beProportion[_N]
bys year: gen cfProportion = sum(cf) / _N
bys year: replace cfProportion = cfProportion[_N] + beProportion
bys year: gen earningsProportion = sum(earnings) / _N
bys year: replace earningsProportion = earningsProportion[_N] + cfProportion
bys year: gen ebitProportion = sum(ebit) / _N
bys year: replace ebitProportion = ebitProportion[_N] + earningsProportion
bys year: gen ebitdaProportion = sum(ebitda) / _N
bys year: replace ebitdaProportion = ebitdaProportion[_N] + ebitProportion
bys year: gen gpProportion = sum(gp) / _N
bys year: replace gpProportion = gpProportion[_N] + ebitdaProportion
bys year: gen isProportion = sum(is) / _N
bys year: replace isProportion = isProportion[_N] + gpProportion
bys year: gen revenueProportion = sum(revenue) / _N
bys year: replace revenueProportion = revenueProportion[_N] + isProportion
bys year: gen assetsProportion = sum(assets) / _N
bys year: replace assetsProportion = assetsProportion[_N] + revenueProportion

label var beProportion "Book Equity"
label var cfProportion "Cash Flow"
label var earningsProportion "Earnings"
label var ebitProportion "EBIT"
label var ebitdaProportion "EBITDA"
label var gpProportion "Gross Profit"
label var isProportion "Industry Specific"
label var revenueProportion "Revenue"
label var assetsProportion "Assets"

twoway (area assetsProportion year) (area revenueProportion year) (area isProportion year) (area gpProportion year) (area ebitdaProportion year) (area ebitProportion year) (area earningsProportion year) (area cfProportion year) (area beProportion year), xlabel(2000 (3) 2019) ylabel(0 (.2) 1) yscale(r(0 1))
graph export "$graphdir/valuation_denominator.jpg", as(jpg) name("Graph") quality(100) replace
   
   
   
   // valuation denominator type: 'stock vs. flow' (I just also rebucketed the denominator types into stock-vs-flow buckets)

gen stock = 0
replace stock = 1 if denom_type == "stock"
gen flow = 0
replace flow = 1 if denom_type == "flow"
bys year: gen stockProportion = sum(stock) / _N
bys year: replace stockProportion = stockProportion[_N]
bys year: gen flowProportion = sum(flow) / _N
bys year: replace flowProportion = flowProportion[_N] + stockProportion

label var stockProportion "Stock"
label var flowProportion "Flow"

twoway (area flowProportion year, color(gs13)) (area stockProportion year, color(gs4)), xlabel(2000 (3) 2019) ylabel(0 (.2) 1) yscale(r(0 1))
graph export "$graphdir/stock_vs_flow.jpg", as(jpg) name("Graph") quality(100) replace
		
   
   
   // valuation denominator time-period: past vs. current vs. future, 2000-2019
   
   
keep if v_denom_time ! = "" 

gen past = 0
replace past = 1 if v_denom_time == "past"
gen current = 0 
replace current = 1 if v_denom_time == "current"
gen future = 0
replace future = 1 if v_denom_time == "future"


bys year: gen pastProportion = sum(past) / _N
bys year: replace pastProportion = pastProportion[_N]
bys year: gen currentProportion = sum(current) / _N
bys year: replace currentProportion = currentProportion[_N] + pastProportion
bys year: gen futureProportion = sum(future) / _N
bys year: replace futureProportion = futureProportion[_N] + currentProportion

label var pastProportion "Past"
label var currentProportion "Current"
label var futureProportion "Future"



twoway (area futureProportion year, color(gs13)) (area currentProportion year, color(gs9)) (area pastProportion year, color(gs4)), xlabel(2000 (3) 2019) ylabel(0 (.2) 1) yscale(r(0 1))
graph export "$graphdir/valuation_time_period.jpg", as(jpg) name("Graph") quality(100) replace

replace v_type = "Transaction" if v_type == "transaction"
replace v_type = "Trading" if v_type == "trading"

replace v_numerator = "Equity" if v_numerator == "equity"
replace v_numerator = "Enterprise" if v_numerator == "enterprise"

replace denom_type = "Stock" if denom_type == "stock"
replace denom_type = "Flow" if denom_type == "flow"

replace v_denom_time = "Future" if v_denom_time == "future"
replace v_denom_time = "Past" if v_denom_time == "past"
replace v_denom_time = "Current" if v_denom_time == "current"

replace v_acct_denom = "Revenue" if v_acct_denom == "revenue"
replace v_acct_denom = "Gross Profit" if v_acct_denom == "gross profit"
replace v_acct_denom = "EBITDA" if v_acct_denom == "ebitda"
replace v_acct_denom = "EBIT" if v_acct_denom == "ebit"
replace v_acct_denom = "Earnings" if v_acct_denom == "earnings"
replace v_acct_denom = "Assets" if v_acct_denom == "assets"
replace v_acct_denom = "Book Equity" if v_acct_denom == "book equity"
replace v_acct_denom = "Industry Specific" if v_acct_denom == "industry specific"
replace v_acct_denom = "Cash Flow" if v_acct_denom == "cash flow"

keep sdc_deal_no year v_type v_numerator v_acct_denom denom_type v_denom_time


export excel "$datadir/2A_timegraph_dataset.xlsx", firstrow(var) replace 
