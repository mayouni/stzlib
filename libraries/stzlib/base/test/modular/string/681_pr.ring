# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #681.

load "../../../stzBase.ring"


o1 = new stzString("BATISTA1")
o1.RemoveLastChar()
? o1.Content()
#--> BATISTA

? StzStringQ("BATISTA1").LastCharRemoved()
#--> BATISTA

pf()
# Executed in 0.01 second(s) in Ring 1.22
