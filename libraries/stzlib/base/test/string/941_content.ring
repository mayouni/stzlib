# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #941.

load "../../stzBase.ring"

pr()

o1 = new stzList( @Chars("SOFTANZA") )
o1.InsertAfterPositions([ 2, 4, 6, 8 ], "~")
? @@( o1.Content() )
#--> [ "S", "O", "~", "F", "T", "~", "A", "N", "~", "Z", "A" ]

pf()
# Executed in 0.01 second(s).
