# Narrative
# --------
# Format consistency across operations
#
# Extracted from stzdatetimetest.ring, block #56.

load "../../../stzBase.ring"


pr()

oDT = StzDateTimeQ("2024-03-15 08:30:00")

? oDT.ToString12h()
#--> 2024-03-15 8:30:00 AM

oDT.AddHours(6)
? oDT.ToString12h()
#--> 2024-03-15 2:30:00 PM (crossed noon)

oDT.AddHours(12)
? oDT.ToString12h()
#--> 2024-03-16 2:30:00 AM (crossed midnight)

pf()
# Executed in 0.01 second(s) in Ring 1.24
