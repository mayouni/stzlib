# Narrative
# --------
# Alternative Means
#
# Extracted from stzdatasettest.ring, block #2.

load "../../stzBase.ring"

# Geometric mean (product-based average) and harmonic mean (reciprocal-based average)
# are useful for rates or skewed data.

pr()

# Four decimals, because that is the precision these expectations are
# written to. Ring renders a float through the PROCESS-GLOBAL decimals
# setting, which defaults to 2 -- so a standard deviation of 10.8012
# printed as 10.80 and the promise beside it read as a divergence. The
# value was always right; only the rendering was short.
StzDecimals(4)

o1 = new stzDataSet([ 2, 8, 32 ])
o1 {
    ? GeometricMean()   #--> 8.0000 (nth root of product)
    ? HarmonicMean()    #--> 4.5714 (n divided by sum of reciprocals)
}

pf()
# Executed in 0.0010 second(s) in Ring 1.24
