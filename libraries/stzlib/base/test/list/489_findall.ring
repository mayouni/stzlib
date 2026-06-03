# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #489.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 122, 67, 120, 58, 101, 120 ])

? o1.FindAll(120)
#--> [ 3, 6 ]

? o1.NumberOfOccurrence(120)
#--> 2

pf()
# Executed in 0.01 second(s).
