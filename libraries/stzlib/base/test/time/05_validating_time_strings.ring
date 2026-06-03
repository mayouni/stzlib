# Narrative
# --------
# Validating time strings
#
# Extracted from stztimetest.ring, block #5.

load "../../stzBase.ring"


pr()

? IsTime("14:30:00")
#--> TRUE

? IsTime("2:3 PM")  #TODO ERROR
#--> TRUE

? IsTime("25:00:00")
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.23
