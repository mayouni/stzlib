# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #669.

load "../../../stzBase.ring"


o1 = new stzString("....00000")

? @@( o1.FindTrailingChars() )
#--> [ 5, 6, 7, 8, 9 ]

? @@( o1.FindTrailingCharsZZ() )
#--> [ 5, 9 ]

pf()
# Executed in 0.01 second(s).
