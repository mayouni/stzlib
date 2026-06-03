# Narrative
# --------
# Test global matrix creation functions
#
# Extracted from stzmatrixtest.ring, block #2.

load "../../stzBase.ring"


pr()

? @@NL( Diagonal1Matrix([ 1, 2, 3, 4 ]) ) + NL
#--> [
#	[ 1, 0, 0, 0 ],
#	[ 2, 0, 0, 0 ],
#	[ 3, 0, 0, 0 ],
#	[ 4, 0, 0, 0 ]
# ]

? @@NL( Diagonal2Matrix([ 1, 2, 3, 4 ]) ) + NL
#--> [
#	[ 0, 0, 0, 1 ],
#	[ 0, 0, 2, 0 ],
#	[ 0, 3, 0, 0 ],
#	[ 4, 0, 0, 0 ]
# ]

? @@NL( ConstantMatrix([ 3, [2, 4] ]) )
#--> [
#	[ 3, 3, 3, 3 ],
#	[ 3, 3, 3, 3 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
