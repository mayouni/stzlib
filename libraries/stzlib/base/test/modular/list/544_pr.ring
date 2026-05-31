# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #544.

load "../../../stzBase.ring"



obj1 = TRUEObject()
obj2 = FALSEObject()

o1 = new stzList([ "a", 1, 3, "b", ["A1", "A2"], obj1, "c", 3, [ "B1", "B2" ], obj2 ])

? o1.OnlyStrings()
#--> [ "a", "b", "c" ]

? o1.OnlyNumbers()
#--> [ 1, 3, 3 ]

? o1.OnlyLists()
#--> [ "A1", "A2", "B1", "B2" ]

? o1.OnlyObjects()
#--> The two objects o1 and o2 printed in the console:
#
# @oobject: NULL
# @cvarname: @trueobject
#
# @oobject: NULL
# @cvarname: @falseobject

pf()
# Executed in almost 0 second(s).
