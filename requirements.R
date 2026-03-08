# requirements.R
# This script ensures all necessary packages are installed before running the pipeline.

required_packages <- c(
  "data.table",   # Fast data loading
  "dplyr",        # Data manipulation
  "config",       # YAML configuration handling
  "factoextra",   # Clustering visualization
  "cluster",      # Clustering algorithms
  "ggplot2",      # Standard plotting
  "ggrepel",      # Plot text spacing
  "caret",        # Machine Learning workflow
  "glmnet",       # Elastic Net feature selection
  "doParallel",   # Parallel processing
  "e1071",        # SVM base
  "kernlab",      # SVM radial kernel backend
  "randomForest", # Random Forest
  "MASS",         # GDA/LDA
  "pROC",         # ROC and AUC calculations
  "MLmetrics",    # Advanced metrics calculation
  "testthat"      # Unit testing
)

# Check which packages are already installed
installed_packages <- rownames(installed.packages())

# Install missing packages
for (pkg in required_packages) {
  if (!(pkg %in% installed_packages)) {
    message("Installing missing package: ", pkg)
    install.packages(pkg, dependencies = TRUE)
  } else {
    message("✔ Package already installed: ", pkg)
  }
}

message("✅ All required dependencies are ready to go!")