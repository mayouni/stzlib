# Narrative
# --------
# The (*) operator repeats a list's items in place.
#
# o1 holds a single 0; multiplying by 3 grows it to three 0s, which Show()
# then prints. (The extracted file had lost its `o1 = Q([0])` setup line;
# restored here.)
#
# Extracted from stzlisttest.ring, block #145.

load "../../stzBase.ring"

pr()

o1 = Q([0])
o1 * 3
o1.Show()
#--> [ 0, 0, 0 ]

pf()
