# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #21.

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 0, 5, 3 ],
	[ 0, 7, 9 ],
	[ 0, 9, 7 ]
]

FastProUpdate(aMatrix, :Modulo = [ :ColsFrom = [ 2, :To = 3 ], :By = 2 ])
? @@NL(aMatrix) + NL
#--> [
#	[ 0, 1, 1 ],
#	[ 0, 1, 1 ],
#	[ 0, 1, 1 ]
# ]

#---

aMatrix = [
	[ 0, 0, 0 ],
	[ 2, 7, 4 ],
	[ 5, 9, 7 ]
]

FastProUpdate(aMatrix, :Modulo = [ :RowsFrom = [ 2, :To = 3 ], :By = 2 ])
? @@NL(aMatrix)
#--> [
#	[ 0, 0, 0 ],
#	[ 0, 1, 0 ],
#	[ 1, 1, 1 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
