library(tidyverse)
library(data.table)
library(fs)

source_dir <- "C://Users//erich//RData//file_combination"
max_files_per_combination <- 4

files <- path_file(dir_ls(source_dir))
files_list <- split(files, ceiling(seq_along(files) / max_files_per_combination))

all_data_df <-
  fread(
    paste(source_dir, files_list[[1]][1], sep = "//"),
    sep = "|",
    quote = "",
    header = FALSE,
    fill = TRUE,
    stringsAsFactors = FALSE,
    colClasses = c("character")
  )
