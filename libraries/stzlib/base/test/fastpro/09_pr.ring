# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #9.

load "../../stzBase.ring"


aMatrix = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 1,  4, 3 ],
#	[ 4, 10, 6 ],
#	[ 7, 16, 9 ]
# ]

FastProUpdate(aMatrix, :Multiply = [ :Col = 1, :By = 3, :ToCol = 3 ])
? @@NL(aMatrix)
#--> [
#	[ 1,  4, 3 ],
#	[ 4, 10, 12 ],
#	[ 7, 16, 21 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
