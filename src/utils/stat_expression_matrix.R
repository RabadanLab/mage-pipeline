# This script computes the statistics/filtering information based on a given expresison matrix
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(jsonlite))


args <- commandArgs(TRUE)
EXPRESSION_MATRIX  <- args[1]
SUM_EST_COUNT_CUTOFF <- as.numeric(args[2])  # 1e6

df_exprs <- suppressMessages( read_tsv(EXPRESSION_MATRIX) )


df_lib_summary <- df_exprs %>%
                    select_if(is.numeric) %>%
                    gather(id, est_counts) %>%
                    group_by(id) %>%
                    summarize(sum_est_counts=sum(est_counts))

# Samples to drop
samples_to_drop_df <- df_lib_summary %>%
  filter(sum_est_counts < SUM_EST_COUNT_CUTOFF)


# Genes to drop


# Return 
list(
  number_of_samples_before_dropping=NROW(df_lib_summary),
  number_of_samples_after_dropping = df_lib_summary %>% filter( ! id %in% samples_to_drop_df[["id"]]) %>% NROW(),
  samples_to_drop=samples_to_drop_df[["id"]],
  number_of_features_before_dropping=df_exprs %>% distinct(target_id) %>% NROW(),
  number_of_features_after_dropping=df_exprs %>% distinct(target_id) %>% NROW(), # XXX for now
  genes_to_drop=0, # XXX for now
  lib_summary_df=df_lib_summary
) %>% jsonlite::toJSON(pretty=TRUE, auto_unbox=TRUE)
