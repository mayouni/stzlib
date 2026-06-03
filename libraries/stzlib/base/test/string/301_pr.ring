# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #301.

load "../../stzBase.ring"


o1 = new stzString("Ring langua  ge is like a r  ing at your fing er  tips!")

? @@( o1.FindZZ([ "langua  ge", "r  ing", "fing er  tips!" ]) )
#--> [ [ 6, 15 ], [ 27, 32 ], [ 42, 55 ] ]

o1.RemoveSpacesInSections([ [ 6, 15 ], [ 27, 32 ], [ 42, 55 ] ])
? o1.Content()
#--> Ring language is like a ring at your fingertips!

pf()
# Executed in 0.05 second(s) in Ring 1.22
