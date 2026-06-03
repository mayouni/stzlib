# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #146.

load "../../stzBase.ring"


# Changes the object and returns its content IN THE SAME TIME:

o1 = new stzList([0])
? o1 * 3
#--> [0, 0, 0]

o1.Show()
#--> [ 0, 0, 0 ]

pf()
