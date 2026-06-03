# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #532.
#ERR Error (R21) : Using operator with values of incorrect type

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
