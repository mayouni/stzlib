# Narrative
# --------
# Start and end of hour
#
# Extracted from stztimetest.ring, block #24.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("10:45:30")

? oTime.StartOfHour()
#--> 10:00:00

? oTime.EndOfHour()
#--> 10:59:59

? oTime.Content()
#--> 10:45:30

pf()
# Executed in almost 0 second(s) in Ring 1.23
