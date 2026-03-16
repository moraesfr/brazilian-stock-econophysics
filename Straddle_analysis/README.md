# Straddle Analysis

This folder contains the options strategy analysis using straddle positions based on econophysics alerts.

## Files

- `straddle_strategy.R`: Main script for backtesting straddle strategies triggered by risk alerts.
- `straddle_analysis_summary.csv`: CSV summary of strategy performance.
- `straddle_risk_meter.png`: Risk meter plot for current market conditions.
- `straddle_pnl_*.png`: Profit/loss plots for each stock's straddle strategy.

## Usage

Run the straddle analysis:

```r
source("straddle_strategy.R")
# Executes backtest and generates outputs
```

## Methodology

- Uses risk scores from recent analysis to trigger straddle entries.
- Simulates buying call + put options at-the-money.
- Holds positions for 20 days or until expiration.
- Evaluates performance against buy-and-hold.

## Results

- Provides ROI, win rate, and comparison to passive strategies.
- Demonstrates how econophysics alerts can inform options trading.