# Narrative
# --------
# Large matrix
#
# Extracted from stzmatrextest.ring, block #46.

load "../../../stzBase.ring"

pr()

oMx = new stzMatrex("{size(10x10)}")

aLarge = []
for i = 1 to 10
	aRow = []
	for j = 1 to 10
		aRow + (i * 10 + j)
	next
	aLarge + aRow
next

? oMx.Match(aLarge)
#--> TRUE

pf()
