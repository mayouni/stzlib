# Narrative
# --------
# Lower triangular matrix
#
# Extracted from stzmatrextest.ring, block #13.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(lower)}")

aLower = [
	[1, 0, 0],
	[2, 3, 0],
	[4, 5, 6]
]

aUpper = [
	[1, 2, 3],
	[0, 4, 5],
	[0, 0, 6]
]

? oMx.Match(aLower)
#--> TRUE

? oMx.Match(aUpper)
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.24

#=======================#
#  ELEMENT CONSTRAINTS  #
#=======================#
