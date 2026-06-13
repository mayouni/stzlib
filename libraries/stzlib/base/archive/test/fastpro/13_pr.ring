# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #13.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 1, 2, 3 ],
	[ 1, 2, 3 ]
]

FastProUpdate(aMatrix, :Add = [ 8, :ToColsFrom = [ 1, :To = 2 ] ])
? @@NL(aMatrix) + NL
#--> [
#	[ 9, 10, 3 ],
#	[ 9, 10, 3 ],
#	[ 9, 10, 3 ]
# ]

FastProUpdate(aMatrix, :Add = [ 7, :ToRowsFrom = [ 2, :To = 3 ] ])
? @@NL(aMatrix)
#--> [
#	[ 9, 10, 3 ],
#	[ 16, 17, 10 ],
#	[ 16, 17, 10 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
