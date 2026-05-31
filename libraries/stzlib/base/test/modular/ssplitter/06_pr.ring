# Narrative
# --------
# pr()
#
# Extracted from stzSsplittertest.ring, block #6.

load "../../../stzBase.ring"


o1 = new stzSplitter(10)

? @@( o1.Split( :ToPartsOfNItems = 3 ) ) # Or :ToPartsOfExactlyNItems
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ] ]


? @@( o1.Split( :ToPartsOfNItemsXT = 3 ) ) # XT ~> Adds the remaining part
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 9 ], [ 10, 10 ] ]

? @@( o1.Split( :ToNParts = 4 ) )
#--> [ [ 1, 3 ], [ 4, 6 ], [ 7, 8 ], [ 9, 10 ] ]

pf()
# Executed in 0.14 second(s) in Ring 1.21
# Executed in 0.16 second(s) in Ringh 1.20
