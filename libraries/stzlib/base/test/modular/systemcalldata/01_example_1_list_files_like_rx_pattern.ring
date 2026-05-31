# Narrative
# --------
# EXAMPLE 1: List Files (Like Rx pattern)
#
# Extracted from stzsystemcalldatatest.ring, block #1.

load "../../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:ListFiles)
Sy.Run()
? Sy.Output()

pf()
