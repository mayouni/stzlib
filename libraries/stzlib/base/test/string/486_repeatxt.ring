# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #486.

load "../../stzBase.ring"

pr()

? Q("A").RepeatXTQ(:String, 3).StzType()
#--> "stzstring"

? Q("A").RepeatXTQ(:List, 3).StzType()
#--> "stzlist"

pf()
# Executed in 0.02 second(s).
