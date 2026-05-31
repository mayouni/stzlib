# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #6.

load "../../../stzBase.ring"


aMatrix = [
	[ 1, 2, 3 ],
	[ 4, 5, 6 ],
	[ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :set = [ :all, :with = 5 ])
? @@NL(aMatrix)
#--> [
#	[ 5, 5, 5 ],
#	[ 5, 5, 5 ],
#	[ 5, 5, 5 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
