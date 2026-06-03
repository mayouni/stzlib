# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #532.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])

o1.ReplaceAt([2, 5], "♥")	# Or ReplaceAnyAt()
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", "♥" ]

o1.ReplaceThisAt(3, "♥", 3)
? @@( o1.Content() )
#--> [ "♥", "♥", 3, "♥", "♥" ]

pf()
# Executed in almost 0 second(s).
