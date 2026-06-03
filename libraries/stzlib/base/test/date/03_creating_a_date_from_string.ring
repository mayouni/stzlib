# Narrative
# --------
# Creating a date from string
#
# Extracted from stzdatetest.ring, block #3.

load "../../stzBase.ring"


pr()

oDate = StzDateQ("15/03/2024") # Or 2024-03-15
? oDate.Date()
#--> 15/03/2024		# Format by deafult, can be changed

pf()
# Executed in almost 0 second(s) in Ring 1.23
