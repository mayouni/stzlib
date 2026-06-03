# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #392.
#ERR Error (R14) : Calling Method without definition: commonsubstrings

load "../../stzBase.ring"

pr()

o1 = new stzString("ab")
? @@( o1.CommonSubStrings(:With = "abc") )
#--> [ "a", "ab", "b" ]

pf()
# Executed in 0.08 second(s)
