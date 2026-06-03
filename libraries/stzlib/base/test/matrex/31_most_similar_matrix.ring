# Narrative
# --------
# Most similar matrix
#
# Extracted from stzmatrextest.ring, block #31.

load "../../stzBase.ring"


pr()

oMx = new stzMatrex("")

aTarget = [[1, 2], [3, 4]]

aCandidates = [
	[[1, 2], [3, 0]],
	[[5, 6], [7, 8]],
	[[1, 2], [3, 4]]
]

? @@( oMx.MostSimilarMatrix(:To = aTarget, :In = aCandidates) )
#--> [[1, 2], [3, 4]]

? oMx.FindMostSimilarMatrix(aTarget, aCandidates) 

pf()

#=======================#
#  PATTERN COMBINATION  #
#=======================#
