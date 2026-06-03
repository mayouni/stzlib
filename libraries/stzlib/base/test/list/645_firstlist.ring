# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #645.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", 1:3, "C", "D", 4:5 ])
? o1.FirstList()
#--> [ 1, 2, 3 ]

? o1.FindFirstList()
#--> 3

pf()
# Executed in almost 0 second(s).
