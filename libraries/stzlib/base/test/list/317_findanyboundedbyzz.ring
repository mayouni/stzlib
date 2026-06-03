# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #317.
#ERR Error (R14) : Calling Method without definition: findanyboundedbyzz

load "../../stzBase.ring"

pr()

#  BOUNDED-BY             v-------v
#                       v---v     v-v    v           
o1 = new stzString("---[ [===]---[=] ]--[=]--")
#                       | | |     ‖ |    ‖
#   DEEP-FIND >>        | \_/    15 |   22
#                       | 7 9       |
#                       \___________/
#                       5           17

? @@( o1.FindAnyBoundedByZZ([ "[", "]" ]) ) + NL
#--> [ [ 5, 9 ], [ 15, 15 ], [ 22, 22 ] ]

? @@NL( o1.SubStringsBoundedByZZ([ "[", "]" ]) ) + NL
#--> [
#	[ " [===", [ 5, 9 ] ],
#	[ "=", [ 15, 15 ] ],
#	[ "=", [ 22, 22 ] ]
# ]

#---

? @@( o1.DeepFindSubStringsZZ(:BoundedBy = [ "[", "]" ]) ) + NL
#--> [ [ 7, 9 ], [ 15, 15 ], [ 22, 22 ], [ 5, 17 ] ]

? @@NL( o1.DeepSubStringsZZ(:BoundedBy = [ "[", "]" ]) )
#--> [
#	[ "===", [ 7, 9 ] ],
#	[ "=", [ 15, 15 ] ],
#	[ "=", [ 22, 22 ] ],
#	[ " [===]---[=] ", [ 5, 17 ] ]
# ]

StopProfiler()

pf()
# Executed in 0.04 second(s) in Ring 1.22
