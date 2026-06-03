# Narrative
# --------
# Categorical Insights
#
# Extracted from stzdatasettest.ring, block #29.

load "../../stzBase.ring"

# Insights tailored for categorical data.

pr()

o1 = new stzDataSet([ "A", "B", "A", "C", "A", "D" ])
? @@NL(o1.Insights())
#-->
'
[
	"Low variability (CV = 0%) indicates consistent, homogeneous data.",
	"Near-normal distribution characteristics (skewness 0, kurtosis 0). Parametric methods appropriate.",
	"High information content (entropy = 1.7925) indicates balanced categorical distribution."
]
'

pf()
# Executed in 0.0430 second(s) in Ring 1.24
