library(tidyverse)

rgampois_proposed <- function(n, mu, precision) {
  prob <- precision / (precision + mu)
  #  this definition is directly copied off of the documentation of rnbionom :
  # "...An alternative parametrization (often used in ecology) is
  # by the mean mu (see above), and size, the dispersion parameter,
  # where prob = size/(size+mu). The variance is mu + mu^2/size in this parametrization...."
  
  rnbinom(n = n, size = precision,  prob = prob)
}


#' Simulate the RNA_seq samples for a gene in two conditions
#'
#' @param n Number of replicates to make
#' @param exprs Mean Expressions
#' @param fc Fold change
#' @param dispers Dispersion
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



# Parameters ----
exprs <-
  seq(10, 1000, by = 5)
#c(low = 11, mid = 100, high = 1000) # expression level in counts
#dispers <- c(0.5, 1, 2) # dispersion
dispers <- seq(0.5, 2, by = 0.1) # dispersion
fc <- c(1, 2, 0.5)  # fold change
ratio_fc <- c(0.8, 0.2)



adjust_meta  <- function(meta, PERC = 0.1) {
  split_df <-  base::split(meta, meta$fc)
  name_split_df <- names(split_df)
  to_sample <- setdiff(name_split_df, "1")
  res <- list()
  for (sample_name in to_sample) {
    sampled_df <-
      dplyr::sample_n(split_df[[sample_name]], base::NROW(split_df[["1"]]) * PERC /
                        length(to_sample))
    res[[sample_name]] <-  sampled_df
  }
  
  dplyr::bind_rows(split_df[["1"]], res)
  
}

# Simulate the RNA-seq data
simulate_with_n <- function(N_REP, meta, PREFIX) {
  data_sim_tmp <- meta %>%
    mutate(sample = pmap(list(n = N_REP, exprs, fc, dispers), simulate))
  
  data_sim <- data_sim_tmp %>%
    mutate(sample = map(sample, as_tibble)) %>%
    unnest() %>%
    gather(sample, data, 5:6) %>%
    mutate(target_id = paste0("r", exprs, "_fc", fc, "_d", dispers)) %>%
    mutate(id = paste0(sample, "_", rep))
  
  DEPTH <- FALSE
  if (DEPTH) {
    sim_meta <- data_sim %>%
      distinct(id) %>%
      mutate(size_factor = rnorm(
        n = NROW(.),
        mean = 1,
        sd = 0.1
      )) %>%
      mutate(depth = 1e7 * size_factor)
    
    data_sim <- data_sim %>%
      mutate(data = data / 1e7) %>%
      left_join(sim_meta, by = "id") %>%
      mutate(data = as.integer(data * depth))
  }
  
  # Generate wide matrix
  data_sim_w <- data_sim %>%
    select(target_id, id, data) %>%
    spread(id, data)
  
  cname <- colnames(data_sim_w)[-1]
  
  # Save wide expression data ----
  write_tsv(data_sim_w,
            paste0(PREFIX, N_REP, ".tsv"))
  
  invisible(list(data_sim_w, meta, meta_sample))
}

simulate_all <- function(meta, SET, PERC, NREP) {
  #SET <- 1
  #PERC <- 0.1
  meta_adj <- adjust_meta(meta, PERC = PERC)
  set.seed(as.integer(20 * SET))
  data <-
    simulate_with_n(
      NREP,
      meta_adj,
      PREFIX = paste0(
        "tests/benchmark_data/S",
        SET,
        "_P",
        PERC,
        "_N"
      )
    )
  
}

# Construct multiple scenarios ----
meta <- as_tibble(expand.grid(
  exprs = exprs,
  fc = fc,
  dispers = dispers
))

SETS <- seq(1, 3)
PERCS <- c(0.01, 0.1, 0.5)
NREPS <- c(3, 10, 50)
expand.grid(sets = SETS,
            percs = PERCS,
            nreps = NREPS) %>%
  as_tibble %>%
  mutate(x = pmap(list(sets, percs, nreps), function(s, p, n) {
    simulate_all(meta,
                 SET = s,
                 PERC = p,
                 NREP = n)
  }))
