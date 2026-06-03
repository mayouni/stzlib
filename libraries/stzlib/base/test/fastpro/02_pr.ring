# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #2.

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 1, 2, 3 ],
	[ 1, 2, 3 ]
]

FastProUpdate(aMatrix, :Raise = [ :ColsFrom = [ 2, :To = 3 ], :ToPower = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 1, 4, 9 ],
#	[ 1, 4, 9 ],
#	[ 1, 4, 9 ]
# ]

FastProUpdate(aMatrix, :Raise = [ :RowsFrom = [ 2, :To = 3 ], :ToPower = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 1, 4, 9 ],
#	[ 1, 16, 81 ],
#	[ 1, 16, 81 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
