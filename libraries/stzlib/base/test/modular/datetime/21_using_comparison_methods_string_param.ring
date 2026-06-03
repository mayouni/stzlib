# Narrative
# --------
# Using comparison methods (string param) #TODO #ERR
#
# Extracted from stzdatetimetest.ring, block #21.

load "../../../stzBase.ring"


pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")

? oDateTime1.IsBefore("2024-03-20 10:00:00")
#--> TRUE

? oDateTime1.IsAfter("2024-03-20 10:00:00")
#--> FALSE

? oDateTime1.IsEqualTo("2024-03-15 10:00:00")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.24
