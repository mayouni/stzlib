# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #28.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"

pr()

? Q("Ringggg") - "ggg"
#--> Ring

? (Q("Ringggg") - Q("ggg")).Content()
#--> A StzString object containg "Ring"

pf()
