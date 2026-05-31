# Narrative
# --------
# Calling Today() and Creating a date object from today
#
# Extracted from stzdatetest.ring, block #1.

load "../../../stzBase.ring"


pr()

? Today()
#--> 27/09/2025

oDate = TodayQ()
? oDate.Date() # Or ToString()
#--> 27/09/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23
