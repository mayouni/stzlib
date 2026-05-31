# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #14.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "B", 1:3, 4:5, 6:8, "C", 9:10, 11:12 ])
o1.RandomiseLists() # Or ShuffleLists()
? @@( o1.Content() )
#--> [ "A", "B", [ 1, 2, 3 ], [ 6, 7, 8 ], [ 4, 5 ], "C", [11, 12 ], [ 9, 10 ] ]
#--> [ "A", "B", [ 1, 2, 3 ], [ 4, 5 ], [ 6, 7, 8 ], "C", [ 9, 10 ], [ 11, 12 ] ]
#--> [ "A", "B", [ 4, 5 ], [ 6, 7, 8 ], [ 1, 2, 3 ], "C", [ 9, 10 ], [ 11, 12 ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.20
