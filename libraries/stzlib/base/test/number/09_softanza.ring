# Narrative
# --------
# #ring + softanza
#
# Extracted from stznumbertest.ring, block #9.

load "../../stzBase.ring"


pr()

anPrimes = PrimesUnder(5000)
nLen = len(anPrimes)

anResult = []
for i = 1 to nLen
	if isWeiferich(anPrimes[i])
		anResult + i
	ok
next

? anResult
# Executed in 0.36 second(s) in Ring 1.21

pf()
