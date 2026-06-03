# Narrative
# --------
# High Precision Duration
#
# Extracted from stzdurationtest.ring, block #12.

load "../../stzBase.ring"


pr()

oPrecise = new stzDuration([
	:Hours = 1,
	:Minutes = 23,
	:Seconds = 45,
	:Milliseconds = 678
])

? oPrecise.ToStringXT("HH:mm:ss.zzz")
#--> 01:23:45.678

? oPrecise.Milliseconds()
#--> 678

? oPrecise.TotalSeconds()
#--> 5025

pf()
# Executed in almost 0 second(s) in Ring 1.24
