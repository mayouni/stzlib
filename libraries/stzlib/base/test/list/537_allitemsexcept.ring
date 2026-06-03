# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #537.
#ERR Error (R14) : Calling Method without definition: allitemsexcept

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", 3, "c"])
? o1.AllItemsExcept(3)
#--> [ "a", "b", "c" ]

pf()
# Executed in almost 0 second(s).
