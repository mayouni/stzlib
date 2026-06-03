# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #298.

load "../../stzBase.ring"

pr()

o1 = new stzString("Softanza is an acc  elera tive library f   or Ring.")

? @@( o1.FindZZ([ "acc  elera tive", "f   or" ]) )
#--> [ [ 16, 30 ], [ 40, 45 ] ]

o1.RemoveSpacesInSections([ [ 16, 30 ], [ 40, 45 ] ])
? o1.Content()
#--> Softanza ia an accelerative library for Ring.

pf()
# Executed in 0.06 second(s).
