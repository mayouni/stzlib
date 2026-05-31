# Narrative
# --------
# EXAMPLE 8: Create Directory
#
# Extracted from stzsystemcalldatatest.ring, block #8.

load "../../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:MakeDir)
Sy {
	SetParam(:path, "test_folder")
	Run()
	
	? "Exit code: " + ExitCode()
	? "Success: " + Succeeded()
}

pf()
