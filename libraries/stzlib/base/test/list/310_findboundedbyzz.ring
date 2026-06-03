# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #310.

load "../../stzBase.ring"

pr()

#                   1..4.6..9.1.34..7..0
o1 = new stzString("[••[•[••]•[•]]••[••]]")

? @@( o1.FindBoundedByZZ([ "[","]" ]) ) + NL
#--> [ [ 7, 8 ], [ 12, 12 ], [ 18, 19 ] ]

? @@( o1.DeepFindBoundedByZZ([ "[","]" ]) )
#--> [ [ 7, 8 ], [ 12, 12 ], [ 18, 19 ], [ 5, 13 ], [ 2, 20 ] ]

StopProfiler()

pf()
# Executed in 0.02 second(s) in Ring 1.22
