# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #680.

load "../../../stzBase.ring"


o1 = new stzString("BATISTA123")

o1.RemoveNLastChars(3)
? o1.Content()
#--> BATISTA

? StzStringQ("BATISTA123").LastNCharsRemoved(3)
#--> BATISTA

pf()
# Executed in 0.01 second(s).
