# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #7.

load "../../stzBase.ring"

pr()

# Create a 2D list and set first column to 100

aMatrix = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

FastProUpdate(aMatrix, :set = [ :col = 1, :with = 100 ])
? @@NL(aMatrix)
#--> [
#	[ 100, 2, 3 ],
#	[ 100, 5, 6 ],
#	[ 100, 8, 9 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
