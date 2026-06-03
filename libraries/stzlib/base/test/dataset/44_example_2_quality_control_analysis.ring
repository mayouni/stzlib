# Narrative
# --------
# EXAMPLE 2: Quality Control Analysis
#
# Extracted from stzdatasettest.ring, block #44.

load "../../stzBase.ring"


# Manufacturing process data (with some issues)

aProcessData = [
	98.2, 99.1, 97.8, 101.5, 98.9, 99.3, 98.7, 110.2, 99.0, 98.5, 
	99.4, 97.9, 98.8, 99.2, 98.6, 85.1, 99.1, 98.4, 99.7, 98.3
]

oProcess = new stzDataSet(aProcessData)

# Quality control Plan
oQCResults = oProcess.ExecutePlan(:quality)
#-->
`
╭──────────────────────────────────────────╮
│ Executing Plan: Quality Control Analysis │
╰──────────────────────────────────────────╯
• Name: {quality}
• Goal: Statistical process control and quality assessment
• Steps: 8

✅ Step 1/8: Data integrity check
╰─> ValidateData: 1 value(s)

✅ Step 2/8: Process center
╰─> Mean: 98.7850

✅ Step 3/8: Process variation
╰─> Std Dev: 4.1642

✅ Step 4/8: Process consistency
╰─> CoefficientOfVariation: 100

✅ Step 5/8: Process anomalies
╰─> Outliers present: 1

✅ Step 6/8: Out-of-control points
╰─> Outliers: 3 value(s)

✅ Step 7/8: Process spread
╰─> Range: 25.1000

✅ Step 8/8: Process drift detection
❌ Error: Error (R21) : Using operator with values of incorrect type

( Plan completed in 0.0320s : 8 successful step(s), 1 error(s) )
`

pf()
# Executed in 2.4140 second(s) in Ring 1.24
# Executed in 3.7100 second(s) in Ring 1.22
