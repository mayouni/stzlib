# Narrative
# --------
# EXAMPLE 10: Conditional Plan Execution
#
# Extracted from stzdatasettest.ring, block #52.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

# Test dataset with various characteristics
oMixedData = new stzDataSet([
	100, 98, 102, 99, 101, 97, 103, 95, 105, 99, 
	98, 101, 96, 104, 100, 180, 99, 102, 98, 101,
	97, 103, 100, 99, 102, 98, 101, 97, 104, 100
])

oMixedData.AdaptiveAnalysis()
#-->
`
~> Start with basic exploration...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

╭───────────────────────────────────────────╮
│ Executing Plan: Exploratory Data Analysis │
╰───────────────────────────────────────────╯
• Name: {eda}
• Goal: Comprehensive data exploration and understanding
• Steps: 9

✅ Step 1/9: Check data quality
╰─> ValidateData: 1 value(s)

✅ Step 2/9: Identify data type
╰─> Data type: numeric

✅ Step 3/9: Get sample size
╰─> Sample size: 30

✅ Step 4/9: Central tendency
╰─> Mean: 102.6333

✅ Step 5/9: Robust center
╰─> Median: 100

✅ Step 6/9: Variability
╰─> Std Dev: 14.8219

✅ Step 7/9: Distribution shape
╰─> Quartiles: 3 value(s)

✅ Step 8/9: Asymmetry check
╰─> Skewness: 0.1744

✅ Step 9/9: Outlier detection
╰─> Outliers present: 1

( Plan completed in 0.0460s : 9 successful step(s), 0 error(s) )

~> Outliers found, performing detailed outlier analysis...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

╭────────────────────────────────────────────────╮
│ Executing Plan: Outlier Detection and Analysis │
╰────────────────────────────────────────────────╯
• Name: {outliers}
• Goal: Comprehensive outlier identification and impact assessment
• Steps: 7

✅ Step 1/7: Initial outlier detection
╰─> Outliers present: 1

✅ Step 2/7: List outlier values
╰─> Outliers: 1 value(s)

✅ Step 3/7: Standardized scores
╰─> ZScores: 30 value(s)

✅ Step 4/7: Mean with outliers
╰─> Mean: 102.6333

✅ Step 5/7: Robust mean (10% trimmed)
╰─> TrimmedMean: 100.0833

✅ Step 6/7: Outlier-resistant center
╰─> Median: 100

✅ Step 7/7: Outlier-resistant scaling
╰─> RobustScale: 30 value(s)

( Plan completed in 0.0320s : 7 successful step(s), 0 error(s) )

~> Sufficient sample size, testing normality assumptions...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

╭───────────────────────────────────────────╮
│ Executing Plan: Normality Assessment Plan │
╰───────────────────────────────────────────╯
• Name: {normality}
• Goal: Determine if data follows normal distribution
• Steps: 6

✅ Step 1/6: Check sample size adequacy
╰─> Sample size: 30

✅ Step 2/6: Formal normality test
╰─> Normality p-value: [ "skewness", 0.1744 ]

✅ Step 3/6: Check asymmetry
╰─> Skewness: 0.1744

✅ Step 4/6: Check tail behavior
╰─> Kurtosis: -2.2873

✅ Step 5/6: Visual normality indicators
╰─> BoxPlotStats: 8 value(s)

✅ Step 6/6: Outlier impact on normality
╰─> Outliers: 1 value(s)

( Plan completed in 0.0220s : 6 successful step(s), 0 error(s) )

~> Trend pattern identified, analyzing temporal behavior...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
╭────────────────────────────────────────────╮
│ Executing Plan: Time Series Trend Analysis │
╰────────────────────────────────────────────╯
• Name: {trends}
• Goal: Analyze temporal patterns and trends
• Steps: 6

✅ Step 1/6: Check sufficient data points
╰─> Sample size: 30

✅ Step 2/6: Overall trend direction
❌ Error: Error (R21) : Using operator with values of incorrect type

✅ Step 3/6: Smooth short-term fluctuations
╰─> MovingAverage: 26 value(s)

✅ Step 4/6: Long-term trend smoothing
╰─> MovingAverage: 21 value(s)

✅ Step 5/6: Trend stability assessment
╰─> Std Dev: 14.8219

✅ Step 6/6: Trend magnitude
╰─> Range: 85

( Plan completed in 0.0270s : 6 successful step(s), 1 error(s) )
`

pf()
# Executed in 0.1220 second(s) in Ring 1.24
# Executed in 0.2430 second(s) in Ring 1.22
