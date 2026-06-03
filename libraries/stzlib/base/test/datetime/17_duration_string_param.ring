# Narrative
# --------
# Duration (string param) #TODO #ERR
#
# Extracted from stzdatetimetest.ring, block #17.

load "../../stzBase.ring"


pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
? oDateTime1.DurationTo("2024-03-20 14:30:15", :InMinutes)
#--> 7470.25

pf()
# Executed in 0.01 second(s) in Ring 1.24
