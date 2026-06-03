# Narrative
# --------
# Getting current datetime with NowXT()
#
# Extracted from stzdatetimetest.ring, block #1.

load "../../stzBase.ring"


pr()

? NowXT()
#--> 2025-30-04 21:30:44

? NowDateTime()
#--> 2025-30-04 21:30:44

oDateTime = StzDateTimeQ("")
? oDateTime.DateTime() # Or Content() or ToString()
#--> 2025-10-04 21:30:44.668

pf()
# Executed in almost 0 second(s) in Ring 1.24
