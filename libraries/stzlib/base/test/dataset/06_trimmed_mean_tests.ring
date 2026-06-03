# Narrative
# --------
# Trimmed Mean Tests
#
# Extracted from stzdatasettest.ring, block #6.

load "../../stzBase.ring"

# Trimmed mean removes a percentage of extreme values to reduce outlier impact.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 100 ])
o1 {
    ? Mean()         	#--> 14.5 (affected by outlier 100)
    ? TrimmedMean(10) 	#--> 5.5 (trims 10% from each end)
    ? TrimmedMean(20) 	#--> 5.5 (trims 20% from each end)
    ? Median()       	#--> 5.5 (for comparison, robust to outliers)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22
