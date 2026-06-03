# Narrative
# --------
# o1 = new stzListOfStrings([ "name", "اسم", "姓名" ])
#
# Extracted from stzlistofstringstest.ring, block #13.

load "../../stzBase.ring"

pr()

o1.RemoveAt(2)
? @@(o1.Content())
#--> [ "name", "姓名" ]

pf()
