# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #558.

load "../../stzBase.ring"

pr()

o1 = new stzSplitter(5)

? @@( o1.SplitBeforePositions([ 1, 6 ]) )
#--> ERROR: Incorrect param value!
# panPos must contain unique numbers between 1 and 5.

pf()
