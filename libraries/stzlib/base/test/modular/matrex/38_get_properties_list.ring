# Narrative
# --------
# Get properties list
#
# Extracted from stzmatrextest.ring, block #38.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{property(identity)}")

aMatrix = [
	[1, 0, 0],
	[0, 1, 0],
	[0, 0, 1]
]

oMx.Match(aMatrix)
? oMx.Properties()
#--> ["Square", "Symmetric", "Diagonal", "Identity"]

pf()

#======================#
#  PATTERN CONSTRAINT  #
#======================#
