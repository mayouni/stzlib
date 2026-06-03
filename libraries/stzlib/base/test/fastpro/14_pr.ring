# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #14.

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 10, 20, 30 ],
	[ 40, 50, 60 ],
	[ 70, 80, 90 ]
]

FastProUpdate(aMatrix, :Subtract = [ 10, :FromColsFrom = [ 1, :To = 3 ] ])
? @@NL(aMatrix) + NL
#--> [
#	[ 0, 10, 20 ],
#	[ 30, 40, 50 ],
#	[ 60, 70, 80 ]
# ]

FastProUpdate(aMatrix, :Subtract = [ 10, :FromRowsFrom = [ 1, :To = 3 ] ])
? @@NL(aMatrix)
#--> [
#	[ -10, 0, 10 ],
#	[ 20, 30, 40 ],
#	[ 50, 60, 70 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
