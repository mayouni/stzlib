# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #189.

load "../../../stzBase.ring"


o1 = new stzString("_/♥\__/♥\__/♥♥__/♥\_")
o1.ReplaceXT(:Nth = 4, "♥", :With = "\")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

pf()
#--> Executed in 0.01 second(s)
