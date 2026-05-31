# Narrative
# --------
# Getting current date and time
#
# Extracted from stzdatetest.ring, block #7.

load "../../../stzBase.ring"


pr()

? Now() # Default format
#--> 27/09/2025 14:30:25

? NowXT() # ISO format
#--> 2025-26-10 14:26:38

pf()
# Executed in almost 0 second(s) in Ring 1.23
