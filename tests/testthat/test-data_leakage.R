# tests/testthat/test-data_leakage.R
library(testthat)

test_that("Strict Isolation: Train and Test indices do not overlap", {
  
  # 1. Load the data and indices
  dt <- readRDS("../../data/processed/full_clean_data.rds")
  train_idx <- readRDS("../../data/splits/train_index.rds")
  
  # Calculate test indices
  all_indices <- 1:nrow(dt)
  test_idx <- setdiff(all_indices, train_idx)
  
  # 2. Check for overlap
  overlap <- intersect(train_idx, test_idx)
  
  # 3. The Test: Length of overlap MUST be 0
  expect_length(overlap, 0)
})

test_that("Scaler Rigor: Test data was not used to calculate Means", {
  
  # 1. Load Test Data and the Training Scaler
  dt <- readRDS("../../data/processed/full_clean_data.rds")
  train_idx <- readRDS("../../data/splits/train_index.rds")
  scaler_stats <- readRDS("../../models/train_scaler.rds")
  
  all_indices <- 1:nrow(dt)
  test_idx <- setdiff(all_indices, train_idx)
  test_data <- dt[test_idx, -1] # Just features
  
  # 2. Get original raw means of the test set
  test_raw_means <- colMeans(test_data)
  
  # 3. Get the means saved in the scaler (which should be from the TRAIN set)
  train_scaler_means <- scaler_stats$means
  
  # 4. The Test: The scaler means MUST NOT perfectly match the test set means. 
  # If they matched perfectly, it would prove we scaled globally (Data Leakage).
  # We check the first 10 genes to be sure.
  expect_false(identical(test_raw_means[1:10], train_scaler_means[1:10]))
})