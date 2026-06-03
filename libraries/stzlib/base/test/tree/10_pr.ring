# Narrative
# --------
# pr()
#
# Extracted from stzTreeTest.ring, block #10.

load "../../stzBase.ring"


o1 = new stzList([ "X", [ 1, "Y", 2, [ 3, "X"] ], 4, "Y" ])
o1.DeepRemoveMany([ "X", "Y" ])
? @@( o1.Content() )
#--> [ [ 1, 2, [ 3 ] ], 4 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
