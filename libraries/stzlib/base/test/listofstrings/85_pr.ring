# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #85.

load "../../stzBase.ring"


o1 = new stzList([ "a", "b", "c", "d" ])

? o1.NumberOfCombinations() + NL
#--> 6

? @@( o1.Combinations() )
#--> [
#	[ "a", "b" ], [ "a", "c" ], [ "a", "d" ],
#	[ "b", "c" ], [ "b", "d" ], [ "c", "d" ]
# ]

pf()
# Executed in almost 0 second(s).
