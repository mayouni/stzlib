# Narrative
# --------
# #narration HOW TO RETRIVE A NAMED OBJECT USING v()
#
# Extracted from stzlisttest.ring, block #412.

load "../../stzBase.ring"


pr()

o1 = StzNamedStringQ(:mystr = "Hello!")

? v(:mystr).Content()
#--> "Hello!"

o2 = StzNamedListQ(:mylst = 1:3 )
? v(:mylst).Content()
#--> [ 1, 2, 3 ]

pf()
# Executed in 0.02 second(s).
