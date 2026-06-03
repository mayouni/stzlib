# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #20.

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 1, 2, 4 ],
	[ 2, 4, 9 ],
	[ 2, 7, 8 ]
]

FastProUpdate(aMatrix, :Modulo = [ :Col = 3, :By = 2 ])

? @@NL(aMatrix)
#--> aMatrix = [
#	[ 1, 2, 0 ],
#	[ 2, 4, 1 ],
#	[ 2, 7, 0 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
