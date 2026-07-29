load "../../stzBase.ring"
load "../_narrated.ring"

# The Moore-Penrose PSEUDO-INVERSE -- the last piece of the numeric foundation's
# linear-algebra line, added between phases 4 and 5.
#
# IT CLOSES A DOOR SLICE 7 DELIBERATELY LEFT OPEN. LeastSquaresFor REFUSES a
# rank-deficient system, and its comment says why: infinitely many coefficient vectors
# share the minimum residual, "and least squares does not choose between them -- that
# is minimum-norm, a different problem needing a different decomposition." This IS
# that decomposition. A+b is the vector that both minimises ||Ax - b|| AND, among all
# the vectors that do, is the shortest. A principled choice, not an arbitrary one --
# which is exactly why it can be offered where least squares declines.
#
# IT GENERALISES EVERYTHING AROUND IT:
#     square and invertible   ->  A+ IS the inverse
#     tall and full rank      ->  A+b IS the least-squares solution
#     rank deficient          ->  A+b is the minimum-norm least-squares solution
#     wide                    ->  A+b is the minimum-norm EXACT solution
#
# A+ = V * S+ * U', two lines on top of the SVD, with one subtlety: "negligible" must
# be the SAME judgement rank and the condition number use, so it asks the same
# negligibleThreshold. That authority exists because slice 9 found rank and
# conditioning disagreeing when they each had their own rule.
#
# TESTED BY THE FOUR PENROSE CONDITIONS, which DEFINE A+ uniquely:
#     A A+ A = A     A+ A A+ = A+     (A A+)' = A A+     (A+ A)' = A+ A
# Nothing else needs asserting, and unlike a transcribed constant they cannot be
# mistyped into agreement. The engine checks all four across eight shapes -- tall,
# wide, square, singular, single-row, single-column and the zero matrix.

Scenario("A+ generalises the ordinary inverse")
	oM = new stzMatrix([ [4,7], [2,6] ])
	Then("for an invertible matrix it IS the inverse",
	     @@(oM.PseudoInverse()), "[ [ 0.60, -0.70 ], [ -0.20, 0.40 ] ]")
	Then("the alias is the same method", @@(oM.MoorePenroseInverse()), @@(oM.PseudoInverse()))

	# The naming law does the disambiguating here. Inverse() is a NOUN, so it returns
	# the inverse AS DATA and leaves the matrix alone; Invert() is the VERB, and it
	# replaces the matrix by its inverse -- the same pairing as Transpose(). This used
	# to be one method that mutated and returned nothing, which cost a confusing
	# minute and was fixed rather than documented.
	oA = new stzMatrix([ [4,7], [2,6] ])
	oB = new stzMatrix([ [4,7], [2,6] ])
	oB.Invert()	# the verb: oB now IS its own inverse
	Then("the pseudo-inverse agrees with what Invert() left behind",
	     @@(oA.PseudoInverse()), @@(oB.Content()))
	# compared numerically rather than by their printed form: these come back as
	# 4.0000000000000004 and print as "4.00", which is a fact about Ring's float
	# display and not about the mathematics
	aBack = oB.PseudoInverse()
	Then("...and A+ of the inverse is the original matrix again",
	     Rnd8(aBack[1][1]) = 4 and Rnd8(aBack[1][2]) = 7 and
	     Rnd8(aBack[2][1]) = 2 and Rnd8(aBack[2][2]) = 6, TRUE)
EndScenario()

Scenario("A A+ A = A -- the first Penrose condition, checked in Ring")
	# The condition that says A+ undoes A as far as anything can. It holds even when
	# A is singular, which no inverse can manage.
	aA = [ [1,2,3], [2,4,6], [1,1,1] ]      # row 2 = 2 * row 1, so singular
	oS = new stzMatrix(aA)
	Then("the matrix really is singular", oS.Rank() < 3, TRUE)
	aP = oS.PseudoInverse()

	# A A+ A, computed by hand so the assertion is about the mathematics
	nWorst = 0
	for i = 1 to 3
		for j = 1 to 3
			nSum = 0
			for k = 1 to 3
				for l = 1 to 3
					nSum += aA[i][k] * aP[k][l] * aA[l][j]
				next
			next
			if fabs(nSum - aA[i][j]) > nWorst
				nWorst = fabs(nSum - aA[i][j])
			ok
		next
	next
	Then("A A+ A reproduces A, for a SINGULAR matrix", nWorst < 0.000000001, TRUE)
EndScenario()

Scenario("where LeastSquaresFor refuses, A+b answers -- and answers well")
	# The rank-deficient design from slice 9: column 3 IS column 1 + column 2.
	aA = [ [1,0,1], [0,1,1], [1,1,2], [2,0,2], [0,3,3] ]
	ab = [ 1, 2, 3, 4, 5 ]
	oD = new stzMatrix(aA)

	Then("the design is rank deficient", oD.Rank(), 2)
	Then("LeastSquaresFor refuses it", @@(oD.LeastSquaresFor(ab)), "[ ]")

	anX = oD.MinimumNormSolutionFor(ab)
	Then("...but the minimum-norm solution exists", len(anX), 3)

	# IT REALLY IS A LEAST-SQUARES SOLUTION: the residual is orthogonal to every
	# column, which is the definition.
	nWorst = 0
	for j = 1 to 3
		nDot = 0
		for i = 1 to 5
			nR = aA[i][1]*anX[1] + aA[i][2]*anX[2] + aA[i][3]*anX[3] - ab[i]
			nDot += aA[i][j] * nR
		next
		if fabs(nDot) > nWorst
			nWorst = fabs(nDot)
		ok
	next
	Then("the residual is orthogonal to every column", nWorst < 0.000000001, TRUE)

	# AND IT IS THE SHORTEST SUCH. The null-space direction here is (1, 1, -1):
	# moving along it leaves the residual untouched but must lengthen the vector.
	nN0 = NormSq(anX)
	Then("shifting along the null space keeps the same residual",
	     Rnd6(SumSq(aA, ab, anX)), Rnd6(SumSq(aA, ab, [ anX[1]+0.5, anX[2]+0.5, anX[3]-0.5 ])))
	Then("...but makes the vector LONGER",
	     NormSq([ anX[1]+0.5, anX[2]+0.5, anX[3]-0.5 ]) > nN0, TRUE)
	Then("...in either direction",
	     NormSq([ anX[1]-0.5, anX[2]-0.5, anX[3]+0.5 ]) > nN0, TRUE)
	Then("...and for a small step too",
	     NormSq([ anX[1]+0.01, anX[2]+0.01, anX[3]-0.01 ]) > nN0, TRUE)
	# which is what "minimum norm" means, demonstrated rather than asserted.
EndScenario()

Scenario("where the design IS full rank, both routes agree")
	# The pseudo-inverse must not be a different answer -- it must be the SAME answer,
	# reached by a different decomposition. QR via Householder, A+ via the SVD.
	aA = [ [1,1], [1,2], [1,3], [1,4], [1,5] ]
	ay = [ 2.1, 3.9, 6.2, 7.8, 10.1 ]
	oF = new stzMatrix(aA)
	anQR = oF.LeastSquaresFor(ay)
	anPI = oF.MinimumNormSolutionFor(ay)
	Then("the intercepts match", Rnd8(anQR[1]), Rnd8(anPI[1]))
	Then("...and the slopes", Rnd8(anQR[2]), Rnd8(anPI[2]))

	# PREFER LeastSquaresFor when the design is full rank. A refusal there is
	# INFORMATION -- it means the predictors are collinear -- and reaching for the
	# minimum-norm answer by default would hide that.
EndScenario()

Scenario("a WIDE system: more unknowns than equations")
	# Two equations, three unknowns: infinitely many EXACT solutions. LeastSquaresFor
	# raises on this shape; A+b returns the shortest of them.
	oW = new stzMatrix([ [1,1,1], [1,-1,0] ])
	anW = oW.MinimumNormSolutionFor([ 6, 2 ])

	Then("it solves the first equation exactly", Rnd9(anW[1] + anW[2] + anW[3]), 6)
	Then("...and the second", Rnd9(anW[1] - anW[2]), 2)

	# the null space is spanned by (1, 1, -2): still exact, but longer
	nN0 = NormSq(anW)
	aShift = [ anW[1]+0.3, anW[2]+0.3, anW[3]-0.6 ]
	Then("a shifted solution is still exact",
	     Rnd9(aShift[1] + aShift[2] + aShift[3]), 6)
	Then("...but longer than the one A+ chose", NormSq(aShift) > nN0, TRUE)

	Then("LeastSquaresFor still raises on this shape, which is correct",
	     RaisesLS(oW, [6,2]), TRUE)
	# a different question, and now there is a method that answers this one.
EndScenario()

Scenario("shapes and edges")
	Then("a single column works", len((new stzMatrix([ [3], [4], [0] ])).PseudoInverse()), 1)
	Then("...and a single row", len((new stzMatrix([ [3,4,0] ])).PseudoInverse()), 3)

	# the pseudo-inverse of the zero matrix is the zero matrix -- there is no
	# direction to invert, so A+ sends everything to nothing
	Then("the zero matrix pseudo-inverts to zeros",
	     @@((new stzMatrix([ [0,0], [0,0] ])).PseudoInverse()), "[ [ 0, 0 ], [ 0, 0 ] ]")

	# A is m*n, so A+ is n*m -- the shape transposes
	oRect = new stzMatrix([ [1,2,3], [4,5,6], [7,8,9], [1,1,1] ])   # 4x3
	aP = oRect.PseudoInverse()
	Then("a 4x3 pseudo-inverts to a 3x4: three rows", len(aP), 3)
	Then("...of four columns each", len(aP[1]), 4)
EndScenario()

Summary()

func NormSq(aX)
	nS = 0
	nLen = len(aX)
	for i = 1 to nLen
		nS += aX[i] * aX[i]
	next
	return nS

func SumSq(aA, ab, aX)
	nS = 0
	nLen = len(ab)
	for i = 1 to nLen
		nR = -ab[i]
		nCols = len(aX)
		for j = 1 to nCols
			nR += aA[i][j] * aX[j]
		next
		nS += nR * nR
	next
	return nS

func RaisesLS(oM, aB)
	bR = FALSE
	try
		anIgnored = oM.LeastSquaresFor(aB)
	catch
		bR = TRUE
	done
	return bR

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000
func Rnd8(n)
	return ceil(n * 100000000 - 0.5) / 100000000
func Rnd9(n)
	return ceil(n * 1000000000 - 0.5) / 1000000000
