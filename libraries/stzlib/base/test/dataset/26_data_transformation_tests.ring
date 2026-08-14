# Narrative
# --------
# Data Transformation Tests
#
# Extracted from stzdatasettest.ring, block #26.

load "../../stzBase.ring"

# Normalization scales to [0,1]; standardization to mean 0, variance 1;
# robust scaling uses median and IQR.

pr()

# Four decimals, because that is the precision these expectations are
# written to. Ring renders a float through the PROCESS-GLOBAL decimals
# setting, which defaults to 2 -- so a standard deviation of 10.8012
# printed as 10.80 and the promise beside it read as a divergence. The
# value was always right; only the rendering was short.
StzDecimals(4)

o1 = new stzDataSet([ 100, 200, 300, 400, 500 ])
o1 {
    ? @@(Normalize())     #--> [ 0, 0.2500, 0.5000, 0.7500, 1 ]
    ? @@(Standardize())   #--> [ -1.2649, -0.6325, 0, 0.6325, 1.2649 ]
    ? @@(RobustScale())   #--> [ -1, -0.5000, 0, 0.5000, 1 ]
}

pf()
# Executed in 0.0010 second(s) in Ring 1.24
# Executed in 0.0030 second(s) in Ring 1.22
