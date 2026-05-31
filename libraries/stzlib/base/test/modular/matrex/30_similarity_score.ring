# Narrative
# --------
# Similarity score
#
# Extracted from stzmatrextest.ring, block #30.

load "../../../stzBase.ring"


pr()

oMx = new stzMatrex("")

aMatrix1 = [[1, 2], [3, 4]]
aMatrix2 = [[1, 2], [3, 4]]
aMatrix3 = [[1, 0], [0, 4]]

? oMx.SimilarityScore(aMatrix1, aMatrix2)
#--> 1.0

? oMx.SimilarityScore(aMatrix1, aMatrix3)
#--> 0.5

pf()
