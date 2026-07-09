# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #636.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "b", "b", "c" ])
//? @@( o1 - these([ "b", "b" ]) )
#--> [ "a", "c" ]

? @@( o1.DifferenceWith([ "a", "c" ]) )
#--> [ "b", "b", "b" ]

pf()
# Executed in almost 0 second(s).
