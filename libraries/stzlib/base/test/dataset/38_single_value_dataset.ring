# Narrative
# --------
# Single Value Dataset
#
# Extracted from stzdatasettest.ring, block #38.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Tests behavior with minimal data.

pr()

o1 = new stzDataSet([ 42 ])
o1 {
    ? Mean()              #--> 42
    ? StandardDeviation() #--> 0 (no variability)

    ? @@NL(o1.Insights())
    #--> [
    # "Low variability (CV = 0%) indicates consistent, homogeneous data.",
    # "Near-normal distribution characteristics (skewness 0, kurtosis 0). Parametric methods appropriate."
    # ]

}

pf()
# Executed in 0.0370 second(s) in Ring 1.24
# Executed in 0.0040 second(s) in Ring 1.22
