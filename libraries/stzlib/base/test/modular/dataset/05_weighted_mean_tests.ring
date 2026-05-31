# Narrative
# --------
# Weighted Mean Tests
#
# Extracted from stzdatasettest.ring, block #5.

load "../../../stzBase.ring"

# Weighted mean assigns different importance (weights) to each value.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {
    ? WeightedMean([ 1, 2, 3, 2, 1 ]) #--> 30 (higher weights on middle values)
    ? WeightedMean([ 5, 1, 1, 1, 5 ]) #--> 30 (higher weights on extremes)
    ? WeightedMean([ 1, 1, 1, 1, 1 ]) #--> 30 (equal weights = regular mean)
}

pf()
# Executed in 0.0010 second(s) in Ring 1.24
