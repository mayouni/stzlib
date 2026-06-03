# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #531.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "♥", 2, "♥", "♥", 5 ])

o1.ReplaceAt(2, "♥")
? @@( o1.Content() )
#--> [ "♥", "♥", "♥", "♥", 5 ]

pf()
# Executed in almost 0 second(s).
