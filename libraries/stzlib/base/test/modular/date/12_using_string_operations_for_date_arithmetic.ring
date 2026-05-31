# Narrative
# --------
# Using string operations for date arithmetic
#
# Extracted from stzdatetest.ring, block #12.

load "../../../stzBase.ring"


pr()

oDate = new stzDate("01/01/2025")
? oDate + "2 months"
#--> 01/03/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23
