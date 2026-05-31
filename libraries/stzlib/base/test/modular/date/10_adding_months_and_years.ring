# Narrative
# --------
# Adding months and years
#
# Extracted from stzdatetest.ring, block #10.

load "../../../stzBase.ring"


pr()

oDate = StzDateQ("15/06/2024")
oDate { AddMonths(3) AddYears(1) ? ToString() }
#--> 15/09/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23
