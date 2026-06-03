# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #537.

load "../../stzBase.ring"


o1 = new stzList([ "a", "b", 3, "c"])
? o1.AllItemsExcept(3)
#--> [ "a", "b", "c" ]

pf()
# Executed in almost 0 second(s).
