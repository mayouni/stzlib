# Narrative
# --------
# EXAMPLE 14: Direct Program Call (Original Style)
#
# Extracted from stzsystemcalldatatest.ring, block #14.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

# Still works - not using syscmd()
Sy = new stzSystemCall("cmd.exe")
Sy {
	SetArgs(["/c", "echo", "Direct call"])
	Run()
	? Output()
}

pf()

# load "stzlib.ring"   # stzBase.ring at top already loads the library
