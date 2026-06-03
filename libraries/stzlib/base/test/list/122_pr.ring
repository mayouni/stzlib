# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #122.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:18)

o1.Show()
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 ]

o1.ShowShort()
#--> [ 1, 2, 3, " ... ", 16, 17, 18 ]

pf()
# Executed in 0.03 second(s)
