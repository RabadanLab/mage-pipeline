suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(jsonlite))

args <- commandArgs(TRUE)
EXPRESSION_MATRIX_PATH <- args[1]
STAT_EXPRESSION_MATRIX <- args[2]

df_exprs <- read_tsv(EXPRESSION_MATRIX_PATH,  col_types=cols(
  .default = col_integer(),
  target_id = col_character()
))

# TODO Add filtering step based on STAT_EXPRESSION_MATRIX

df_exprs %>%
  gather(id, est_counts, 2:ncol(.)) %>% 
  arrange(target_id, id) %>%
  format_tsv() %>%
  cat()
