library(caret)
library(glmnet)
library(doParallel)

#' Run Elastic Net Feature Selection
#' Runs glmnet with Parallel Processing and Cross-Validation.
#' @param x_train Scaled training matrix
#' @param y_train Training labels (factor)
#' @param alpha_grid Vector of alpha values to tune (0=Ridge, 1=Lasso)
#' @param n_cores Number of CPU cores to use
#' @param seed Random seed for reproducibility
run_elastic_net_selection <- function(x_train, y_train, alpha_grid, n_cores = 2, seed = 123) {
  
  # 1. Setup Parallel Processing
  # This makes the heavy math run much faster by using multiple CPU cores
  cl <- makeCluster(n_cores)
  registerDoParallel(cl)
  message("Elastic Net: Running on ", getDoParWorkers(), " cores.")
  
  set.seed(seed)
  
  # 2. Define Train Control
  # We use Cross-Validation (CV) to find the best hyperparameters without overfitting
  ctrl <- trainControl(method = "cv", number = 10, allowParallel = TRUE)
  
  # 3. Define Grid of Hyperparameters
  # We test many combinations of Alpha (mixing) and Lambda (penalty)
  tune_grid <- expand.grid(alpha = alpha_grid, 
                           lambda = seq(0.001, 1, length.out = 100))
  
  # 4. Train the Model
  model <- train(
    x = x_train,
    y = y_train,
    method = "glmnet",
    family = "multinomial", # Multi-class classification
    tuneGrid = tune_grid,
    trControl = ctrl
  )
  
  # 5. Stop Cluster (Clean up computer resources)
  stopCluster(cl)
  return(model)
}

#' Extract Selected Features
#' Pulls the names of genes that have non-zero coefficients.
extract_selected_features <- function(caret_model) {
  # Get best parameters
  best_alpha <- caret_model$bestTune$alpha
  best_lambda <- caret_model$bestTune$lambda
  
  # Get the final model object
  final_model <- caret_model$finalModel
  
  # Get coefficients at the best lambda
  coefs <- coef(final_model, s = best_lambda)
  
  # Extract non-zero features across all classes
  selected_features <- c()
  for (i in 1:length(coefs)) {
    mat <- as.matrix(coefs[[i]])
    # Find rows where coefficient is NOT zero
    feats <- rownames(mat)[mat[,1] != 0]
    # Remove the Intercept (it's not a gene)
    feats <- feats[feats != "(Intercept)"]
    selected_features <- c(selected_features, feats)
  }
  
  return(unique(selected_features))
}
