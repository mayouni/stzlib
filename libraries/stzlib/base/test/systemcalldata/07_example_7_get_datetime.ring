# Narrative
# --------
# EXAMPLE 7: Get Date/Time
#
# Extracted from stzsystemcalldatatest.ring, block #7.

load "../../stzBase.ring"

==========================================

pr()

StzSystemCallQ(:CurrentDate) { ? Run() ? Output() }
StzSystemCallQ(:CurrentTime) { Run() ? Output() }

pf()
