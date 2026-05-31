# Narrative
# --------
# EXAMPLE 5: Custom Plan Creation
#
# Extracted from stzdatasettest.ring, block #47.

load "../../../stzBase.ring"


pr()

# Create a specialized financial analysis Plan

aFinancialSteps = [
    [ :function = "Mean", :required = TRUE, :description = "Average return" ],
    [ :function = "StandardDeviation", :required = TRUE, :description = "Volatility measure" ],
    [ :function = "CoefficientOfVariation", :required = TRUE, :description = "Risk-return ratio" ],
    [ :function = "Skewness", :required = TRUE, :description = "Return asymmetry" ],
    [ :condition = "Skewness() > 0", :function = "Percentile", :args = [5], :description = "Downside risk (5th percentile)" ],
    [ :function = "ContainsOutliers", :required = TRUE, :description = "Extreme market events" ],
    [ :condition = "ContainsOutliers()", :function = "Outliers", :description = "Crisis periods identification" ]
]

# Stock return data
aReturns = [0.05, 0.02, -0.01, 0.08, -0.15, 0.03, 0.07, -0.02, 0.12, -0.08, 
            0.04, 0.01, -0.03, 0.09, -0.20, 0.06, 0.02, -0.01, 0.11, -0.04]

oReturns = new stzDataSet(aReturns)

# Register custom Plan
oReturns.AddPlan(
	:FinRisk,
	"Financial Risk Analysis",
	"Comprehensive financial risk assessment", 
    aFinancialSteps
)

# Execute custom Plan
oReturns.ExecutePlan(:FinRisk)
#-->
`
╭─────────────────────────────────────────╮
│ Executing Plan: Financial Risk Analysis │
╰─────────────────────────────────────────╯
• Name: {finrisk}
• Goal: Comprehensive financial risk assessment
• Steps: 6

✅ Step 1/6: Average return
╰─> Mean: 0.0080

✅ Step 2/6: Volatility measure
╰─> Std Dev: 0.0815

✅ Step 3/6: Risk-return ratio
╰─> CoefficientOfVariation: 1018.4160

✅ Step 4/6: Return asymmetry
╰─> Skewness: -0.0537

✅ Step 5/6: Extreme market events
╰─> Outliers present: 1

✅ Step 6/6: Crisis periods identification
╰─> Outliers: 1 value(s)

( Plan completed in 0.0250s : 6 successful step(s), 0 error(s) )
`

pf()
# Executed in 0.0260 second(s) in Ring 1.24
# Executed in 0.0740 second(s) in Ring 1.22
