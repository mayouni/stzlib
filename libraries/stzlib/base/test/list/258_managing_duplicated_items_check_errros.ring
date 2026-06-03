# Narrative
# --------
# MANAGING DUPLICATED ITEMS: Check errros
#
# Extracted from stzlisttest.ring, block #258.

load "../../stzBase.ring"


pr()

o1 = new stzList([ 5, 7, 5, 5, 4, 7, 1 ])

? o1.Duplicates()
#--> [5, 7]

? o1.FindDuplicates()
#--> [3, 4, 6]

pf()
# Executed in 0.05 second(s)
