# Narrative
# --------
# Elements in range
#
# Extracted from stzmatrextest.ring, block #14.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{element(0..10)}")

aInRange = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

aOutOfRange = [
	[1, 2, 15],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aInRange)
#--> TRUE

? oMx.Match(aOutOfRange)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24
