# Narrative
# --------
# EXAMPLE 5: Multiple Params at Once
#
# Extracted from stzsystemcalldatatest.ring, block #5.

load "../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:FindInFile)
Sy {
	SetParams([
		[:text, "ceo"],
		[:file, "../_data/bank_structure.tszorg"]
	])
	Run()
	? Output()
}

pf()
