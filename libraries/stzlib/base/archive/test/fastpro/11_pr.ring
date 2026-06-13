# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #11.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :Set = [ :RowsFrom = [ 2, :To = 3 ], :With = 5 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 2, 3 ],
#	[ 5, 5, 5 ],
#	[ 5, 5, 5 ]
# ]
/*
FastProUpdate(aMatrix, :Set = [ :Cols = [ :From = 2, :To = 3 ], :With = 0 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 0, 0 ],
#	[ 5, 0, 0 ],
#	[ 5, 0, 0 ]
# ]
*/
pf()
# Executed in almost 0 second(s) in Ring 1.22
