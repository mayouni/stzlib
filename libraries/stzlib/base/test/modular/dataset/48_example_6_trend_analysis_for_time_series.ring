# Narrative
# --------
# EXAMPLE 6: Trend Analysis for Time Series
#
# Extracted from stzdatasettest.ring, block #48.

load "../../../stzBase.ring"


pr()

# Monthly website visitors
aVisitors = [1200, 1350, 1180, 1420, 1580, 1750, 1650, 1820, 1920, 1780, 2100, 2350]
oVisitors = new stzDataSet(aVisitors)

# Trend analysis Plan
oVisitors.ExecutePlan(:trends)
`
╭────────────────────────────────────────────╮
│ Executing Plan: Time Series Trend Analysis │
╰────────────────────────────────────────────╯
• Name: {trends}
• Goal: Analyze temporal patterns and trends
• Steps: 6

✅ Step 1/6: Check sufficient data points
╰─> Sample size: 12

✅ Step 2/6: Overall trend direction
❌ Error: Error (R21) : Using operator with values of incorrect type

✅ Step 3/6: Smooth short-term fluctuations
╰─> MovingAverage: 8 value(s)

✅ Step 4/6: Long-term trend smoothing
╰─> MovingAverage: 3 value(s)

✅ Step 5/6: Trend stability assessment
╰─> Std Dev: 354.8239

✅ Step 6/6: Trend magnitude
╰─> Range: 1170

( Plan completed in 0.0690s : 6 successful step(s), 1 error(s) )
`

pf()
# Executed in 0.0300 second(s) in Ring 1.24
# Executed in 0.0700 second(s) in Ring 1.22
