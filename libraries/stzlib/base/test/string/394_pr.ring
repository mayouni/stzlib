# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #394.

load "../../stzBase.ring"


o1 = new stzString("Ring is nice")
? @@( o1.CommonSubStrings(:With = "I love Ring") )
#--> [ "R", "Ri", "Rin", "Ring", "i", "in", "ing", "n", "ng", "g", " ", "e" ]

pf()
# Executed in 0.64 second(s)
