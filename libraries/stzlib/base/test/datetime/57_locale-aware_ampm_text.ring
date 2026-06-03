# Narrative
# --------
# Locale-aware AM/PM text
#
# Extracted from stzdatetimetest.ring, block #57.

load "../../stzBase.ring"


pr()

# Assumes stzLocale returns locale-specific AM/PM

Lc = new stzLocale("")
? Lc.amText() #--> AM
? Lc.pmText() #--> PM

oDateTime = StzDateTimeQ("2024-03-15 14:30:00")
? oDateTime.ToSimple()
#--> 15/03/2024 2:30 PM

pf()
# Executed in 0.01 second(s) in Ring 1.24
