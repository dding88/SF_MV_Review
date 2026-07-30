
setwd("~/R/SF-pricing-data-analysis/code")
source('util.R')

# function param:
# risk_window - number days (3M: 63-day, 12M: 250-day)
# data_file_name - oringal csv data file name in data/folder,
# bucketing_flag - 0: generate result for all original ratings in data file
#                  1: grouping ratings first then generate result for only rating category 
# example: run_price_decline_analysis_more_quantile(63, "v_SecuritizedPricingLiquidity_202410231158_CLO.csv", 1 )

run_price_decline_analysis_more_quantile<- function(risk_window,data_file_name,bucketing_flag)
{
  
  
  
  # Read the CSV file with ALL daily data including pricing info
  #file_name = "v_SecuritizedPricingLiquidity_202410231158_CLO.csv"
  file_name = data_file_name
  file_path <- paste("../data/", file_name, sep="")  
  data <- fread(file_path)
  
  
  # for RMBS, filter our IO tranches, ~29%
  if (grepl("NONAGENCY", file_name, ignore.case = TRUE)) {
    
    # Filter rows where Tranche_Name does not contain 'IO', 'I', or 'X'
    # Matching is case-insensitive
    data_no_io <- data[!grepl("IO|I|X", Tranche_Name, ignore.case = TRUE)]
    
    # Calculate % of rows with IO, I, or X in Tranche_Name
    # match_count <-  data[grepl("IO|I|X", Tranche_Name, ignore.case = TRUE), .N]
    # total_count <- nrow(data)
    # 
    # percent_match <- (match_count / total_count) * 100
    #assign back
    data =  data_no_io
  }
  
  # for RMBS, filter our IO tranches, ~16%
  if (grepl("7_CMBS", file_name, ignore.case = TRUE)) {
    
    # Filter rows where Tranche_Name does not contain 'IO', 'I', or 'X'
    # Matching is case-insensitive
    data_no_io <- data[!grepl("X", Tranche_Name, ignore.case = TRUE)]
    
    # Calculate % of rows with IO, I, or X in Tranche_Name
    # data_w_io <- data[grepl("X", Tranche_Name, ignore.case = TRUE)]
    # match_count <-  data[grepl("IO|I|X", Tranche_Name, ignore.case = TRUE), .N]
    # total_count <- nrow(data)
    # 
    # percent_match <- (match_count / total_count) * 100
    #assign back
    data =  data_no_io
    
  }
  
  
  
  #get asset type
  underscore_positions <- gregexpr("_", file_name)[[1]]
  dot_position <- regexpr("\\.", file_name)[1]
  asset_name = substr(file_name, underscore_positions[3] + 1, dot_position - 1)
  
  
  
  
  # read in rating info for each tranch in above data file, all rating info is a separate file
  rating_file_name <- "IDF_rating_info.csv"
  rating_file_path<- paste("../data/", rating_file_name, sep="")
  rating_data <- fread(rating_file_path)
  
  # Ensure key info in right formats 
  data$ISIN <- as.character(data$ISIN)
  data$Mid_Price <- as.numeric(data$Mid_Price)
  data$Type <- as.factor(data$Type)
  data$Date <-as.Date(data$Date)
  data$Deal_name <- as.character(data$Deal_name)
  
  # 2 fix 'Active?' column in the rating table, change 1st name to 'Active' in rating_info data set, 
  # should not have '?' at the end
  
  setnames(rating_data, old = "Active?", new = "Active")
  
  # change column name of 'ISINS' to 'ISIN' in rating_info data set, should not have a 'S' at the end
  setnames(rating_data, old = "ISINS", new = "ISIN")
  
  # remove '(' at the beginning and ')' at the end for rating such as '(BBB (sf))'
  rating_data_rating_trimmed = rating_data
 
  rating_data_rating_trimmed[, `Orig Rating` := sapply(`Orig Rating`, function(x) {
    if (startsWith(x, "(") && endsWith(x, ")")) {
      # Remove both '(' at the start and ')' at the end
      x <- substr(x, 2, nchar(x) - 1)
    }
    return(x)
  })]
  
  
  #get rating info from rating_data based on ISIN, first record is the original rating info
  rating_data_unique <- rating_data_rating_trimmed %>%
    group_by(ISIN) %>%
    slice(1) %>%
    ungroup()
  
  #merge pricing data with rating info by 'ISIN' to create a new data table
  merged_data <- data %>%
    left_join(rating_data_unique, by = "ISIN")
  
  #make rating buckets
  ori_ratings = merged_data$`Orig Rating`
  
  
  merged_data[, `Rating Bucket` := sapply(`Orig Rating`, bucket_rating)]
  # for debugging of rating bucketing correctness
  new_rating = t(merged_data$`Rating Bucket`)
  compare_rating = rbind(ori_ratings,new_rating)
  #end of make rating buckets
  
  #for debugging 
  selected_columns <- c('Date', 'ISIN', 'Ticker', 'Mid_Price', 'WAL', 'Orig Rating')
  # Create a new data table with only the selected columns
  filtered_data <- merged_data[, ..selected_columns]
  #pick out one rating
  condition <- filtered_data[["Orig Rating"]] == "B (sf)"
  filtered_data_1_rating <- filtered_data[condition]
  # Save the filtered data to a CSV file
  #fwrite(filtered_data_1_rating, "filtered_merged_data.csv",append = FALSE,nThread = 4)
  #end of debugging
  
  
  #count total number of rating, rating with (sf) are from SP, otherwise Moody's or Fitch
  rating_count <- uniqueN(merged_data$`Orig Rating`)
  
  
  
  
  
  
  # risk horizon for first round of analysis is 3M (63days) and 12M(250 days), 
  risk_horizon <- risk_window
  
  # create a new column and calculate price decline for given risk horizon  
  set(merged_data, j = "Price_Diff", value = as.numeric(NA))
  merged_data[, Price_Diff := {
    diff_result <- calc_differential(Mid_Price, risk_horizon)
    if (length(diff_result) != .N) {  # Ensure the result has the same length as the group
      rep(NA, .N)
    } else {
      diff_result
    }
  }, by = .(ISIN, `Orig Rating`)]
  
  # rating grouping
  if (bucketing_flag) {
  merged_data_rating_bucket = merged_data
  merged_data_rating_bucket[, `Orig Rating` := sapply(`Orig Rating`, bucket_rating)]
  # Calculate start and end dates for available time serie for each rating
  date_range <- merged_data_rating_bucket[, .(Starting_Date = min(Date, na.rm = TRUE), 
                                End_Date = max(Date, na.rm = TRUE)), 
                            by = `Orig Rating`]
  } else {
    date_range <- merged_data[, .(Starting_Date = min(Date, na.rm = TRUE), 
                                  End_Date = max(Date, na.rm = TRUE)), 
                              by = `Orig Rating`]
  }
  
  # Transpose `date_range` and convert to data frame and remove `Orig Rating` column before transposing
  date_range_df <- as.data.frame(t(date_range[, -1]))  
  
  #  Rename row and column names for compatibility with `quantile_df` later on
  rownames(date_range_df) <- c("Starting_Date", "End_Date")
  colnames(date_range_df) <- date_range$`Orig Rating`
  
  
  
  # combine all ISINs price deline for one rating together
  if (bucketing_flag) {
    rating_diff <- merged_data_rating_bucket[, .(Differential = list(Price_Diff)), by = .(`Orig Rating`, ISIN)]
  } else {
    rating_diff <- merged_data[, .(Differential = list(Price_Diff)), by = .(`Orig Rating`, ISIN)]
  }
  
  #get total data points
  total_values <- sum(lengths(rating_diff[[3]]))
  
  # for each rating, put all price deline together and reformatting to flat
  combined_diff <- rating_diff[, .(Combined_Differential = list(do.call(c, Differential))), by = `Orig Rating`]
  total_combined_values <- sum(sapply(combined_diff$Combined_Differential, length))
  max_length <- max(sapply(combined_diff$Combined_Differential, length))
  
  combined_diff[, Padded_Diff := lapply(Combined_Differential, function(x) c(x, rep(NA, max_length - length(x))))]
  combined_diff_flat <- combined_diff[, .(Padded_Diff = unlist(Padded_Diff)), by = `Orig Rating`]
  
  # Create a wide-format table, one column per 'Orig Rating', wiht each column of all price decline values for this rating
  result <- dcast(combined_diff_flat, rowid(`Orig Rating`) ~ `Orig Rating`, value.var = "Padded_Diff")
  
  result <- result[, -1]
  
  
  # Calculate quantiles for each rating category
  #quantile_levels <- c(0,0.001,0.003,0.005,0.01, 0.05,0.1,0.15,0.25, 0.5, 0.75, 0.85,0.9,0.95, 0.99)
  quantile_levels <- c(0,0.005,0.01, 0.05,0.1,0.15,0.25, 0.5, 0.75, 0.85,0.9,0.95, 0.99)
  
  #get total valid data points
  non_na_counts <- colSums(!is.na(result))
  
  # Convert non-NA counts to a data frame row
  non_na_counts_df <- as.data.frame(t(non_na_counts))
  
  # Rename the row to "Non_NA_Count"
  rownames(non_na_counts_df) <- "Total # Data Point"
  
  
  
  
  # Apply quantile function to each column of the 'result' table
  quantile_result <- apply(result, 2, function(x) quantile(x, probs = quantile_levels, na.rm = TRUE))
  
  # Convert to a data frame so both row and column headers are preserved
  quantile_df <- as.data.frame(quantile_result)
  
  # Add row names for the quantile vector
  rownames(quantile_df) <- paste0("Quantile_", (1-quantile_levels)*100,"%")
  
  # Combine non-NA counts as the top row of quantile_df
  quantile_df <- rbind(non_na_counts_df, quantile_df)
  
  date_range_df <- date_range_df[, colnames(quantile_df), drop = FALSE] 
  
  quantile_df <- rbind(date_range_df, quantile_df)
  # View the final quantile table in command line for checking
  print(quantile_df)
  
  
  
  # Force all columns from row 3 onward to be numeric
  quantile_df[3:nrow(quantile_df), ] <- data.frame(lapply(quantile_df[3:nrow(quantile_df), ], as.numeric))
  quantile_df[1:2, ] <- lapply(quantile_df[1:2, ], as.character)
  
  quantile_df <- as.data.frame(quantile_df)
  
  
  #create info table for 'worst in history'
  worst_values <- quantile_df["Quantile_100%", ] 
  
  worst_dates <- vector("character", length(worst_values))
  worst_deals <- vector("character", length(worst_values))
  worst_isins <- vector("character", length(worst_values))
  
  
  for (i in seq_along(worst_values)) {
    # get the rating name
    rating <- names(worst_values)[i]  
    
    # extract the worst value for this rating
    worst_value <- as.numeric(worst_values[[rating]])
    
    # subset the merged_data for the current rating
    if (bucketing_flag) {
      rating_data <- merged_data_rating_bucket[merged_data$`Orig Rating` == rating, ]
    } else {
      rating_data <- merged_data[merged_data$`Orig Rating` == rating, ]
    }
    
    # locate the row with the worst value
    worst_row <- rating_data[which.min(abs(rating_data$Price_Diff - worst_value)), ]
    
    # store the info if the worst_row is valid
    if (nrow(worst_row) > 0) {
      worst_dates[i] <- as.character(worst_row$Date)
      worst_deals[i] <- worst_row$Deal_name
      worst_isins[i] <- worst_row$ISIN
    } else {
      worst_dates[i] <- NA
      worst_deals[i] <- NA
      worst_isins[i] <- NA
    }
  }
  
  # create the 'worst_info_df' data frame
  ratings_row <- colnames(quantile_df)
  worst_info_df <- rbind(
    #ratings_row,  # First row: Orig Rating values
    worst_values,      # Second row: Worst values (100% quantile)
    worst_dates,       # Third row: Dates of worst values
    worst_deals,       # Fourth row: Deal names of worst values
    worst_isins        # Fifth row: ISINs of worst values
  )
  colnames(worst_info_df) <- colnames(quantile_df)
  
  # add  row names to 'worst_info_df'
  rownames(worst_info_df) <- c(
    # "Orig_Rating", 
    "Worst_Value", 
    "Worst_Date", 
    "Worst_Deal_Name", 
    "Worst_ISIN"
  )
  
  
  result_wb <- createWorkbook()
  addWorksheet(result_wb, asset_name)
  #writeData(result_wb, asset_name, quantile_df, rowNames = TRUE)
  writeData(result_wb, asset_name, quantile_df, rowNames = TRUE, keepNA = TRUE)
  
  addWorksheet(result_wb, paste0(asset_name,"_WORST"))
  writeData(result_wb, paste0(asset_name,"_WORST"), worst_info_df, rowNames = TRUE, keepNA = TRUE)
               
  
  #save the result to report/ folder
  asset_name_with_date <- paste0(asset_name, "_", Sys.Date())
  
  if (bucketing_flag)
  {
  saveWorkbook(result_wb, paste0("../report/result_quantile_",asset_name_with_date,"_with_grouping_",risk_window,"_days",".xlsx"), overwrite = TRUE)
  } else
  {
    saveWorkbook(result_wb, paste0("../report/result_quantile_",asset_name_with_date,"_no_grouping_",risk_window,"_days",".xlsx"), overwrite = TRUE)
  }
  
}

