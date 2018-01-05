#' Factor to integer
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
ftoi <- function(x) {
  as.integer(as.factor(x))
}

suppressPackageStartupMessages(library(tidyverse))
args <- commandArgs(TRUE)
df <- read_tsv(args[1])

list_of_genes_tmp <- df %>%
  gather(id, exprs, 2:ncol(.)) %>%
  arrange(target_id) %>%
  separate(id, c("type", "rep"), sep = "_") %>%
  mutate(typei = ftoi(type))

meta <- list_of_genes_tmp %>%
  group_by(type, rep) %>%
  summarize(depth = sum(exprs)) %>%
  ungroup()

list_of_genes <- list_of_genes_tmp %>%
  left_join(meta, by = c("type", "rep")) %>% 
  format_tsv() %>% 
  cat()