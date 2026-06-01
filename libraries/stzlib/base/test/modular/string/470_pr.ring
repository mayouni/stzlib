# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #470.

load "../../../stzBase.ring"


str = "sun"
? Q(str).IsEither("moon", :Or = "sun")
#--> TRUE

pf()
# Executed in 0.01 second(s).
