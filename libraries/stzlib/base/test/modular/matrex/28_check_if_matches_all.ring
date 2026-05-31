# Narrative
# --------
# Check if matches all
#
# Extracted from stzmatrextest.ring, block #28.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{shape(square)}")

aAllSquare = [
	[[1, 2], [3, 4]],
	[[1, 2, 3], [4, 5, 6], [7, 8, 9]]
]

aMixed = [
	[[1, 2], [3, 4]],
	[[1, 2, 3], [4, 5, 6]]
]

? oMx.MatchesAll( :In = aAllSquare )
#--> TRUE

? oMx.MatchesAll(aMixed)
#--> FALSE

pf()

#===========================#
#  ANALYSIS AND STATISTICS  #
#===========================#
