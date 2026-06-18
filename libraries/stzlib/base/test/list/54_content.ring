# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #54.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ring", "ring", "ruby", "ring", "python", "ring" ])
o1.ReplaceItemByManyXT("ring", [ "♥", "♥♥" ])
	
? @@( o1.Content() )
#--> [ "♥", "♥♥", "ruby", "♥", "python", "♥♥" ]

pf()
# Executed in 0.02 second(s)
