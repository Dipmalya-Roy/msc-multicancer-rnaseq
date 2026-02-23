# setup_project.R
# RUN THIS ONCE TO BUILD YOUR ELITE FOLDER STRUCTURE

# 1. Define the directory tree
dirs <- c(
  "data/raw", "data/processed", "data/splits",
  "R", "scripts", "tests/testthat",
  "models", "results/tables", "results/figures", "reports"
)

message("Creating directories...")
for (d in dirs) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE)
    message("  ✓ Created: ", d)
  }
}

# 2. Add .gitkeep to preserve empty folders in Git
for (d in c("data/raw", "data/splits", "models", "results/tables", "results/figures")) {
  gitkeep <- file.path(d, ".gitkeep")
  if (!file.exists(gitkeep)) file.create(gitkeep)
}

# 3. Create placeholder files
files <- c(
  "config.yml", ".Rprofile", ".gitignore", "README.md", "run_pipeline.R",
  "R/data_loaders.R", "R/preprocessing.R", "R/feature_selection.R", 
  "R/evaluation.R", "R/plotting.R",
  "scripts/01_global_clustering.R", "scripts/02_create_splits.R",
  "scripts/03_supervised_training.R", "scripts/04_evaluate_models.R",
  "tests/testthat.R", "tests/testthat/test-data_leakage.R",
  "tests/testthat/test-math_properties.R",
  "reports/dissertation.qmd", "reports/references.bib"
)

message("\nCreating files...")
for (f in files) {
  if (!file.exists(f)) {
    file.create(f)
    message("  ✓ Created: ", f)
  }
}

# 4. Populate key files
if (!file.exists(".gitignore") || file.size(".gitignore") == 0) {
  writeLines(c(
    ".Rproj.user", ".Rhistory", ".RData", ".Ruserdata",
    "renv/library/", "models/*.rds", "data/processed/*.rds",
    "data/raw/*", "!data/raw/.gitkeep", ".DS_Store"
  ), ".gitignore")
}

if (!file.exists(".Rprofile") || file.size(".Rprofile") == 0) {
  cat('source("renv/activate.R")\n', file = ".Rprofile")
}

if (!file.exists("config.yml") || file.size("config.yml") == 0) {
  cat('var_threshold: 0.8\nn_folds: 5\nalpha: 0.5\nseed: 42\n', file = "config.yml")
}

if (!file.exists("README.md") || file.size("README.md") == 0) {
  cat('# MSc Multi-Cancer RNA-Seq Pipeline\n\nRun: `source("run_pipeline.R")`\n', 
      file = "README.md")
}

message("\n✅ Project structure created successfully!")
message("Next steps:\n  1. Run renv::init() to lock dependencies\n  2. Add raw data to data/raw/")
