# Narrative
# --------
# EXAMPLE 4: Fluent Style with Params
#
# Extracted from stzsystemcalldatatest.ring, block #4.

load "../../../stzBase.ring"

==========================================

pr()

StzSystemCallQ(:FindFiles).
	SetParamQ(:pattern, "*.ring").
	RunQ() {
	? Output()
}

pf()
