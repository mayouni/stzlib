# Narrative
# --------
# Chaining operations with Q functions
#
# Extracted from stztimetest.ring, block #32.

load "../../../stzBase.ring"


pr()

oTime = StzTimeQ("10:00:00")
? oTime.AddHoursQ(2).AddMinutesQ(30).ToString()
#--> 12:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23
