# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #562.
#ERR Error (R14) : Calling Method without definition: finditem

load "../../stzBase.ring"

pr()

o1 = new stzList([ "*", "a", "*", "b", "C", "D", "*", "e" ])

? o1.Find("*")
#--> [1, 3, 7]

? o1.FindItem("*")
#--> [1, 3, 7]

? o1.Find(:Item = "*")
#--> [1, 3, 7]

pf()
# Executed in almost 0 second(s) in Ring 1.21
