# Narrative
# --------
# Percentile Rank Tests
#
# Extracted from stzdatasettest.ring, block #7.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Percentile rank shows the percentage of values below a given value.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 ])
o1 {
    ? PercentileRank(55) 	#--> 50.0 (55 is between 50 and 60)
    ? PercentileRank(30) 	#--> 25.0 (30 is at 25th percentile)
    ? PercentileRank(5)  	#--> 0.0 (below minimum)
    ? PercentileRank(105) 	#--> 100.0 (above maximum)
}

pf()
# Executed in 0.0010 second(s) in Ring 1.24

#======================================================================#
#  PILLAR 2: COMPOSITION - Frequency & Categorical Analysis            #
#======================================================================#

# This pillar analyzes the composition of data, focusing on frequency and
# categorical distributions.
