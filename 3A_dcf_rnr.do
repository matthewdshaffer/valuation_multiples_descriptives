///////////////////////////////////////////
///////// 1A: Reshape Multiples// //////// 
/////////////////////////////////////////// 
clear 
di "current user: `c(username)'"
if "`c(username)'" == "matthewshaffer" {
	global dir "/Users/matthewshaffer/Dropbox" 
}
else if "`c(username)'" == "jackzhou" {
	global dir "/Users/jackzhou/Dropbox" 
}
    
cd "$dir/which multiples matter descriptive"           
global datadir "Data"                       
global tabdir "Tables" 	
global originaldata "Data/Original_Data"
global tempfiles "Data/tempfiles"		

/////////////////////////////////////////// 

clear all

frame create dcf
frame change dcf

// load in the dcf data
import excel "$originaldata/dcf_download_reshaped.xlsx", sheet("Request 3") firstrow clear 

// clean the variables from excel reading
rename DealNumber sdc_deal_no
tostring dcf_tmultiple_type_6, force replace
tostring dcf_tmultiple_type_7, force replace
tostring dcf_iev_type_7, force replace
tostring fo_author_name_7, force replace

// reshape the data to valuation-level obs
global stub_vars "dcf_discount_rate_high_ dcf_discount_rate_low_ dcf_iev_high_ dcf_iev_low_ dcf_iev_type_ dcf_pgrowth_high_ dcf_pgrowth_low_ dcf_tmultiple_high_ dcf_tmultiple_low_ dcf_tmultiple_type_ fo_author_name_"
reshape long $stub_vars, i(sdc_deal_no) j(fo_dcf_num)
drop if fo_author_name_ == "."

// collapse down to deal level average to merge
collapse(mean) dcf_discount_rate_high_ dcf_discount_rate_low_ dcf_pgrowth_high_ dcf_pgrowth_low_, by(sdc_deal_no)

// gen var for presence of dcf if it has discount rate data
gen ind_dcf = 1 if dcf_discount_rate_high_ != . | dcf_discount_rate_low_ != .
replace ind_dcf = 0 if ind_dcf == .

/////////////////////////////////////////// 

frame create main
frame change main

use "$datadir/1D_labeled_dataset", clear

// merge
frlink m:1 sdc_deal_no, frame(dcf)
frget dcf_discount_rate_high_ dcf_discount_rate_low_ dcf_pgrowth_high_ dcf_pgrowth_low_ ind_dcf, from(dcf)

// gen dep. var
gen income_statement_level = .
replace income_statement_level = 1 if denom_earnings_ind == 1
replace income_statement_level = 2 if denom_ebit_ind == 1
replace income_statement_level = 3 if denom_ebitda_ind == 1
replace income_statement_level = 4 if denom_grossprofit_ind == 1
replace income_statement_level = 5 if denom_revenue_ind == 1



// preliminary regressions on discount rate assumptions... 

gen mean_dr = (dcf_discount_rate_high_ + dcf_discount_rate_low_)/2
replace mean_dr = dcf_discount_rate_low_ if dcf_discount_rate_low_ != . & dcf_discount_rate_high_ == . 
 //winsor2 mean_dr, replace cuts(1 99)trim 

su mean_dr 
reg type_transaction_ind mean_dr i.year
reg num_enterprise_ind mean_dr i.year
reg type_stock_ind mean_dr i.year
reg time_num mean_dr i.year
reg income_statement_level mean_dr i.year


	xtile drquartile = mean_dr, n(4)
	gen dr_q1 = drquartile == 1
	gen dr_q2 = drquartile == 2
	gen dr_q3 = drquartile == 3
	gen dr_q4 = drquartile == 4

reg type_transaction_ind dr_q*, noc
reg num_enterprise_ind dr_q*, noc
reg type_stock_ind dr_q*, noc
reg time_num dr_q*, noc
reg income_statement_level dr_q*, noc




	
/// Create tables for paper...: 

//  Order: numerator, measurement period, set of comps type, value-driver denominator. 



	// Panel A: Valuation numerator / DCF 
tab v_numerator ind_dcf, col chi2

	// exporting the table to LaTex format. relable variables for formality.

		replace  v_numerator = "Enterprise Value" if v_numerator == "enterprise"
		replace  v_numerator = "Equity Value" if v_numerator == "equity"
			eststo clear
			eststo freqind: estpost tabulate v_numerator ind_dcf
			esttab freqind using "${tabdir}/summstats/v_numerator_by_dcf_ind.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
		
		
		
	// Panel B: Value-Driver Denominator x DCF
	
 tab v_acct_denom ind_dcf, col chi2
 
       // tab command automatically exports with rowvars in alphabetical order.
		// temporarily relabel to get in economically intuitive order.
 


		replace v_acct_denom = "a Revenue" if v_acct_denom == "revenue"
		replace v_acct_denom = "b Gross Profit" if v_acct_denom == "gross profit"
		replace v_acct_denom = "c EBITDA" if v_acct_denom == "ebitda"
		replace v_acct_denom = "d EBIT" if v_acct_denom == "ebit"
		replace v_acct_denom = "d Earnings" if v_acct_denom == "earnings"
		replace v_acct_denom = "f Cash Flow" if v_acct_denom == "cash flow"
		replace v_acct_denom = "g Book Equity" if v_acct_denom == "book equity"
		replace v_acct_denom = "h Assets" if v_acct_denom == "assets"
		replace v_acct_denom = "i Indusry Specific" if v_acct_denom == "industry specific"
			eststo clear
			eststo freqind: estpost tabulate v_acct_denom ind_dcf
			esttab freqind using "${tabdir}/summstats/v_acct_denom_by_dcf_ind.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear

		
		
	// Panel C: Measurement period x DCF 

tab v_denom_time ind_dcf, col chi2

	// exporting the table to LaTex format
	 
		replace v_denom_time = "a Past" if v_denom_time == "past"
		replace v_denom_time = "b Current" if v_denom_time == "current"
		replace v_denom_time = "c Future" if v_denom_time == "future"
			eststo clear
			eststo freqind: estpost tabulate v_denom_time ind_dcf
			esttab freqind using "${tabdir}/summstats/v_denom_time_by_dcf_ind.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
 
		
 // Note: as in text, 2x2 tabulation with indicator for forward value driver not signif.
	gen v_denom_time_alt = v_denom_tim == "c Future"
	tab v_denom_time_alt ind_dcf, row chi2

		
		
	// Panel D: Comps type x DCF 
	
tab v_type ind_dcf, col chi2


			eststo clear
			eststo freqind: estpost tabulate v_type ind_dcf
			esttab freqind using "${tabdir}/summstats/v_type_by_dcf_ind.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear

	
	
//////// Discount-rate assumption tests...: 

tab v_numerator drquartile , col chi2
tab v_acct_denom drquartile , col chi2
tab v_denom_time drquartile , col chi2
tab v_type drquartile , col chi2




// Create tables for paper...: 

//  Order: numerator, measurement period, set of comps type, value-driver denominator. 



	// Panel A: Valuation numerator / dr quartile
tab v_numerator drquartile, col chi2

	// exporting the table to LaTex format. relable variables for formality.

			eststo clear
			eststo freqind: estpost tabulate v_numerator drquartile
			esttab freqind using "${tabdir}/dr_tests/v_numerator_by_dr_quartile.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
		
		
		
	// Panel B: Value-Driver Denominator x dr quartile
	
 tab v_acct_denom drquartile, col chi2
 
			eststo clear
			eststo freqind: estpost tabulate v_acct_denom drquartile
			esttab freqind using "${tabdir}/dr_tests/v_acct_denom_by_dr_quartile.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear

		
		
	// Panel C: Measurement period x DCF 

tab v_denom_time drquartile, col chi2

	// exporting the table to LaTex format
	 

			eststo clear
			eststo freqind: estpost tabulate v_denom_time drquartile
			esttab freqind using "${tabdir}/dr_tests/v_denom_time_by_dr_quartile.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
 
		
		
		
	// Panel D: Comps type x DCF 
	
tab v_type drquartile, col chi2


			eststo clear
			eststo freqind: estpost tabulate v_type drquartile
			esttab freqind using "${tabdir}/dr_tests/v_type_by_drquartile.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
