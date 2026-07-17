# Narrative
# --------
# EXAMPLE 9: Plan Chaining
#
# Extracted from stzdatasettest.ring, block #51.
#ERR exit 1: Error (S1) In file: 51_example_9_plan_chaining.ring

load "../../stzBase.ring"


pr()

# Comprehensive data analysis pipeline
pProductionData = new stzDataSet([
	95.2, 96.1, 94.8, 97.3, 95.9, 96.5, 95.1, 98.2, 96.0, 95.7,
    96.8, 94.9, 95.6, 96.3, 95.4, 99.1, 96.2, 95.8, 96.7, 95.3
])

pProductionData.ChainPlans([ "EDA", "QUALITY", "OUTLIERS", "NORMALITY" ])
#-->
'
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
╰─> Sample size: 20

✅ Step 4/9: Central tendency
╰─> Mean: 96.1450

✅ Step 5/9: Robust center
╰─> Median: 95.9500

✅ Step 6/9: Variability
╰─> Std Dev: 1.0880

✅ Step 7/9: Distribution shape
╰─> Quartiles: 3 value(s)

✅ Step 8/9: Asymmetry check
╰─> Skewness: 0.0655

✅ Step 9/9: Outlier detection
╰─> Outliers present: 1

( Plan completed in 0.0430s : 9 successful step(s), 0 error(s) )

╭──────────────────────────────────────────╮
│ Executing Plan: Quality Control Analysis │
╰──────────────────────────────────────────╯
• Name: {quality}
• Goal: Statistical process control and quality assessment
• Steps: 8

✅ Step 1/8: Data integrity check
╰─> ValidateData: 1 value(s)

✅ Step 2/8: Process center
╰─> Mean: 96.1450

✅ Step 3/8: Process variation
╰─> Std Dev: 1.0880

✅ Step 4/8: Process consistency
╰─> CoefficientOfVariation: 1.1316

✅ Step 5/8: Process anomalies
╰─> Outliers present: 1

✅ Step 6/8: Out-of-control points
╰─> Outliers: 1 value(s)

✅ Step 7/8: Process spread
╰─> Range: 4.3000

✅ Step 8/8: Process drift detection
❌ Error: Error (R21) : Using operator with values of incorrect type

( Plan completed in 0.0300s : 8 successful step(s), 1 error(s) )

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
╰─> ZScores: 20 value(s)

✅ Step 4/7: Mean with outliers
╰─> Mean: 96.1450

✅ Step 5/7: Robust mean (10% trimmed)
╰─> TrimmedMean: 95.9937

✅ Step 6/7: Outlier-resistant center
╰─> Median: 95.9500

✅ Step 7/7: Outlier-resistant scaling
╰─> RobustScale: 20 value(s)

( Plan completed in 0.0320s : 7 successful step(s), 0 error(s) )

╭───────────────────────────────────────────╮
│ Executing Plan: Normality Assessment Plan │
╰───────────────────────────────────────────╯
• Name: {normality}
• Goal: Determine if data follows normal distribution
• Steps: 6

✅ Step 1/6: Check sample size adequacy
╰─> Sample size: 20

✅ Step 2/6: Formal normality test
╰─> Normality p-value: [ "skewness", 0.0655 ]

✅ Step 3/6: Check asymmetry
╰─> Skewness: 0.0655

✅ Step 4/6: Check tail behavior
╰─> Kurtosis: -3.2691

✅ Step 5/6: Visual normality indicators
╰─> BoxPlotStats: 8 value(s)

✅ Step 6/6: Outlier impact on normality
╰─> Outliers: 1 value(s)

( Plan completed in 0.0250s : 6 successful step(s), 0 error(s) )
'

pf()
# Executed in 0.1310 second(s) in Ring 1.24
# Executed in 0.3180 second(s) in Ring 1.22
