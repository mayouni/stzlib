# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #12.

load "../../../stzBase.ring"


aMatrix = [
	[ 1, 2, 3 ],
	[ 1, 2, 3 ],
	[ 1, 2, 3 ]
]

FastProUpdate(aMatrix, :Add = [ 8, :ToCol = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 10, 3 ],
#	[ 1, 10, 3 ],
#	[ 1, 10, 3 ]
# ]

FastProUpdate(aMatrix, :Subtract = [ 10, :FromCol = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 0, 3 ],
#	[ 1, 0, 3 ],
#	[ 1, 0, 3 ]
# ]

pf()
