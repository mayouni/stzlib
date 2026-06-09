# Narrative
# --------
# EXAMPLE 1: Basic Data Exploration
#
# Extracted from stzdatasettest.ring, block #43.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

aSalesData = [
	120, 150, 89, 200, 175,
	95, 180, 210, 165, 145,
	190, 88, 220, 155, 170
]

oSales = new stzDataSet(aSalesData)

# Making a plan for understanding data

oPlan = oSales.MakePlan(:Understand) # Or PreparePlan() or GeneratePlan()

# Preview Plan without execution

? oSales.PlanSummary(:Understand)
#-->
`
╭─────────────────────────────────╮
│ Plan: Exploratory Data Analysis │
╰─────────────────────────────────╯
• Name: {eda}
• Goal: Comprehensive data exploration and understanding
• Steps (9):
  1. Check data quality
  2. Identify data type
  3. Get sample size
  4. Central tendency (conditional)
  5. Robust center (conditional)
  6. Variability (conditional)
  7. Distribution shape (conditional)
  8. Asymmetry check (conditional)
  9. Outlier detection (conditional)
`

# Full Plan execution

oResults = oSales.ExecutePlan(:EDA) # Or RunPlan() or PerformPlan()
#-->
`
╭───────────────────────────────────────────╮
│ Executing Plan: Exploratory Data Analysis │
╰───────────────────────────────────────────╯
• Name: {eda}
• Goal: Comprehensive data exploration and understanding
• Steps: 9

✅ Step 1/9: Check data quality
╰─> ValidateData: 1 values

✅ Step 2/9: Identify data type
╰─> Data type: numeric

✅ Step 3/9: Get sample size
╰─> Sample size: 15

✅ Step 4/9: Central tendency
╰─> Mean: 156.8000

✅ Step 5/9: Robust center
╰─> Median: 165

✅ Step 6/9: Variability
╰─> Std Dev: 125.5495

✅ Step 7/9: Distribution shape
╰─> Quartiles: 3 values

✅ Step 8/9: Asymmetry check
╰─> Skewness: 0.0850

✅ Step 9/9: Outlier detection
╰─> Outliers present: 0

( Plan completed in 0.0980s : 9 successful steps, 0 errors )
`

pf()
# Executed in 0.0910 second(s) in Ring 1.24
# Executed in 0.1990 second(s) in Ring 1.22
