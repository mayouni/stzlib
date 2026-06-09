# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #8.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# Create a matrix and perform multi-row/column operations

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

# Set rows 1-2 to value 100

FastProUpdate(aMatrix, :set = [ :rows = [1, 2], :with = 100 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 100, 100, 100 ],
#	[ 100, 100, 100 ],
#	[   7,   8,   9 ]
# ]

# Multiply column 2 by 10, result in column 3

FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 10, :ToCol = 3 ])

? @@NL(aMatrix)
#--> [
#	[ 100, 100, 1000 ],
#	[ 100, 100, 1000 ],
#	[   7,   8,   80 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
