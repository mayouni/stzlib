# Narrative
# --------
# Copy and Clone
#
# Extracted from stzdurationtest.ring, block #14.

load "../../../stzBase.ring"


pr()

oOriginal = DurationQ("2 hours 30 minutes")
oCopy = oOriginal.Copy()

oCopy.AddMinutes(15)

# Original
? oOriginal.ToHuman()
#--> 2 hours and 30 minutes

# Copy (modified)
? oCopy.ToHuman()
#--> 2 hours and 45 minutes

oClone = oOriginal.Clone()
? oClone.ToHuman()
#--> 2 hours and 30 minutes

pf()
# Executed in 0.04 second(s) in Ring 1.24
