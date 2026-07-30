setwd("~/R/SF-pricing-data-analysis/code")
source("run_price_decline_analysis_MV_criteria_grouping_more_quantile.R")
source("run_price_decline_analysis_more_quantile.R")

#all asset types, 3m window, no grouping
run_price_decline_analysis_more_quantile(63, "v_SecuritizedPricingLiquidity_202410231158_CLO.csv", 0 )
run_price_decline_analysis_more_quantile(63, "v_SecuritizedPricingLiquidity_202410231237_CMBS.csv", 0 )
# run_price_decline_analysis(63, "v_SecuritizedPricingLiquidity_202410231245_Euro_CMBS.csv", 0 )
# run_price_decline_analysis(63, "v_SecuritizedPricingLiquidity_202410231251_Euro_ABS.csv", 0 )
# run_price_decline_analysis(63, "v_SecuritizedPricingLiquidity_202410231254_Asian_ABS.csv", 0 )
# run_price_decline_analysis(63, "v_SecuritizedPricingLiquidity_202410231259_European_ABS.csv", 0 )
# run_price_decline_analysis(63, "v_SecuritizedPricingLiquidity_202410231302_Canadian_ABS.csv", 0 )

#all asset types, 3m window, with grouping
run_price_decline_analysis_more_quantile(63, "v_SecuritizedPricingLiquidity_202410231158_CLO.csv", 1 )
run_price_decline_analysis_more_quantile(63, "v_SecuritizedPricingLiquidity_202410231237_CMBS.csv", 1 )
# run_price_decline_analysis(63, "v_SecuritizedPricingLiquidity_202410231245_Euro_CMBS.csv", 1 )
# run_price_decline_analysis(63, "v_SecuritizedPricingLiquidity_202410231251_Euro_ABS.csv", 1 )
# run_price_decline_analysis(63, "v_SecuritizedPricingLiquidity_202410231254_Asian_ABS.csv", 1 )
# run_price_decline_analysis(63, "v_SecuritizedPricingLiquidity_202410231259_European_ABS.csv", 1 )
# run_price_decline_analysis(63, "v_SecuritizedPricingLiquidity_202410231302_Canadian_ABS.csv", 1 )

#all asset types, 12m window, no grouping
run_price_decline_analysis_more_quantile(250, "v_SecuritizedPricingLiquidity_202410231158_CLO.csv", 0 )
run_price_decline_analysis_more_quantile(250, "v_SecuritizedPricingLiquidity_202410231237_CMBS.csv", 0 )
# run_price_decline_analysis(250, "v_SecuritizedPricingLiquidity_202410231245_Euro_CMBS.csv", 0 )
# run_price_decline_analysis(250, "v_SecuritizedPricingLiquidity_202410231251_Euro_ABS.csv", 0 )
# run_price_decline_analysis(250, "v_SecuritizedPricingLiquidity_202410231254_Asian_ABS.csv", 0 )
# run_price_decline_analysis(250, "v_SecuritizedPricingLiquidity_202410231259_European_ABS.csv", 0 )
# run_price_decline_analysis(250, "v_SecuritizedPricingLiquidity_202410231302_Canadian_ABS.csv", 0 )

#all asset types, 12m window, with grouping
run_price_decline_analysis_more_quantile(250, "v_SecuritizedPricingLiquidity_202410231158_CLO.csv", 1 )
run_price_decline_analysis_more_quantile(250, "v_SecuritizedPricingLiquidity_202410231237_CMBS.csv", 1 )
# run_price_decline_analysis(250, "v_SecuritizedPricingLiquidity_202410231245_Euro_CMBS.csv", 1 )
# run_price_decline_analysis(250, "v_SecuritizedPricingLiquidity_202410231251_Euro_ABS.csv", 1 )
# run_price_decline_analysis(250, "v_SecuritizedPricingLiquidity_202410231254_Asian_ABS.csv", 1 )
# run_price_decline_analysis(250, "v_SecuritizedPricingLiquidity_202410231259_European_ABS.csv", 1 )
# run_price_decline_analysis(250, "v_SecuritizedPricingLiquidity_202410231302_Canadian_ABS.csv", 1 )

#all asset types, 3m window, with MV criteria rating grouping
run_price_decline_analysis_MV_criteria_grouping_more_quantile(63, "v_SecuritizedPricingLiquidity_202410231158_CLO.csv" )
run_price_decline_analysis_MV_criteria_grouping_more_quantile(63, "v_SecuritizedPricingLiquidity_202410231237_CMBS.csv" )
# run_price_decline_analysis_MV_criteria_grouping(63, "v_SecuritizedPricingLiquidity_202410231245_Euro_CMBS.csv")
# run_price_decline_analysis_MV_criteria_grouping(63, "v_SecuritizedPricingLiquidity_202410231251_Euro_ABS.csv")
# run_price_decline_analysis_MV_criteria_grouping(63, "v_SecuritizedPricingLiquidity_202410231254_Asian_ABS.csv")
# run_price_decline_analysis_MV_criteria_grouping(63, "v_SecuritizedPricingLiquidity_202410231259_European_ABS.csv")
# run_price_decline_analysis_MV_criteria_grouping(63, "v_SecuritizedPricingLiquidity_202410231302_Canadian_ABS.csv")

#all asset types, 12m window,  with MV criteria rating grouping
run_price_decline_analysis_MV_criteria_grouping_more_quantile(250, "v_SecuritizedPricingLiquidity_202410231158_CLO.csv" )
run_price_decline_analysis_MV_criteria_grouping_more_quantile(250, "v_SecuritizedPricingLiquidity_202410231237_CMBS.csv")
# run_price_decline_analysis_MV_criteria_grouping(250, "v_SecuritizedPricingLiquidity_202410231245_Euro_CMBS.csv")
# run_price_decline_analysis_MV_criteria_grouping(250, "v_SecuritizedPricingLiquidity_202410231251_Euro_ABS.csv")
# run_price_decline_analysis_MV_criteria_grouping(250, "v_SecuritizedPricingLiquidity_202410231254_Asian_ABS.csv")
# run_price_decline_analysis_MV_criteria_grouping(250, "v_SecuritizedPricingLiquidity_202410231259_European_ABS.csv")
# run_price_decline_analysis_MV_criteria_grouping(250, "v_SecuritizedPricingLiquidity_202410231302_Canadian_ABS.csv")