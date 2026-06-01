# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #898.

load "../../../stzBase.ring"


o1 = new stzString("123SOFTANZA12345")

o1.RemoveNCharsLeft(3)
? o1.Content()
#--> SOFTANZA12345

o1.RemoveNCharsRight(5)
? o1.Content()
#--> SOFTANZA

pf()
# Executed in 0.01 second(s).
