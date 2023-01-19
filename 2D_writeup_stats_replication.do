///////////////////////////////////////////
/////// *** Part A: Preamble  *** //////// 
/////////////////////////////////////////// 
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
    
cd "$dir/which multiples matter descriptive"            
global datadir "Data"                       
global tabdir "Tables" 	
global originaldata "Data/Original_Data"
global tempfiles "Data/tempfiles"		


/////////////////////////////////////////// 
/////////////////////////////////////////// 

use "$datadir/1D_labeled_dataset", clear


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
	
	


// "Even after applying our standardization scheme, the most common standardized multiple, \textit{Trading Enterprise to Current EBITDA} (Table \ref{tab:synthetic_mult_frequency}) accounts for only 7.37\% of the sample,  is "

tab synthetic_multiple, sort



//, accrual-accounting based measures dominate as the value-drivers used in this setting. The six most common value-driver denominators are, in order, \textit{EBITDA} (32\%), \textit{Net Income} (25\%), \textit{Revenue} (22\%), \textit{Book Equity} (9\%), \textit{EBIT} (6.4\%), and \textit{Total Assets} (2\%), collectively comprising 97\% of the total sample. All cash-flow metrics combined comprise only 1.77\% of the sample. 

tab v_acct_denom, sort

gen flag = v_acct_denom == "industry specific"

gsort - flag

//And more ``bespoke'' industry-specific measures (e.g., \textit{Daily Production}, \textit{Proven Reserves}, \textit{Deposits}, \textit{Funds from Operations}), comprise only 1.47\% of the total sample, and overwhelmingly concentrated in the finance and real-estate.


gen flag2 = strpos(valuation_method, "depos") == 0 & flag == 1
gsort -flag2



// Third, ``flow'' metrics (e.g., earnings, EBITDA), dominate ``stock'' measures (e.g., book equity, total assets) as value-driver denominators. \textit{Book Equity} and \textit{Total Assets}, respectively, are used in only 9\% and 2\% of valuation multiples. However, even this small fraction is overwhelmingly concentrated in the financial services, insurance, and real-estate industries. (A natural explanation is that, for those industries, the net assets recognized on the balance sheet more closely track the total economic assets of the firm.) Excluding SIC Codes 6000-6799



generate target_sic_numeric = target_sic

destring target_sic_numeric, force replace 
order target_sic_numeric

tab v_acct_denom if inrange(target_sic_numeric, 5999, 6800) == 0, sort




// Fifth, M&A advisors show a modest preference for enterprise-value (EV) valuations (60%of the total) rather than direct equity 

tab v_numerator


// Sixth, and finally, we note that advisors typically draw the ``comps'' for their multiples from other trading firms, rather than comparable transactions.

tab v_type



/// 

/* Examining variation by sector (SIC Division), the \textit{Finance, Insurance and Real Estate} sector (SIC codes 6000-6799) stands out: In this industry, advisers use Enterprise (vs. Equity) multiples only 16\% (vs. 84\%) of the time, while the numbers are  73\% (vs. 27\%) for the remainder of the sample, exclusive of that sector. Targets in these industries also have significantly higher leverage ratios. */ 

tabulate v_numerator if  SIC_Industry_Category != "03 FIRE"

/* 
v_numerator |      Freq.     Percent        Cum.
------------+-----------------------------------
 enterprise |      7,263       73.27       73.27
     equity |      2,650       26.73      100.00
------------+-----------------------------------
      Total |      9,913      100.00
*/ 


su leverage if  SIC_Industry_Category != "03 FIRE" /* 

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
    leverage |      9,607    2.199102    5.000142  -18.31656   33.28535 */ 

su leverage if  SIC_Industry_Category == "03 FIRE"  /* 

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
    leverage |      2,659    9.304992    6.665155  -18.31656   33.28535 */ 
	
	
	
// And, in a two-way tabulation, we find no significant difference: Advisers use \textit{Enterprise Value} in 59\% of multiples with trading comps, and 60\% of multiples with transaction comps.

tabulate type_transaction_ind v_num, row

/* \textit{Tr |
 ansaction |      v_numerator
 Multiple} | enterpr..     equity |     Total
-----------+----------------------+----------
         0 |     5,068      3,503 |     8,571 
           |     59.13      40.87 |    100.00 
-----------+----------------------+----------
         1 |     2,687      1,765 |     4,452 
           |     60.35      39.65 |    100.00 
-----------+----------------------+----------
     Total |     7,755      5,268 |    13,023 
           |     59.55      40.45 |    100.00 

		   
		   */ 
		   
		   
tabulate v_acct_denom if SIC_Industry_Category != "03 FIRE",  sort
/* 
     v_acct_denom |      Freq.     Percent        Cum.
------------------+-----------------------------------
           ebitda |      3,889       39.25       39.25
          revenue |      2,777       28.03       67.27
         earnings |      1,936       19.54       86.81
             ebit |        793        8.00       94.81
        cash flow |        221        2.23       97.04
      book equity |        204        2.06       99.10
           assets |         38        0.38       99.49
industry specific |         27        0.27       99.76
     gross profit |         24        0.24      100.00
------------------+-----------------------------------
            Total |      9,909      100.00


tabulate type_stock_ind if SIC_Industry_Category != "Fin, Ins and RE",  sort

*/ 


// \textit{Total Assets} is uncommon throughout, and not easily visible in the plot---but it accounts for 3.1\% of multiples in 2000-2004, vs. 1.7\% of multiples in 2015-2019. 


tab denom_assets_ind if inrange(year, 2000, 2004)

tab denom_assets_ind if inrange(year, 2015, 2019)


// Examining variation by sector, \textit{Finance, Insurance, and Real Estate} once against stands out. Advisers use forward multiples in only 15\% of multiples for targets in that sector, vs. 


tab v_denom_time if  SIC_Industry_Category == "03 FIRE", sort
tab v_denom_time if  SIC_Industry_Category != "03 FIRE", sort 



/* Another notable difference is that the \textit{FIRE} industry has a higher frequency of ``Industry Specific'' value drivers, and 50\% of those are stock measures---most commonly \textit{Deposits}. */ 

 gen flag1 =  SIC_Industry_Cat == "03 FIRE" & v_acct_denom == "industry specific"

gsort -flag1

tab denom_type if flag1 == 1



// 

gen flag3 = v_acct_denom == "industry specific"

gsort -flag3 valuation_method

// 

gen flag4 = strpos(valuation_method, "production") > 0 

gsort - flag4

// 
gen flag5 = strpos(valuation_method, "subscrib") > 0 

gsort - flag5
