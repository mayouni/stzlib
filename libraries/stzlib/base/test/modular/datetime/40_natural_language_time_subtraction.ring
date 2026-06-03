# Narrative
# --------
# Natural language time subtraction
#
# Extracted from stzdatetimetest.ring, block #40.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime.SubtractNatural("1 day 2 hours")
? oDateTime.ToString()
#--> 2024-03-14 08:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
