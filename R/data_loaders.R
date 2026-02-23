library(data.table)
library(dplyr)

load_merged_data <- function(rna_path, label_path) {
  # Load raw files
  message("Loading data from: ", rna_path)
  rna_data <- fread(rna_path)
  
  message("Loading label from: ", label_path)
  label_data <- fread(label_path, header = TRUE)
  
  # Check dimensions match (Rows must be equal)
  if (nrow(rna_data) != nrow(label_data)) {
    stop("Row mismatch between RNA data and label!")
  }
  
  # 1. Bind them exactly as in original code
  # original: data2=cbind(data1,rna_data,header=TRUE)
  combined_data <- cbind(label_data, rna_data)
  
  # 2. Remove columns 1 and 3 from the COMBINED result
  # original: data2=data2[ ,-c(1,3)]
  # We use with=FALSE to ensure data.table handles indices correctly
  combined_data <- combined_data[, -c(1, 3), with = FALSE]
  
  # 3. Rename the first remaining column to "Class" (Target)
  # In original code, column 2 (which becomes col 1) was  the Class
  colnames(combined_data)[1] <- "Class"
  
  # Convert Class to factor
  combined_data$Class <- as.factor(combined_data$Class)
  
  return(combined_data)
}
