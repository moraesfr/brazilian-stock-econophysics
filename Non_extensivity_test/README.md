# Non-Extensivity Test

This folder contains scripts and plots for testing the hypothesis of non-extensive behavior in the Brazilian stock market.

## Files

- `test_qgaussian_fits.R`: Script to fit q-Gaussian and normal distributions to daily returns of IBOV and individual stocks.
- `compare_crisis_normal.R`: Script to compare returns and correlations during crisis windows vs. normal periods.
- `*fits.png`: Histogram plots with q-Gaussian (blue) and normal (red) fits for each stock.
- `crisis_returns.png`: Distribution of returns during crisis periods.
- `normal_returns.png`: Distribution of returns during normal periods.
- `entropy_crisis_normal.png`: Tsallis entropy comparison between crisis and normal correlations.

## Usage

Run the q-Gaussian fitting:

```r
source("test_qgaussian_fits.R")
results <- test_qgaussian_fits()
```

Run the crisis vs. normal comparison:

```r
source("compare_crisis_normal.R")
results <- compare_crisis_normal()
```

## Findings

- Normal Gaussian often fits well for returns, but correlations show non-extensivity.
- Crisis periods exhibit higher correlations and different entropy profiles.
- Demonstrates that while returns may be Gaussian, the system's correlations are non-extensive.