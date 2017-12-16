suppressPackageStartupMessages(library(tidyverse))

args <- commandArgs(TRUE)

EXPRESSION_MATRIX_TRANSCRIPT_PATH <- args[1] # "Z:/projSST/scripts/mage_run/config_files/expression_matrix_transcript.tsv"
TRANSCRIPT_TO_GENE_MAPPING_PATH <- args[2] # "Z:/projSST/scripts/mage_run/config_files/transcript_to_gene_mapping.tsv"
df_exprs_trans <- read_tsv(EXPRESSION_MATRIX_TRANSCRIPT_PATH, col_types=cols(
  .default = col_integer(),
  target_id = col_character()
))
t2g_mapping <- read_tsv(TRANSCRIPT_TO_GENE_MAPPING_PATH, col_types=cols(
  gene_id = col_character(),
  transcript_id = col_character(),
  gene_name = col_character(),
  transcript_name = col_character()
))

df_exprs_trans %>%
  gather(id, est_counts, 2:ncol(.)) %>%
  left_join(t2g_mapping, by=c("target_id"="transcript_id")) %>% 
  group_by(gene_id, id) %>%  # summarize by gene
  summarize(est_counts=sum(est_counts)) %>% 
  ungroup() %>% 
  spread(id, est_counts) %>%
  rename(target_id=gene_id) %>% 
  format_tsv() %>%
  cat()
