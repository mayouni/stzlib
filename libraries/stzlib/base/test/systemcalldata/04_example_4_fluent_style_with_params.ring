# Narrative
# --------
# EXAMPLE 4: Fluent Style with Params
#
# Extracted from stzsystemcalldatatest.ring, block #4.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

StzSystemCallQ(:FindFiles).
	SetParamQ(:pattern, "*.ring").
	RunQ() {
	? Output()
}

pf()
