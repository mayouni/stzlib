# Narrative
# --------
# Relative time description
#
# Extracted from stzdatetimetest.ring, block #28.

load "../../stzBase.ring"


pr()

o1 = new stzDateTime('')
o1 - "2 hours"
? o1.Content()
? o1.ToRelative()
#--> 2 hours ago

oFuture = StzDateTimeQ('') + "3 days"
? oFuture.ToRelative()
#--> in 3 days

pf()
# Executed in 0.01 second(s) in Ring 1.23
