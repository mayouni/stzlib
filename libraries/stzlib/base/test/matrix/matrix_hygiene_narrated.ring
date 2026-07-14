# R4 step 1 ACCEPTANCE -- matrix hygiene: the training prerequisites
# Elementwise ops, trace/norm, Ax=b with honest singular refusal,
# and the random distributions learning/ seeds weights with.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: elementwise algebra --"
o = new stzMatrix([ [4, 7], [2, 6] ])
o.SubtractMatrix([ [1, 1], [1, 1] ])
chk("SubtractMatrix", o.Content()[1][1] = 3 and o.Content()[2][2] = 5)
o2 = new stzMatrix([ [1, 2], [3, 4] ])
o2.HadamardProduct([ [2, 2], [2, 2] ])
chk("Hadamard (elementwise multiply)", o2.Content()[2][2] = 8)
o2b = new stzMatrix([ [8, 6] ])
o2b.DivideElementwise([ [2, 3] ])
chk("elementwise divide", o2b.Content()[1][1] = 4 and o2b.Content()[1][2] = 2)
bZ = 0
try
	o2b.DivideElementwise([ [0, 1] ])
catch
	bZ = 1
done
chk("division by zero refuses", bZ = 1)

? ""
? "-- Scene 2: trace, norm --"
o3 = new stzMatrix([ [5, 1], [2, 8] ])
chk("Trace sums the diagonal", o3.Trace() = 13)
oN = new stzMatrix([ [3, 4] ])
chk("Frobenius norm (3,4) = 5", oN.FrobeniusNorm() = 5)

? ""
? "-- Scene 3: Solve(Ax=b) -- exact, or an honest refusal --"
oA = new stzMatrix([ [2, 1], [1, 3] ])
aX = oA.SolveFor([ 5, 10 ])
chk("2x+y=5, x+3y=10 -> x=1, y=3", aX[1] = 1 and aX[2] = 3)
bS = 0
oS = new stzMatrix([ [1, 2], [2, 4] ])
try
	oS.SolveFor([ 3, 6 ])
catch
	bS = 1
done
chk("a singular system REFUSES (no least-squares guessing)", bS = 1)

? ""
? "-- Scene 4: the distributions (weight-init seeds) --"
aU = RandomUniformList(200, -1, 1)
nMin = 99
nMax = -99
for i = 1 to 200
	if aU[i] < nMin nMin = aU[i] ok
	if aU[i] > nMax nMax = aU[i] ok
next
chk("uniform stays in its range", nMin >= -1 and nMax <= 1)
aN = RandomNormalList(500, 10, 2)
nS = 0
for i = 1 to 500
	nS += aN[i]
next
nMean = nS / 500
chk("Box-Muller normal centers on its mean", nMean > 9 and nMean < 11)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
