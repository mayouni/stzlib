# Narrative
# --------
# Operator subtraction to get time difference
#
# Extracted from stzdatetimetest.ring, block #36.

load "../../stzBase.ring"


pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
nSecsDiff = oDateTime1 - "2024-03-15 12:30:00"
? nSecsDiff
#--> 9000 (2.5 hours in seconds)

pf()
# Executed in 0.01 second(s) in Ring 1.24
