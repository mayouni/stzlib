# Narrative
# --------
# pr()
#
# Extracted from stzdurationtest.ring, block #8.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


oDuration = new stzDuration("3 hours 25 minutes 42 seconds")

# Default format (H:mm:ss)
? oDuration.ToString()
#--> 3:25:42

# Custom formats
? oDuration.ToStringXT("HH:mm:ss")
#--> 03:25:42

? oDuration.ToStringXT("H hours, m minutes")
#--> 3 hours, 25 minutes

# Human-readable
? oDuration.ToHuman()
#--> 3 hours, 25 minutes, and 42 seconds

# Compact notation
? oDuration.ToCompact()
#--> 3h 25m 42s

# Simple time format
? oDuration.ToSimple()
#--> 3:25:42

pf()
# Executed in 0.04 second(s) in Ring 1.24


pr()

oDuration = new stzDuration("1 hour")

oDuration.AddMinutes(30)
? oDuration.ToHuman()
#--> 1 hour and 30 minutes

oDuration.AddHours(2)
? oDuration.ToHuman()
#--> 3 hours and 30 minutes

oDuration.Subtract("30 minutes")
? oDuration.ToHuman()
#--> 3 hours

# Chaining modifications
oDuration = DurationQ("1 hour")
oDuration {
	AddMinutes(45)
	AddSeconds(30)
	? ToHuman()
}
#--> 1 hour, 45 minutes, and 30 seconds

pf()
# Executed in 0.03 second(s) in Ring 1.24
