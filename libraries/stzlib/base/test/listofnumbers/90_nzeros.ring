# Narrative
# --------
# NZeros(n) is the "give me a vector of n zeros" helper, the
# numeric counterpart to NStrings("", n). Used widely as the
# initialiser for histogram / counter / matrix-row scratch
# arrays.
#
# Extracted from stzlistofnumberstest.ring, the NZeros block.

load "../../stzBase.ring"

pr()

? NZeros(5)
#--> [ 0, 0, 0, 0, 0 ]

pf()
