# Narrative
# --------
# #todo write a #narration
#
# Extracted from stzGlobalTest.ring, block #31.

load "../../../stzBase.ring"


pr()

o1 = new stzString("...|---|....|--|..--")

? @@( o1.FindAsSections([ "---", "....", "--" ]) ) + NL
#--> [ [ 5, 6 ], [ 5, 7 ], [ 6, 7 ], [ 9, 12 ], [ 14, 15 ], [ 19, 20 ] ]

? @@( o1.Sections( o1.FindAsSections([ "---", "....", "--" ]) ) ) + NL

#--> [ "--", "---", "--", "....", "--", "--" ]

? @@NL( o1.TheseSubStringsZZ([ "---", "....", "--" ]) )
#--> [
#	[ "---", [ [ 5, 7 ] ] ],
#	[ "....", [ [ 9, 12 ] ] ],
#	[ "--", [ [ 5, 6 ], [ 6, 7 ], [ 14, 15 ], [ 19, 20 ] ] ]
# ]

pf()
# Executed in 0.08 second(s)
