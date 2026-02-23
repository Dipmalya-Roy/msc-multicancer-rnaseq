# scripts/01_global_clustering.R

# 1. Setup
# Load the "recipes" we wrote earlier
source("R/data_loaders.R")
source("R/preprocessing.R")

# Load necessary libraries
library(config)
library(factoextra)
library(cluster)
library(ggplot2)

# Read the "Pantry List" (Config)
cfg <- config::get()

# 2. Load Data
# We use the keys exactly as defined in your config.yml
dt <- load_merged_data(
  rna_path = cfg$paths$rna_data,
  label_path = cfg$paths$label 
)

# Separate Genes (Features) from Class (Labels)
gene_data <- dt[, -1] 

# 3. Preprocessing (Global)
# Note: Global scaling is acceptable here because this is UNSUPERVISED exploration.
# We are not training a predictor to generalize to new data yet.
message("Transforming data...")
log_data <- transform_log2(gene_data, cfg$preprocessing$log_offset)

# Simple scaling for PCA
scaled_data <- scale(log_data) 

# 4. Variance Filter
message("Filtering genes...")
# Use the function from R/preprocessing.R
selected_genes <- get_high_variance_genes(scaled_data, cfg$preprocessing$var_threshold_quantile)
cluster_data <- scaled_data[, selected_genes, drop=FALSE]

message("Selected ", length(selected_genes), " genes for clustering.")

# 5. PCA (Principal Component Analysis)
message("Running PCA...")
pca_res <- prcomp(cluster_data, scale. = FALSE) 

# --- Save Scree Plot ---
png("results/figures/pca_scree.png")
fviz_eig(pca_res, addlabels = TRUE, main = "Scree Plot")
dev.off()

# --- Save PCA Cluster Plot ---
# We take the top N components defined in config
reduced_data <- pca_res$x[, 1:cfg$clustering$pca_components]
pca_df <- data.frame(reduced_data, Class = dt$Class)

png("results/figures/pca_clusters.png")
print(
  ggplot(pca_df, aes(PC1, PC2, color = Class)) + 
    geom_point(alpha = 0.6) + 
    theme_minimal() +
    ggtitle("PCA Plot of Cancer Subtypes")
)
dev.off()

# 6. K-Means Clustering
message("Running K-Means (k=", cfg$clustering$kmeans_k, ")...")
set.seed(cfg$modeling$seed)
km_res <- kmeans(reduced_data, centers = cfg$clustering$kmeans_k, nstart = cfg$clustering$kmeans_nstart)

png("results/figures/kmeans_plot.png")
print(fviz_cluster(km_res, data = reduced_data, main = "K-Means Clustering"))
dev.off()

# 7. K-Medoids (PAM) - Robustness Check
message("Running K-Medoids (PAM)...")
pam_res <- pam(reduced_data, k = cfg$clustering$kmeans_k)

png("results/figures/kmedoids_plot.png")
print(fviz_cluster(pam_res, data = reduced_data, main = "K-Medoids Clustering"))
dev.off()

message("✅ Unsupervised pipeline complete. Figures saved to results/figures/")