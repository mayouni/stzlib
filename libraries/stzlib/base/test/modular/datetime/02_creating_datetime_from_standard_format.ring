# Narrative
# --------
# Creating datetime from standard format
#
# Extracted from stzdatetimetest.ring, block #2.

load "../../../stzBase.ring"


pr()

oDateTime = new stzDateTime("2024-03-15 10:30:00")
? oDateTime.Content()
#--> 2024-03-15 10:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23
