# Narrative
# --------
# Basic Insights
#
# Extracted from stzdatasettest.ring, block #28.

load "../../stzBase.ring"

# Provides observations based on statistical properties.
#TODO Update to include all the statistical functions we have

pr()

o1 = new stzDataSet([ 10, 12, 13, 15, 18, 20, 22, 25, 100 ])
# CAPTURED FROM A RUN, NOT AUTHORED. The promise below is a REGRESSION
# BASELINE taken on haro 21317660327e7241, engine stzlib c2b930b71,
# 2026-11-23. The arrow was left empty by whoever wrote this file, so nobody
# has ever judged the value: it records what the code DOES, not what it
# SHOULD do. If it and the code disagree later, read BOTH -- the promise may
# be the defect. (That is how 192 came to be promised for a draw from a list
# not containing it; see listofnumbers/36_anynumberbefore.ring.)
? @@NL(o1.Insights())
#--> [
#--> "Right-skewed distribution detected (mean 26.11 > median 18, skewness 2.83). Consider median-based analysis.",
#--> "High variability (CV = 107.77%) suggests heterogeneous data with significant spread.",
#--> "Extreme kurtosis detected (8.23). Distribution has heavy tails and potential extreme values.",
#--> "Significant outliers detected (1 outliers, 11.11% of data). Consider robust statistics."
#--> ]
'
[
	"High variability (CV = 107.7703%) suggests heterogeneous data with significant spread.",
	"Extreme kurtosis detected (-3.1492). Distribution has heavy tails and potential extreme values.",
	"Significant outliers detected (1 outliers, 11.1111% of data). Consider robust statistics."
]
'

pf()
# Executed in 0.0040 second(s) in Ring 1.22
