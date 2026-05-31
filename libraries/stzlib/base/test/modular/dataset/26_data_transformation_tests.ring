# Narrative
# --------
# Data Transformation Tests
#
# Extracted from stzdatasettest.ring, block #26.

load "../../../stzBase.ring"

# Normalization scales to [0,1]; standardization to mean 0, variance 1;
# robust scaling uses median and IQR.

pr()

o1 = new stzDataSet([ 100, 200, 300, 400, 500 ])
o1 {
    ? @@(Normalize())     #--> [0, 0.25, 0.5, 0.75, 1]
    ? @@(Standardize())   #--> [-1.2649, -0.6325, 0, 0.6325, 1.2649]
    ? @@(RobustScale())   #--> [-1, -0.5, 0, 0.5, 1]
}

pf()
# Executed in 0.0010 second(s) in Ring 1.24
# Executed in 0.0030 second(s) in Ring 1.22
