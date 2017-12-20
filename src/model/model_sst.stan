data {
  // N's
  int<lower=1> N;         // Number of observations
  int<lower=1> N_dpi;     // Number of day post infection type
  int<lower=1> N_tissue;  // Number of tissue types
  
  // Covariate and reponse
  int dpi_idx[N];
  int tissue_idx[N];
  int interaction_idx[N];
  
  int y[N];           // counts
  vector[N] depth;
}

parameters {
  real mu_intercept;

  real beta_tissue_raw[N_tissue];
  real beta_dpi_raw[N_dpi];
  real beta_interaction_raw[N_dpi*N_tissue];

  real<lower=0> phi;
  real mu_dpi; // hyperprior mean
  real<lower=0> sigma_dpi;   // hyperpror std dev
  
  //tissue 
  real mu_tissue;
  real<lower=0> sigma_tissue;
  
  //interaction
  real mu_interaction;
  real<lower=0> sigma_interaction;
}
transformed parameters {
  real beta_dpi[N_dpi];
  real beta_tissue[N_tissue];
  real beta_interaction[N_dpi*N_tissue];
    // Combine all
  for( n in 1:N ) {
      beta_dpi[dpi_idx[n]] = 5*mu_dpi + sigma_dpi*beta_dpi_raw[dpi_idx[n]];
      beta_tissue[tissue_idx[n]] = 5*mu_tissue + sigma_tissue*beta_tissue_raw[tissue_idx[n]] ;
      beta_interaction[interaction_idx[n]] = 5*mu_interaction + sigma_interaction*beta_interaction_raw[interaction_idx[n]];

  }
  
}
model {
  vector[N] yhat; 
  mu_intercept ~ normal(0, 10); 
  //hyper prior for dpi
  mu_dpi ~ normal(0, 1);
  sigma_dpi ~ cauchy(0, 2);   
  
  //hyerprior for tissue
  mu_tissue ~ normal(0, 1);
  sigma_tissue ~ cauchy(0, 2);
  
  //hyerprior for tissue x dpi interaction
  mu_interaction ~ normal(0, 1);
  sigma_interaction ~ cauchy(0, 2);
  
  //prior for inverse dispersion
  phi ~ cauchy(0, 2);

  beta_tissue_raw ~ normal(0, 1);
  beta_dpi_raw ~ normal(0, 1);
  beta_interaction_raw ~ normal(0, 1);

  for( n in 1:N ) {
    yhat[n] =  mu_intercept + 
                     beta_dpi[dpi_idx[n]] +
                     beta_tissue[tissue_idx[n]] +
                     beta_interaction[interaction_idx[n]] +
                     log(depth[n]);
  }
  // log linear negative binomial regression
  y ~ neg_binomial_2_log(yhat, phi);
}
generated quantities {
  vector[N] yhat; 
  vector[N] log_lik;

  for (n in 1:N) {
    yhat[n] =  mu_intercept + 
                     beta_dpi[dpi_idx[n]] +
                     beta_tissue[tissue_idx[n]] +
                     beta_interaction[interaction_idx[n]] +
                     log(depth[n]);
    // preferred Stan syntax as of version 2.10.0
    log_lik[n] = neg_binomial_2_log_lpmf(y[n] |  yhat[n] , phi);
  }

}
