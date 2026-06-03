# Narrative
# --------
# Checking if datetime is tomorrow/yesterday
#
# Extracted from stzdatetimetest.ring, block #30.

load "../../stzBase.ring"


pr()

o1 = StzDateTimeQ('')
o1 + "1 day"
? o1.IsTomorrow()
#--> TRUE

o2 = StzDateTimeQ('')
o2 - "1 day"
? o2.IsYesterday()
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23
