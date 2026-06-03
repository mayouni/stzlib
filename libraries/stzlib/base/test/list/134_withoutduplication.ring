# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #134.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])
? @@( o1.Withoutduplication() ) # Or ToSet()
#--> [ "A", "B", "2", 2, "." ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19
