# Narrative
# --------
# EXAMPLE 3: Copy File with Parameters
#
# Extracted from stzsystemcalldatatest.ring, block #3.

load "../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:CopyFile)
Sy {
	SetParam(:source, "../_data/test.txt")
	SetParam(:dest, "../_data/backup.txt")
	Run()
	
	if Succeeded()
		? "File copied successfully!"
	ok
}

pf()
