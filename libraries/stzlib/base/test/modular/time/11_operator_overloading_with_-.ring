# Narrative
# --------
# Operator overloading with -
#
# Extracted from stztimetest.ring, block #11.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("10:00:00")
oTime - 1800  # Subtract 30 minutes (1800 seconds)
? oTime.Content()
#--> 09:30:00

pf()
