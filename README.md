# Brazilian Stock Market Analysis: Econophysics and Tsallis Entropy

This project applies econophysics principles to analyze the Brazilian stock market, using Tsallis entropy to study correlations, detect crises, and inform trading strategies. I have left the pandemic time out of analysis.

## Project Structure

- **[Analyze_brazilian_stocks/](Analyze_brazilian_stocks/)**: Core analysis scripts for historical data (2006-2019), correlation computation, Tsallis entropy, and crisis/boom detection.
- **[Non_extensivity_test/](Non_extensivity_test/)**: Tests for non-extensive behavior, including q-Gaussian vs. normal distribution fits and crisis vs. normal period comparisons.
- **[Straddle_analysis/](Straddle_analysis/)**: Options strategy analysis using straddle positions based on econophysics alerts.

## Key Features

- **Tsallis Entropy Analysis**: Measures non-extensivity in stock correlations.
- **Crisis Detection**: Identifies extreme market events using volatility thresholds.
- **Distribution Testing**: Compares q-Gaussian and normal fits for returns.
- **Options Strategies**: Straddle recommendations for volatility events.
- **PDF Reports**: Automated generation of analysis reports.

## Stocks Analyzed
- PETR4.SA (Petrobras)
- VALE3.SA (Vale)
- ITUB4.SA (Itaú Unibanco)
- BBDC4.SA (Bradesco)
- ABEV3.SA (Ambev)
- WEGE3.SA (WEG)
- MGLU3.SA (Magazine Luiza)

## Requirements

### R Packages
```r
install.packages(c("quantmod", "zoo", "ggplot2", "dplyr", "rmarkdown", "gridExtra", "tinytex", "fitdistrplus", "MASS"))
```

### Data Source
- Yahoo Finance for historical stock data
- IBOVESPA (^BVSP) as market benchmark

## Usage

1. Clone the repository
2. Install required R packages
3. Run scripts in each subfolder as needed
4. View generated plots and reports

## Methodology

- **Non-Extensive Statistics**: Tsallis entropy for systems with long-range correlations
- **Event Detection**: Threshold-based identification of crises (>5% drop or high volatility)
- **Correlation Dynamics**: Analysis of changing inter-stock relationships during stress
- **Options Strategy**: Straddle positions to profit from predicted volatility

## Contributing

This is an open-source project for educational and research purposes. Contributions welcome!

## License

MIT License
- R (version 4.0+)
- LaTeX (for PDF generation)
- Internet connection (for data fetching)

## Usage

### Generate Full Historical Report
```bash
Rscript analyze_brazilian_stocks.R
# Then run the R Markdown
R -e "rmarkdown::render('report.Rmd')"
```

### Run Recent Market Analysis
```bash
Rscript recent_analysis.R
```

## Output Files
- `report.pdf`: Comprehensive analysis report
- `tsallis_entropy_plot.png`: Entropy visualization
- `crisis_events_plot.png`: Crisis event plot
- `recent_entropy_plot.png`: Recent entropy plot

## Key Findings

### Historical Analysis (2006-2019)
- Strong correlations between banking sector stocks
- Multiple crisis events during 2008 financial crisis and 2015-2016 recession
- Tsallis entropy reveals non-extensive market behavior

### Recent Analysis
- Real-time monitoring of market conditions
- Predictive scoring for volatility opportunities
- Early warning system for extreme events

## Academic Background

This project demonstrates the application of econophysics - using statistical physics methods to understand economic systems. Tsallis entropy, developed by Constantino Tsallis, is particularly suited for systems with long-range correlations and non-Gaussian distributions, which are characteristic of financial markets.

## License

This project is for educational and research purposes. Please cite appropriately if used in academic work.

## Contact

For questions or contributions, please open an issue or pull request.
