# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #24.

load "../../../stzBase.ring"


o1 = new stzString("---ring")

? o1.LeftCharRemoved()
#--> --ring

? o1.CharRemovedFromLeft("*")
#--> ---ring

? o1.CharRemovedFromLeft("-")
#--> --ring

? o1.CharRemovedFromLeftXT("*")
#--> ---ring

? o1.CharRemovedFromLeftXT("-")
#--> ring

? o1.CharTrimmedFromLeft("-")
#--> --ring

pf()
# Executed in 0.01 second(s)
