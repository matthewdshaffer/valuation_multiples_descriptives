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


/////////////////////////////////////////// 
/////////////////////////////////////////// 

use "$datadir/1D_labeled_dataset", clear

/////////////////////////////////////////// 
/////////////////////////////////////////// 

// MS 10/19/2021 update: Now, CY 2020 obs are already dropped in construction of analysis dataset.

// First: Clean up industry and other variables for the purpose of this file (tables)

// Industry: 


	//using target_sic to assign industry categories
	gen SIC_Industry_Category = ""
	replace SIC_Industry_Category = "09 Ag" if SIC > 1 & SIC < 1000
	replace SIC_Industry_Category = "06 Mining" if SIC >= 1000 & SIC < 1500
	replace SIC_Industry_Category = "08 Construction" if SIC >= 1500 & SIC < 1800
	replace SIC_Industry_Category = "n/a" if SIC >= 1800 & SIC < 2000
	replace SIC_Industry_Category = "01 Manufacturing" if SIC >= 2000 & SIC < 4000
	replace SIC_Industry_Category = "05 TransComm" if SIC >= 4000 & SIC < 5000
	replace SIC_Industry_Category = "07 Wholesale" if SIC >= 5000 & SIC < 5200
	replace SIC_Industry_Category = "04 Retail" if SIC >= 5200 & SIC < 6000
	replace SIC_Industry_Category = "03 FIRE" if SIC >= 6000 & SIC < 7000
	replace SIC_Industry_Category = "02 Services" if SIC >= 7000 & SIC < 9100
	replace SIC_Industry_Category = "10 Public Admin" if SIC >= 9100 & SIC < 9900
	replace SIC_Industry_Category = "Nonclassifiable" if SIC >= 9900 & SIC <= 9999
	
	

	
// tab the accounting denominator, so it is output in order:

tab v_acct_denom, sort

replace v_acct_denom = "1 EBITDA" if v_acct_denom == "ebitda"
replace v_acct_denom = "2 Net Income" if v_acct_denom == "earnings"
replace v_acct_denom = "3 Revenue" if v_acct_denom == "revenue"
replace v_acct_denom = "4 Book Equity" if v_acct_denom == "book equity"
replace v_acct_denom = "5 EBIT" if v_acct_denom == "ebit" 
replace v_acct_denom = "6 Assets" if v_acct_denom == "assets"
replace v_acct_denom = "7 Cash-flow metrics" if v_acct_denom == "cash flow"
replace v_acct_denom = "8 Industry specific" if v_acct_denom == "industry specific"
replace v_acct_denom = "9 Gross Profit"  if v_acct_denom == "gross profit"


//=============================================================================================
// Table 7: Accounting Value Driver Denominator by Industry
//=============================================================================================




	// exporting the table to LaTex format
	 
		// Column Percentages in Parentheses
		preserve
			eststo clear
			eststo freqind: estpost tabulate v_acct_denom SIC_Industry_Category 
			esttab freqind using "${tabdir}/summstats/acct_val_denom_by_ind.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("Industry")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
		restore 


		
//=============================================================================================
// Table X: Accounting Value Driver Denominator by Industry **TRANSPOSED**
//=============================================================================================
		

/// TWO-WAY FREQUENCY TABLE

//tabulate v_acct_denom SIC_Industry_Category, column

	//exporting the table to LaTex format
	 
		// Column Percentages in Parentheses
//		preserve
//			eststo clear
//			eststo freqind: estpost tabulate v_acct_denom SIC_Industry_Category
//			esttab freqind using "${tabdir}/summstats/acct_val_denom_by_industry.tex", ///
//			replace cell(b colpct(fmt(%5.2f) par)) ///
//			varlabels(, blist(Total)) ///
//			eqlabels(, lhs("")) ///
//			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
//			eststo clear
//		restore 
		
		
		
		
//=============================================================================================
// Table 8: Enterprise vs. Equity by Industry
//=============================================================================================

// Format variable for tables

replace v_numerator = "Enterprise Value" if v_numerator == "enterprise"
replace v_numerator = "Equity Value" if v_numerator == "equity"


	// exporting the table to LaTex format
	 
		// Column Percentages in Parentheses
		preserve
			eststo clear
			eststo freqind: estpost tabulate v_numerator SIC_Industry_Category 
			esttab freqind using "${tabdir}/summstats/v_numerator_by_ind.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("Industry")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
		restore 

		
		
//=============================================================================================
// Table 9: Comparable Transaction vs. Trading Comps by Industry
//=============================================================================================


// Format variable for tables

replace v_type = "Transaction Comps" if v_type == "transaction"
replace v_type = "Trading Comps" if v_type == "trading"



	//exporting the table to LaTex format
	 
		// Column Percentages in Parentheses
		preserve
			eststo clear
			eststo freqind: estpost tabulate v_type SIC_Industry_Category 
			esttab freqind using "${tabdir}/summstats/v_type_by_ind.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("Industry")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
		restore 

		
		
//=============================================================================================
// Table 10: Measurement Period  by Industry
//=============================================================================================

// Format for tables: 
replace v_denom_time = "1 Past Period" if v_denom_time == "past"
replace v_denom_time = "2 Current Period" if v_denom_time == "current"
replace v_denom_time = "3 Future Period" if v_denom_time == "future"
//replace v_denom_time = "4 Unidentified" if v_denom_time == ""




	//exporting the table to LaTex format
	 
		// Row Percentages in Parentheses
		preserve
			eststo clear
			eststo freqind: estpost tabulate v_denom_time SIC_Industry_Category 
			esttab freqind using "${tabdir}/summstats/v_denom_time_by_ind.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("Industry")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
		restore 
		


		
//=============================================================================================
// Appendix: Denominator x measurement period
//=============================================================================================

	 
		// Row Percentages in Parentheses
		preserve
			eststo clear
			eststo freqind: estpost tabulate v_denom_time v_acct_denom
			esttab freqind using "${tabdir}/summstats/denominator_period.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
		restore 
		
		
		
//=============================================================================================
// Appendix: Enterprise Value x comps type
//=============================================================================================

	 
		// Row Percentages in Parentheses
		preserve
			eststo clear
			eststo freqind: estpost tabulate v_type v_num 
			esttab freqind using "${tabdir}/summstats/numerator_type.tex", ///
			replace cell(b colpct(fmt(%5.2f) par)) ///
			varlabels(, blist(Total)) ///
			eqlabels(, lhs("")) ///
			unstack nonumber noobs nomtitle wrap varwidth(15) collabels(none) 
			eststo clear
		restore 
		

