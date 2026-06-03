# Narrative
# --------
# EXAMPLE 1: List Files (Like Rx pattern)
#
# Extracted from stzsystemcalldatatest.ring, block #1.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:ListFiles)
Sy.Run()
? Sy.Output()

pf()
