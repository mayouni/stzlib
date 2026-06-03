# Narrative
# --------
# TEXT PROCESSING PIPELINE
#
# Extracted from stzsystemcalldatatest.ring, block #26.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

cFile = "data.txt"

# Count words
Sy = new stzSystemCall(:WordCount)
Sy {
	SetParam(:file, cFile)
	Run()
	? "Words: " + Output()
}

# Find and replace
new stzSystemCall(:FindAndReplace) {
	SetParams([
		[:file, cFile],
		[:old, "old_text"],
		[:new, "new_text"]
	])
	Run()
}

# Search in file
new stzSystemCall(:FindInFile) {
	SetParams([
		[:text, "important"],
		[:file, cFile]
	])
	Run()
	? Output()
}

pf()
