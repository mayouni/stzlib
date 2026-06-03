# Narrative
# --------
# Ring's `:` range operator works with negative endpoints too:
# -5:1 enumerates every integer from -5 up through 1.
#
# Extracted from stzrandomtest.ring, the negative-range block.

load "../../stzBase.ring"

pr()

? -5:1
#--> [ -5, -4, -3, -2, -1, 0, 1 ]

pf()
