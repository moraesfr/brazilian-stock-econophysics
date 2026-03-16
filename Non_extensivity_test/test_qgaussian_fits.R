# Script to test q-Gaussian vs Normal Gaussian distribution of daily returns
# For IBOVESPA index and individual Brazilian stocks

test_qgaussian_fits <- function() {

# Load necessary libraries
if (!require(quantmod)) install.packages("quantmod")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(dplyr)) install.packages("dplyr")
if (!require(MASS)) install.packages("MASS")

library(quantmod)
library(ggplot2)
library(dplyr)
library(MASS)

# Define assets: IBOV and stocks
assets <- c("^BVSP", "PETR4.SA", "VALE3.SA", "ITUB4.SA", "BBDC4.SA", "ABEV3.SA", "WEGE3.SA", "MGLU3.SA")

# Fetch data
getSymbols(assets, src = "yahoo", from = "2006-01-01", to = "2019-12-31", auto.assign = TRUE)

# Function to compute daily returns
get_returns <- function(symbol) {
  if (!exists(symbol)) return(NULL)
  data <- try(get(symbol), silent = TRUE)
  if (inherits(data, "try-error")) return(NULL)
  close <- try(data[, paste0(symbol, ".Adjusted")], silent = TRUE)
  if (inherits(close, "try-error")) return(NULL)
  returns <- try(dailyReturn(close), silent = TRUE)
  if (inherits(close, "try-error")) return(NULL)
  returns <- na.omit(returns)
  return(as.numeric(returns))
}

# q-Gaussian density function (corrected normalization)
qgaussian_density <- function(x, q, beta) {
  if (q == 1) {
    return(dnorm(x, mean = 0, sd = sqrt(1/beta)))
  } else {
    C <- sqrt(beta / pi) * gamma(1 / (q - 1)) / gamma((3 - q) / (2 * (q - 1)))
    arg <- 1 + (1 - q) * beta * x^2
    if (any(arg <= 0)) return(rep(0, length(x)))
    density <- C * arg^(-(q)/(1 - q))
    return(density)
  }
}

# Function to fit q-Gaussian (fixed q=1.4, beta adjusted for support)
fit_qgaussian <- function(data) {
  q <- 1.4
  beta <- 1 / (var(data) * 100)  # Adjust to extend support
  return(list(q = q, beta = beta))
}

# Plot function
plot_fits <- function(returns, asset_name) {
  # Histogram
  hist_data <- data.frame(returns = returns)
  p <- ggplot(hist_data, aes(x = returns)) +
    geom_histogram(aes(y = ..density..), bins = 50, fill = "lightblue", alpha = 0.7) +
    labs(title = paste("Daily Returns Distribution:", asset_name),
         x = "Daily Return", y = "Density") +
    theme_minimal()

  # Fit normal
  norm_fit <- fitdistr(returns, "normal")
  norm_mean <- norm_fit$estimate["mean"]
  norm_sd <- norm_fit$estimate["sd"]
  x_vals <- seq(min(returns), max(returns), length.out = 100)
  norm_density <- dnorm(x_vals, mean = norm_mean, sd = norm_sd)

  # Fit q-Gaussian
  q_fit <- fit_qgaussian(returns)
  q_density <- qgaussian_density(x_vals, q_fit$q, q_fit$beta)

  # Add lines
  p <- p + geom_line(data = data.frame(x = x_vals, y = norm_density), aes(x = x, y = y), color = "red", size = 1) +
    geom_line(data = data.frame(x = x_vals, y = q_density), aes(x = x, y = y), color = "blue", size = 1) +
    annotate("text", x = max(returns)*0.8, y = max(density(returns)$y)*0.9, label = paste("Normal: μ=", round(norm_mean, 4), ", σ=", round(norm_sd, 4)), color = "red") +
    annotate("text", x = max(returns)*0.8, y = max(density(returns)$y)*0.8, label = paste("q-Gaussian: q=", round(q_fit$q, 2), ", β=", round(q_fit$beta, 2)), color = "blue")

  return(p)
}

# Process each asset
plots <- list()
for (asset in assets) {
  returns <- get_returns(asset)
  if (is.null(returns) || length(returns) <= 100) next
  print(paste("Plotting for", asset))
  plots[[asset]] <- plot_fits(returns, asset)
}

# Save plots or display
# For now, return plots list; in practice, you can save with ggsave
return(plots)

}

# Run the function
results <- test_qgaussian_fits()

# Save plots
for (asset in names(results)) {
  ggsave(paste0(asset, "_fits.png"), results[[asset]])
}