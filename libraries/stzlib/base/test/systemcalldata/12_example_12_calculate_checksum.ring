# Narrative
# --------
# EXAMPLE 12: Calculate Checksum
#
# Extracted from stzsystemcalldatatest.ring, block #12.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:Sha256sum)
Sy {
	SetParam(:file, "test.txt")
	Run()
	? Output()
}

pf()
