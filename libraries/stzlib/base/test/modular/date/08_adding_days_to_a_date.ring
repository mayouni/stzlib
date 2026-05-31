# Narrative
# --------
# Adding days to a date
#
# Extracted from stzdatetest.ring, block #8.

load "../../../stzBase.ring"


pr()

oDate = StzDateQ("01/01/2025")
oDate.AddDays(30)
? oDate.Date()
#--> 31/01/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23
