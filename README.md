# Cancer Subtype Classification Pipeline

This repository contains an  machine learning pipeline for classifying cancer subtypes using high-dimensional RNA-Seq gene expression data. 

## Project Architecture
This project has been heavily refactored from standard exploratory research scripts into a modular pipeline.

* `config.yml`: The master configuration file (hyperparameters, file paths, seeds).
* `R/`: Core logic and pure functions (Data loading, Strict Preprocessing, Feature Selection, Evaluation).
* `scripts/`: Execution scripts that run the actual steps of the pipeline.
* `tests/`: Mathematical proofs ensuring zero data leakage and correct transformations.
* `models/`: Where trained scalers, selected features, and caret models are saved.
* `results/`: Output directories for generated ROC curves, cluster plots, and metric tables.

## Setup Instructions

**1. Install Dependencies**
Open R or RStudio and run the requirements script to ensure you have all necessary packages:
```R
source("requirements.R")