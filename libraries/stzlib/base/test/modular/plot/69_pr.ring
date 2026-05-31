# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #69.

load "../../../stzBase.ring"


o1 = new stzListOfPairs([

	[1,12], [1,14], [1,16], [1,18], [1,20],
	[1,22], [1,24], [1,26], [1,30]
])

o1.ReversePairs()
? @@(o1.Content())
#--> [ [ 12, 1 ], [ 14, 1 ], [ 16, 1 ], [ 18, 1 ], [ 20, 1 ], [ 22, 1 ], [ 24, 1 ], [ 26, 1 ], [ 30, 1 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.22
