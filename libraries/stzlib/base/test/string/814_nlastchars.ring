# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #814.
#ERR Error (R14) : Calling Method without definition: nlastcharsq

load "../../stzBase.ring"

pr()

o1 = new stzString("مَنْصُورِيَّاتُُ")

? o1.NLastCharsQ(2).IsMadeOfSome([ "ُ", "س", "ص" ])
#--> TRUE

pf()
# Executed in 0.01 second(s).
