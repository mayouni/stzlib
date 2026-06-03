# Narrative
# --------
# Validating datetime strings
#
# Extracted from stzdatetimetest.ring, block #32.

load "../../stzBase.ring"


pr()

? IsDateTime("2024-03-15 10:00:00")
#--> TRUE

? IsDateTime("2024-03-15T10:00:00")
#--> TRUE

? IsDateTime("invalid")
#--> FALSE

? IsValidDateTime("2024-03-15 10:00:00")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.24
