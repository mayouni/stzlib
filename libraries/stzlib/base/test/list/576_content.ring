# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #576.
#ERR Error (R14) : Calling Method without definition: sortinascending

load "../../stzBase.ring"

pr()

obj1 = TRUEObject()
obj2 = FALSEObject()

o1 = new stzList([ "_", 3, "_" , obj1, "*", 6, [ "L1", "L1" ], 12, obj2, [ "L2", "L2" ], 24, "*" ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ 3, 6, 12, 24, "*", "*", "_", "_", [ "L1", "L1" ], [ "L2", "L2" ], @trueobject, @falseobject ]

pf()
# Executed in 0.03 second(s).
