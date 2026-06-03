# Narrative
# --------
# Edge Cases
#
# Extracted from stzdurationtest.ring, block #15.

load "../../stzBase.ring"


pr()

# Empty/null duration
oEmpty = DurationQ("")
? oEmpty.IsZero() + NL
#--> TRUE

# Very large duration
oLarge = DurationQ("365 days")
? oLarge.ToHuman()
? oLarge.TotalHours() + NL

# Single unit durations
oOneSecond = DurationQ("1 second")
? oOneSecond.ToHuman()
#--> 1 second

oOneMinute = DurationQ("1 minute")
? oOneMinute.ToHuman()
#--> 1 minute

oOneHour = DurationQ("1 hour")
? oOneHour.ToHuman()
#--> 1 hour

oOneDay = DurationQ("1 day")
? oOneDay.ToHuman()
#--> 1 day

pf()
# Executed in 0.06 second(s) in Ring 1.24
