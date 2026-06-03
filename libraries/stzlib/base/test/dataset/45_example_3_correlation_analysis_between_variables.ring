# Narrative
# --------
# EXAMPLE 3: Correlation Analysis Between Variables
#
# Extracted from stzdatasettest.ring, block #45.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

# Temperature and ice cream sales data
aTemperature = [72, 75, 80, 85, 90, 68, 78, 82, 88, 95, 70, 77, 83, 87, 92]
aSales = [120, 145, 180, 220, 280, 95, 160, 200, 250, 320, 110, 155, 205, 240, 300]

oTemp = new stzDataSet(aTemperature)
oSalesTemp = new stzDataSet(aSales)

# Correlation Plan (automatically chooses Pearson vs Spearman)
oCorrelation = oTemp.ExecutePlan(:relation)
#-->
`
╭───────────────────────────────────────────╮
│ Executing Plan: Correlation Analysis Plan │
╰───────────────────────────────────────────╯
• Name: {correlation}
• Goal: Analyze relationships between variables
• Steps: 5

✅ Step 1/5: Verify numeric data
╰─> Data type: numeric

✅ Step 2/5: Check sample size
╰─> Sample size: 15

✅ Step 3/5: Test normality assumption
╰─> Normality p-value: [ "skewness", 0.0756 ]

✅ Step 4/5: Spearman correlation (non-normal data)
❌ Error: Error (R19) : Calling function with less number of parameters

✅ Step 5/5: Covariance analysis
❌ Error: Error (R19) : Calling function with less number of parameters

( Plan completed in 0.0290s : 3 successful step(s), 2 error(s) )
`

? ""
# Manual correlation with second dataset
? oTemp.CorrelationWith(oSalesTemp)
#--> 0.9942  #TODO Strong positive correlation expected?

pf()
# Executed in 0.0300 second(s) in Ring 1.24
