# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #10.

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :Set = [ :Row = 2, :With = 0 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 1, 2, 3 ],
#	[ 0, 0, 0 ],
#	[ 7, 8, 9 ]
# ]

FastProUpdate(aMatrix, :Set = [ :Col = 2, :With = 0 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 0, 3 ],
#	[ 0, 0, 0 ],
#	[ 7, 0, 9 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
