clear all
di "current user: `c(username)'"
if "`c(username)'" == "matthewshaffer" {
	global dir "/Users/matthewshaffer/Dropbox" 
}

else if "`c(username)'" == "mdshaffe" {

global dir "C:\Users\mdshaffe\Dropbox"    
}

else if "`c(username)'" == "jackzhou" {
	global dir "/Users/jackzhou/Dropbox" 
}
else if "`c(username)'" == "jason" {
	global dir "/Users/jason/Dropbox/Research"
}
else if "`c(username)'" == "stable" {
	global dir "/Users/stable/Dropbox"
}
    
cd "$dir/which multiples matter descriptive copy"            
global datadir "Data"                       
global tabdir "Tables" 	
global originaldata "Data/Original_Data"
global tempfiles "Data/tempfiles"	

////////////////////////////////////////////////////////////////////////////////

use "/Users/stable/Dropbox/which multiples matter descriptive copy/Data/1D_labeled_dataset.dta"

////////////////////////////////////////////////////////////////////////////////

mean one_month_premium if num_enterprise_ind == 1
mean one_month_premium if num_enterprise_ind == 0

eststo clear

qui: eststo p1: estpost summarize one_month_premium if num_enterprise_ind == 1
qui: eststo p2: estpost summarize one_month_premium if num_enterprise_ind == 0

esttab p1 p2 using "$tabdir/summarystats_1.tex", replace ///
    cell((mean(fmt(%9.4f)))) mtitle("\textit{Enterprise}" "\textit{Equity}") nonumber label
	
eststo clear

////////////////////////////////////////////////////////////////////////////////

mean one_month_premium if denom_assets_ind == 1
mean one_month_premium if denom_bookequity_ind == 1
mean one_month_premium if denom_cashflow_ind == 1
mean one_month_premium if denom_industryspecific_ind == 1
mean one_month_premium if denom_revenue_ind == 1
mean one_month_premium if denom_grossprofit_ind == 1
mean one_month_premium if denom_ebitda_ind == 1
mean one_month_premium if denom_ebit_ind == 1
mean one_month_premium if denom_earnings_ind == 1

eststo clear

qui: eststo p1: estpost summarize one_month_premium if denom_assets_ind == 1
qui: eststo p2: estpost summarize one_month_premium if denom_bookequity_ind == 1
qui: eststo p3: estpost summarize one_month_premium if denom_cashflow_ind == 1
qui: eststo p4: estpost summarize one_month_premium if denom_industryspecific_ind == 1
qui: eststo p5: estpost summarize one_month_premium if denom_revenue_ind == 1
qui: eststo p6: estpost summarize one_month_premium if denom_grossprofit_ind == 1
qui: eststo p7: estpost summarize one_month_premium if denom_ebitda_ind == 1
qui: eststo p8: estpost summarize one_month_premium if denom_ebit_ind == 1
qui: eststo p9: estpost summarize one_month_premium if denom_earnings_ind == 1

esttab p1 p2 p3 p4 p5 p6 p7 p8 p9 using "$tabdir/summarystats_2.tex", replace ///
    cell((mean(fmt(%9.4f)))) mtitle("\textit{Assets}" "\textit{Book Equity}" "\textit{Cash Flow}" "\textit{Industry Specific}" "\textit{Revenue}" "\textit{Gross Profit}" "\textit{EBITDA}" "\textit{EBIT}" "\textit{Earnings}") nonumber label
	
eststo clear

////////////////////////////////////////////////////////////////////////////////

mean one_month_premium if v_denom_time == "past"
mean one_month_premium if v_denom_time == "current"
mean one_month_premium if v_denom_time == "future"

eststo clear

qui: eststo p1: estpost summarize one_month_premium if v_denom_time == "past"
qui: eststo p2: estpost summarize one_month_premium if v_denom_time == "current"
qui: eststo p3: estpost summarize one_month_premium if v_denom_time == "future"

esttab p1 p2 p3 using "$tabdir/summarystats_3.tex", replace ///
    cell((mean(fmt(%9.4f)))) mtitle("\textit{Past}" "\textit{Current}" "\textit{Future}") nonumber label
	
eststo clear

////////////////////////////////////////////////////////////////////////////////

mean one_month_premium if type_transaction_ind == 1
mean one_month_premium if type_transaction_ind == 0

eststo clear

qui: eststo p1: estpost summarize one_month_premium if type_transaction_ind == 1
qui: eststo p2: estpost summarize one_month_premium if type_transaction_ind == 0

esttab p1 p2 using "$tabdir/summarystats_4.tex", replace ///
    cell((mean(fmt(%9.4f)))) mtitle("\textit{Transaction}" "\textit{Trading}") nonumber label
	
eststo clear

////////////////////////////////////////////////////////////////////////////////

use "$datadir/1D_labeled_dataset", clear
replace synthetic = subinstr(synthetic,"trading","",.) 
replace synthetic = subinstr(synthetic,"transaction","",.) 
replace synthetic = subinstr(synthetic,"enterprise","Enterprise Value",.)
replace synthetic = subinstr(synthetic,"equity","Equity Value",.) 
replace synthetic = subinstr(synthetic,"past","Past",.)
replace synthetic = subinstr(synthetic,"present","Present",.)
replace synthetic = subinstr(synthetic,"future","Future",.)
replace synthetic = subinstr(synthetic,"current","Current",.)
replace synthetic = subinstr(synthetic,"ebitda","EBITDA",.)
replace synthetic = subinstr(synthetic,"ebit","EBIT",.)
replace synthetic = subinstr(synthetic,"earnings","Earnings",.)
replace synthetic = subinstr(synthetic,"earnings","Earnings",.)
replace synthetic = subinstr(synthetic,"book","Book",.)
replace synthetic = subinstr(synthetic,"cash flow","Cash Flow",.)
replace synthetic = subinstr(synthetic,"revenue","Revenue",.)
replace synthetic = subinstr(synthetic,"assets","Assets",.)

replace synthetic = subinstr(synthetic,"Book Equity Value","Book Equity",.)  // disambiguate 

replace synthetic = subinstr(synthetic,"  "," Current ",.) if v_denom_time == "current"  // bodge bc original synthetics made before last time coding
replace synthetic = subinstr(synthetic,"  "," Future ",.) if v_denom_time == "future"
replace synthetic = subinstr(synthetic,"  "," Past ",.) if v_denom_time == "past"


replace synthetic = synthetic + ", Trading Comps" if v_type == "trading"
replace synthetic = synthetic + ", Transaction Comps" if v_type == "transaction"


eststo clear
estpost tabulate synthetic, sort

bysort synthetic: gen obs2 = _N
replace synthetic = "Other" if obs2 < 130

eststo p1: estpost tabstat one_month_premium, by(synthetic_multiple) statistics(count mean sd p10 p25 p50 p75 p90)
// esttab p1 using "$tabdir/synthetic_table.tex", replace cells("count mean sd p10 p25 p50 p75 p90") varlabels("frequency" "mean" "sd" "p10" "p25" "median" "p75" "p90" (fmt(%9.4f))) nonumber 
// esttab p1 using "$tabdir/synthetic_table.tex", replace cells("count mean sd p10 p25 p50 p75 p90") varlabels("Frequency" "Mean" "Standard deviation" "10th percentile" "25th percentile" "Median" "75th percentile" "90th percentile" (fmt(%9.4f))) nonumber


