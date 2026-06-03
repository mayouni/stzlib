# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #392.

load "../../stzBase.ring"


o1 = new stzString("ab")
? @@( o1.CommonSubStrings(:With = "abc") )
#--> [ "a", "ab", "b" ]

pf()
# Executed in 0.08 second(s)
