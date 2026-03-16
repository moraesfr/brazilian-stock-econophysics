# Script to analyze Brazilian stock market using econophysics and Tsallis entropy
# This script studies correlations between companies and identifies crisis events

analyze_brazilian_stocks <- function() {

# Load necessary libraries
if (!require(quantmod)) install.packages("quantmod")
if (!require(zoo)) install.packages("zoo")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(dplyr)) install.packages("dplyr")

library(quantmod)
library(zoo)
library(ggplot2)
library(dplyr)

# Define major Brazilian stocks (B3 tickers)
stocks <- c("PETR4.SA", "VALE3.SA", "ITUB4.SA", "BBDC4.SA", "ABEV3.SA", "WEGE3.SA", "MGLU3.SA")

# Fetch historical data from Yahoo Finance
getSymbols(stocks, src = "yahoo", from = "2006-01-01", to = "2019-12-31", auto.assign = TRUE)

# Get adjusted closes for stocks
stock_closes <- lapply(stocks, function(x) if (exists(x)) get(x)[, paste0(x, ".Adjusted")] else NULL)
names(stock_closes) <- stocks

# Compute daily returns
returns_list <- lapply(stocks, function(x) dailyReturn(get(x)))
returns_df <- do.call(cbind, returns_list)
names(returns_df) <- stocks

# Remove NA values
returns_df <- na.omit(returns_df)

# Compute correlation matrix
cor_matrix <- cor(returns_df, use = "complete.obs")

# Tsallis entropy function
tsallis_entropy <- function(p, q) {
  if (q == 1) {
    return(-sum(p * log(p), na.rm = TRUE))
  } else {
    return((1 - sum(p^q, na.rm = TRUE)) / (q - 1))
  }
}

# Analyze correlations using Tsallis entropy
# Flatten lower triangle of correlation matrix
cor_flat <- cor_matrix[lower.tri(cor_matrix)]
abs_cor <- abs(cor_flat)

# Normalize to create probability distribution
p <- abs_cor / sum(abs_cor)

# Compute Tsallis entropy for different q values
q_values <- seq(0.5, 3, by = 0.1)
entropies <- sapply(q_values, function(q) tsallis_entropy(p, q))

# Plot Tsallis entropy vs q
entropy_plot <- ggplot(data.frame(q = q_values, entropy = entropies), aes(x = q, y = entropy)) +
  geom_line() +
  labs(title = "Tsallis Entropy of Stock Correlations",
       x = "q parameter",
       y = "Tsallis Entropy") +
  theme_minimal()

# Crisis detection using IBOVESPA index
getSymbols("^BVSP", src = "yahoo", from = "2006-01-01", to = "2019-12-31")

ibov_close <- BVSP$BVSP.Adjusted
ibov_close <- na.omit(ibov_close)

ibov_returns <- dailyReturn(ibov_close)

# Compute rolling volatility (30-day window)
volatility <- rollapply(ibov_returns, width = 30, FUN = sd, fill = NA, align = "right")

# Define crisis criteria:
# 1. Daily return < -5%
# 2. Rolling volatility > 3 standard deviations above mean
vol_mean <- mean(volatility, na.rm = TRUE)
vol_sd <- sd(volatility, na.rm = TRUE)
crisis_vol_threshold <- vol_mean + 3 * vol_sd

crisis_events <- ifelse(ibov_returns < -0.05 | volatility > crisis_vol_threshold, TRUE, FALSE)

# Define boom criteria:
# Daily return > +5%
boom_events <- ifelse(ibov_returns > 0.05, TRUE, FALSE)

# Create data frame for plotting
crisis_df <- data.frame(
  Date = index(ibov_returns),
  Returns = as.numeric(ibov_returns),
  Volatility = as.numeric(volatility),
  Crisis = crisis_events
)

# Plot IBOVESPA returns with crisis events highlighted
crisis_plot <- ggplot(crisis_df, aes(x = Date, y = Returns)) +
  geom_line() +
  geom_point(data = crisis_df[crisis_df$Crisis, ], aes(x = Date, y = Returns), color = "red", size = 2) +
  labs(title = "IBOVESPA Daily Returns with Crisis Events",
       x = "Date",
       y = "Daily Return") +
  theme_minimal()

# Return results
return(list(
  cor_matrix = cor_matrix,
  entropy_plot = entropy_plot,
  crisis_events = crisis_events,
  boom_events = boom_events,
  crisis_df = crisis_df,
  crisis_plot = crisis_plot,
  ibov_returns = ibov_returns,
  ibov_close = ibov_close,
  stock_closes = stock_closes,
  stocks = stocks
))

}