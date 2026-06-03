# Narrative
# --------
# EXAMPLE 7: Get Date/Time
#
# Extracted from stzsystemcalldatatest.ring, block #7.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

StzSystemCallQ(:CurrentDate) { ? Run() ? Output() }
StzSystemCallQ(:CurrentTime) { Run() ? Output() }

pf()
