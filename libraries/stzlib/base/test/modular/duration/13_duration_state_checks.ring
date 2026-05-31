# Narrative
# --------
# Duration State Checks
#
# Extracted from stzdurationtest.ring, block #13.

load "../../../stzBase.ring"


pr()

oZero = DurationQ(0)
? oZero.IsZero()
#--> TRUE

oPositive = DurationQ("2 hours")
? oPositive.IsPositive()
#--> TRUE

oNegative = DurationQ(-3600)
? oNegative.IsNegative()
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.24
