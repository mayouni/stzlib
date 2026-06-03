# Narrative
# --------
# PACKAGE INSTALLATION
#
# Extracted from stzsystemcalldatatest.ring, block #25.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

# Install Python package
new stzSystemCall(:PipInstall) {
	SetParam(:package, "requests")
	Run()
	? Output()
}

# Install Node package
new stzSystemCall(:NpmInstall) {
	SetParam(:package, "express")
	Run()
}

pf()
