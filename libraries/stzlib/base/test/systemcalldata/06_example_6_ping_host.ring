# Narrative
# --------
# EXAMPLE 6: Ping Host
#
# Extracted from stzsystemcalldatatest.ring, block #6.

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
