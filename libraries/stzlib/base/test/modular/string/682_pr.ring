# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #682.

load "../../../stzBase.ring"


o1 = new stzString("123BATISTA")

o1.RemoveNFirstChars(3)
? o1.Content()
#--> BATISTA

? StzStringQ("123BATISTA").FirstNCharsRemoved(3)
#--> BATISTA

pf()
# Executed in 0.01 second(s) in Ring 1.22
