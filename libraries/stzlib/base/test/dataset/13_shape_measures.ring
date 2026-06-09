# Narrative
# --------
# Shape Measures
#
# Extracted from stzdatasettest.ring, block #13.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Skewness measures asymmetry; kurtosis measures tailedness.

pr()

o1 = new stzDataSet([ 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 ])
o1 {
    ? Skewness()
    #--> 0.0027 (near 0, nearly symmetric)

    ? Kurtosis()
    #--> -3.9006 (negative = flatter than normal distribution)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22
