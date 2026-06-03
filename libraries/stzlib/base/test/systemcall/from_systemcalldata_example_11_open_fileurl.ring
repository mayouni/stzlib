# Narrative
# --------
# EXAMPLE 11: Open File/URL
#
# Extracted from stzsystemcalldatatest.ring, block #11.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

new stzSystemCall(:OpenFile) {
	SetParam(:file, "document.pdf")
	RunSilently()
}

new stzSystemCall(:OpenUrl) {
	SetParam(:url, "https://softanza.com")
	RunSilently()
}

? "Opened!"

pf()
