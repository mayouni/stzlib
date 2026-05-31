# Narrative
# --------
# Working with milliseconds
#
# Extracted from stztimetest.ring, block #31.

load "../../../stzBase.ring"


pr()

oTime = new stzTime([:Hour = 14, :Minute = 30, :Second = 45, :Millisecond = 123])
? oTime.Millisecond()
#--> 123

? oTime.ToLong()
#--> 14:30:45.123

pf()
# Executed in almost 0 second(s) in Ring 1.23
