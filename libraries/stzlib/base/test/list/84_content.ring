# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #84.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "♥", 1, 2, 2, "♥", "♥", 3 ])
o1.RemoveAllExcept("♥") # Or RemoveItemsOtherThan()

? @@( o1.Content() )
#--> [ "♥", "♥", "♥" ]

pf()
# Executed in 0.04 second(s)
