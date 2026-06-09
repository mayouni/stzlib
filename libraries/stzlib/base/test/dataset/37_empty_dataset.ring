# Narrative
# --------
# Empty Dataset
#
# Extracted from stzdatasettest.ring, block #37.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Handles cases with no data.

pr()

o1 = new stzDataSet([  ])
o1 {
    ? DataType()          #--> "empty"
    ? Mean()              #--> 0 (default for empty)
    ? Median()            #--> 0
    ? @@(Mode())          #--> ""

    ? @@(Insights())
    #--> [
    # 	"Dataset is empty - No analysis possible without data.",
    #   "Low variability (CV = 0%) indicates consistent, homogeneous data.",
    #   "Near-normal distribution characteristics (skewness 0, kurtosis 0). Parametric methods appropriate."
    # ]
}

pf()
# Executed in 0.0310 second(s) in Ring 1.24
