# Narrative
# --------
# #ring #perf
#
# Extracted from stzlisttest.ring, block #175.

load "../../stzBase.ring"


pr()

aList = 1: 100_000
nLen = len(aList)

bResult = TRUE
for i = 1 to nLen
	if NOT isNumber(aList[i])
		bResult = FALSE
		exit
	ok
next

? bResult

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.22 second(s) in Ring 1.17
