# Narrative
# --------
# EXAMPLE 10: Check Disk Space
#
# Extracted from stzsystemcalldatatest.ring, block #10.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:DiskSpace)
? Sy.Run()

pf()
