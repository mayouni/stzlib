# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #95.
#ERR Error (R14) : Calling Method without definition: stringifylowercaseandreplace

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "r_INg", 2, "R_ng", 3, "R_ING" ])
o1.StringifyLowercaseAndReplace("_", :With = AHeart())
o1.Show()
#--> [ "1", "r♥ing", "2", "r♥ng", "3", "r♥ing" ]

pf()
# Executed in 0.03 second(s)
