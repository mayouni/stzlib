# Narrative
# --------
# EXAMPLE 2: With Braces Syntax
#
# Extracted from stzsystemcalldatatest.ring, block #2.

load "../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:SystemInfo)
Sy {
	Run()
	? Output()
}

pf()
