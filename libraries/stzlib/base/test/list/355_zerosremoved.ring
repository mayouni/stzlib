# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #355.
#ERR Error (R14) : Calling Method without definition: zerosremoved

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", 0, 0, "B", "C", 0, "D", 0, 0 ])
? o1.ZerosRemoved()
#--> [ "A", "B", "C", "D" ]

pf()
# Executed in almost 0 second(s).
