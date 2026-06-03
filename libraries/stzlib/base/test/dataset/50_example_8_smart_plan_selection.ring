# Narrative
# --------
# EXAMPLE 8: Smart Plan Selection
#
# Extracted from stzdatasettest.ring, block #50.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

# Function to automatically suggest best Plan based on data characteristics

# Test with different datasets
# Test all plan suggestions
oNormalData = new stzDataSet([100, 102, 98, 101, 99, 100, 98, 102, 101, 99, 100, 101])
oSkewedData = new stzDataSet([10, 11, 12, 11, 10, 45, 12, 11, 10, 11, 9, 12])
oHighVarData = new stzDataSet([50, 150, 75, 200, 25, 175, 100, 225, 60, 180])
oTinyData = new stzDataSet([5, 7])
oTrendData = new stzDataSet([10, 12, 14, 16, 18, 20, 22, 24, 26, 28])
oStableData = new stzDataSet([100, 100, 100, 100, 100, 100, 100, 100])

? "Normal data → " + oNormalData.SuggestPlan()     # normality
? "Skewed data → " + oSkewedData.SuggestPlan()     # outliers  
? "High variance → " + oHighVarData.SuggestPlan()  # quality
? "Tiny sample → " + oTinyData.SuggestPlan()       # eda
? "Trending → " + oTrendData.SuggestPlan()         # trends
? "No variance → " + oStableData.SuggestPlan()     # eda


# You can run any plan easily using its name
? ""
oNormalData.RunPlan(:normality) # Or ExecutePlan()
#-->
`
╭───────────────────────────────────────────╮
│ Executing Plan: Normality Assessment Plan │
╰───────────────────────────────────────────╯
• Name: {normality}
• Goal: Determine if data follows normal distribution
• Steps: 5

✅ Step 1/5: Check sample size adequacy
╰─> Sample size: 12

✅ Step 2/5: Formal normality test
╰─> Normality p-value: [ "skewness", -0.0147 ]

✅ Step 3/5: Check asymmetry
╰─> Skewness: -0.0147

✅ Step 4/5: Check tail behavior
╰─> Kurtosis: -3.7808

✅ Step 5/5: Visual normality indicators
╰─> BoxPlotStats: 8 value(s)

( Plan completed in 0.0270s : 5 successful step(s), 0 error(s) )
`

pf()
# Executed in 0.0310 second(s) in Ring 1.24
# Executed in 0.0600 second(s) in Ring 1.22
