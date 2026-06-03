# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #19.

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 1, 2, 3 ],
	[ 1, 2, 3 ],
	[ 1, 2, 3 ]
]

FastProUpdate(aMatrix, :Divide = [ :ColsFrom = [ 1, :To = 3 ], :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 0.50, 1, 1.50 ],
#	[ 0.50, 1, 1.50 ],
#	[ 0.50, 1, 1.50 ]
# ]

FastProUpdate(aMatrix, :Divide = [ :RowsFrom = [ 2, :To = 3 ], :By = 3 ])
? @@NL(aMatrix)
#--> [
#	[ 0.50, 1, 1.50 ],
#	[ 0.17, 0.33, 0.50 ],
#	[ 0.17, 0.33, 0.50 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
