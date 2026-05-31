# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #16.

load "../../../stzBase.ring"


aMatrix = [
	[ 1, 2, 3 ],
	[ 1, 2, 3 ],
	[ 1, 2, 3 ]
]

FastProUpdate(aMatrix, :Multiply = [ :ColsFrom = [ 1, :To = 3 ], :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
# 	[ 2, 4, 6 ],
# 	[ 2, 4, 6 ],
# 	[ 2, 4, 6 ]
# ]

FastProUpdate(aMatrix, :Multiply = [ :RowsFrom = [ 2, :To = 3 ], :By = 3 ])
? @@NL(aMatrix)
#--> [
#	[ 2, 4, 6 ],
#	[ 6, 12, 18 ],
#	[ 6, 12, 18 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
