# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #18.

load "../../../stzBase.ring"


aMatrix = [
	[ 2, 4, 8 ],
	[ 1, 2, 4 ],
	[ 3, 4, 8 ]
]

FastProUpdate(aMatrix, :Divide = [ :Row = 1, :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 1, 2, 4 ],
#	[ 1, 2, 4 ],
#	[ 3, 4, 8 ]
# ]

#--

FastProUpdate(aMatrix, :Divide = [ :Col = 3, :By = 4 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 1, 2, 1 ],
#	[ 1, 2, 1 ],
#	[ 3, 4, 2 ]
#]

FastProUpdate(aMatrix, :Divide = [ :Col = 2, :By = 2, :ToCol = 1 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 2, 1 ],
#	[ 1, 2, 1 ],
#	[ 2, 4, 2 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
