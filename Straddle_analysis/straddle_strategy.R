# Straddle Strategy Analyzer for Brazilian Stocks
# Uses econophysics alerts to identify optimal entry points for straddle options strategies

# Load necessary libraries
if (!require(quantmod)) install.packages("quantmod")
if (!require(zoo)) install.packages("zoo")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(dplyr)) install.packages("dplyr")

library(quantmod)
library(zoo)
library(ggplot2)
library(dplyr)

# Source the recent analysis script to get alerts
# Note: This assumes recent_analysis.R is in the same directory
# We'll extract the key analysis functions

# Function to get current market risk assessment
get_market_risk <- function() {
  # This replicates the risk calculation from recent_analysis.R

  # Define major Brazilian stocks
  stocks <- c("PETR4.SA", "VALE3.SA", "ITUB4.SA", "BBDC4.SA", "ABEV3.SA", "WEGE3.SA", "MGLU3.SA")

  # Fetch recent data (last 30 days)
  end_date <- Sys.Date()
  start_date <- end_date - 30

  # Get IBOVESPA data
  getSymbols("^BVSP", src = "yahoo", from = start_date, to = end_date, auto.assign = TRUE)

  ibov_returns <- dailyReturn(BVSP$BVSP.Adjusted)
  ibov_returns <- na.omit(ibov_returns)

  # Compute rolling volatility (10-day window)
  volatility <- rollapply(ibov_returns, width = min(10, length(ibov_returns)), FUN = sd, fill = NA, align = "right")
  volatility <- na.omit(volatility)

  # Get current values
  current_vol <- tail(volatility, 1)
  avg_vol <- mean(volatility, na.rm = TRUE)

  # Calculate risk score
  vol_risk_score <- 0
  if (length(volatility) > 0 && current_vol > avg_vol * 1.2) vol_risk_score <- vol_risk_score + 1

  # Check for recent extreme events (simplified)
  recent_extreme <- any(abs(ibov_returns) > 0.03)  # 3% daily move as extreme
  if (recent_extreme) vol_risk_score <- vol_risk_score + 1

  # Simplified entropy check (would need full correlation analysis)
  vol_risk_score <- vol_risk_score + 1  # Assume some baseline

  return(list(
    risk_score = vol_risk_score,
    current_vol = current_vol,
    avg_vol = avg_vol,
    ibov_price = as.numeric(tail(BVSP$BVSP.Adjusted, 1))
  ))
}

# Straddle strategy parameters and analysis
analyze_straddle_opportunity <- function() {
  cat("🔄 ANALYZING STRADDLE OPPORTUNITY BASED ON ECONOPHYSICS ALERTS\n")
  cat("================================================================\n\n")

  # Get market risk assessment
  risk_data <- get_market_risk()

  risk_score <- risk_data$risk_score
  current_vol <- risk_data$current_vol
  avg_vol <- risk_data$avg_vol
  ibov_price <- risk_data$ibov_price

  cat("📊 CURRENT MARKET CONDITIONS:\n")
  cat("IBOVESPA Level:", round(ibov_price, 2), "\n")
  cat("Current Volatility (10-day):", round(current_vol * 100, 2), "%\n")
  cat("Average Volatility (10-day):", round(avg_vol * 100, 2), "%\n")
  cat("Risk Score:", risk_score, "/4\n\n")

  # Straddle strategy recommendation
  cat("🎯 STRADDLE STRATEGY ANALYSIS:\n")

  if (risk_score >= 3) {
    cat("🟢 HIGH OPPORTUNITY: STRONGLY RECOMMEND ENTERING STRADDLE POSITION\n")
    cat("   - Expected high volatility justifies the premium cost\n")
    cat("   - Both call and put options likely to profit from large moves\n\n")

    # Suggest strike prices (at-the-money)
    strike_price <- round(ibov_price, 0)
    cat("💰 SUGGESTED STRADDLE SETUP:\n")
    cat("   - Underlying: IBOVESPA (Brazilian stock index)\n")
    cat("   - Strike Price:", strike_price, "(At-the-money)\n")
    cat("   - Buy 1 Call option + Buy 1 Put option\n")
    cat("   - Expiration: Next monthly cycle (typically 1-2 months)\n\n")

    # Cost estimate (rough approximation)
    # Real options pricing would need Black-Scholes or market data
    estimated_vol <- max(current_vol, avg_vol) * 100  # Convert to percentage
    days_to_expiry <- 30  # Assume 30 days
    risk_free_rate <- 0.12  # Brazilian interest rate approx

    # Simplified premium estimate (this is very rough)
    # In reality, you'd get actual quotes from your broker
    call_premium <- strike_price * (estimated_vol/100) * sqrt(days_to_expiry/365) * 0.2
    put_premium <- call_premium  # Symmetric for ATM
    total_premium <- call_premium + put_premium

    cat("💸 ESTIMATED PREMIUM COST (ROUGH APPROXIMATION):\n")
    cat("   - Call Premium:", round(call_premium, 2), "points\n")
    cat("   - Put Premium:", round(put_premium, 2), "points\n")
    cat("   - Total Cost:", round(total_premium, 2), "points\n")
    cat("   - As % of Index:", round(total_premium/strike_price * 100, 2), "%\n\n")

    # Breakeven points
    upper_breakeven <- strike_price + total_premium
    lower_breakeven <- strike_price - total_premium

    cat("🎯 BREAKEVEN POINTS:\n")
    cat("   - Profit if IBOVESPA moves above:", round(upper_breakeven, 0), "\n")
    cat("   - Profit if IBOVESPA moves below:", round(lower_breakeven, 0), "\n")
    cat("   - Maximum Risk: Premium paid (", round(total_premium, 2), "points)\n")
    cat("   - Unlimited Profit Potential in either direction\n\n")

    # Risk management
    cat("⚠️  RISK MANAGEMENT:\n")
    cat("   - Set stop loss at 50% of premium if volatility doesn't materialize\n")
    cat("   - Monitor implied volatility - exit if it drops significantly\n")
    cat("   - Consider position sizing: Risk no more than 2-5% of portfolio\n\n")

  } else if (risk_score >= 2) {
    cat("🟡 MODERATE OPPORTUNITY: CONSIDER STRADDLE WITH CAUTION\n")
    cat("   - Some volatility potential, but not extreme\n")
    cat("   - May be better to wait for higher conviction signals\n")
    cat("   - Consider shorter-dated options to reduce premium cost\n\n")

  } else {
    cat("🔴 LOW OPPORTUNITY: NOT RECOMMENDED\n")
    cat("   - Market appears stable, straddle premiums likely too expensive\n")
    cat("   - Consider alternative strategies or wait for better setup\n\n")
  }

  # Market outlook
  cat("🔮 MARKET OUTLOOK:\n")
  if (current_vol > avg_vol * 1.5) {
    cat("   - Volatility is elevated - good environment for options strategies\n")
  } else {
    cat("   - Volatility is normal - options may be fairly priced\n")
  }

  cat("   - Monitor for news events that could trigger volatility spikes\n")
  cat("   - Brazilian market sensitive to global risk sentiment\n\n")

  # Disclaimer
  cat("⚠️  IMPORTANT DISCLAIMER:\n")
  cat("   This analysis is for educational purposes only.\n")
  cat("   Options trading involves substantial risk and is not suitable for all investors.\n")
  cat("   Past performance does not guarantee future results.\n")
  cat("   Consult with a financial advisor and get actual option quotes from your broker.\n")
  cat("   The premium estimates are approximations and actual costs may vary significantly.\n\n")

  # Save analysis summary
  summary <- data.frame(
    Date = Sys.Date(),
    Risk_Score = risk_score,
    IBOV_Level = ibov_price,
    Current_Vol = current_vol,
    Avg_Vol = avg_vol,
    Recommendation = ifelse(risk_score >= 3, "ENTER STRADDLE",
                           ifelse(risk_score >= 2, "CONSIDER", "AVOID"))
  )

  write.csv(summary, "straddle_analysis_summary.csv", row.names = FALSE)
  cat("📄 Analysis summary saved to: straddle_analysis_summary.csv\n\n")

  return(summary)
}

# Run the analysis
result <- analyze_straddle_opportunity()

# Optional: Create a simple visualization
if (result$Risk_Score >= 2) {
  cat("📊 Generating risk visualization...\n")

  # Create a simple risk meter plot
  risk_levels <- c("Low", "Moderate", "High")
  risk_colors <- c("green", "yellow", "red")

  risk_df <- data.frame(
    Level = factor(risk_levels, levels = risk_levels),
    Score = c(1, 2, 3),
    Color = risk_colors
  )

  current_risk <- min(result$Risk_Score, 3)

  risk_plot <- ggplot(risk_df, aes(x = Level, y = Score, fill = Color)) +
    geom_bar(stat = "identity", alpha = 0.7) +
    geom_hline(yintercept = current_risk, color = "red", size = 2, linetype = "dashed") +
    scale_fill_manual(values = c("green" = "#4CAF50", "yellow" = "#FFEB3B", "red" = "#F44336")) +
    labs(title = "Current Market Risk Level for Straddle Strategy",
         subtitle = paste("Risk Score:", result$Risk_Score, "/4"),
         x = "Risk Level", y = "Threshold") +
    theme_minimal() +
    theme(legend.position = "none")

  ggsave("straddle_risk_meter.png", risk_plot, width = 8, height = 6)
  cat("📈 Risk meter saved to: straddle_risk_meter.png\n")
}

cat("✅ Straddle strategy analysis complete!\n")