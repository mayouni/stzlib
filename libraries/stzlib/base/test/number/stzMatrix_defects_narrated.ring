load "../../stzBase.ring"
load "../_narrated.ring"

# stzMatrix (base/number/stzMatrix.ring) -- the two register rows kept as a guard. Run from inside this folder:
#     rnxc stzMatrix_defects_narrated.ring
# It needs only the engine's matrix and string modules: no network, no file, no other DLL.
#
# THE HISTORY: the register said
#   Diagonal1       "Returns nothing today instead of the main diagonal, because its body is empty": the method
#                   was a bare `func Diagonal1()` with no statement, so it answered "" for every matrix.
#   EigenVectors    "raises an error unless the matrix is square, for a defective matrix, and when an eigenvector
#                   is complex". Measured before any change: those three refusals are DELIBERATE and already
#                   named (a message that starts EigenVectors and points at ComplexEigenVectors), and every real,
#                   diagonalisable matrix tried was answered with vectors that satisfy A v = lambda v. What was
#                   NOT right: (1) the sign of a column came from the algorithm, so [[2,1,1],[1,2,1],[1,1,2]]-like
#                   symmetric matrices returned (-0.58, 0.58, 0.58) in one column and a non-symmetric one a
#                   different rule; (2) for a repeated eigenvalue of a NON-symmetric matrix the columns of the
#                   eigenspace were independent but not orthogonal (0.33 off), where a symmetric matrix gave an
#                   orthonormal basis; (3) the refusals were documented as a "warning", which the register reads
#                   as a fault.
#
# THE RULES the guard holds the class to:
#   Diagonal1   the main diagonal, the cells (1,1) (2,2) ... of min(rows, columns) numbers: the SAME answer as
#               Diagonal, which MultiplyDiagonal1 / AddInDiagonal / :InDiagonal1 already call the main diagonal.
#               Diagonal2 stays the secondary one. A matrix that is not square gives its leading cells, as
#               Diagonal does. The matrix is not changed.
#   EigenVectors   for a square matrix with real eigenvalues and a full set of eigenvectors, a matrix whose COLUMN j
#               is the unit eigenvector of EigenValues()[j] (same order, A v = lambda v, norm 1 within 1e-9).
#               SIGN: the component of largest magnitude in each column is positive; among components equal
#               within one part in 1e9 the first one. So the answer is the same on every run and on both paths.
#               SYMMETRIC: the columns are orthonormal. REPEATED eigenvalue: the columns that share it are
#               orthonormal whatever the matrix (Gram-Schmidt inside the group only: columns of different
#               eigenvalues of a non-symmetric matrix stay non-orthogonal, as they must).
#               REFUSED with a named error, never R14, never copies: not square; defective (fewer independent
#               eigenvectors than rows); complex eigenvalues (ComplexEigenVectors answers those).
#   Nothing else moves: Diagonal, Diagonal2, Trace, Determinant, Transpose, EigenValues,
#   NumberOfIndependentEigenVectors, ComplexEigenVectors answer what they answered.
#
# TOLERANCES: 1e-9 for a residual ||A v - lambda v|| and for |norm - 1| on matrices up to 3x3 and 1e-8 on 20x20.
# Exact values are compared after rounding to 9 places. ASCII only on the console.

$cMxRaised = ""
$oMx = ""

# ---------------------------------------------------------------------------------------------------------------
Scenario("1. Diagonal1: the main diagonal, exactly as Diagonal gives it")
try
	Given("matrices of every shape")
	Then("1x1 [[5]] gives [ 5 ]", @@(new stzMatrix([ [5] ]).Diagonal1()), "[ 5 ]")
	Then("[[1,2],[3,4]] gives [ 1, 4 ]", @@(new stzMatrix([ [1,2],[3,4] ]).Diagonal1()), "[ 1, 4 ]")
	Then("3x3 gives [ 1, 5, 9 ]", @@(new stzMatrix([ [1,2,3],[4,5,6],[7,8,9] ]).Diagonal1()), "[ 1, 5, 9 ]")
	Then("2x3 gives its leading cells [ 1, 5 ]", @@(new stzMatrix([ [1,2,3],[4,5,6] ]).Diagonal1()), "[ 1, 5 ]")
	Then("3x2 gives its leading cells [ 1, 4 ]", @@(new stzMatrix([ [1,2],[3,4],[5,6] ]).Diagonal1()), "[ 1, 4 ]")
	Then("the identity gives ones", @@(new stzMatrix([ [1,0,0],[0,1,0],[0,0,1] ]).Diagonal1()), "[ 1, 1, 1 ]")
	Then("the zero matrix gives zeros", @@(new stzMatrix([ [0,0],[0,0] ]).Diagonal1()), "[ 0, 0 ]")
	Then("negative and fractional cells are kept", MxFrac(new stzMatrix([ [-1.5,2],[3,0.25] ]).Diagonal1()), 1)
	Then("NEGATIVE: it is not the empty answer the empty body gave", isList(new stzMatrix([ [1,2],[3,4] ]).Diagonal1()), 1)
	Then("...it has min(rows, columns) cells", len(new stzMatrix([ [1,2,3],[4,5,6] ]).Diagonal1()), 2)
	Then("NEGATIVE: it is not the secondary diagonal", @@(new stzMatrix([ [1,2],[3,4] ]).Diagonal1()) = @@(new stzMatrix([ [1,2],[3,4] ]).Diagonal2()), 0)
	Then("the secondary diagonal is still [ 2, 3 ]", @@(new stzMatrix([ [1,2],[3,4] ]).Diagonal2()), "[ 2, 3 ]")
	Then("it equals Diagonal on every shape tried", MxSameDiag([ [1,2,3],[4,5,6],[7,8,9] ]) + MxSameDiag([ [1,2,3],[4,5,6] ]) + MxSameDiag([ [1,2],[3,4],[5,6] ]) + MxSameDiag([ [7] ]), 4)
	Then("the matrix is not changed by asking", MxUnchangedByDiag1([ [1,2],[3,4] ]), 1)
catch
	MxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("2. Diagonal1 agrees with the siblings that already say 'diagonal 1'")
try
	Given("a 3x3 matrix whose main diagonal is changed by the numbered operations")
	$oMx = new stzMatrix([ [1,2,3],[4,5,6],[7,8,9] ])
	$oMx.MultiplyDiagonal1(10)
	Then("after MultiplyDiagonal1(10) it reads 10 50 90", @@($oMx.Diagonal1()), "[ 10, 50, 90 ]")
	Then("...and the secondary diagonal moved only at the shared centre", @@($oMx.Diagonal2()), "[ 3, 50, 7 ]")
	$oMx = new stzMatrix([ [1,2,3],[4,5,6],[7,8,9] ])
	$oMx.AddInDiagonal(100)
	Then("after AddInDiagonal(100) it reads 101 105 109", @@($oMx.Diagonal1()), "[ 101, 105, 109 ]")
	Then("...and Diagonal says the same", @@($oMx.Diagonal()), "[ 101, 105, 109 ]")
	Then("the trace is the sum of the diagonal", $oMx.Trace(), 315)
	$oMx = new stzMatrix(MxBig(20, 1))
	Then("a 20x20 matrix: 20 cells", len($oMx.Diagonal1()), 20)
	Then("...equal to Diagonal", @@($oMx.Diagonal1()), @@($oMx.Diagonal()))
catch
	MxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("3. the neighbouring methods answer what they answered")
try
	Given("fixed matrices, the values read before any change")
	Then("Diagonal of [[1,2,3],[0,4,5],[0,0,6]]", @@(new stzMatrix([ [1,2,3],[0,4,5],[0,0,6] ]).Diagonal()), "[ 1, 4, 6 ]")
	Then("Diagonal2 of the same", @@(new stzMatrix([ [1,2,3],[0,4,5],[0,0,6] ]).Diagonal2()), "[ 3, 4, 0 ]")
	Then("Trace of the same", new stzMatrix([ [1,2,3],[0,4,5],[0,0,6] ]).Trace(), 11)
	Then("Determinant of the same", new stzMatrix([ [1,2,3],[0,4,5],[0,0,6] ]).Determinant(), 24)
	Then("Determinant of [[2,1],[1,2]]", new stzMatrix([ [2,1],[1,2] ]).Determinant(), 3)
	Then("Diagonal of a 2x3", @@(new stzMatrix([ [1,2,3],[4,5,6] ]).Diagonal()), "[ 1, 5 ]")
	Then("Diagonal2 of a 2x3", @@(new stzMatrix([ [1,2,3],[4,5,6] ]).Diagonal2()), "[ 3, 5 ]")
	$oMx = new stzMatrix([ [1,2,3],[4,5,6] ])
	$oMx.Transpose()
	Then("Transpose of a 2x3", @@($oMx.Content()), "[ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ] ]")
	Then("Trace of a 2x3 is refused", MxHas(MxRaised('new stzMatrix([ [1,2,3],[4,5,6] ]).Trace()'), "square"), 1)
	Then("EigenValues of [[2,1],[1,2]] are [ 3, 1 ]", @@(new stzMatrix([ [2,1],[1,2] ]).EigenValues()), "[ 3, 1 ]")
	Then("EigenValues of an upper-triangular matrix", @@(new stzMatrix([ [1,2,3],[0,4,5],[0,0,6] ]).EigenValues()), "[ 1, 4, 6 ]")
	Then("EigenValues of a rotation still refuses, pointing at ComplexEigenValues", MxHas(MxRaised('new stzMatrix([ [0,-1],[1,0] ]).EigenValues()'), "ComplexEigenValues"), 1)
	Then("[[1,1],[0,1]] has one independent eigenvector", new stzMatrix([ [1,1],[0,1] ]).NumberOfIndependentEigenVectors(), 1)
	Then("...and is defective", new stzMatrix([ [1,1],[0,1] ]).IsDefective(), 1)
	Then("the identity has a full set", new stzMatrix([ [1,0],[0,1] ]).NumberOfIndependentEigenVectors(), 2)
catch
	MxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("4. EigenVectors: exact values")
try
	Given("matrices whose eigenvectors are known by hand")
	$aMxV = new stzMatrix([ [2,1],[1,2] ]).EigenVectors()
	Then("[[2,1],[1,2]]: column 1 is (1,1)/sqrt(2)", MxRnd($aMxV[1][1]) = MxRnd(1/sqrt(2)) and MxRnd($aMxV[2][1]) = MxRnd(1/sqrt(2)), 1)
	Then("...column 2 is (1,-1)/sqrt(2): the first of two equal parts is positive", MxRnd($aMxV[1][2]) = MxRnd(1/sqrt(2)) and MxRnd($aMxV[2][2]) = MxRnd(-1/sqrt(2)), 1)
	$aMxV = new stzMatrix([ [2,1],[0,3] ]).EigenVectors()
	Then("[[2,1],[0,3]] (non-symmetric): column 1 is e1", MxRnd($aMxV[1][1]) = 1 and MxRnd($aMxV[2][1]) = 0, 1)
	Then("...column 2 is (1,1)/sqrt(2)", MxRnd($aMxV[1][2]) = MxRnd(1/sqrt(2)) and MxRnd($aMxV[2][2]) = MxRnd(1/sqrt(2)), 1)
	Then("1x1 [[5]] gives [[1]]", @@(new stzMatrix([ [5] ]).EigenVectors()), "[ [ 1 ] ]")
	Then("1x1 [[-4]] gives [[1]]: the sign is fixed, not the algorithm's", @@(new stzMatrix([ [-4] ]).EigenVectors()), "[ [ 1 ] ]")
	Then("the identity gives the identity", @@(new stzMatrix([ [1,0,0],[0,1,0],[0,0,1] ]).EigenVectors()), "[ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]")
	Then("the zero matrix gives the identity", @@(new stzMatrix([ [0,0],[0,0] ]).EigenVectors()), "[ [ 1, 0 ], [ 0, 1 ] ]")
	Then("[[3,0],[0,7]] is symmetric, so its eigenvalues are [ 7, 3 ]", @@(new stzMatrix([ [3,0],[0,7] ]).EigenValues()), "[ 7, 3 ]")
	Then("...and the columns follow them: e2 first, then e1", @@(new stzMatrix([ [3,0],[0,7] ]).EigenVectors()), "[ [ 0, 1 ], [ 1, 0 ] ]")
	$aMxV = new stzMatrix([ [-1,5],[0,-3] ]).EigenVectors()
	Then("[[-1,5],[0,-3]]: column 1 is e1 (eigenvalue -1)", MxRnd($aMxV[1][1]) = 1 and MxRnd($aMxV[2][1]) = 0, 1)
	Then("...column 2 is (5,-2)/sqrt(29) with the larger part positive", MxRnd($aMxV[1][2]) = MxRnd(5/sqrt(29)) and MxRnd($aMxV[2][2]) = MxRnd(-2/sqrt(29)), 1)
	Then("NEGATIVE: that is not the flipped column", MxRnd($aMxV[1][2]) = MxRnd(-5/sqrt(29)), 0)
catch
	MxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("5. EigenVectors: A v = lambda v, norm 1, in the order of EigenValues, sign fixed")
try
	Given("real-spectrum matrices: symmetric, triangular, mixed, repeated, negative")
	$aMxGood = [
		[ "1x1",                       [ [5] ] ],
		[ "2x2 symmetric",             [ [2,1],[1,2] ] ],
		[ "3x3 symmetric",             [ [4,1,0],[1,3,1],[0,1,2] ] ],
		[ "negative symmetric",        [ [-2,1],[1,-2] ] ],
		[ "2x2 non-symmetric",         [ [2,1],[0,3] ] ],
		[ "negative non-symmetric",    [ [-1,5],[0,-3] ] ],
		[ "3x3 upper triangular",      [ [1,2,3],[0,4,5],[0,0,6] ] ],
		[ "3x3 mixed",                 [ [1,2,0],[0,3,0],[4,0,5] ] ],
		[ "identity 3",                [ [1,0,0],[0,1,0],[0,0,1] ] ],
		[ "zero 2x2",                  [ [0,0],[0,0] ] ],
		[ "repeated, symmetric",       [ [2,1,1],[1,2,1],[1,1,2] ] ],
		[ "repeated, non-symmetric",   [ [2,0,0],[0,2,0],[1,0,3] ] ],
		[ "repeated, full eigenspace", [ [2,0,0],[-0.5,2.5,0.5],[-0.5,0.5,2.5] ] ],
		[ "repeated 5,5,-2",           [ [5,0,0],[3.5,1.5,-3.5],[3.5,-3.5,1.5] ] ]
	]
	for nMxI = 1 to len($aMxGood)
		Then($aMxGood[nMxI][1] + ": A v = lambda v for every column, in EigenValues order",
		     MxResidual($aMxGood[nMxI][2]) < 0.000000001, 1)
		Then($aMxGood[nMxI][1] + ": every column has norm 1",
		     MxNormErr($aMxGood[nMxI][2]) < 0.000000001, 1)
		Then($aMxGood[nMxI][1] + ": the largest part of each column is positive",
		     MxSignOk($aMxGood[nMxI][2]), 1)
	next
catch
	MxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("6. EigenVectors: orthonormal for a symmetric matrix and inside a repeated eigenvalue, and no further")
try
	Given("symmetric matrices, then a non-symmetric one with a two-dimensional eigenspace")
	Then("3x3 symmetric: V'V is the identity", MxOrthErr(new stzMatrix([ [4,1,0],[1,3,1],[0,1,2] ]).EigenVectors()) < 0.000000001, 1)
	Then("repeated symmetric 2,2,2+: V'V is the identity", MxOrthErr(new stzMatrix([ [2,1,1],[1,2,1],[1,1,2] ]).EigenVectors()) < 0.000000001, 1)
	Then("20x20 symmetric: V'V is the identity to 1e-8", MxOrthErr(new stzMatrix(MxSym(20, 7)).EigenVectors()) < 0.00000001, 1)
	$aMxA = [ [2,0,0],[-0.5,2.5,0.5],[-0.5,0.5,2.5] ]
	$aMxV = new stzMatrix($aMxA).EigenVectors()
	$aMxL = new stzMatrix($aMxA).EigenValues()
	Then("the eigenvalues are 2, 3, 2 (columns 1 and 3 share the eigenvalue 2)", @@($aMxL), "[ 2, 3, 2 ]")
	Then("the two columns that share it are orthogonal", fabs(MxDot($aMxV, 1, 3)) < 0.000000001, 1)
	Then("...and each of unit length", fabs(MxDot($aMxV, 1, 1) - 1) < 0.000000001 and fabs(MxDot($aMxV, 3, 3) - 1) < 0.000000001, 1)
	Then("NEGATIVE: the column of the other eigenvalue is NOT made orthogonal to them (it could not be)", fabs(MxDot($aMxV, 1, 2)) > 0.1, 1)
	Then("...so the matrix of eigenvectors is not orthogonal, which is right for a non-symmetric matrix", MxOrthErr($aMxV) > 0.1, 1)
	Then("...and the residual is still nil", MxResidual($aMxA) < 0.000000001, 1)
catch
	MxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("7. EigenVectors: the named refusals, never R14, never copies")
try
	Given("a matrix that is not square, a defective one, and ones with complex eigenvalues")
	$cMxRaised = MxRaised('new stzMatrix([ [1,2,3],[4,5,6] ]).EigenVectors()')
	Then("a 2x3 raises", $cMxRaised != "", 1)
	Then("...saying EigenVectors and square", MxHas($cMxRaised, "EigenVectors") and MxHas($cMxRaised, "square"), 1)
	$cMxRaised = MxRaised('new stzMatrix([ [1,2],[3,4],[5,6] ]).EigenVectors()')
	Then("a 3x2 raises the same way", MxHas($cMxRaised, "square"), 1)
	$cMxRaised = MxRaised('new stzMatrix([ [1,1],[0,1] ]).EigenVectors()')
	Then("[[1,1],[0,1]] raises", $cMxRaised != "", 1)
	Then("...saying DEFECTIVE and how many it has: only 1 independent", MxHas($cMxRaised, "DEFECTIVE") and MxHas($cMxRaised, "only 1 independent"), 1)
	Then("...and pointing at ComplexEigenVectors", MxHas($cMxRaised, "ComplexEigenVectors"), 1)
	Then("NEGATIVE: it is not an R14 or an undefined-method error", MxHas($cMxRaised, "R14") = 0 and MxHas($cMxRaised, "Error (R") = 0, 1)
	$cMxRaised = MxRaised('new stzMatrix([ [2,1,0],[0,2,1],[0,0,2] ]).EigenVectors()')
	Then("a 3x3 Jordan block raises as defective", MxHas($cMxRaised, "DEFECTIVE") and MxHas($cMxRaised, "only 1 independent"), 1)
	$cMxRaised = MxRaised('new stzMatrix([ [0,-1],[1,0] ]).EigenVectors()')
	Then("a rotation raises", $cMxRaised != "", 1)
	Then("...saying complex and pointing at ComplexEigenVectors", MxHas($cMxRaised, "complex") and MxHas($cMxRaised, "ComplexEigenVectors"), 1)
	$cMxRaised = MxRaised('new stzMatrix([ [0,-1,0],[1,0,0],[0,0,2] ]).EigenVectors()')
	Then("a rotation with a real eigenvalue beside it raises too", MxHas($cMxRaised, "complex"), 1)
	Then("NEGATIVE: a good matrix raises nothing", MxRaised('new stzMatrix([ [2,1],[0,3] ]).EigenVectors()'), "")
	Then("NEGATIVE: a repeated eigenvalue with a full eigenspace raises nothing", MxRaised('new stzMatrix([ [2,0],[0,2] ]).EigenVectors()'), "")
	$oMx = new stzMatrix([ [0,-1],[1,0] ])
	Then("the door the message names works: ComplexEigenVectors has 2 columns of 2", len($oMx.ComplexEigenVectors()) = 2 and len($oMx.ComplexEigenVectors()[1]) = 2, 1)
	Then("...its first column has unit length", fabs(MxComplexNorm($oMx.ComplexEigenVectors(), 1) - 1) < 0.000000001, 1)
catch
	MxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("8. EigenVectors: reproducible, agrees with ComplexEigenVectors, leaves the matrix alone")
try
	Given("one matrix asked twice, and by the complex form")
	$aMxA = [ [1,2,3],[0,4,5],[0,0,6] ]
	Then("two objects answer the same, to the last bit", @@(new stzMatrix($aMxA).EigenVectors()) = @@(new stzMatrix($aMxA).EigenVectors()) and MxBitSame(new stzMatrix($aMxA).EigenVectors(), new stzMatrix($aMxA).EigenVectors()), 1)
	$oMx = new stzMatrix($aMxA)
	$aMxV = $oMx.EigenVectors()
	Then("the matrix is unchanged by the call", @@($oMx.Content()), @@($aMxA))
	Then("the same object answers the same twice", MxBitSame($aMxV, $oMx.EigenVectors()), 1)
	Then("ComplexEigenVectors has the same real parts on this real-spectrum matrix", MxAgreesWithComplex($aMxA), 1)
	Then("...and the same on a 3x3 non-symmetric mixed matrix", MxAgreesWithComplex([ [1,2,0],[0,3,0],[4,0,5] ]), 1)
catch
	MxAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("9. EigenVectors at 20x20: the property holds, and what it costs")
try
	Given("a 20x20 symmetric matrix and a 20x20 upper-triangular one with distinct diagonal")
	$aMxS = MxSym(20, 7)
	$aMxU = MxUpper(20, 11)
	Then("symmetric: max ||A v - lambda v|| below 1e-8", MxResidual($aMxS) < 0.00000001, 1)
	Then("symmetric: every column has norm 1 within 1e-8", MxNormErr($aMxS) < 0.00000001, 1)
	Then("symmetric: the sign rule holds in all 20 columns", MxSignOk($aMxS), 1)
	Then("upper triangular: max ||A v - lambda v|| below 1e-8", MxResidual($aMxU) < 0.00000001, 1)
	Then("upper triangular: every column has norm 1 within 1e-8", MxNormErr($aMxU) < 0.00000001, 1)
	Then("upper triangular: the sign rule holds in all 20 columns", MxSignOk($aMxU), 1)
	$nMxMsS = MxTime($aMxS, 20)
	$nMxMsU = MxTime($aMxU, 20)
	? "      measured: 20 calls of EigenVectors on 20x20 symmetric = " + $nMxMsS + " ms, upper triangular = " + $nMxMsU + " ms"
	Then("20 calls on the symmetric 20x20 take under 5 s (a band, measured far below)", $nMxMsS < 5000, 1)
	Then("20 calls on the non-symmetric 20x20 take under 5 s", $nMxMsU < 5000, 1)
catch
	MxAbort()
done
EndScenario()

Summary()

# ---------------------------------------------------------------------------------------------------------------
# helpers: every name a function reads is a $global or a parameter (Rule A)

func MxAbort()
	? "      (the scenario stopped: " + cCatchError + ")"
	$_zst_fail++
	$_zst_total++

func MxRnd(n)
	return ceil(n * 1000000000 - 0.5) / 1000000000

# the text of the error a statement raises, "" when it raises nothing
func MxRaised(cCode)
	$cMxRaised = ""
	try
		eval("$oMx = " + cCode)
	catch
		$cMxRaised = cCatchError
	done
	return $cMxRaised

# 1 if cText contains cPart (exact, case-sensitive through the hex)
func MxHas(cText, cPart)
	if NOT isString(cText)  return 0  ok
	if len(cText) = 0  return 0  ok
	return (StzFindFirst(cPart, cText) > 0)

func MxFrac(aD)
	if len(aD) = 2 and aD[1] = -1.5 and aD[2] = 0.25  return 1  ok
	return 0

func MxSameDiag(aM)
	o = new stzMatrix(aM)
	if @@(o.Diagonal1()) = @@(o.Diagonal())  return 1  ok
	return 0

func MxUnchangedByDiag1(aM)
	o = new stzMatrix(aM)
	a = o.Diagonal1()
	if @@(o.Content()) = @@(aM) and len(a) > 0  return 1  ok
	return 0

# a deterministic n x n matrix of small numbers (a linear congruential generator, so no randomness)
func MxBig(n, nSeed)
	nS = nSeed
	aOut = []
	for i = 1 to n
		aRow = []
		for j = 1 to n
			nS = (nS * 1103515245 + 12345) % 2147483648
			aRow + ((nS % 1000) / 100 - 5)
		next
		aOut + aRow
	next
	return aOut

func MxSym(n, nSeed)
	aM = MxBig(n, nSeed)
	for i = 1 to n
		for j = 1 to i - 1
			aM[i][j] = aM[j][i]
		next
	next
	return aM

# upper triangular, distinct diagonal i * 1.3, so a full set of eigenvectors
func MxUpper(n, nSeed)
	aM = MxBig(n, nSeed)
	for i = 1 to n
		for j = 1 to i - 1
			aM[i][j] = 0
		next
		aM[i][i] = i * 1.3
	next
	return aM

# max over columns of || A v_j - EigenValues()[j] v_j ||
func MxResidual(aM)
	o = new stzMatrix(aM)
	aV = o.EigenVectors()
	aL = o.EigenValues()
	n = len(aM)
	nMax = 0
	for j = 1 to n
		nRes = 0
		for i = 1 to n
			nSum = 0
			for k = 1 to n
				nSum += aM[i][k] * aV[k][j]
			next
			nDiff = nSum - aL[j] * aV[i][j]
			nRes += nDiff * nDiff
		next
		if sqrt(nRes) > nMax  nMax = sqrt(nRes)  ok
	next
	return nMax

# max over columns of | ||v_j|| - 1 |
func MxNormErr(aM)
	aV = new stzMatrix(aM).EigenVectors()
	n = len(aM)
	nMax = 0
	for j = 1 to n
		nN = 0
		for i = 1 to n
			nN += aV[i][j] * aV[i][j]
		next
		if fabs(sqrt(nN) - 1) > nMax  nMax = fabs(sqrt(nN) - 1)  ok
	next
	return nMax

# 1 if, in every column, the first component of largest magnitude is positive
func MxSignOk(aM)
	aV = new stzMatrix(aM).EigenVectors()
	n = len(aM)
	for j = 1 to n
		nBig = 0
		for i = 1 to n
			if fabs(aV[i][j]) > nBig  nBig = fabs(aV[i][j])  ok
		next
		nPick = 0
		for i = 1 to n
			if nPick = 0 and fabs(aV[i][j]) >= nBig * 0.999999999  nPick = i  ok
		next
		if aV[nPick][j] < 0  return 0  ok
	next
	return 1

# dot product of columns j and k of a matrix
func MxDot(aV, j, k)
	nS = 0
	for i = 1 to len(aV)
		nS += aV[i][j] * aV[i][k]
	next
	return nS

# max |V'V - I|
func MxOrthErr(aV)
	n = len(aV)
	nMax = 0
	for j = 1 to n
		for k = 1 to n
			nT = 0
			if j = k  nT = 1  ok
			if fabs(MxDot(aV, j, k) - nT) > nMax  nMax = fabs(MxDot(aV, j, k) - nT)  ok
		next
	next
	return nMax

func MxBitSame(aA, aB)
	if @@(aA) != @@(aB)  return 0  ok
	for i = 1 to len(aA)
		for j = 1 to len(aA[i])
			if aA[i][j] != aB[i][j]  return 0  ok
		next
	next
	return 1

# modulus of column j of a matrix of stzComplex
func MxComplexNorm(aV, j)
	nS = 0
	for i = 1 to len(aV)
		nM = aV[i][j].Modulus()
		nS += nM * nM
	next
	return sqrt(nS)

# 1 if the real parts of ComplexEigenVectors equal EigenVectors and the imaginary parts are nil
func MxAgreesWithComplex(aM)
	o = new stzMatrix(aM)
	aR = o.EigenVectors()
	aC = o.ComplexEigenVectors()
	for i = 1 to len(aR)
		for j = 1 to len(aR)
			if fabs(aC[i][j].RealPart() - aR[i][j]) > 0.000000001  return 0  ok
			if fabs(aC[i][j].ImaginaryPart()) > 0.000000001  return 0  ok
		next
	next
	return 1

# milliseconds for nReps calls of EigenVectors on a fresh object
func MxTime(aM, nReps)
	o = new stzMatrix(aM)
	t0 = clock()
	for r = 1 to nReps
		o.EigenVectors()
	next
	return clock() - t0
