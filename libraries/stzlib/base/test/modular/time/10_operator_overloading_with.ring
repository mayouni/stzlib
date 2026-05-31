# Narrative
# --------
# Operator overloading with +
#
# Extracted from stztimetest.ring, block #10.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("10:00:00")
oTime + 3600  # Add 1 hour (3600 seconds)
? oTime.Content()
#--> 11:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.23
