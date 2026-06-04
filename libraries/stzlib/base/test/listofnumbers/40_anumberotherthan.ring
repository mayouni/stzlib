# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #40.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"

pr()

o1 = new stzListOfNumbers(1: 10)
? o1.ANumberOtherThan(5)

pf()
