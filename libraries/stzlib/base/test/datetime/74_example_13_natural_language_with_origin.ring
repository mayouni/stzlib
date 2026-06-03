# Narrative
# --------
# Example 13: Natural language with origin
#
# Extracted from stzdatetimetest.ring, block #74.

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime("5 years 3 months counting from space age")
? oDateTime.Content()
#--> 1975-04-01 07:00:00

pf()
# Executed in 0.01 second(s) in Ring 1.24
