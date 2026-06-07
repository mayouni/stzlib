# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #25.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

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
