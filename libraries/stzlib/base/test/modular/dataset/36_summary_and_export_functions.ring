# Narrative
# --------
# Summary and Export Functions
#
# Extracted from stzdatasettest.ring, block #36.

load "../../../stzBase.ring"

# Provides a formatted summary and structured export.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])

# Export structured data
? @@NL(o1.Export()) + nl
#--> [
#	[ "data_type", "numeric" ],
#	[ "count", 5 ],
#	[ "unique_count", 5 ],
#	[ "mean", 30 ],
#	[ "median", 30 ],
#	[ "mode", "10" ],
#	[ "standard_deviation", 15.8114 ],
#	[ "variance", 250 ],
#	[ "range", 40 ],
#	[ "min", 10 ],
#	[ "max", 50 ],
#	[ "quartiles", [ 20, 30, 40 ] ],
#	[ "skewness", 0 ],
#	[ "kurtosis", -6.6400 ],
#	[ "outliers", [  ] ]
# ]

# Complete summary (XT to include Recommendations)
# Use Summary() without XT to get the basic summary

? o1.SummaryXT()
#-->
'
╭─────────────────╮
│ Dataset Content │
╰─────────────────╯
[10, 20, 30, 40, 50]

╭─────────────────╮
│ Dataset Summary │
╰─────────────────╯
• Type: numeric

• Count: 5

╭──────────────────╮
│ Dataset Insights │
╰──────────────────╯
• High variability (CV = 52.7046%) suggests heterogeneous data with significant spread.

• Extreme kurtosis detected (-6.6400). Distribution has heavy tails and potential extreme values.

╭─────────────────╮
│ Recommendations │
╰─────────────────╯
• Small sample size (n=5) prone to outlier influence. Use non-parametric methods, bootstrap confidence intervals, TrimmedMean(), and interpret results cautiously.

• Non-normal distribution violates test assumptions. Use non-parametric tests, percentile-based confidence intervals, or apply Normalize()/Standardize().

• Extremely high variability (CV = 52.7046%) may indicate multiple populations. Consider subgroup analysis or use MovingAverage(5) to identify patterns.

• Sequential data contains temporal patterns. Apply TrendAnalysis() and MovingAverage(5) to smooth fluctuations and identify trends.
'

pf()
# Executed in 0.0850 second(s) in Ring 1.24

#======================================================================#
#  Edge Cases and Validation                                           #
#======================================================================#

# Tests robustness in unusual scenarios.
