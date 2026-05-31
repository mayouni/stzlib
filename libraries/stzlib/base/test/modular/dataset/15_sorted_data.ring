# Narrative
# --------
# Sorted Data
#
# Extracted from stzdatasettest.ring, block #15.

load "../../../stzBase.ring"

# Returns data in ascending order for distribution analysis.

pr()

o1 = new stzDataSet([ 30, 10, 20, 50, 40 ])
? @@(o1.SortedData())
#--> [10, 20, 30, 40, 50]

pf()
# Executed in almost 0 second(s) in Ring 1.24
# Executed in 0.0010 second(s) in Ring 1.22
