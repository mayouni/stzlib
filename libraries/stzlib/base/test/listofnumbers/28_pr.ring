# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #28.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

? Q("Ringggg") - "ggg"
#--> Ring

? (Q("Ringggg") - Q("ggg")).Content()
#--> A StzString object containg "Ring"

pf()
