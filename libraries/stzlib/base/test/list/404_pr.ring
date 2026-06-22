# Narrative
# --------
# The (*) operator with a LIST right-hand operand (zip-pairing) -- FEATURE STUB.
#
# The intent: Q([ "VALUE1", "VALUE2", "VALUE3" ]) * [ 1001, 1002, 1003 ] pairs
# each left item with the whole right list, producing [ [item, rhsList], ... ].
# The current (*) operator only accepts a numeric RHS (it raises "operator *:
# rhs must be a number" on a list), so this form is not yet implemented. The
# recorded outputs document the intended pairing. Left as a documented stub
# (companion to 402's object/string RHS forms).
#
# Extracted from stzlisttest.ring, block #404.
#ERR operator *: rhs must be a number.  (list RHS zip-pairing pending)

load "../../stzBase.ring"

pr()

? @@SP( Q([ "VALUE1", "VALUE2", "VALUE3" ]) * [ 1001, 1002, 1003 ] )
#--> [
#	[  "VALUE1", [ 1001, 1002, 1003 ] ],
#	[  "VALUE2", [ 1001, 1002, 1003 ] ],
#	[  "VALUE3", [ 1001, 1002, 1003 ] ]
# ]

? @@NL( Q([ 15, 25, 70]) * [ 2, 4, 6 ] )
#--> [
#	[ 15, [ 2, 4, 6 ] ],
#	[ 25, [ 2, 4, 6 ] ],
#	[ 70, [ 2, 4, 6 ] ]
# ]

pf()
# Executed in almost 0 second(s).
