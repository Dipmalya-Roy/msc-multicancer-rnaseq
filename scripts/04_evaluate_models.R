# scripts/04_evaluate_models.R

# 1. Setup
library(caret)
library(pROC)
library(config)
source("R/preprocessing.R")
source("R/evaluation.R") # Load our new ROC functions
source("R/plotting.R") # Load the new plotting tools

cfg <- config::get()

# 2. Load Data & Isolate Test Set
dt <- readRDS("data/processed/full_clean_data.rds")
train_idx <- readRDS("data/splits/train_index.rds") 
all_indices <- 1:nrow(dt)
test_idx <- setdiff(all_indices, train_idx) 

test_data <- dt[test_idx, ]
x_test_raw <- test_data[, -1]
y_test <- test_data$Class

message("Test set loaded: ", nrow(test_data), " samples.")

# 3. Load Saved Artifacts
selected_features <- readRDS("models/selected_genes_elasticnet.rds")
scaler_stats <- readRDS("models/train_scaler.rds") 

# 4. Preprocess Test Data (Strictly apply Train parameters)
message("Applying Training Scaler to Test Data...")
x_test_log <- transform_log2(x_test_raw, cfg$preprocessing$log_offset)
genes_in_scaler <- names(scaler_stats$means)
x_test_filt <- x_test_log[, genes_in_scaler, drop=FALSE]
x_test_scaled_full <- apply_saved_scaler(x_test_filt, scaler_stats)
x_test_final <- x_test_scaled_full[, selected_features, drop=FALSE]

# 5. Evaluation Function (Calculates Accuracy and AUC)
evaluate_model <- function(model_path, model_name) {
  model <- readRDS(model_path)
  
  # Predict classes & Accuracy
  preds <- predict(model, newdata = x_test_final)
  cm <- confusionMatrix(preds, y_test)
  acc <- cm$overall["Accuracy"]
  
  # Calculate ROC and AUC
  roc_list <- calculate_ovr_roc(model, x_test_final, y_test)
  macro_auc <- get_macro_auc(roc_list)
  
  #  NEW: Generate and save the ROC plot 
  plot_path <- paste0("results/figures/roc_", model_name, ".png")
  plot_multiclass_roc(roc_list, model_name, plot_path)
  message(model_name, " | Accuracy: ", round(acc, 4), " | Macro-AUC: ", round(macro_auc, 4))
  
  # Save Confusion Matrix
  write.csv(as.matrix(cm$table), paste0("results/tables/cm_", model_name, ".csv"))
  
  return(list(name = model_name, accuracy = acc, auc = macro_auc))
}

# 6. Run Evaluation
message("Evaluating Models...")
res_svm <- evaluate_model("models/svm_model.rds", "SVM")
res_rf  <- evaluate_model("models/rf_model.rds", "RandomForest")
res_knn <- evaluate_model("models/knn_model.rds", "KNN")
res_gda <- evaluate_model("models/gda_model.rds", "GDA")

# 7. Compile and Save Results
results_df <- data.frame(
  Model = c("SVM", "RandomForest", "KNN", "GDA"),
  Accuracy = c(res_svm$accuracy, res_rf$accuracy, res_knn$accuracy, res_gda$accuracy),
  Macro_AUC = c(res_svm$auc, res_rf$auc, res_knn$auc, res_gda$auc) 
)

write.csv(results_df, "results/tables/final_metrics.csv", row.names = FALSE)
message("✅ Evaluation complete. Final metrics saved to results/tables/final_metrics.csv")