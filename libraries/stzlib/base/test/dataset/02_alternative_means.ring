# Narrative
# --------
# Alternative Means
#
# Extracted from stzdatasettest.ring, block #2.

load "../../stzBase.ring"

# Geometric mean (product-based average) and harmonic mean (reciprocal-based average)
# are useful for rates or skewed data.

pr()

o1 = new stzDataSet([ 2, 8, 32 ])
o1 {
    ? GeometricMean()   #--> 8 (nth root of product)
    ? HarmonicMean()    #--> 4.5714 (n divided by sum of reciprocals)
}

pf()
# Executed in 0.0010 second(s) in Ring 1.24
