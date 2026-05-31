# Narrative
# --------
# Add constraint to pattern
#
# Extracted from stzmatrextest.ring, block #39.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("{size(3x3)}")

aMatrix1 = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
]

? oMx.Match(aMatrix1)
#--> TRUE

oMx.AddConstraint("property(symmetric)") # We have alos RemoveConstraing()

? oMx.Match(aMatrix1)
#--> FALSE

pf()

#========================#
#  DEBUG AND INSPECTION  #
#========================#
