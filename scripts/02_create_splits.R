# scripts/02_create_splits.R

# 1. Setup
library(caret)
library(config)
source("R/data_loaders.R")

# Read Config
cfg <- config::get()

# 2. Load the Full Data
# We load it one last time to split it.
dt <- load_merged_data(
  rna_path = cfg$paths$rna_data,
  label_path = cfg$paths$label
)

message("Loaded dataset with ", nrow(dt), " samples.")

# 3. Create Partition Indices
# We use caret::createDataPartition to ensure the class balance is preserved 
# (e.g., if 20% of total is BRCA, 20% of Train will be BRCA).
set.seed(cfg$modeling$seed) # [cite: 374, 375]

# This returns the Row Numbers (Indices) for the Training Set
train_index <- createDataPartition(
  y = dt$Class, 
  p = cfg$modeling$train_fraction, 
  list = FALSE
)

message("Created training split with ", length(train_index), " samples.")

# 4. Save Artifacts for Next Steps
# We save the INDICES, not the data itself, to keep it lightweight and unambiguous.
saveRDS(train_index, "data/splits/train_index.rds")

# We also save the clean merged data so downstream scripts don't have to re-merge CSVs.
saveRDS(dt, "data/processed/full_clean_data.rds")

message("✅ Split indices saved to data/splits/train_index.rds")
message("✅ Cleaned data saved to data/processed/full_clean_data.rds")