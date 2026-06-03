# Narrative
# --------
# Checking if datetime is between two others (string params) #TODO #ERR
#
# Extracted from stzdatetimetest.ring, block #23.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-17 10:00:00")
? oDateTime.IsBetween("2024-03-15 10:00:00", :And = "2024-03-20 10:00:00")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.24
