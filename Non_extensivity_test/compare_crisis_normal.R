# Script to compare daily returns and correlations during normal times vs. crisis events
# Uses sliding windows around crisis events

compare_crisis_normal <- function(window_size = 30) {  # Window size in days

# Load necessary libraries
if (!require(quantmod)) install.packages("quantmod")
if (!require(zoo)) install.packages("zoo")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(dplyr)) install.packages("dplyr")
if (!require(gridExtra)) install.packages("gridExtra")

library(quantmod)
library(zoo)
library(ggplot2)
library(dplyr)
library(gridExtra)

# Define stocks
stocks <- c("PETR4.SA", "VALE3.SA", "ITUB4.SA", "BBDC4.SA", "ABEV3.SA", "WEGE3.SA", "MGLU3.SA")

# Fetch data
getSymbols(stocks, src = "yahoo", from = "2006-01-01", to = "2019-12-31", auto.assign = TRUE)
getSymbols("^BVSP", src = "yahoo", from = "2006-01-01", to = "2019-12-31")

# Get returns
returns_list <- lapply(stocks, function(x) dailyReturn(get(x)))
returns_df <- do.call(cbind, returns_list)
names(returns_df) <- stocks
returns_df <- na.omit(returns_df)

ibov_returns <- dailyReturn(BVSP$BVSP.Adjusted)
ibov_returns <- na.omit(ibov_returns)

# Align dates
common_dates <- index(returns_df) %in% index(ibov_returns)
returns_df <- returns_df[common_dates, ]
ibov_returns <- ibov_returns[index(returns_df)]

# Compute volatility
volatility <- rollapply(ibov_returns, width = 30, FUN = sd, fill = NA, align = "right")
vol_mean <- mean(volatility, na.rm = TRUE)
vol_sd <- sd(volatility, na.rm = TRUE)
crisis_vol_threshold <- vol_mean + 3 * vol_sd

# Define crisis events
crisis_events <- ifelse(ibov_returns < -0.05 | volatility > crisis_vol_threshold, TRUE, FALSE)

# Function to get windows around crisis
get_crisis_windows <- function(crisis_idx, window_size) {
  crisis_dates <- index(ibov_returns)[crisis_idx]
  windows <- lapply(crisis_dates, function(d) {
    start <- d - window_size
    end <- d + window_size
    idx <- index(ibov_returns) >= start & index(ibov_returns) <= end
    return(idx)
  })
  return(windows)
}

crisis_indices <- which(crisis_events)
crisis_windows <- get_crisis_windows(crisis_indices, window_size)

# Combine crisis windows (union)
crisis_mask <- Reduce(`|`, crisis_windows)
normal_mask <- !crisis_mask & !is.na(volatility)  # Exclude NAs

# Extract returns
crisis_returns <- as.numeric(ibov_returns[crisis_mask])
normal_returns <- as.numeric(ibov_returns[normal_mask])

# Plot histograms
p1 <- ggplot(data.frame(returns = crisis_returns), aes(x = returns)) +
  geom_histogram(aes(y = ..density..), bins = 50, fill = "red", alpha = 0.7) +
  labs(title = "IBOV Daily Returns During Crisis Windows", x = "Daily Return", y = "Density") +
  theme_minimal()

p2 <- ggplot(data.frame(returns = normal_returns), aes(x = returns)) +
  geom_histogram(aes(y = ..density..), bins = 50, fill = "blue", alpha = 0.7) +
  labs(title = "IBOV Daily Returns During Normal Times", x = "Daily Return", y = "Density") +
  theme_minimal()

# Compute correlations
cor_crisis <- cor(returns_df[crisis_mask, ], use = "complete.obs")
cor_normal <- cor(returns_df[normal_mask, ], use = "complete.obs")

# Average correlation
avg_cor_crisis <- mean(cor_crisis[lower.tri(cor_crisis)])
avg_cor_normal <- mean(cor_normal[lower.tri(cor_normal)])

# Tsallis entropy on correlations
tsallis_entropy <- function(p, q) {
  if (q == 1) {
    return(-sum(p * log(p), na.rm = TRUE))
  } else {
    return((1 - sum(p^q, na.rm = TRUE)) / (q - 1))
  }
}

# For correlations
cor_flat_crisis <- cor_crisis[lower.tri(cor_crisis)]
abs_cor_crisis <- abs(cor_flat_crisis)
p_crisis <- abs_cor_crisis / sum(abs_cor_crisis)

cor_flat_normal <- cor_normal[lower.tri(cor_normal)]
abs_cor_normal <- abs(cor_flat_normal)
p_normal <- abs_cor_normal / sum(abs_cor_normal)

q_values <- seq(0.5, 3, by = 0.1)
entropies_crisis <- sapply(q_values, function(q) tsallis_entropy(p_crisis, q))
entropies_normal <- sapply(q_values, function(q) tsallis_entropy(p_normal, q))

entropy_df <- data.frame(
  q = rep(q_values, 2),
  entropy = c(entropies_crisis, entropies_normal),
  period = rep(c("Crisis", "Normal"), each = length(q_values))
)

p3 <- ggplot(entropy_df, aes(x = q, y = entropy, color = period)) +
  geom_line() +
  labs(title = "Tsallis Entropy of Stock Correlations: Crisis vs. Normal",
       x = "q parameter", y = "Tsallis Entropy") +
  theme_minimal()

# Summary stats
stats_crisis <- c(mean = mean(crisis_returns), sd = sd(crisis_returns), kurtosis = mean((crisis_returns - mean(crisis_returns))^4) / sd(crisis_returns)^4)
stats_normal <- c(mean = mean(normal_returns), sd = sd(normal_returns), kurtosis = mean((normal_returns - mean(normal_returns))^4) / sd(normal_returns)^4)

# Return results
return(list(
  crisis_returns = crisis_returns,
  normal_returns = normal_returns,
  cor_crisis = cor_crisis,
  cor_normal = cor_normal,
  avg_cor_crisis = avg_cor_crisis,
  avg_cor_normal = avg_cor_normal,
  entropy_plot = p3,
  returns_plots = list(p1, p2),
  stats_crisis = stats_crisis,
  stats_normal = stats_normal
))

}

# Run
results <- compare_crisis_normal()

# Save plots
ggsave("crisis_returns.png", results$returns_plots[[1]])
ggsave("normal_returns.png", results$returns_plots[[2]])
ggsave("entropy_crisis_normal.png", results$entropy_plot)

# Print summaries
cat("Average Correlation - Crisis:", results$avg_cor_crisis, "\n")
cat("Average Correlation - Normal:", results$avg_cor_normal, "\n")
cat("Crisis Stats - Mean:", results$stats_crisis["mean"], "SD:", results$stats_crisis["sd"], "Kurtosis:", results$stats_crisis["kurtosis"], "\n")
cat("Normal Stats - Mean:", results$stats_normal["mean"], "SD:", results$stats_normal["sd"], "Kurtosis:", results$stats_normal["kurtosis"], "\n")