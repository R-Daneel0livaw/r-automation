library(tidyverse)
library(data.table)
library(fs)

source_dir <- "C://Users//erich//RData//file_combination//input"
dest_dir <- "C://Users//erich//RData//file_combination//output"
max_files_per_combination <- 4

combine_files <- function(files) {
  header_row <- get_common_header(get_first(files))
  footer_row <- get_common_footer(get_first(files))
  detail_rows <- files %>% map_dfr(get_detail_rows)
  updated_footer_row <- update_footer(footer_row, (nrow(detail_rows) + 2))
  res <- list(header = header_row, footer = updated_footer_row, detail_rows = detail_rows, file_name = get_first(files))
  res
}

get_files <- function() {
  files <- path_file(dir_ls(source_dir))
  files_list <- split(files, ceiling(seq_along(files) / max_files_per_combination))
}

get_first <- function(files) {
  first_file <- files[[1]][1]
  first_file
}

get_detail_rows <- function(file_name) {
  all_data_df <- read_file_df(file_name)
  detail_rows <- all_data_df %>% slice(2:(n()-1))
  detail_rows
}

get_common_header <- function(file_name) {
  header_df <- read_file_df(file_name)
  header <- header_df %>% slice(1) %>% trim_empty_cols()
  header
}

get_common_footer <- function(file_name) {
  footer_df <- read_file_df(file_name)
  footer <- footer_df %>% slice(n()) %>% trim_empty_cols()
  footer
}

update_footer <- function(footer, num_rows) {
  updated_footer <-
    footer %>% mutate(V2 = str_pad(
      as.character(num_rows),
      width = 8,
      side = "left",
      pad = "0"
    ))
  updated_footer
}

trim_empty_cols <- function(df) {
  trimmed <- df %>% select(-where(~any(str_length(.) < 1)))
  trimmed
}

read_file_df <- function(file_name) {
  file_df <-
    fread(
      paste(source_dir, file_name, sep = "//"),
      sep = "|",
      quote = "",
      header = FALSE,
      fill = TRUE,
      stringsAsFactors = FALSE,
      colClasses = c("character")
    )
  
  file_df
}

write_file_df <- function(combined_files) {
  write_header(combined_files$header, combined_files$file_name)
  write_append_row(combined_files$detail_rows, combined_files$file_name)
  write_append_row(combined_files$footer, combined_files$file_name)
}

write_header <- function(header_row, file_name) {
  fwrite(
    header_row,
    paste(dest_dir, file_name, sep = "//"),
    sep = "|",
    col.names = FALSE
  )
}

write_append_row <- function(row, file_name) {
  fwrite(
    row,
    paste(dest_dir, file_name, sep = "//"),
    sep = "|",
    append = TRUE
  )
}

combined_files <- get_files() %>% map(combine_files)
combined_files %>% walk(write_file_df)
