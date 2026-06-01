# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #823.

load "../../../stzBase.ring"


o1 = new stzString("Ring language")

o1.InsertBefore("language", "programming ")
? o1.Content()
# Ring programming language

pf()
# Executed in 0.01 second(s) in Ring 1.22

*------

pr()

o1 = new stzString("Ring language")

o1.InsertAfter("Ring", " programming")
? o1.Content()
# Ring programming language

pf()
# Executed in 0.01 second(s) in Ring 1.22

pf()
# Executed in 0.09 second(s).
