# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #25.

load "../../../stzBase.ring"


o1 = new stzString("ring---")

? o1.RightCharRemoved()
#--> ring--

? o1.CharRemovedFromRight("*")
#--> ring---

? o1.CharRemovedFromRight("-")
#--> ring--

? o1.CharRemovedFromRightXT("*")
#--> ring---

? o1.CharRemovedFromRightXT("-")
#--> ring

? o1.CharTrimmedFromRight("-")
#--> ring--

pf()
# Executed in 0.01 second(s)
