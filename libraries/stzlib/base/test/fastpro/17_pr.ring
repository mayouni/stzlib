# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #17.

load "../../stzBase.ring"


aMatrix = [
	[ 2, 4, 8 ],
	[ 1, 2, 4 ],
	[ 3, 4, 8 ]
]

FastProUpdate(aMatrix, :Divide = [ :Col = 2, :By = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 2, 2, 8 ],
#	[ 1, 1, 4 ],
#	[ 3, 2, 8 ]
# ]

FastProUpdate(aMatrix, :Divide = [ :Col = 3, :By = 2, :ToCol = 1 ])
? @@NL(aMatrix)
#--> [
#	[ 4, 2, 8 ],
#	[ 2, 1, 4 ],
#	[ 4, 2, 8 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
