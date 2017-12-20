library(tidyverse)

rgampois_proposed <- function(n, mu, precision) {
  prob <- precision / (precision + mu)
  #  this definition is directly copied off of the documentation of rnbionom :
  # "...An alternative parametrization (often used in ecology) is
  # by the mean mu (see above), and size, the dispersion parameter,
  # where prob = size/(size+mu). The variance is mu + mu^2/size in this parametrization...."
  
  rnbinom(n = n, size = precision,  prob = prob)
}


#' Simulate the RNA_seq samples
#'
#' @param n Number of replicates to make
#' @param exprs
#' @param fc
#' @param dispers
#'
#' @return
#' @export
#'
#' @examples
simulate <- function(n, exprs, fc, dispers) {
  s1 <-
    rgampois_proposed(n = n,
                      mu = exprs,
                      precision = 1 / dispers)
  
  # multiply fold change for the second group
  s2 <-
    rgampois_proposed(n = n,
                      mu = exprs * fc,
                      precision = 1 / dispers)
  
  list(rep = seq(1, n),
       s1 = s1,
       s2 = s2)
}



# Parameters
exprs <-
  c(low = 10, mid = 100, high = 1000) # expression level in counts
dispers <- c(0.5, 1, 2) # dispersion
fc <- c(1, 2, 5)  # fold change

# Construct multiple scenarios
meta <- as_tibble(expand.grid(exprs = exprs,
                    fc = fc,
                    dispers = dispers))


# Simulate the RNA-seq data
set.seed(628)
data_sim <- meta %>%
  mutate(sample = pmap(list(n = 3, exprs, fc, dispers), simulate)) %>%
  mutate(sample = map(sample, as_tibble)) %>%
  unnest() %>%
  gather(sample, data, 5:6)

# Generate wide matrix
data_sim_w <- data_sim %>%
  mutate(gene_label = paste0("r", exprs, "_fc", fc, "_d", dispers)) %>%
  mutate(id = paste0(sample, "_", rep)) %>%
  select(gene_label, id, data) %>%
  spread(id, data)

# Save wide expression data
write_tsv(data_sim_w, "tests/toydata_exprs_w.tsv") 
