load "../../stzBase.ring"
load "../_narrated.ring"

# stzMatrex -- the defect register, one scenario per family, each fact worked out by hand.
# Run from inside test/matrex.
#
# Hand-checked facts the scenarios rest on:
#   the determinant of [[1,2],[3,4]] is 1*4 - 2*3 = -2, and the sum of its cells is 10
#   the sum of 1..9 laid out as a 3x3 is 45, and that matrix is not symmetric (2 against 4)
#   [[1,2],[2,1]] is symmetric, [[1,0],[0,1]] is the identity, [[0,0],[0,0]] is zero
#
# FIXED   : CheckSize (3xn, mx3, >n, <n), MatchesNone is NOT here (see below), RemoveConstraint,
#           SimilarityScore (wrapped forms), CommonProperties, Andd, Not_, ToJSON, TokensToJSON, TokenToJSON
# STUBS   : CheckRows, CheckCols, CheckPattern, CheckSum, CheckDiagonal, CheckDeterminant -- the syntax and
#           the meaning of their terms are stated nowhere, so the stub is kept and the guard pins what it does
# DECISION: MatchesNone answers TRUE when something matches; test/matrex/27 expects it

aA33  = [ [1,2,3], [4,5,6], [7,8,9] ]
aA32  = [ [1,2], [3,4], [5,6] ]
aA23  = [ [1,2,3], [4,5,6] ]
aA24  = [ [1,2,3,4], [5,6,7,8] ]
aA22  = [ [1,2], [3,4] ]
aSym2 = [ [1,2], [2,1] ]
aSym3 = [ [1,2,3], [2,4,5], [3,5,6] ]
aId2  = [ [1,0], [0,1] ]
aZero2 = [ [0,0], [0,0] ]
aRow  = [ [1,2,3] ]
aCol  = [ [1], [2], [3] ]
aOne  = [ [7] ]

Scenario("Size: a number, or m and n for any count")
	Then("3xn needs 3 rows: a 3x3 passes", MxMatch("{size(3xn)}", aA33), 1)
	Then("3xn: a 3x2 passes", MxMatch("{size(3xn)}", aA32), 1)
	Then("3xn: a 2x3 does not", MxMatch("{size(3xn)}", aA23), 0)
	Then("3xn: a 2x4 does not", MxMatch("{size(3xn)}", aA24), 0)
	Then("mx3 needs 3 columns: a 2x3 passes", MxMatch("{size(mx3)}", aA23), 1)
	Then("mx3: a 3x3 passes", MxMatch("{size(mx3)}", aA33), 1)
	Then("mx3: a 3x2 does not", MxMatch("{size(mx3)}", aA32), 0)
	Then("2xm needs 2 rows: a 2x4 passes", MxMatch("{size(2xm)}", aA24), 1)
	Then("2xm: a 3x3 does not", MxMatch("{size(2xm)}", aA33), 0)
	Then("nx2 needs 2 columns: a 3x2 passes", MxMatch("{size(nx2)}", aA32), 1)
	Then("nx2: a 2x4 does not", MxMatch("{size(nx2)}", aA24), 0)
	Then("mxn still accepts every size", MxMatch("{size(mxn)}", aA24), 1)
	Then("3x3 stays exact: the 3x3", MxMatch("{size(3x3)}", aA33), 1)
	Then("3x3 stays exact: the 3x2 is rejected", MxMatch("{size(3x3)}", aA32), 0)
	Then("capitals are read like lowercase: 3XN", MxMatch("{size(3XN)}", aA32), 1)
	Then("a size of no known form is not satisfied: size(abc)", MxMatch("{size(abc)}", aA33), 0)
	Then("a lone number is not a size: size(3)", MxMatch("{size(3)}", aA33), 0)
	Then("three sides is not a size: size(3x3x3)", MxMatch("{size(3x3x3)}", aA33), 0)
	Then("a number with no side is not a size: size(3x)", MxMatch("{size(3x)}", aA33), 0)
	Then("an empty size() states nothing, so it holds", MxMatch("{size()}", aA33), 1)
EndScenario()

Scenario("Size: > and < apply to both dimensions, strictly")
	Then(">2 holds for a 3x3", MxMatch("{size(>2)}", aA33), 1)
	Then(">2 holds for a 3x4", MxMatch("{size(>2)}", [ [1,2,3,4], [1,2,3,4], [1,2,3,4] ]), 1)
	Then(">2 does not hold for a 2x2", MxMatch("{size(>2)}", aA22), 0)
	Then(">2 does not hold for a 3x2: one dimension is not above 2", MxMatch("{size(>2)}", aA32), 0)
	Then(">3 is strict: the 3x3 is rejected", MxMatch("{size(>3)}", aA33), 0)
	Then(">0 holds for a 1x1", MxMatch("{size(>0)}", aOne), 1)
	Then("<3 holds for a 2x2", MxMatch("{size(<3)}", aA22), 1)
	Then("<3 is strict: the 3x3 is rejected", MxMatch("{size(<3)}", aA33), 0)
	Then("<3 does not hold for a 2x3: one dimension is not below 3", MxMatch("{size(<3)}", aA23), 0)
	Then("<2 does not hold for a 2x2", MxMatch("{size(<2)}", aA22), 0)
	Then("<2 holds for a 1x1", MxMatch("{size(<2)}", aOne), 1)
	Then("a number after the sign is required: size(>)", MxMatch("{size(>)}", aA33), 0)
	Then("a comparison joins other terms: >2 and symmetric", MxMatch("{size(>2) & property(symmetric)}", aSym3), 1)
	Then("... and the same pattern rejects a non symmetric 3x3", MxMatch("{size(>2) & property(symmetric)}", aA33), 0)
	Then("a negated comparison is the opposite: @!size(>2) on a 2x2", MxMatch("{@!size(>2)}", aA22), 1)
	Then("... and on a 3x3", MxMatch("{@!size(>2)}", aA33), 0)
	oS = new stzMatrex("{size(3xn)}")
	aTokens = oS.Tokens()
	aTok = aTokens[1]
	Then("CheckSize reads the token directly: true", oS.CheckSize(aTok, aA32), 1)
	Then("CheckSize reads the token directly: false", oS.CheckSize(aTok, aA23), 0)
EndScenario()

Scenario("Stubs kept: a term with no stated meaning tests nothing")
	Given("the cells of 1..9 add up to 45 and [[1,2],[3,4]] has determinant 1*4-2*3 = -2")
	nSum = 0
	for i = 1 to 9
		nSum += i
	next
	Then("the sum of 1..9 is 45 (hand check)", nSum, 45)
	Then("the determinant of [[1,2],[3,4]] is -2 (hand check)", (1*4) - (2*3), -2)
	Then("row(3) accepts the 3x3", MxMatch("{row(3)}", aA33), 1)
	Then("row(3) also accepts the 2x4: it tests nothing", MxMatch("{row(3)}", aA24), 1)
	Then("col(2) accepts the 3x3: it tests nothing", MxMatch("{col(2)}", aA33), 1)
	Then("pattern(checkerboard) accepts the 2x2: it tests nothing", MxMatch("{pattern(checkerboard)}", aA22), 1)
	Then("sum(45) accepts the 1..9 matrix", MxMatch("{sum(45)}", aA33), 1)
	Then("sum(1) accepts it too: the sum is computed and ignored", MxMatch("{sum(1)}", aA33), 1)
	Then("determinant(-2) accepts [[1,2],[3,4]]", MxMatch("{determinant(-2)}", aA22), 1)
	Then("determinant(5) accepts it too: only squareness is tested", MxMatch("{determinant(5)}", aA22), 1)
	Then("determinant(5) rejects a matrix that is not square", MxMatch("{determinant(5)}", aA24), 0)
	Then("diagonal(1) accepts a square matrix whatever its diagonal", MxMatch("{diagonal(1)}", aA22), 1)
	Then("diagonal(1) rejects a matrix that is not square", MxMatch("{diagonal(1)}", aA24), 0)
	Then("a stub still obeys @!: @!row(3) rejects every matrix", MxMatch("{@!row(3)}", aA33), 0)
EndScenario()

Scenario("MatchesNone: kept as it answers, pinned until the author decides")
	oS = new stzMatrex("{property(symmetric)}")
	Then("no matrix of [2x2, 2x2] is symmetric: FALSE, as test 27 expects", oS.MatchesNone([ aA22, [ [5,6], [7,8] ] ]), 0)
	Then("one symmetric matrix in the list: TRUE", oS.MatchesNone([ aA22, aSym2 ]), 1)
	Then("the none-matches question is CountMatchingMatrices = 0: it holds when nothing matches", oS.CountMatchingMatrices([ aA22, [ [5,6], [7,8] ] ]) = 0, 1)
	Then("... and fails when one matches", oS.CountMatchingMatrices([ aA22, aSym2 ]) = 0, 0)
	Then("the in-form is read the same: MatchesNone(:In = list)", oS.MatchesNone([ "in", [ aA22, aSym2 ] ]), 1)
EndScenario()

Scenario("RemoveConstraint: the pattern text and the tokens go together")
	oRem = new stzMatrex("{size(2x2) -> property(symmetric) -> element(0..9)}")
	Then("three terms to start with", len(oRem.Tokens()), 3)
	Then("[[1,2],[3,4]] is not symmetric, so the pattern rejects it", oRem.Match(aA22), 0)
	oRem.RemoveConstraint(2)
	Then("the pattern text drops the term", oRem.Pattern(), "{size(2x2) -> element(0..9)}")
	Then("two tokens remain", len(oRem.Tokens()), 2)
	aEx = oRem.Explain()
	Then("Explain counts the same two tokens", aEx[2][2], 2)
	Then("the matrix is accepted now: the symmetric term is gone", oRem.Match(aA22), 1)
	Then("... and the size term still rejects a 3x3", oRem.Match(aA33), 0)
	oRem.RemoveConstraint(5)
	Then("a position above the last changes nothing", oRem.Pattern(), "{size(2x2) -> element(0..9)}")
	oRem.RemoveConstraint(0)
	Then("position 0 changes nothing", oRem.Pattern(), "{size(2x2) -> element(0..9)}")
	oRem.RemoveConstraint(1)
	Then("removing the first term leaves the second", oRem.Pattern(), "{element(0..9)}")
	oRem.RemoveConstraint(1)
	Then("removing the last term leaves an empty pattern", oRem.Pattern(), "{}")
	Then("an empty pattern accepts every matrix", oRem.Match(aA33), 1)
	oC = new stzMatrex("{size(3x3) & property(symmetric)}")
	oC.RemoveConstraint(1)
	Then("a term that holds & goes whole", oC.Pattern(), "{}")
	oAdd = new stzMatrex("{size(3x3)}")
	oAdd.AddConstraint("property(symmetric)")
	Then("AddConstraint rejects the non symmetric 3x3", oAdd.Match(aA33), 0)
	oAdd.RemoveConstraint(2)
	Then("RemoveConstraint takes it back: the pattern is the first one again", oAdd.Pattern(), "{size(3x3)}")
	Then("... and the 3x3 matches again", oAdd.Match(aA33), 1)
	Then("a position that is not a number raises", MxRaisesRemove("a"), 1)
	Then("a number does not raise", MxRaisesRemove(1), 0)
EndScenario()

Scenario("SimilarityScore: plain and wrapped forms")
	oS = new stzMatrex("")
	Then("identical matrices score 1", oS.SimilarityScore(aA22, aA22), 1)
	Then("one cell of four differs: 0.75", oS.SimilarityScore(aA22, [ [1,2], [3,0] ]), 0.75)
	Then("two cells of four equal: 0.5", oS.SimilarityScore(aA22, [ [1,0], [0,4] ]), 0.5)
	Then("no cell equal: 0", oS.SimilarityScore(aA22, [ [0,0], [0,0] ]), 0)
	Then("matrices of other sizes score 0", oS.SimilarityScore(aA22, aA33), 0)
	Then("the wrapped form [between, m] and [and, m] gives the plain answer", oS.SimilarityScore([ "between", aA22 ], [ "and", [ [1,2], [3,0] ] ]), 0.75)
	Then("the wrapped identical pair scores 1", oS.SimilarityScore([ "between", aA22 ], [ "and", aA22 ]), 1)
	Then("only the first wrapped is read too", oS.SimilarityScore([ "between", aA22 ], aA22), 1)
	Then("only the second wrapped is read too", oS.SimilarityScore(aA22, [ "and", aA22 ]), 1)
	Then("SimilarityScoreBetween agrees", oS.SimilarityScoreBetween(aA22, [ [1,2], [3,0] ]), 0.75)
	Then("an unknown wrapper is still refused", MxRaisesScore([ "with", aA22 ], aA22), 1)
	Then("a plain pair does not raise", MxRaisesScore(aA22, aA22), 0)
EndScenario()

Scenario("CommonProperties: square is reported, and nothing matching means nothing common")
	oS = new stzMatrex("{size(2x2)}")
	Then("an identity: everything an identity has but zero", @@(oS.CommonProperties([ aId2 ])), '[ "square", "symmetric", "diagonal", "identity", "upper", "lower" ]')
	Then("identity and zero share what both have, square included", @@(oS.CommonProperties([ aId2, aZero2 ])), '[ "square", "symmetric", "diagonal", "upper", "lower" ]')
	Then("a symmetric matrix that is not diagonal", @@(oS.CommonProperties([ aSym2 ])), '[ "square", "symmetric" ]')
	Then("a matrix that is neither: only square", @@(oS.CommonProperties([ aA22 ])), '[ "square" ]')
	Then("a matrix that does not match the pattern is left out", @@(oS.CommonProperties([ aId2, aA33 ])), '[ "square", "symmetric", "diagonal", "identity", "upper", "lower" ]')
	Then("when no matrix matches there is nothing in common", @@(oS.CommonProperties([ aA33, aA24 ])), "[ ]")
	oW = new stzMatrex("{shape(rectangular)}")
	Then("a zero 2x3 is zero and nothing else here", @@(oW.CommonProperties([ [ [0,0,0], [0,0,0] ] ])), '[ "zero" ]')
	Then("property(square) is a property now: the 2x2 has it", MxMatch("{property(square)}", aA22), 1)
	Then("property(square): the 2x3 has not", MxMatch("{property(square)}", aA23), 0)
	Then("property(square) agrees with shape(square) on a 3x3", MxMatch("{property(square)}", aA33), 1)
EndScenario()

Scenario("Andd: the same answer as And_")
	oA = new stzMatrex("{size(3x3)}")
	oB = new stzMatrex("{property(symmetric)}")
	oAnd = oA.Andd(oB)
	oAnd2 = oA.And_(oB)
	Then("Andd joins the two patterns with &", oAnd.Pattern(), "{size(3x3) & property(symmetric)}")
	Then("And_ gives the same pattern", oAnd2.Pattern(), oAnd.Pattern())
	Then("a symmetric 3x3 matches", oAnd.Match(aSym3), 1)
	Then("a non symmetric 3x3 does not", oAnd.Match(aA33), 0)
	Then("a symmetric 2x2 does not: the size term holds the line", oAnd.Match(aSym2), 0)
	Then("the first original is unchanged", oA.Pattern(), "{size(3x3)}")
	Then("the second original is unchanged", oB.Pattern(), "{property(symmetric)}")
	Then("a value that is not a stzMatrex raises", MxRaisesAndd("{size(3x3)}"), 1)
EndScenario()

Scenario("Not_: the opposite of the whole pattern, not of its first term")
	oD = new stzMatrex("{property(diagonal)}")
	oND = oD.Not_()
	Then("a single term: the diagonal matrix is rejected", oND.Match([ [1,0], [0,2] ]), 0)
	Then("a single term: the non diagonal matrix is accepted", oND.Match(aA22), 1)

	oAnd = new stzMatrex("{size(2x2) & property(symmetric)}")
	oNAnd = oAnd.Not_()
	Then("the negated pattern is written around one group", oNAnd.Pattern(), "{@!(size(2x2) & property(symmetric))}")
	aNT = oNAnd.Tokens()
	aNC = aNT[1][2][2]
	Then("the negated pattern is one conjunction holding one condition", len(aNC), 1)
	Then("that condition is a group token, marked negated", aNC[1][1][2] + ":" + aNC[1][3][2], "group:1")
	Then("& : a 2x2 symmetric matrix is the one thing rejected", oNAnd.Match(aSym2), 0)
	Then("& : a 2x2 that is not symmetric is accepted (first term holds, second fails)", oNAnd.Match(aA22), 1)
	Then("& : a symmetric 3x3 is accepted (second term holds, first fails)", oNAnd.Match(aSym3), 1)
	Then("& : a 2x3 that is not symmetric is accepted (both terms fail)", oNAnd.Match(aA23), 1)

	aAll = [ aA33, aA32, aA23, aA24, aA22, aSym2, aSym3, aId2, aZero2, aRow, aCol, aOne ]
	Then("& : on twelve matrices the pattern and its negation always disagree", MxDisagreements(oAnd, oNAnd, aAll), 12)

	oOr = new stzMatrex("{shape(row) | shape(column)}")
	oNOr = oOr.Not_()
	Then("| : a row vector is rejected", oNOr.Match(aRow), 0)
	Then("| : a column vector is rejected", oNOr.Match(aCol), 0)
	Then("| : a 2x2 is accepted", oNOr.Match(aA22), 1)
	Then("| : on twelve matrices the two always disagree", MxDisagreements(oOr, oNOr, aAll), 12)

	oSeq = new stzMatrex("{size(2x2) -> property(symmetric)}")
	oNSeq = oSeq.Not_()
	Then("-> : the 2x2 symmetric matrix is rejected", oNSeq.Match(aSym2), 0)
	Then("-> : the 2x2 non symmetric matrix is accepted", oNSeq.Match(aA22), 1)
	Then("-> : the symmetric 3x3 is accepted", oNSeq.Match(aSym3), 1)
	Then("-> : on twelve matrices the two always disagree", MxDisagreements(oSeq, oNSeq, aAll), 12)

	oBack = oNAnd.Not_()
	Then("negating twice gives the original answers", MxDisagreements(oAnd, oBack, aAll), 0)
	Then("the original object is unchanged", oAnd.Pattern(), "{size(2x2) & property(symmetric)}")

	oEmpty = new stzMatrex("")
	oNEmpty = oEmpty.Not_()
	Then("an empty pattern accepts every matrix", oEmpty.Match(aA33), 1)
	Then("its negation accepts none", oNEmpty.Match(aA33), 0)

	oG = new stzMatrex("{size(2x2) & (property(symmetric))}")
	Then("a parenthesised group is a term: symmetric 2x2 holds", oG.Match(aSym2), 1)
	Then("... and the group still tests: a non symmetric 2x2 fails", oG.Match(aA22), 0)
	oN3 = new stzMatrex("{@!property(symmetric)}")
	Then("the one-term form @!term is unchanged: a symmetric matrix is rejected", oN3.Match(aSym2), 0)
	Then("... and the other accepted", oN3.Match(aA22), 1)
EndScenario()

Scenario("Match: a known gap, pinned so that fixing it updates the doc")
	Then("a group of alternatives followed by & drops the second term: a non diagonal 2x2 passes", MxMatch("{(size(2x2) | size(3x3)) & property(diagonal)}", aA22), 1)
EndScenario()

Scenario("JSON: tokens as objects, text escaped by the library writer")
	oE = new stzMatrex("")
	Then("an empty pattern", oE.ToJSON(), '{"pattern":"{}","tokens":[]}')
	Then("no tokens: an empty array", oE.TokensToJSON(), "[]")

	oS = new stzMatrex("{size(2x2)}")
	cTok = '{"type":"size","value":"2x2","constraints":[],"min":1,"max":1,"negated":0}'
	aSTokens = oS.Tokens()
	Then("one size token as an object, an empty list as []", oS.TokenToJSON(aSTokens[1]), cTok)
	Then("the tokens as an array", oS.TokensToJSON(), "[" + cTok + "]")
	Then("the whole pattern", oS.ToJSON(), '{"pattern":"{size(2x2)}","tokens":[' + cTok + ']}')

	oRg = new stzMatrex("{element(0..9)}")
	Then("a range constraint is an object, numbers stay numbers", oRg.TokensToJSON(), '[{"type":"element","value":"","constraints":[{"type":"range","start":0,"end":9}],"min":1,"max":1,"negated":0}]')

	oSt = new stzMatrex("{element({1;2})}")
	Then("a set constraint holds an array of its values", oSt.TokensToJSON(), '[{"type":"element","value":"","constraints":[{"type":"set","values":["1","2"]}],"min":1,"max":1,"negated":0}]')

	oNg = new stzMatrex("{@!property(zero)}")
	Then("a negated token says negated 1", oNg.TokensToJSON(), '[{"type":"property","value":"zero","constraints":[],"min":1,"max":1,"negated":1}]')

	oCj = new stzMatrex("{size(2x2) & property(symmetric)}")
	cJ = oCj.ToJSON()
	Then("a conjunction is valid JSON", IsJsonString(cJ), 1)
	Then("... and carries its two conditions as an array", StzFindFirst('"conditions":[{"type":"size"', cJ) > 0, 1)
	aBack = JsonToList(cJ)
	Then("reading it back gives the pattern text", aBack[:pattern], "{size(2x2) & property(symmetric)}")

	oAl = new stzMatrex("{shape(square) | shape(row)}")
	Then("an alternation is valid JSON", IsJsonString(oAl.ToJSON()), 1)
	Then("... and carries its alternatives as an array", StzFindFirst('"alternatives":[{"type":"shape","value":"square"', oAl.ToJSON()) > 0, 1)

	oGp = oCj.Not_()
	Then("a negated group is valid JSON", IsJsonString(oGp.ToJSON()), 1)
	Then("... and carries its inner tokens as an array", StzFindFirst('"type":"group","tokens":[{"type":"conjunction"', oGp.ToJSON()) > 0, 1)

	oQ = new stzMatrex('{size(2x2) & say"hi\there}')
	cQ = oQ.ToJSON()
	Then("a quote and a backslash in the pattern are escaped: still valid JSON", IsJsonString(cQ), 1)
	Then("... the quote is written with a backslash before it", StzFindFirst("\" + char(34), cQ) > 0, 1)
	aQ = JsonToList(cQ)
	Then("... and reading it back gives the same pattern text", aQ[:pattern], oQ.Pattern())

	oMany = new stzMatrex("{size(2x2) -> property(symmetric) -> element(0..9)}")
	Then("three parts, three objects in the array: the last one is the element", StzFindFirst('{"type":"element"', oMany.TokensToJSON()) > 0, 1)
	Then("the array is valid JSON", IsJsonString(oMany.TokensToJSON()), 1)
EndScenario()

Summary()

func MxMatch(cPattern, aMatrix)
	oX = new stzMatrex(cPattern)
	return oX.Match(aMatrix)

func MxDisagreements(oP, oQ, aMatrices)
	n = 0
	nLen = len(aMatrices)
	for i = 1 to nLen
		if oP.Match(aMatrices[i]) != oQ.Match(aMatrices[i])
			n++
		ok
	next
	return n

func MxRaisesRemove(x)
	try
		oX = new stzMatrex("{size(2x2) -> property(symmetric)}")
		oX.RemoveConstraint(x)
		return 0
	catch
		return 1
	done

func MxRaisesScore(a, b)
	try
		oX = new stzMatrex("")
		oX.SimilarityScore(a, b)
		return 0
	catch
		return 1
	done

func MxRaisesAndd(x)
	try
		oX = new stzMatrex("{size(2x2)}")
		oX.Andd(x)
		return 0
	catch
		return 1
	done
