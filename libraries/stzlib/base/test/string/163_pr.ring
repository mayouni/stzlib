# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #163.

load "../../stzBase.ring"


o1 = new stzString("__<<teeba>>__<<rined>>__<<teeba>>")

? @@NL( o1.BoundedByUZ([ "<<", ">>" ]) ) + NL
#--> [
#	[ "teeba", [ 5, 27 ] ],
#	[ "rined", [ 16 ] ]
# ]

? @@NL( o1.BoundedByUZZ([ "<<", ">>" ]) )
#--> [
#	[ "teeba", [ [ 5, 9 ], [ 27, 31 ] ] ],
#	[ "rined", [ [ 16, 20 ] ] ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.17 in Ring 1.18
