# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #912.

load "../../stzBase.ring"

pr()

o1 = new stzString("Hello dear!")
o1.InsertBefore("my ", "dear")
? o1.Content()
# Hello my dear!

o1.InsertAfter(" friend", "dear")
? o1.Content()
# Hello my dear friend!

pf()
# Executed in 0.01 second(s).
