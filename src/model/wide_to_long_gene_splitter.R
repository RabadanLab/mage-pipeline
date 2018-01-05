

args <- commandArgs(TRUE)
DF_LONG <- args[1]
INDEX <- as.integer(args[2])

if(is.na(INDEX)) {
  stop("INDEX should be given!")
}

suppressWarnings(suppressPackageStartupMessages(library(tidyverse)))

list_of_genes <- read_tsv(DF_LONG) %>% 
  split(.$target_id)

list_of_genes[[INDEX]] %>% 
  format_tsv() %>% 
  cat()
