# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #458.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c" ])
? @@( o1 - These([ "b", "a" ]))
#--> [ "c" ]

pf()
# Executed in almost 0 second(s).
