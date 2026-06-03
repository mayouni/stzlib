# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #491.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "H", " ", "E", " ", "L", " ", "L", " ", "O" ])
? @@( o1.FindEmptyStrings() )
#--> []

? o1.FindSpaces()
#--> [ 2, 4, 6, 8 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
