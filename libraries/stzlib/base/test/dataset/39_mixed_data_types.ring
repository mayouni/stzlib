# Narrative
# --------
# Mixed Data Types
#
# Extracted from stzdatasettest.ring, block #39.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Handles datasets with both numeric and categorical values.

pr()

o1 = new stzDataSet([ 1, "text", 3, 4, "another" ])

o1 {
    ? DataType() #--> "mixed"

    ? @@NL(Insights())
    #--> [
    #  "Low variability (CV = 0%) indicates consistent, homogeneous data.",
    #  "Near-normal distribution characteristics (skewness 0, kurtosis 0). Parametric methods appropriate.",
    #  "Mixed dataset containing both numeric and categorical data. Consider separating data types for specialized analysis."
    # ]

}

pf()
# Executed in 0.0330 second(s) in Ring 1.24
# Executed in 0.0040 second(s) in Ring 1.22
