library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)


prepare_stan_data <- function(df_slice) {
  mydata <- df_slice
  
  N <- NROW(mydata)
  N_factor <- length(unique(mydata$type))
  idx_b <- mydata$typei
  y <- mydata$exprs
  depth <- mydata$depth
  
  stanD <- list(
    N = N,
    N_factor = N_factor,
    idx_b = idx_b,
    y = y,
    depth = depth
  )
  
  stanD
}

compute_fc <- function(fit, tsv=FALSE) {
  res <- fit %>%
    as.data.frame() %>%
    as_tibble %>%
    select(contains("beta")) %>%
    mutate(fc = exp(`beta[2]` - `beta[1]`)) %>%
    summarize(mean_fc = mean(fc), median_fc = median(fc))
  
  if(tsv) {
    res %>% 
      format_tsv() %>% 
      cat()
    return(invisible(1))
  }
  return(res)
}

args <- commandArgs(TRUE)
stanmodel <- args[1]
long_gene_exprs_df_path <- args[2]
outputfile <- args[3]

long_gene_exprs_df <- read_tsv(long_gene_exprs_df_path)
stanD <- prepare_stan_data(long_gene_exprs_df)
start <- Sys.time()
fit <- stan(file = stanmodel, data = stanD, control = list(adapt_delta = 0.99))
end <- Sys.time()
end - start
write_tsv(compute_fc(fit), path=outputfile)
