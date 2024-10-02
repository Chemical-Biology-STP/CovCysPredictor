# This file converts pkl files to rds files for downstream analysis
# or output via e.g. rshiny/rsconnect

library(reticulate)
args = commandArgs(trailingOnly=TRUE)
# Rscript --vanilla convert_files.R output_dir

output_dir = args[1]

pkl_files <- list.files(output_dir, pattern="pkl$")

for (pkl_file in pkl_files) {
  if (!file.exists(paste0(output_dir, "/", sub("pkl","rds", pkl_file)))) {
    df <- py_load_object(paste0(output_dir, "/", pkl_file))
    saveRDS(df, paste0(output_dir, "/", sub("pkl", "rds", pkl_file)))
  }
}
