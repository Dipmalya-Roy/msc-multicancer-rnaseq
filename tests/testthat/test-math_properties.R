# tests/testthat/test-math_properties.R
library(testthat)
source("../../R/preprocessing.R")

test_that("Log2 transform handles zeros correctly", {
  # 1. Create fake data with a zero
  fake_data <- matrix(c(0, 3, 7, 15), nrow = 2)
  
  # 2. Apply our function (default offset is 0.25)
  result <- transform_log2(fake_data, offset = 0.25)
  
  # 3. Check the math: log2(0 + 0.25) should equal -2
  expect_equal(result[1, 1], -2)
})

test_that("High variance filter selects the correct genes", {
  # 1. Create a fake matrix. 
  # Gene1 has no variance (all 5s). Gene2 has high variance.
  fake_genes <- data.frame(
    Gene1 = c(5, 5, 5, 5),
    Gene2 = c(1, 10, 100, 1000)
  )
  
  # 2. Run our function, asking for the top 50% variance
  selected <- get_high_variance_genes(fake_genes, quantile_threshold = 0.5)
  
  # 3. Check that it correctly dropped Gene1 and kept Gene2
  expect_equal(selected, "Gene2")
})