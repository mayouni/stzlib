# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #227.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "♥", "♥", "♥", 3, 4 ])

? o1.ExtractSection(3, 5)
#--> ["♥", "♥", "♥"]

? o1.Content()
#--> [1, 2, 3, 4]

pf()
# Executed in 0.02 second(s)
