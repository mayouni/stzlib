# Narrative
# --------
# Data Validation
#
# Extracted from stzdatasettest.ring, block #33.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

# Checks for issues like no variance or outliers.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5, 100 ])
? @@(o1.ValidateData()) + NL
#--> [ "Data quality appears good" ]

o1 = new stzDataSet([ 5, 5, 5, 5, 5 ])
? @@(o1.ValidateData()) + NL
#--> [ "No variance in data (all values identical)" ]

o1 = new stzDataSet([ 1, 2, 3, 4, 100 ])
? @@NL(o1.Recommendations())
#--> [
#	"Small sample size (n=5) prone to outlier influence.
#	Use non-parametric methods, bootstrap confidence intervals,
# 	TrimmedMean(), and interpret results cautiously.",
#
#	"Outliers detected (1 values) can distort statistics.
# 	Apply TrimmedMean(10) and RobustScale(), or investigate data quality.",
# 
# 	"Non-normal distribution violates test assumptions.
# 	Use non-parametric tests, percentile-based confidence intervals,
# 	or apply Normalize()/Standardize().",
#
#	"Extremely high variability (CV = 198.2621%) may indicate multiple populations.
# 	Consider subgroup analysis or use MovingAverage(5) to identify patterns.",
#
# 	"Sequential data contains temporal patterns.
# 	Apply TrendAnalysis() and MovingAverage(5) to smooth fluctuations and identify trends."
#
# ]

pf()
# Executed in 0.0320 second(s) in Ring 1.24
# Executed in 0.0040 second(s) in Ring 1.22

#======================================================================#
#  Utilities and Performance                                           #
#======================================================================#

# Enhances functionality and efficiency.
