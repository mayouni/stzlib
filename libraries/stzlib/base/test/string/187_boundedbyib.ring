# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #187.

load "../../stzBase.ring"

pr()

o1 = new stzString("...<<♥♥♥>>...<<★★>>...")

? o1.BoundedByIB([ "<<", ">>" ])
#--> [ "<<♥♥♥>>", "<<★★>>" ]

? o1.BoundedByIBZZ([ "<<", ">>" ])
#--> [
#	[ "<<♥♥♥>>", [ 4, 10 ] ],
#	[ "<<★★>>", [ 14, 19 ] ]
# ]

pf()
# Executed in 0.01 second(s)
