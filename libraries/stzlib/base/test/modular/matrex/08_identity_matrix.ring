# Narrative
# --------
# Identity matrix
#
# Extracted from stzmatrextest.ring, block #8.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(identity)}")

aIdentity = [
	[1, 0, 0],
	[0, 1, 0],
	[0, 0, 1]
]

aNotIdentity = [
	[1, 0, 0],
	[0, 2, 0],
	[0, 0, 1]
]

? oMx.Match(aIdentity)
#--> TRUE

? oMx.Match(aNotIdentity)
#--> FALSE

pf()
# Executed in 0.03 second(s) in Ring 1.24
