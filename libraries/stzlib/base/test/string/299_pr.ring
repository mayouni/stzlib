# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #299.

load "../../stzBase.ring"


o1 = new stzString("Sof tan za is an acc  elera tive library for Rin g .")

? @@( o1.FindZZ([ "Sof tan za", "acc  elera tive", "Rin g ." ]) )
#--> [ [ 1, 10 ], [ 18, 32 ], [ 46, 52 ] ]

o1.RemoveSpacesInSections([ [ 1, 10 ], [ 18, 32 ], [ 46, 52 ] ])
? o1.Content()
#--> Softanza is an accelerative library for Ring.

pf()
# Executed in 0.06 second(s).
