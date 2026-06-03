# Narrative
# --------
# Calculating Age
#
# Extracted from stzdatetest.ring, block #26.
# @clock 2025-09-27 00:00:00

load "../../stzBase.ring"


pr()

# Traditional approach requires complex date math
# stzDate approach
oBirthday = StzDateQ("15/06/1990")
? oBirthday.Age()  # Automatic calculation
#--> 35

pf()
# Executed in almost 0 second(s) in Ring 1.23
