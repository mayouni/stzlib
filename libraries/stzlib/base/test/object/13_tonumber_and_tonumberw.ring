# Narrative
# --------
# ToNumber() and ToNumberW()
#
# Extracted from stzObjectTest.ring, block #13.

load "../../stzBase.ring"


pr()

? Q(5).ToNumber()
#--> 5

? Q("5").ToNumber()
#--> 5

? Q([ "a", "b", "c" ]).ToNumber()
#--> 3

pf()
# Executed in 0.03 second(s)
