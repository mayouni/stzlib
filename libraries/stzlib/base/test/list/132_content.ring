# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #132.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])
o1.RemoveDuplicates()
? @@(o1.Content())
#--> [ "A", "B", "2", 2, "." ]

pf()
# Executed in almost 0 second(s).
