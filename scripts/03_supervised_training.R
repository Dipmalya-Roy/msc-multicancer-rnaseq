# scripts/03_supervised_training.R

# 1. Setup
library(caret)
library(config)
library(doParallel)
library(e1071)      # For SVM
library(randomForest)
library(MASS)       # For LDA (GDA)

# Load our custom functions
source("R/preprocessing.R")
source("R/feature_selection.R")

cfg <- config::get()

# 2. Load Data & Splits
# We read the cleaned data and the training indices we created in step 02
dt <- readRDS("data/processed/full_clean_data.rds")
train_idx <- readRDS("data/splits/train_index.rds")

# SUBSET: Strictly isolate the Training Data
# The Test set is physically removed from memory here.
train_data <- dt[train_idx, ]
x_train_raw <- train_data[, -1] # Genes
y_train <- train_data$Class     # Labels

message("Training set loaded: ", nrow(train_data), " samples.")

# 3. Preprocessing (Strict Train-Only)
message("Preprocessing Training Data...")

# A. Log Transform
x_train_log <- transform_log2(x_train_raw, cfg$preprocessing$log_offset)

# B. Variance Filter (Calculated on Train)
# We identify the noisy genes using only the training data
selected_genes_var <- get_high_variance_genes(x_train_log, cfg$preprocessing$var_threshold_quantile)
x_train_filt <- x_train_log[, selected_genes_var, drop=FALSE]

message("Variance filtering retained ", length(selected_genes_var), " genes.")

# C. Scaling (The Non-Negotiable Fix)
# We fit the scaler (Mean/SD) on Train, apply it, and SAVE the stats for Test later.
message("Fitting Scaler on Training Data...")
scaling_result <- fit_and_apply_scaler(x_train_filt)

# Extract the scaled data for training
x_train_scaled <- scaling_result$scaled_data

# SAVE ARTIFACT 1: The Scaler Statistics
# We need these to scale the Test Set exactly the same way.
saveRDS(scaling_result$scaler, "models/train_scaler.rds")
message("✅ Scaler statistics saved to models/train_scaler.rds")

# 4. Feature Selection (Elastic Net)
message("Starting Elastic Net Selection (Parallel)...")

# We use the function from R/feature_selection.R
en_model <- run_elastic_net_selection(
  x_train = x_train_scaled, 
  y_train = y_train, 
  alpha_grid = unlist(cfg$modeling$elastic_net_alpha_grid),
  n_cores = cfg$modeling$n_cores
)

# Extract the specific genes selected by the model
final_features <- extract_selected_features(en_model)
message("Elastic Net selected ", length(final_features), " significant genes.")

# SAVE ARTIFACT 2: The Final Feature List
saveRDS(final_features, "models/selected_genes_elasticnet.rds")
message("✅ Selected features saved to models/selected_genes_elasticnet.rds")

# 5. Model Training (The 4 Classifiers)
# Subset Training Data to ONLY the final selected features
x_train_final <- x_train_scaled[, final_features, drop=FALSE]
train_df_final <- data.frame(Class = y_train, x_train_final)

# Setup Cross-Validation for all models
ctrl <- trainControl(
  method = "cv", 
  number = cfg$modeling$cv_folds, 
  classProbs = TRUE, 
  summaryFunction = multiClassSummary
)

# A. SVM (Support Vector Machine)
message("Training SVM...")
set.seed(cfg$modeling$seed)
svm_model <- train(Class ~ ., data = train_df_final, method = "svmRadial", trControl = ctrl)
saveRDS(svm_model, "models/svm_model.rds")

# B. Random Forest
message("Training Random Forest...")
set.seed(cfg$modeling$seed)
rf_model <- train(Class ~ ., data = train_df_final, method = "rf", trControl = ctrl)
saveRDS(rf_model, "models/rf_model.rds")

# C. KNN (K-Nearest Neighbors)
message("Training KNN...")
set.seed(cfg$modeling$seed)
knn_model <- train(Class ~ ., data = train_df_final, method = "knn", trControl = ctrl)
saveRDS(knn_model, "models/knn_model.rds")

# D. GDA (Gaussian Discriminant Analysis / LDA)
message("Training GDA (LDA)...")
set.seed(cfg$modeling$seed)
# LDA assumes normal distribution, works well with our scaled data
lda_model <- train(Class ~ ., data = train_df_final, method = "lda", trControl = ctrl)
saveRDS(lda_model, "models/gda_model.rds")

message("✅ All models trained and saved to models/")