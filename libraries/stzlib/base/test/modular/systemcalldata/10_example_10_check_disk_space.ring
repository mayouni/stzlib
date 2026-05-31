# Narrative
# --------
# EXAMPLE 10: Check Disk Space
#
# Extracted from stzsystemcalldatatest.ring, block #10.

load "../../../stzBase.ring"

==========================================

pr()

Sy = new stzSystemCall(:DiskSpace)
? Sy.Run()

pf()
