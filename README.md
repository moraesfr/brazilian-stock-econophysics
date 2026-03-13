# Brazilian Stock Market Analysis: Econophysics and Tsallis Entropy

This project applies principles of econophysics to analyze the Brazilian stock market, focusing on correlations between major companies and the identification of crisis and boom events using Tsallis entropy.

## Features

### Main Analysis (`analyze_brazilian_stocks.R`)
- Analyzes historical data (2006-2019) for major Brazilian stocks
- Computes correlations and Tsallis entropy
- Identifies crisis events (sharp drops) and boom events (sharp gains)
- Generates comprehensive PDF report

### Recent Analysis (`recent_analysis.R`)
- Monitors the last 30 days of market data
- Provides real-time assessment of market stability
- Predictive analysis for upcoming volatility and events
- Risk scoring for volatility-based investments

### PDF Report (`report.pdf`)
- Complete analysis report with visualizations
- Crisis and boom event details
- Individual stock behavior analysis
- Correlation matrices and entropy plots

## Methodology

The analysis uses:
- **Tsallis Entropy**: Generalized entropy measure for non-extensive systems
- **Correlation Analysis**: Study of inter-stock relationships
- **Event Detection**: Identification of extreme market movements
- **Volatility Monitoring**: Rolling volatility analysis
- **Predictive Indicators**: Early warning signals for market events

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
install.packages(c("quantmod", "zoo", "ggplot2", "dplyr", "rmarkdown", "gridExtra", "tinytex"))
```

### System Requirements
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