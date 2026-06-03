# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #22.

load "../../stzBase.ring"

pr()

aMatrix = [
	[ 5, 5, 5 ],
	[ 5, 5, 5 ],
	[ 5, 5, 5 ]
]

FastProUpdate(aMatrix, :Set = [ :Col = 1, :Step = 0 ])
? @@NL( aMatrix )
#--> [
#	[ 1, 5, 5 ],
#	[ 2, 5, 5 ],
#	[ 3, 5, 5 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
