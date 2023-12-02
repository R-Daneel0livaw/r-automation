library(tidyverse)
library(data.table)
library(fs)

source_dir <- "C://Users//erich//RData//file_combination//input"
dest_dir <- "C://Users//erich//RData//file_combination//output"
max_files_per_combination <- 4

files <- path_file(dir_ls(source_dir))
files_list <- split(files, ceiling(seq_along(files) / max_files_per_combination))

combine_files <- function(files) {
   detail_rows <- files %>% map_dfr(get_detail_rows)
}

get_detail_rows <- function(file_name) {
  all_data_df <-
    fread(
      paste(source_dir, file_name, sep = "//"),
      sep = "|",
      quote = "",
      header = FALSE,
      fill = TRUE,
      stringsAsFactors = FALSE,
      colClasses = c("character")
    )
  
  detail_rows <- all_data_df %>% slice(2:(n()-1))
}

combined_files <- files_list %>% map(combine_files)

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

first_row_df <- all_data_df[1, , drop = FALSE]
first_row_df <-  first_row_df %>% select(-where(~any(str_length(.) < 1)))

last_row_df <- all_data_df[nrow(all_data_df), , drop = FALSE]
last_row_df <- last_row_df %>% select(-where(~any(str_length(.) < 1)))

detail_rows_df <- all_data_df[-c(1, nrow(all_data_df)), , drop = FALSE]

fwrite(
  first_row_df,
  paste(dest_dir, "oo.txt", sep = "//"),
  sep = "|",
  col.names = FALSE
)
fwrite(
  detail_rows_df,
  paste(dest_dir, "oo.txt", sep = "//"),
  sep = "|",
  append = TRUE
)
fwrite(
  last_row_df,
  paste(dest_dir, "oo.txt", sep = "//"),
  sep = "|",
  append = TRUE
)


