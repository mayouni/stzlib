# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #574.

load "../../stzBase.ring"

pr()

obj1 = TRUEObject()
obj2 = FALSEObject()

o1 = new stzList([ 5, [ :me, :you ], 4, "tunis", obj2, 3, 7, [ :them, :others ], "cairo", obj1  ])
o1.SortInAscending()
? @@( o1.Content() )
#--> [ 3, 4, 5, 7, "cairo", "tunis", [ "me", "you" ], [ "them", "others" ], @falseobject,  @trueobject ]

pf()
# Executed in 0.03 second(s).
