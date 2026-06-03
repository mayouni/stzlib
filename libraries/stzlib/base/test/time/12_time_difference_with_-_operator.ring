# Narrative
# --------
# Time difference with - operator
#
# Extracted from stztimetest.ring, block #12.

load "../../stzBase.ring"


pr()

oTime1 = new stzTime("14:00:00")
oTime2 = new stzTime("10:00:00")

nSecsDiff = oTime2 - oTime1
? nSecsDiff
#--> -14400  # 4 hours = 14400 seconds (negative because oTime2 is earlier)

pf()
# Executed in almost 0 second(s) in Ring 1.23
