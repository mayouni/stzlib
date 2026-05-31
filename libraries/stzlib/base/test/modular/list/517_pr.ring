# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #517.

load "../../../stzBase.ring"


o1 = new stzList([ "{", "<", "A", "B", "C", ">", "}" ])

? @@( o1.BoundsUpToNItems(1) ) + NL
#--> [ "{","}" ]

? @@( o1.BoundsUpToNItems(2) )
#--> [ [ "{", "<" ], [ ">", "}" ] ]

pf()
# Executed in almost 0 second(s).
