``` r
library("dplyr")
library("tidyr")
library("ggplot2")
library("multipleuncertainty")
knitr::opts_chunk$set(cache = TRUE)
```

Simulation of the growth function illustrates roughly comparable parameter values (e.g. same unfished equilibrium value)

``` r
sims <- function(model, r){
  f <- get(as.character(model))
  x <- numeric(10)
  x[1] <- 60
  for(t in 1:length(x))
    x[t+1] = f(x[t], 0, r = r)
  data.frame(x, t = 1:length(x))
}
```

``` r
options(stringsAsFactors = FALSE)

expand.grid(model = c("logistic", "bevertonholt", "ricker", "gompertz"), 
            r = c(0.1, 0.5, 0.75, 1)) %>%
  dplyr::group_by(model, r) %>%
  dplyr::do(sims(.$model, .$r)) -> 
  df

ggplot(df, aes(x = t, y = x, color = model)) + geom_line() + facet_grid(model ~ r)
```

![](robust_to_model_pars_files/figure-markdown_github/unnamed-chunk-3-1.png)

Optimal control under multiple uncertainty by model:

``` r
fig3 <- function(model){  
  grid <- seq(0, 200, length = 401)
  model <- get(model)
  small     <- multiple_uncertainty(f = model, x_grid = grid, sigma_g = 0.1, sigma_m = 0.1, sigma_i = 0.1)
  growth    <- multiple_uncertainty(f = model, x_grid = grid, sigma_g = 0.5, sigma_m = 0.1, sigma_i = 0.1)
  measure   <- multiple_uncertainty(f = model, x_grid = grid, sigma_g = 0.1, sigma_m = 0.5, sigma_i = 0.1)
  implement <- multiple_uncertainty(f = model, x_grid = grid, sigma_g = 0.1, sigma_m = 0.1, sigma_i = 0.5)
  df <- data.frame(y_grid = grid, small = small, growth = growth, 
                   measure = measure, implement = implement) %>%
    tidyr::gather(scenario, value, -y_grid)
}

df <- 
data.frame(model = c("logistic", "bevertonholt", "ricker", "gompertz"), stringsAsFactors = FALSE) %>%
  dplyr::group_by(model) %>%
  dplyr::do(fig3(.$model))
```

``` r
df %>%
  ggplot(aes(x = y_grid, y = value, col = scenario)) + 
    geom_point()  + 
    facet_wrap(~model, ncol = 2) + 
    xlab("Stock") + 
    ylab("Escapement") + 
    coord_cartesian(xlim = c(0, 150), ylim = c(0,100)) + 
    theme_bw()
```

![](robust_to_model_pars_files/figure-markdown_github/unnamed-chunk-5-1.png)