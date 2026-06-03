# Narrative
# --------
# BATCH FILE OPERATIONS
#
# Extracted from stzsystemcalldatatest.ring, block #23.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

# Find all large files
Sy = new stzSystemCall(:FindLargeFiles)
Sy {
	SetParam(:size, "100M")
	Run()
	aLargeFiles = split(Output(), NL)
	? "Found " + len(aLargeFiles) + " large files"
}

# Compress to archive
new stzSystemCall(:ZipFiles) {
	SetParams([
		[:source, "project/"],
		[:dest, "project_backup.zip"]
	])
	Run()
}

pf()
