# run_pipeline.R
# Master Orchestrator for the Cancer Subtype Classification Pipeline

message("===========================================")
message("    STARTING CANCER SUBTYPE PIPELINE     ")
message("===========================================")

# Step 0: Ensure dependencies are installed
message("\n--- Step 0: Checking Dependencies ---")
source("requirements.R")

# Step 1: Unsupervised Learning (Clustering & PCA)
message("\n--- Step 1: Running Global Clustering ---")
source("scripts/01_global_clustering.R")

# Step 2: Data Splitting (Strict 80/20 Split)
message("\n--- Step 2: Creating Train/Test Splits ---")
source("scripts/02_create_splits.R")

# Step 3: Supervised Training (Scaling, Feature Selection, Modeling)
# Note: This step takes the longest due to parallel Elastic Net and Random Forest
message("\n--- Step 3: Training Supervised Models ---")
source("scripts/03_supervised_training.R")

# Step 4: Evaluation (Testing on hold-out data)
message("\n--- Step 4: Evaluating Models ---")
source("scripts/04_evaluate_models.R")

# Step 5: Run Unit Tests (Proof of Rigor)
message("\n--- Step 5: Running Integrity Tests ---")
source("tests/testthat.R")

message("===========================================")
message("   ✅ PIPELINE EXECUTED SUCCESSFULLY!      ")
message("===========================================")
 