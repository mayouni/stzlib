# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #427.

load "../../stzBase.ring"

pr()

o1 = new stzString("..._...__...___...")
? @@( o1.FindALL("_") )
#--> [ 4, 8, 9, 13, 14, 15 ]

? @@( o1.FindSubstringsMadeOfZZ("_") )
#--> [ [ 4, 4 ], [ 8, 9 ], [ 13, 15 ] ]

? o1.SubStringsMadeOf("_")
#--> [ "_", "__", "___" ]

pf()
# Executed in 0.05 second(s) in Ring 1.22
