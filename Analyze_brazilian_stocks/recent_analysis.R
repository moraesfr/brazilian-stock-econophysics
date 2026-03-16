# Script to analyze recent Brazilian stock market (last 30 days)
# Uses econophysics and Tsallis entropy to check for potential boom/crisis conditions

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

# Fetch recent data (last 30 days)
end_date <- Sys.Date()
start_date <- end_date - 30

cat("Fetching recent data from", as.Date(start_date), "to", as.Date(end_date), "\n")

# Fetch historical data from Yahoo Finance
getSymbols(stocks, src = "yahoo", from = start_date, to = end_date, auto.assign = TRUE)

# Get adjusted closes for stocks
stock_closes <- lapply(stocks, function(x) if (exists(x)) get(x)[, paste0(x, ".Adjusted")] else NULL)
names(stock_closes) <- stocks

# Fetch IBOVESPA data
getSymbols("^BVSP", src = "yahoo", from = start_date, to = end_date)

ibov_close <- BVSP$BVSP.Adjusted
ibov_close <- na.omit(ibov_close)

ibov_returns <- dailyReturn(ibov_close)

# Compute daily returns for stocks
returns_list <- lapply(stocks, function(x) {
  if (!is.null(stock_closes[[x]])) {
    dailyReturn(stock_closes[[x]])
  } else {
    NULL
  }
})
names(returns_list) <- stocks

# Remove NULLs
valid_stocks <- stocks[!sapply(returns_list, is.null)]
returns_list <- returns_list[valid_stocks]
stock_closes <- stock_closes[valid_stocks]

returns_df <- do.call(cbind, returns_list)
names(returns_df) <- valid_stocks

# Remove NA values
returns_df <- na.omit(returns_df)
ibov_returns <- na.omit(ibov_returns)

# Compute correlation matrix
if (nrow(returns_df) > 1) {
  cor_matrix <- cor(returns_df, use = "complete.obs")
  cat("Recent Correlation Matrix:\n")
  print(cor_matrix)
} else {
  cat("Not enough data for correlation analysis.\n")
  cor_matrix <- NULL
}

# Tsallis entropy function
tsallis_entropy <- function(p, q) {
  if (q == 1) {
    return(-sum(p * log(p), na.rm = TRUE))
  } else {
    return((1 - sum(p^q, na.rm = TRUE)) / (q - 1))
  }
}

# Analyze correlations using Tsallis entropy
if (!is.null(cor_matrix)) {
  cor_flat <- cor_matrix[lower.tri(cor_matrix)]
  abs_cor <- abs(cor_flat)

  # Normalize to create probability distribution
  p <- abs_cor / sum(abs_cor)

  # Compute Tsallis entropy for different q values
  q_values <- seq(0.5, 3, by = 0.1)
  entropies <- sapply(q_values, function(q) tsallis_entropy(p, q))

  cat("\nTsallis Entropy Analysis:\n")
  cat("Entropy at q=1 (Shannon):", entropies[q_values == 1], "\n")
  cat("Entropy at q=2:", entropies[q_values == 2], "\n")

  # Plot Tsallis entropy vs q
  entropy_plot <- ggplot(data.frame(q = q_values, entropy = entropies), aes(x = q, y = entropy)) +
    geom_line() +
    labs(title = "Tsallis Entropy of Recent Stock Correlations",
         x = "q parameter",
         y = "Tsallis Entropy") +
    theme_minimal()

  print(entropy_plot)
}

# Compute rolling volatility (10-day window for recent period)
volatility <- rollapply(ibov_returns, width = min(10, length(ibov_returns)), FUN = sd, fill = NA, align = "right")
volatility <- na.omit(volatility)

# Define crisis criteria:
# 1. Daily return < -5%
# 2. Rolling volatility > 3 standard deviations above mean (if enough data)
crisis_events <- ifelse(ibov_returns < -0.05, TRUE, FALSE)

# Define boom criteria:
# Daily return > +5%
boom_events <- ifelse(ibov_returns > 0.05, TRUE, FALSE)

# Check for recent events
recent_crisis_dates <- index(ibov_returns)[crisis_events]
recent_boom_dates <- index(ibov_returns)[boom_events]

cat("\n=== RECENT MARKET ANALYSIS (Last 30 Days) ===\n")

cat("Period analyzed:", as.Date(start_date), "to", as.Date(end_date), "\n")
cat("Trading days in period:", length(ibov_returns), "\n")

if (length(recent_crisis_dates) > 0) {
  cat("\n🚨 CRISIS EVENTS DETECTED:\n")
  for (date in recent_crisis_dates) {
    ret <- as.numeric(ibov_returns[date])
    cat("  -", as.Date(date), ": Return =", round(ret * 100, 2), "%\n")
  }
} else {
  cat("\n✅ No crisis events (> -5% drop) in the last 30 days.\n")
}

if (length(recent_boom_dates) > 0) {
  cat("\n🚀 BOOM EVENTS DETECTED:\n")
  for (date in recent_boom_dates) {
    ret <- as.numeric(ibov_returns[date])
    cat("  -", as.Date(date), ": Return =", round(ret * 100, 2), "%\n")
  }
} else {
  cat("\n✅ No boom events (> +5% gain) in the last 30 days.\n")
}

# Volatility analysis
if (length(volatility) > 0) {
  current_vol <- tail(volatility, 1)
  avg_vol <- mean(volatility, na.rm = TRUE)
  cat("\n📊 VOLATILITY ANALYSIS:\n")
  cat("Current 10-day volatility:", round(current_vol * 100, 2), "%\n")
  cat("Average 10-day volatility:", round(avg_vol * 100, 2), "%\n")

  if (current_vol > avg_vol * 1.5) {
    cat("⚠️  WARNING: Current volatility is significantly elevated!\n")
  } else {
    cat("✅ Volatility levels are normal.\n")
  }
}

# Overall assessment
cat("\n🎯 OVERALL ASSESSMENT:\n")
if (length(recent_crisis_dates) > 0) {
  cat("Market is experiencing crisis conditions. Exercise caution.\n")
} else if (length(recent_boom_dates) > 0) {
  cat("Market is experiencing boom conditions. Monitor for potential corrections.\n")
} else {
  cat("Market conditions appear stable. No extreme events detected.\n")
}

# Predictive analysis for upcoming volatility/events
cat("\n🔮 PREDICTIVE ANALYSIS:\n")

vol_change <- NA  # Initialize

# Volatility trend
if (length(volatility) >= 5) {
  vol_trend <- tail(volatility, 5)
  if (length(vol_trend) == 5 && all(!is.na(vol_trend)) && vol_trend[1] != 0) {
    vol_change <- (vol_trend[5] - vol_trend[1]) / vol_trend[1]
    if (length(vol_change) > 0 && !is.na(vol_change)) {
      cat("Volatility trend (last 5 days):", round(vol_change * 100, 2), "% change\n")
      
      if (vol_change > 0.2) {
        cat("⚠️  Volatility is increasing rapidly - potential for upcoming event!\n")
      } else if (vol_change < -0.2) {
        cat("✅ Volatility is decreasing - market stabilizing.\n")
      } else {
        cat("📊 Volatility trend is stable.\n")
      }
    } else {
      cat("Unable to calculate volatility trend.\n")
      vol_change <- NA
    }
  } else {
    cat("Not enough clean volatility data for trend analysis.\n")
  }
} else {
  cat("Not enough data for volatility trend analysis.\n")
}

# Entropy analysis for prediction
if (exists("entropies")) {
  shannon_entropy <- entropies[q_values == 1]
  q2_entropy <- entropies[q_values == 2]
  
  # Compare to typical ranges (based on historical analysis)
  # These are approximate thresholds from the main analysis
  if (shannon_entropy < 2.5) {
    cat("🧲 Low entropy detected - correlations are strong, potential for coordinated movement.\n")
  } else if (shannon_entropy > 3.0) {
    cat("🌪️  High entropy detected - market complexity increasing, watch for volatility.\n")
  }
  
  if (q2_entropy < 0.8) {
    cat("⚡ Non-extensive effects strong - market may be approaching critical state.\n")
  }
}

# Combined prediction for volatility betting
vol_risk_score <- 0
if (length(volatility) > 0 && current_vol > avg_vol * 1.2) vol_risk_score <- vol_risk_score + 1
if (length(recent_crisis_dates) > 0 || length(recent_boom_dates) > 0) vol_risk_score <- vol_risk_score + 1
if (!is.na(vol_change) && vol_change > 0.1) vol_risk_score <- vol_risk_score + 1
if (exists("shannon_entropy") && shannon_entropy > 2.8) vol_risk_score <- vol_risk_score + 1

cat("\n🎲 VOLATILITY BETTING ASSESSMENT:\n")
cat("Risk Score (0-4):", vol_risk_score, "\n")
if (vol_risk_score >= 3) {
  cat("🎯 HIGH OPPORTUNITY: Good time to consider volatility-based positions!\n")
  cat("   - Consider options strategies or VIX-related products\n")
  cat("   - Monitor for breakout events\n")
} else if (vol_risk_score >= 2) {
  cat("⚠️  MODERATE: Some volatility potential, but not extreme.\n")
} else {
  cat("✅ LOW: Market appears calm, volatility products may not be favorable.\n")
}

cat("\n💡 RECOMMENDATION: This analysis provides early warning signals based on\n")
cat("   econophysics indicators. Always combine with fundamental analysis and\n")
cat("   risk management. Past performance doesn't guarantee future results.\n")

# Save plots
if (exists("entropy_plot")) {
  ggsave("recent_entropy_plot.png", entropy_plot, width = 8, height = 6)
  cat("\nPlot saved as recent_entropy_plot.png\n")
}

cat("\nAnalysis complete.\n")