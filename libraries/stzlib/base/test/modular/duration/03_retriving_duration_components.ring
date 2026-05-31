# Narrative
# --------
# Retriving duration components
#
# Extracted from stzdurationtest.ring, block #3.

load "../../../stzBase.ring"


pr()

oDuration = new stzDuration("2 days 5 hours 30 minutes 45 seconds")

? oDuration.Days()
#--> 2

? oDuration.Hours()
#--> 5

? oDuration.Minutes()
#--> 30

? oDuration.Seconds()
#--> 45

# Total conversions
? oDuration.TotalHours()
#--> 53

? oDuration.TotalMinutes()
#--> 3210

? oDuration.TotalSeconds()
#--> 192645

# Get all components as hash
? @@NL( oDuration.Components() )
#--> [ :Days = 2, :Hours = 5, :Minutes = 30, :Seconds = 45, :Milliseconds = 0 ]

pf()
# Executed in 0.07 second(s) in Ring 1.24
