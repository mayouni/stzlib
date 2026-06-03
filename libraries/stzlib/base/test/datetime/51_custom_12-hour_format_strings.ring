# Narrative
# --------
# Custom 12-hour format strings
#
# Extracted from stzdatetimetest.ring, block #51.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToStringXT("dd/MM/yyyy h:mm AP")
#--> 15/03/2024 2:30 PM

? oDateTime.ToStringXT("MM-dd-yyyy h:mm:ss AP")
#--> 03-15-2024 2:30:45 PM

? oDateTime.ToStringXT("dddd h:mm AP")
#--> Friday 2:30 PM

pf()
# Executed in 0.01 second(s) in Ring 1.24
