# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #23.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 3, 7, 5 ],
	[ 2, 8, 0 ],
	[ 5, 5, 0 ]
]

FastProUpdate(aMatrix, :Merge = [ :Cols = [ 1, 2 ], :InCol = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 3, 10, 5 ],
#	[ 2, 10, 0 ],
#	[ 5, 10, 0 ]
# ]

FastProUpdate(aMatrix, :Merge = [ :Rows = [ 2, 3 ], :InRow = 3 ])
? @@NL(aMatrix)
#--> [
#	[ 3, 10, 5 ],
#	[ 2, 10, 0 ],
#	[ 7, 20, 0 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
