# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #15.

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 2, 4, 8 ],
	[ 1, 2, 4 ],
	[ 2, 4, 9 ]
]


FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 2, 8, 8 ],
#	[ 1, 4, 4 ],
#	[ 2, 8, 9 ]
# ]

FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 2, :ToCol = 3 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 2, 8, 16 ],
#	[ 1, 4,  8 ],
#	[ 2, 8, 16 ]
# ]

#--

FastProUpdate(aMatrix, :Multiply = [ :Row = 2, :By = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 2, 8, 16 ],
#	[ 2, 8, 16 ],
#	[ 2, 8, 16 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
