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
    
cd "$dir/which multiples matter descriptive copy"            
global datadir "Data"                       
global tabdir "Tables" 	
global originaldata "Data/Original_Data"
global tempfiles "Data/tempfiles"		


/////////////////////////////////////////// 
/////////////////////////////////////////// 

use "$datadir/1D_labeled_dataset", clear

/////////////////////////////////////////// 
/////////////////////////////////////////// 

//=============================================================================================
// Table 1: Frequency of synthetic/standardized multiples
//=============================================================================================


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
esttab using "${tabdir}/synthetic_mult_freq_table_full.tex", /// 
	  cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))")       ///
      varlabels(`e(labels)', blist(Total "{hline @width}{break}")) ///
      varwidth(20) nonumber nomtitle noobs replace 

	  
	  
	  
tab synthetic, sort
bysort synthetic: gen number = _N

//replace synthetic = "Other" if number < 40
	  
esttab "${tabdir}/summstats/synthetic_mult_freq_table_full.tex", /// 
	  cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))")       ///
      varlabels(`e(labels)', blist(Total "{hline @width}{break}")) ///
      varwidth(20) nonumber nomtitle noobs replace 
	  
	   // "Other" thus defined is 807 observations.


//=============================================================================================
// Table 2: Year-Frequency Tables
//=============================================================================================

// Table 1: year freqneucy: 
 // Panel A: Valuations by year
  // run preserve-restore loop as one block. 
preserve
eststo clear
	eststo freq: estpost tabulate year if year < 2020
	esttab freq using "${tabdir}/summstats/val_freq_year.tex", replace cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
     varlabels(, blist(\textbf{Total}))      ///
     nonumber nomtitle noobs substitute(\_ _)
eststo clear
restore 



 // Panel B: Deals by year
preserve
duplicates drop sdc, force 
eststo clear 
 eststo freq: estpost tabulate year if year < 2020
 esttab freq using "${tabdir}/summstats/deal_freq_year.tex", replace cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
     varlabels(, blist(\textbf{Total}))      ///
     nonumber nomtitle noobs substitute(\_ _)
eststo clear
restore 




//=============================================================================================
// Table 3:Valuation Characteristics
//=============================================================================================

use "$datadir/1D_labeled_dataset", clear

// Table 2: Valuations characteristics

gen type_flow_ind = 1 - type_stock_ind

//keep these labels here as they are temporary
label var type_transaction_ind "\textit{Transaction Multiple (vs. Trading)}"
label var num_enterprise_ind "\textit{Enterprise Value Numerator (vs. Equity)}"
label var type_flow_ind "\textit{Flow-Measure Denominator (vs. Stock)}"
label var time_past_ind "\textit{Past-Period Denominator}"
label var time_current_ind "\textit{Current-Period Denominator}"
label var time_future_ind "\textit{Future-Period Denominator}"
label var denom_profit_ind "\textit{Earnings-Based Denominator}"
label var denom_earnings_ind "\textit{Net-Income Denominator}"
label var denom_ebitda_ind "\textit{EBITDA Denominator}"
label var denom_ebit_ind "\textit{EBIT Denominator}"
label var denom_ebt_ind "\textit{EBT Denominator}"
label var denom_grossprofit_ind "\textit{Gross Profit Denominator}"
label var TargetNetSales5YearGrowthR "\textit{Growth}"

//create variable showing the number of ratios per deal
gen one=1
sort sdc_deal_no
by sdc_deal_no: egen num_ratios=sum(one)
label var num_ratios "\textit{Number of Valuation Ratios}"

global valuation_summstats "time_past_ind time_current_ind time_future_ind num_enterprise_ind type_flow_ind denom_profit_ind"

eststo clear 
	eststo target: estpost summarize $valuation_summstats if year < 2020 & v_denom_time != ""
	esttab target using "${tabdir}/summstats/valuation_summstats_forecasts.tex", replace ///
	cell((mean(fmt(%9.2f))  )) nomtitle nonumber label
eststo clear 




//=============================================================================================
// Table 4: Deal Characteristics
//=============================================================================================

global deal_vars "mgmt going_private go_shop rumored one_month_premium num_ratios"
//removed as of 9/23:  unsolicited RatioofDealValuetoSales RatioofDealValuetoEBITDA RatioofDealValuetoNetIncom NumberofBidders multiple_bidders cash_deal stock_deal 

 // Do it at deal-level: use preserve-restore bracket (run as one)
preserve
duplicates drop sdc, force // so that the deal-level summary stats are based on unique deals. 
	eststo clear 	
	eststo target: estpost summarize $deal_vars if year < 2020
	esttab target using "${tabdir}/summstats/deal_summary_stats.tex", replace ///
	cell((mean(fmt(%9.2f)) sd(fmt(%9.2f)) min(fmt(%9.2f)) max(fmt(%9.2f)) )) nomtitle nonumber  label
restore 


//=============================================================================================
// Table 5: Target Characteristics
//=============================================================================================

global tar_vars "ROA leverage ni_margin premium target_size analyst_ind"

//removed as of 9/23: tar_high_tech_ind tar_poison_pill 
preserve
duplicates drop sdc, force 
eststo clear 
eststo target: estpost summarize $tar_vars if year < 2020
esttab target using "${tabdir}/summstats/target_summary_stats.tex", replace ///
cell((mean(fmt(%9.2f)) sd(fmt(%9.2f)) min(fmt(%9.2f)) max(fmt(%9.2f)) )) nomtitle nonumber label substitute(\_ _)
restore 

//=============================================================================================
// Table 6: Correlation matrix
//=============================================================================================



preserve 

global corr_vars "type_transaction_ind num_enterprise_ind type_flow_ind time_current_future_ind time_num mgmt going_private go_shop rumored TargetTerm TargetNetSales5YearGrowthR analysts delaware ROA leverage ni_margin one_month_premium target_size analyst_ind"
//removed as of 9/23: unsolicited RatioofDealValuetoNetIncom stock_deal

//keep this labeling code here
label var EquityValuemil "\textit{Book Equity}"
label var TargetNetSalesLTMmil "\textit{Sales}"
label var TargetTotalAssetsmil "\textit{Total Assets}"
label var TgtMarketVal4WwksPriorto "\textit{Pre-Deal MCAP}"
label var NumberofBidders "\textit{Bidders (n.)}"
label var type_transaction_ind "\textit{Transaction Mult.}"
label var num_enterprise_ind "\textit{Enterprise Value (N.)}"
label var type_flow_ind "\textit{Flow D.}"
label var time_past_ind "\textit{Past D.}"
label var time_current_ind "\textit{Current D.}"
label var time_future_ind "\textit{Future D.}"
label var denom_profit_ind "\textit{Earnings-Based D.}"
label var denom_earnings_ind "\textit{Net-Income D.}"
label var denom_ebitda_ind "\textit{EBITDA D.}"

estpost correlate $corr_vars, matrix  // matrix option required to get all pairwise. 
	eststo correlation
	esttab correlation using "${tabdir}/summstats/correlation_matrix.tex", unstack compress b(2) replace label nonumber
	
restore


