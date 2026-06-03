# Narrative
# --------
# EXAMPLE 4: Outlier Investigation
#
# Extracted from stzdatasettest.ring, block #46.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

# Customer satisfaction scores (with some extreme values)
aSatisfaction = [8.2, 7.9, 8.5, 8.1, 7.8, 8.3, 8.0, 2.1, 8.4, 7.7, 
                 8.6, 8.2, 7.9, 9.8, 8.1, 8.3, 7.8, 8.5, 8.0, 7.9]

oSatisfaction = new stzDataSet(aSatisfaction)

# Comprehensive outlier analysis
oSatisfaction.ExecutePlan(:outliers)
#-->
`
╭────────────────────────────────────────────────╮
│ Executing Plan: Outlier Detection and Analysis │
╰────────────────────────────────────────────────╯
• Name: {outliers}
• Goal: Comprehensive outlier identification and impact assessment
• Steps: 7

✅ Step 1/7: Initial outlier detection
╰─> Outliers present: 1

✅ Step 2/7: List outlier values
╰─> Outliers: 2 value(s)

✅ Step 3/7: Standardized scores
╰─> ZScores: 20 value(s)

✅ Step 4/7: Mean with outliers
╰─> Mean: 7.9050

✅ Step 5/7: Robust mean (10% trimmed)
╰─> TrimmedMean: 8.1188

✅ Step 6/7: Outlier-resistant center
╰─> Median: 8.1000

✅ Step 7/7: Outlier-resistant scaling
╰─> RobustScale: 20 value(s)

( Plan completed in 0.0350s : 7 successful step(s), 0 error(s) )
`
pf()
# Executed in 0.0360 second(s) in Ring 1.24
# Executed in 0.0810 second(s) in Ring 1.22
