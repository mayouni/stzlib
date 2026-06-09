# Narrative
# --------
# Creation duration from natural language string
#
# Extracted from stzdurationtest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDuration = new stzDuration("2 hours 30 minutes")
? oDuration.ToHuman()
#--> 2 hours and 30 minutes

# From hash definition
oDuration = new stzDuration([
	:Days = 1,
	:Hours = 3,
	:Minutes = 45,
	:Seconds = 30
])
? oDuration.ToCompact()
#--> 1d 3h 45m 30s

# Quick construction with Q functions
oDur = DurationQ("1 hour 15 minutes")
? oDur.TotalMinutes()
#--> 75

pf()
# Executed in 0.07 second(s) in Ring 1.24
