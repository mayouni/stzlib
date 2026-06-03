# Narrative
# --------
# Example 18: Natural with atomic age
#
# Extracted from stzdatetimetest.ring, block #79.

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime("79 years 2 months counting from atomic age")
? oDateTime.Content()
#--> 2049-02-10 21:00:00

pf()
# Executed in 0.01 second(s) in Ring 1.24
