# Narrative
# --------
# EXAMPLE 7: Comparative Analysis Plan
#
# Extracted from stzdatasettest.ring, block #49.

load "../../stzBase.ring"


pr()

# Before/After performance data
aBefore = [78, 82, 75, 80, 77, 83, 79, 81, 76, 84]
aAfter = [85, 88, 84, 87, 89, 91, 86, 90, 87, 93]

oBefore = new stzDataSet(aBefore)
oAfter = new stzDataSet(aAfter)

# Run EDA on both datasets
oBefore.ExecutePlan(:EDA)

? ""
oAfter.ExecutePlan(:EDA)

? ""
# Compare key metrics
? Boxround("Performance Comparison")
? "Before - Mean: " + @@(oBefore.Mean()) + ", Std: " + @@(oBefore.StandardDeviation())
? "After  - Mean: " + @@(oAfter.Mean()) + ", Std: " + @@(oAfter.StandardDeviation())
nImprovement = ((oAfter.Mean() - oBefore.Mean()) / oBefore.Mean()) * 100
? "Improvement: " + @@(nImprovement) + "%"

#--> OUTPUT
`
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
╰─> Sample size: 10

✅ Step 4/9: Central tendency
╰─> Mean: 79.5000

✅ Step 5/9: Robust center
╰─> Median: 79.5000

✅ Step 6/9: Variability
╰─> Std Dev: 3.0277

✅ Step 7/9: Distribution shape
╰─> Quartiles: 3 value(s)

✅ Step 8/9: Asymmetry check
╰─> Skewness: 0.0000

✅ Step 9/9: Outlier detection
╰─> Outliers present: 0

( Plan completed in 0.0400s : 9 successful step(s), 0 error(s) )

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
╰─> Sample size: 10

✅ Step 4/9: Central tendency
╰─> Mean: 88

✅ Step 5/9: Robust center
╰─> Median: 87.5000

✅ Step 6/9: Variability
╰─> Std Dev: 2.7889

✅ Step 7/9: Distribution shape
╰─> Quartiles: 3 value(s)

✅ Step 8/9: Asymmetry check
╰─> Skewness: 0.0384

✅ Step 9/9: Outlier detection
╰─> Outliers present: 0

( Plan completed in 0.0390s : 9 successful step(s), 0 error(s) )

╭────────────────────────╮
│ Performance Comparison │
╰────────────────────────╯
Before - Mean: 79.5000, Std: 3.0277
After  - Mean: 88, Std: 2.7889
Improvement: 10.6918%
`


pf()
# Executed in 0.0880 second(s) in Ring 1.24
# Executed in 0.2360 second(s) in Ring 1.22
