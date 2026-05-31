# Narrative
# --------
# Invalid Correlation Cases
#
# Extracted from stzdatasettest.ring, block #40.

load "../../../stzBase.ring"

# Tests correlation with incompatible datasets.

pr()

o1 = new stzDataSet([ "A", "B", "C" ])
o2 = new stzDataSet([ 1, 2, 3, 4, 5 ])

? o1.CorrelationWith(o2)
#--> 0 (different lengths)

o3 = new stzDataSet([ 1, 2, 3 ])
o4 = new stzDataSet([ "X", "Y" ])

? o3.ChiSquareWith(o4)
#--> 0 (different lengths)

pf()
# Executed in 0.0010 second(s) in Ring 1.22

#======================================================================#
#  Combined Analysis Example                                           #
#======================================================================#
