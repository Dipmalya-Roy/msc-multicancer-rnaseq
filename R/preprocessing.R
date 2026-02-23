# R/preprocessing.R

#' Log2 Transformation
#' Adds a small offset to handle zeros, then applies log2.
transform_log2 <- function(data_matrix, offset = 0.25) {
  log2(data_matrix + offset)
}

#' Variance Filtering
#' Returns the NAMES of the genes with the highest variance.
get_high_variance_genes <- function(data_matrix, quantile_threshold = 0.8) {
  # Calculate variance for each gene (column)
  gene_variances <- apply(data_matrix, 2, var)
  
  # Determine the cutoff value
  threshold <- quantile(gene_variances, probs = quantile_threshold)
  
  # Return names of genes that pass the threshold
  return(names(gene_variances)[gene_variances >= threshold])
}

# --- RIGOROUS SCALING LOGIC (PREVENTS LEAKAGE) ---

#' Fit Scaler on Training Data
#' Calculates Mean and SD on the training set and scales it.
#' Returns a list containing the scaler stats and the scaled data.
fit_and_apply_scaler <- function(train_data) {
  # 1. Calculate statistics on TRAIN data ONLY
  means <- colMeans(train_data)
  sds <- apply(train_data, 2, sd)
  
  # Handle constant columns (sd = 0) to avoid division by zero
  sds[sds == 0] <- 1 
  
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