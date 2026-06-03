# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #592.

load "../../stzBase.ring"


o1 = new stzList( [ "A", "B", [ 1, "v", 2 ], "X" ] )

? o1.ContainsNo("v")
#--> TRUE

? o1.ContainsNoObjects()
#--> TRUE

? @@( o1.Flattened() ) # can also be written: o1.FlattenQ().Content()
#--> [ "A", "B", 1, "v", 2, "X" ]

pf()
# Executed in almost 0 second(s).
