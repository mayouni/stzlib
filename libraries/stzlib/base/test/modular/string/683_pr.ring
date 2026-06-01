# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #683.

load "../../../stzBase.ring"


o1 = new stzString("1BATISTA")

o1.RemoveFirstChar()
? o1.Content()
#--> BATISTA

? StzStringQ("1BATISTA").FirstCharRemoved()
#--> BATISTA

pf()
# Executed in 0.01 second(s) in Ring 1.22
