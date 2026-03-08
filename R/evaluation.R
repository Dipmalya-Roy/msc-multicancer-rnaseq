library(pROC)

#' Calculate One-vs-Rest ROC curves
#' @param model Trained caret model
#' @param x_test Scaled test data features
#' @param y_test Test data labels
#' @return A list of ROC objects per class
calculate_ovr_roc <- function(model, x_test, y_test) {
  num_classes <- length(levels(y_test))
  roc_list <- list()
  
  # Caret safely extracts probabilities for SVM, RF, KNN, and GDA uniformly
  pred_prob <- predict(model, newdata = x_test, type = "prob")
  
  for (i in 1:num_classes) {
    current_class <- levels(y_test)[i]
    # Create binary target (1 vs Rest)
    binary_y_test <- as.numeric(y_test == current_class)
    
    # Calculate ROC
    if (current_class %in% colnames(pred_prob)) {
      roc_list[[current_class]] <- roc(response = binary_y_test, 
                                       predictor = pred_prob[, current_class],
                                       quiet = TRUE)
    }
  }
  return(roc_list)
}

#' Extract Macro Average AUC
#' @param roc_list List of ROC objects from calculate_ovr_roc
#' @return Single numeric Macro AUC
get_macro_auc <- function(roc_list) {
  auc_values <- sapply(roc_list, function(x) if (!is.null(x)) as.numeric(auc(x)) else NA)
  return(mean(auc_values, na.rm = TRUE))
}