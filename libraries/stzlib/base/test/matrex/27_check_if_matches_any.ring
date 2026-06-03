# Narrative
# --------
# Check if matches any
#
# Extracted from stzmatrextest.ring, block #27.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(symmetric)}")

aMatrices = [
	[[1, 2], [3, 4]],
	[[5, 6], [7, 8]]
]

? oMx.MatchesNone(:In = aMatrices)
#--> FALSE

pf()
