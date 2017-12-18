list.of.packages <- c("tidyverse", "rstan", "rstanarm")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
