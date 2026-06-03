# Narrative
# --------
# EXAMPLE 6: Ping Host
#
# Extracted from stzsystemcalldatatest.ring, block #6.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:Ping)
Sy {
	SetParam(:host, "google.com")
	Run()
	? Output()
}

pf()
