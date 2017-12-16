suppressPackageStartupMessages(library(tidyverse))



args <- commandArgs(TRUE)

KALLISTO_PATH <- args[1]

paths <- dir(KALLISTO_PATH, pattern="abundance.tsv", recursive=TRUE, full.names=TRUE)
sample_ids <- basename(dirname(paths))

paths %>%
  map( ~read_tsv(., col_types=cols(target_id = col_character(), 
                                   length = col_integer(), 
                                   eff_length = col_double(), 
                                   est_counts = col_double(), 
                                   tpm = col_double())) %>%
        select(target_id, est_counts) %>%
        mutate(est_counts=as.integer(round(est_counts))) %>%
        mutate(target_id=gsub("\\.\\d+$", "", target_id))
                                   ) %>%
  map2(sample_ids, function(df, id_name) { colnames(df)[2] <- id_name; df } ) %>%
  reduce(~left_join(.x, .y, by="target_id")) %>% 
  format_tsv() %>%
  cat()


