# Narrative
# --------
# Basic Insights
#
# Extracted from stzdatasettest.ring, block #28.

load "../../../stzBase.ring"

# Provides observations based on statistical properties.
#TODO Update to include all the statistical functions we have

pr()

o1 = new stzDataSet([ 10, 12, 13, 15, 18, 20, 22, 25, 100 ])
? @@NL(o1.Insights())
#-->
'
[
	"High variability (CV = 107.7703%) suggests heterogeneous data with significant spread.",
	"Extreme kurtosis detected (-3.1492). Distribution has heavy tails and potential extreme values.",
	"Significant outliers detected (1 outliers, 11.1111% of data). Consider robust statistics."
]
'

pf()
# Executed in 0.0040 second(s) in Ring 1.22
