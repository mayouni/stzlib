# Narrative
# --------
# EXAMPLE 9: Download File
#
# Extracted from stzsystemcalldatatest.ring, block #9.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:DownloadFile)
Sy {
	SetParams([
		[:url, "https://example.com/file.txt"],
		[:file, "downloaded.txt"]
	])
	Run()
	
	if Succeeded()
		? "Download complete!"
	ok
}

pf()
