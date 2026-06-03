# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #300.
#ERR Error (R14) : Calling Method without definition: removespacesinsections

load "../../stzBase.ring"

pr()

o1 = new stzString("R  in  g language is like a r  ing at your fingertips!")

? o1.Sections([ [ 1, 8 ], [ 29, 34 ] ])
#--> [ "R  in  g", "r  ing" ]

o1.RemoveSpacesInSections([ [ 1, 8 ], [ 29, 34 ] ])
? o1.Content()
#--> "Ring language is like a ring at your fingertips!"

pf()
# Executed in 0.02 second(s).
