data {
  // N's
  int<lower=1> N;         // Number of observations
  int<lower=1> N_factor;     // Number of day post infection type
  
  // Covariate and reponse
  int idx_b[N];
  
  int y[N];           // counts
  vector[N] depth;
}

parameters {
  real alpha; // intercept
  real beta_raw[N_factor]; // random effect
  real<lower=0> phi; // dispersion

  real mu_beta; // hyperprior mean
  real<lower=0> sigma_beta;   // hyperpror std
  
}
transformed parameters {
  real beta[N_factor];

  for( n in 1:N ) {
      beta[idx_b[n]] = 5*mu_beta + sigma_beta*beta_raw[idx_b[n]];
  }
  
}
model {
  vector[N] yhat; 
  
  // Hyperparms
  mu_beta ~ normal(0, 1);
  sigma_beta ~ cauchy(0, 2);   

  alpha ~ normal(0, 10); 
  beta_raw ~ normal(0, 1);

  //prior for inverse dispersion
  phi ~ cauchy(0, 2);


  for( n in 1:N ) {
    yhat[n] =  alpha + 
                     beta[idx_b[n]] +
                     log(depth[n]);
  }
  // log linear negative binomial regression
  y ~ neg_binomial_2_log(yhat, phi);
}
generated quantities {
  vector[N] yhat; 
  vector[N] log_lik;

  for (n in 1:N) {
    yhat[n] =  alpha + 
                     beta[idx_b[n]] +
                     log(depth[n]);
    // preferred Stan syntax as of version 2.10.0
    log_lik[n] = neg_binomial_2_log_lpmf(y[n] |  yhat[n] , phi);
  }

}
