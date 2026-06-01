# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #816.

load "../../../stzBase.ring"


o1 = new stzString("aabbcaacccbb")

? o1.IsMadeOf([ "aa", "bb", "c" ])
#--> TRUE

? o1.IsMadeOfSome([ "a", "b", "c", "x" ])
#--> TRUE

pf()
# Executed in 0.01 second(s).
