# R/preprocessing.R

#' Log2 Transformation
#' Adds a small offset to handle zeros, then applies log2.
transform_log2 <- function(data_matrix, offset = 0.25) {
  # 1. Force into a pure matrix to protect data structure
  mat <- as.matrix(data_matrix)
  
  # 2. Apply the log math
  log_mat <- log2(mat + offset)
  
  # 3. Explicitly lock the column names back in place
  colnames(log_mat) <- colnames(data_matrix)
  
  return(log_mat)
}

#' Variance Filtering
#' Returns the NAMES of the genes with the highest variance.
get_high_variance_genes <- function(data_matrix, quantile_threshold = 0.8) {
  # 1. Force into matrix to protect headers
  mat <- as.matrix(data_matrix)
  
  # 2. Calculate variance, safely ignoring NAs
  gene_variances <- apply(mat, 2, var, na.rm = TRUE)
  
  # 3. SAFETY NET: Re-attach names if apply() accidentally stripped them
  if (is.null(names(gene_variances))) {
    names(gene_variances) <- colnames(mat)
  }
  
  # 4. Filter logic: convert NA variances to 0 so they are dropped
  gene_variances[is.na(gene_variances)] <- 0
  
  # 5. Calculate threshold
  threshold <- quantile(gene_variances, probs = quantile_threshold, na.rm = TRUE)
  
  # 6. Return names of genes that pass the threshold
  return(names(gene_variances)[gene_variances >= threshold])
}

# --- RIGOROUS SCALING LOGIC (PREVENTS LEAKAGE) ---

#' Fit Scaler on Training Data
#' Calculates Mean and SD on the training set and scales it.
#' Returns a list containing the scaler stats and the scaled data.
fit_and_apply_scaler <- function(train_data) {
  # 1. Calculate statistics on TRAIN data ONLY (safely ignoring NAs)
  means <- colMeans(train_data, na.rm = TRUE)
  sds <- apply(train_data, 2, sd, na.rm = TRUE)
  
  # Handle constant or empty columns (sd = 0 or NA) to avoid division by zero
  sds[is.na(sds) | sds == 0] <- 1 
  means[is.na(means)] <- 0
  
  # 2. Scale the training data
  scaled_data <- scale(train_data, center = means, scale = sds)
  
  # 3. Return both the stats (to save) and data (to use)
  list(
    scaler = list(means = means, sds = sds),
    scaled_data = scaled_data
  )
}

#' Apply Saved Scaler to New Data
#' Uses the Means/SDs from the Training set to scale Test/New data.
apply_saved_scaler <- function(new_data, scaler_stats) {
  scale(new_data, center = scaler_stats$means, scale = scaler_stats$sds)
}