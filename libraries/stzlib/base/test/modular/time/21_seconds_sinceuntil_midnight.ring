# Narrative
# --------
# Seconds since/until midnight
#
# Extracted from stztimetest.ring, block #21.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("12:30:45")
? oTime.SecondsSinceMidnight()
#--> 45045

? oTime.SecondsUntilMidnight()
#--> 41355

pf()
# Executed in almost 0 second(s) in Ring 1.23
