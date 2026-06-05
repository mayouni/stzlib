# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #190.

load "../../stzBase.ring"

pr()

o1 = new stzString("_♥♥\__/♥\__/♥\_")
o1.ReplaceXT(:First, "♥", :With = "/")
? o1.Content()
#--> _/♥\__/♥\__/♥\__/♥\_

pf()
#--> Executed in 0.01 second(s)
