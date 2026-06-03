# Narrative
# --------
# Time Series and Trend Analysis
#
# Extracted from stzdatasettest.ring, block #16.

load "../../stzBase.ring"

# Moving averages smooth data; Trend() identifies patterns over time.

pr()

o1 = new stzDataSet([ 1, 3, 5, 7, 9, 11 ])
? @@(o1.MovingAverage(3))
#--> [3, 5, 7, 9] (average of 3 consecutive values)

? @@(Trend([ 1, 3, 5, 7, 9 ])) # Or StzDataSetQ([ 1, 3, 5, 7, 9 ]).Trend()
#--> [[ " up", 5]] (upward trend)

? @@(StzDataSetQ([ 7, 4, 3, 1 ]).Trend())
#--> [[ " down", 4]] (downward trend)

? @@(StzDataSetQ([ 7, 4, 3, 1, 5, 9, 12 ]).Trend())
#--> [[ " down", 4], [ " up", 3]]

? @@(StzDataSetQ([ 7, 4, 3, 1, 1, 1, 5, 9, 12 ]).Trend())
#--> [[ " down", 4], [ " stable", 2], [ " up", 3]]

? @@(StzDataSetQ([ 1, 1, 1, 2, 3, 4 ]).Trend())
#--> [[ " stable", 3], [ " up", 3]]

pf()
# Executed in 0.0050 second(s) in Ring 1.24
