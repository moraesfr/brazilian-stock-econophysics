# Analyze Brazilian Stocks

This folder contains the core scripts for analyzing the Brazilian stock market using econophysics and Tsallis entropy.

## Files

- `analyze_brazilian_stocks.R`: Main function to analyze historical data (2006-2019), compute correlations, Tsallis entropy, and detect crisis/boom events.
- `recent_analysis.R`: Script for monitoring the last 30 days, providing risk scores and predictive alerts.
- `report.Rmd`: R Markdown template for generating PDF reports.
- `report.pdf`: Generated PDF report with analysis and visualizations.
- `crisis_events_plot.png`: Plot of IBOVESPA returns with highlighted crisis events.
- `tsallis_entropy_plot.png`: Tsallis entropy vs. q parameter plot.
- `recent_entropy_plot.png`: Entropy plot for recent data.

## Usage

Run `analyze_brazilian_stocks.R` to perform the main analysis:

```r
source("analyze_brazilian_stocks.R")
results <- analyze_brazilian_stocks()
```

For recent monitoring:

```r
source("recent_analysis.R")
# Run the analysis
```

Compile the report with `rmarkdown::render("report.Rmd")`.

## Methodology

- Fetches data from Yahoo Finance
- Computes daily returns and correlation matrices
- Applies Tsallis entropy to absolute correlations
- Detects crises based on returns < -5% or volatility > 3 SD
- Generates plots and PDF output