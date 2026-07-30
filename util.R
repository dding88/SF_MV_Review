# Load  libraries
library(data.table)  
library(dplyr)       
library(tidyr)
library(openxlsx)


# differential/price decline calculatoin function (return over risk_horizon (days))
# params: 
# pricing: vector or price
# risk_horizon: number of days
calc_differential <- function(pricing, risk_horizon) {
  # Ensure pricing is numeric and replace empty strings with NA
  pricing <- as.numeric(pricing)
  pricing[pricing == ""] <- NA
  
  # If all values are NA or 0, return a vector of NA of the same length
  if (all(is.na(pricing)) || all(pricing == 0,na.rm = TRUE)) {
    return(rep(NA, length(pricing)))
  }
  
  # Find the first valid non-zero, non-NA price
  first_valid_index <- which(!is.na(pricing) & pricing != 0)[1]
  
  # If the first valid value is found, carry it backward to fill any leading NAs or 0s
  if (!is.na(first_valid_index) && first_valid_index > 1) {
    pricing[1:(first_valid_index - 1)] <- pricing[first_valid_index]
  }
  
  # Carry forward the last valid price for zeros or missing values, assuming current price to previous one
  for (i in 2:length(pricing)) {
    if (is.na(pricing[i]) || pricing[i] == 0) {
      pricing[i] <- pricing[i - 1]
    }
  }
  
  # If the length of pricing is less than or equal to the risk horizon, return NA
  if (length(pricing) <= risk_horizon) {
    return(rep(NA, length(pricing)))
  }
  
  # Calculate the differential using the adjusted pricing
  diff_result <- (pricing[(risk_horizon + 1):length(pricing)] - pricing[1:(length(pricing) - risk_horizon)]) / 
    pricing[1:(length(pricing) - risk_horizon)]
  
  # Add NA at the beginning to match the input length
  full_result <- c(rep(NA, risk_horizon), diff_result)
  
  # Ensure the result length matches the input length
  return(full_result[1:length(pricing)])  
}


#grouping all possible rating denotations in orignal data file into ONE rating category
bucket_rating <- function(rating) {
  if (grepl("^AAA\\b|AAA \\(sf\\)|AAAp\\b|AAAp \\(sf\\)", rating)) {
    return("AAA")
  } else if (grepl("^AA[+-]?\\b|AA \\(sf\\)|AAp\\b|AAp \\(sf\\)", rating)) {
    return("AA")
  } else if (grepl("^A[+-]?\\b|A \\(sf\\)|Ap\\b|Ap \\(sf\\)", rating)) {
    return("A")
  } else if (grepl("^BBB[+-]?\\b|BBB \\(sf\\)|BBBp\\b|BBBp \\(sf\\)", rating)) {
    return("BBB")
  } else if (grepl("^BB[+-]?\\b|BB \\(sf\\)|BBp\\b|BBp \\(sf\\)", rating)) {
    return("BB")
  } else if (grepl("^B[+-]?\\b|B \\(sf\\)|Bp\\b|Bp \\(sf\\)", rating)) {
    return("B")
  } else if (rating == "NR") {
    return("NR")
  } else {
    return("NR")  # unexpected values or any ohter rating such as 'C' or 'D' will be treated as 'NR'
  }
}

#grouping in accordance of current MV criteria - putting AAA, AA, A into one bucket
bucket_rating_MV_criteria <- function(rating) {
  if (grepl("^AAA\\b|AAA \\(sf\\)|AAAp\\b|AAAp \\(sf\\)", rating)) {
    return("AAA_AA_A")
  } else if (grepl("^AA[+-]?\\b|AA \\(sf\\)|AAp\\b|AAp \\(sf\\)", rating)) {
    return("AAA_AA_A")
  } else if (grepl("^A[+-]?\\b|A \\(sf\\)|Ap\\b|Ap \\(sf\\)", rating)) {
    return("AAA_AA_A")
  } else if (grepl("^BBB[+-]?\\b|BBB \\(sf\\)|BBBp\\b|BBBp \\(sf\\)", rating)) {
    return("BBB")
  } else if (grepl("^BB[+-]?\\b|BB \\(sf\\)|BBp\\b|BBp \\(sf\\)", rating)) {
    return("BB")
  } else if (grepl("^B[+-]?\\b|B \\(sf\\)|Bp\\b|Bp \\(sf\\)", rating)) {
    return("B")
  } else if (rating == "NR") {
    return("NR")
  } else {
    return("NR")  # unexpected values or any ohter rating such as 'C' or 'D' will be treated as 'NR'
  }
}
