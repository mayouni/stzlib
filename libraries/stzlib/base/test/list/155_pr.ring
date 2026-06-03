# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #155.

load "../../stzBase.ring"

pr()

o1 = new stzList(1 : 3)
o1.ExtendToWithItemsRepeated(8)
o1.Show()
#--> [ 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2 ]

pf()
# Executed in 0.03 second(s)
