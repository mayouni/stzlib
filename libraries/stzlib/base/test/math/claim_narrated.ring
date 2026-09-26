# THE CLAIM GATE OF THE MATHEMATICS PLANE (M6) -- a statement a lesson makes
# is checked on a numeric floor here, on any machine, and emitted for Lean 4;
# the Lean door is opened when Lean and Mathlib are present and named closed
# when they are not. Every positive has its negative: a false statement FAILS
# on the floor with a counterexample, and a closed door is never a proof.
#
#   cd libraries/stzlib/base/test/math
#   ring claim_narrated.ring
load "../../stzBase.ring"

nOk = 0
nBad = 0
nSecClock = 0

sec("-- 1. A CLAIM IS DECLARED, AND A WRONG DECLARATION IS REFUSED BY NAME ---")

oC = StzMathClaimQ([ :kind = :Identity, :lhs = "3^2 + 4^2", :rhs = "5^2", :over = :Natural, :label = "three four five" ])
chk("a claim has a kind, a relation, two sides and a domain: " + oC.Statement(), oC.Kind() = "identity" and oC.Relation() = "=" and oC.Over() = "natural" and oC.Statement() = "3^2 + 4^2 = 5^2")
oS = StzMathClaimQ("1.5^2 != 3")
chk("one statement string is parsed into its kind by its relation: '1.5^2 != 3' is an inequality over the reals", oS.Kind() = "inequality" and oS.Relation() = "!=" and oS.Over() = "real" and oS.Lhs() = "1.5^2")
chk("'7 | 343' is a divisibility fact over the integers", StzMathClaimQ("7 | 343").Kind() = "divisibility" and StzMathClaimQ("7 | 343").Over() = "integer")
chk("the three kinds and the four domains", len(StzMathClaimKinds()) = 3 and len(StzMathClaimDomains()) = 4)
chk("a kind that is none of the three is refused", _McRefuses([ :kind = :Theorem, :lhs = "1", :rhs = "1" ], "kinds are"))
chk("an identity with a '<' is refused: an identity's relation is '='", _McRefuses([ :kind = :Identity, :relation = "<", :lhs = "1", :rhs = "2" ], "relation is '='"))
chk("divisibility over the reals is refused: it is a fact about integers", _McRefuses([ :kind = :Divisibility, :lhs = "2", :rhs = "6", :over = :Real ], "about integers"))
chk("a side is needed: no :rhs is refused", _McRefuses([ :kind = :Identity, :lhs = "1" ], "both sides"))
chk("a name outside the Lean subset is refused with the subset: gamma(3)", _McRefuses([ :kind = :Identity, :lhs = "gamma(3)", :rhs = "2" ], "not in the Lean subset"))
chk("a key that is not of a claim is refused with the keys", _McRefuses([ :kind = :Identity, :lhs = "1", :rhs = "1", :proof = "x" ], "not a key of a claim"))

sec("-- 2. THE FLOOR: EVERY STATEMENT IS EVALUATED, AND A FALSE ONE FAILS WITH A COUNTEREXAMPLE")

chk("3^2 + 4^2 = 5^2 is true on the floor", oC.IsTrue() = 1 and oC.LastCheck()[:route] = "numeric floor")
oW = StzMathClaimQ([ :kind = :Identity, :lhs = "3^2 + 4^2 + 1", :rhs = "5^2", :over = :Natural, :label = "the wrong formula" ])
aW = oW.Check()
chk("NEGATIVE: the wrong formula is FALSE, and the evidence says 26 against 25: " + aW[:evidence], aW[:verdict] = 0 and StzFindFirst("the sides are 26 and 25", aW[:evidence]) > 0)
oId = StzMathClaimQ([ :kind = :Identity, :lhs = "(a + b)^2", :rhs = "a^2 + 2*a*b + b^2", :vars = [ "a", "b" ], :label = "the square of a sum" ])
aId = oId.Check()
chk("an identity in two variables holds at every sampled point: " + aId[:evidence], aId[:verdict] = 1 and aId[:points] = 16)
oNo = StzMathClaimQ([ :kind = :Identity, :lhs = "(a + b)^2", :rhs = "a^2 + b^2", :vars = [ "a", "b" ], :label = "the freshman's dream" ])
aNo = oNo.Check()
chk("NEGATIVE: the freshman's dream fails, and the counterexample names the point: " + aNo[:evidence], aNo[:verdict] = 0 and StzFindFirst(" at a = ", aNo[:evidence]) > 0)
chk("1.7 < sqrt(3) holds; sqrt(3) < 1.7 does not", StzMathClaimQ("1.7 < sqrt(3)").IsTrue() = 1 and StzMathClaimQ("sqrt(3) < 1.7").IsTrue() = 0)
chk("7 | 343 holds; 7 | 344 does not", StzMathClaimQ("7 | 343").IsTrue() = 1 and StzMathClaimQ("7 | 344").IsTrue() = 0)
oDv = StzMathClaimQ([ :kind = :Divisibility, :lhs = "3", :rhs = "3*n", :over = :Integer, :vars = [ "n" ], :label = "three into three n" ])
chk("3 | 3n over the integers holds at sixteen integer points", oDv.IsTrue() = 1 and oDv.LastCheck()[:points] = 16)
oDn = StzMathClaimQ([ :kind = :Divisibility, :lhs = "n", :rhs = "12", :over = :Natural, :vars = [ "n" ], :label = "n into twelve" ])
chk("NEGATIVE: n | 12 fails on the first n that is no divisor, with the sides named: " + oDn.Check()[:evidence], oDn.IsTrue() = 0)
chk("a point where a side has no value is skipped, not counted: sqrt(a) = sqrt(a) holds where sqrt(a) exists", StzMathClaimQ([ :kind = :Identity, :lhs = "sqrt(a)", :rhs = "sqrt(a)", :vars = [ "a" ] ]).Check()[:points] < 16)
chk("Why() says the kind, the domain, the verdict and the door: " + oC.Why(), StzFindFirst("true on the floor", oC.Why()) > 0 and StzFindFirst("the Lean door is", oC.Why()) > 0)

sec("-- 3. LEAN, EMITTED: A THEOREM PER CLAIM, ITS TACTIC BY KIND, THE SUBSET SPELLED MATHLIB'S WAY")

cL = oC.ToLean()
chk("a closed identity over the naturals: 'theorem three_four_five : ((3^2 + 4^2 : ...) = 5^2) := by norm_num'", StzLeft(cL, 24) = "theorem three_four_five " and StzFindFirst("(3^2 + 4^2 : ", cL) > 0 and StzFindFirst(") = 5^2) := by norm_num", cL) > 0)
chk("...and its type is the naturals, N, not R", StzFindFirst(_McN(), cL) > 0 and StzFindFirst(_McR(), cL) = 0)
cV = oId.ToLean()
chk("an identity in variables binds them and closes by ring: '(a b : R) : (((a + b)^2 : R) = a^2 + 2*a*b + b^2) := by ring'", StzFindFirst("theorem the_square_of_a_sum (a b : " + _McR() + ") : (((a + b)^2 : " + _McR() + ") = a^2 + 2*a*b + b^2) := by ring", cV) = 1)
chk("a divisibility fact spells Mathlib's bar: '((7 : Z) | 343) := by norm_num'", StzFindFirst("((7 : " + _McZ() + ") " + _McDiv() + " 343) := by norm_num", StzMathClaimQ("7 | 343").ToLean()) > 0)
chk("!= becomes the not-equal sign and <= the less-or-equal sign", StzFindFirst(_McNe(), oS.ToLean()) > 0 and StzFindFirst(_McLe(), StzMathClaimQ("1 <= 2").ToLean()) > 0)
oSq = StzMathClaimQ([ :kind = :Identity, :lhs = "sqrt(3)^2", :rhs = "3", :label = "the root squared", :tactic = "rw [Real.sq_sqrt (by norm_num)]" ])
chk("sqrt is spelled Real.sqrt with a space before its argument, and the author's tactic replaces the default", StzFindFirst("Real.sqrt (3)^2", oSq.ToLean()) > 0 and StzFindFirst(":= by rw [Real.sq_sqrt (by norm_num)]", oSq.ToLean()) > 0)
chk("pi and e are Real.pi and (Real.exp 1)", StzFindFirst("Real.pi", StzMathClaimQ("pi > 3").ToLean()) > 0 and StzFindFirst("(Real.exp 1)", StzMathClaimQ("e > 2").ToLean()) > 0)
chk("a label becomes a theorem name: 'The zero lies above 1.7' -> the_zero_lies_above_1_7; a digit first is prefixed", StzMathClaimQ([ :kind = :Identity, :lhs = "1", :rhs = "1", :label = "The zero lies above 1.7" ]).TheoremName() = "the_zero_lies_above_1_7" and StzMathClaimQ([ :kind = :Identity, :lhs = "1", :rhs = "1", :label = "3 is 3" ]).TheoremName() = "claim_3_is_3")
chk("an inequality in variables closes by nlinarith by default", StzFindFirst(":= by nlinarith", StzMathClaimQ([ :kind = :Inequality, :relation = ">=", :lhs = "a^2 + b^2", :rhs = "2*a*b", :vars = [ "a", "b" ] ]).ToLean()) > 0)
chk("the emission is deterministic: the same claim emits the same text twice", oId.ToLean() = cV)

sec("-- 4. THE DOOR: CLOSED BY NAME ON THIS MACHINE, AND A CLOSED DOOR IS NEVER A PROOF")

aD = StzLeanDoor()
chk("on this machine the door is " + _McOpen(aD) + ": " + aD[:because], (aD[:open] = 0 and StzFindFirst("no lean executable", aD[:because]) > 0) or (aD[:open] = 1 and aD[:lean] != ""))
chk("with no lean and no project named, the reason names both", StzFindFirst("STZ_LEAN_PROJECT names no Lake project", StzLeanDoorXT("", "")[:because]) > 0)
chk("a project path that holds no lakefile is not a project", StzLeanDoorXT("", "C:/")[:open] = 0)
aCw = oC.CheckWithLean()
chk("CheckWithLean() carries the floor's verdict and the route it took: floor 1, route '" + aCw[:route] + "'", aCw[:floor] = 1 and (aCw[:route] = "door closed" or aCw[:route] = "lean"))
if aD[:open] = 0
	chk("...and with the door closed, proved is EMPTY, not 0 and not 1: the door's state is not a verdict", aCw[:proved] = "" and StzFindFirst("no lean executable", aCw[:because]) > 0)
else
	chk("...and with the door open, proved is a verdict", aCw[:proved] = 0 or aCw[:proved] = 1)
ok
# the half that reads Lean's answer, on Lean's own words
chk("an empty exit-0 run is a proof", StzLeanParseOutput("", 0)[:proved] = 1)
aE = StzLeanParseOutput("claims.lean:3:41: error: unsolved goals" + char(10) + "n : N" + char(10) + "|- False", 1)
chk("an error line is not, and the reason is Lean's own line", aE[:proved] = 0 and StzFindFirst("error: unsolved goals", aE[:because]) > 0)
chk("a non-zero exit without an error line is not, and the exit is named", StzFindFirst("lean exited with 2", StzLeanParseOutput("", 2)[:because]) > 0)
chk("a file that compiled with a sorry is NOT a proof", StzLeanParseOutput("warning: declaration uses 'sorry'", 0)[:proved] = 0)

sec("-- 5. ONE CHAPTER'S IDENTITIES, AS A SET: THE FLOOR IS GREEN, THE FILE IS WRITTEN, A FALSE ONE IS AN ERROR")

oSet = StzSelfCheckLessonClaims()
chk("chapter 15 states six claims: " + oSet.Why(), oSet.Count() = 6 and StzFindFirst("0 false on the numeric floor", oSet.Why()) > 0)
chk("the set's report is sound with no finding", oSet.IsSound() and oSet.Report().NumberOfFindings() = 0)
cFile = oSet.ToLean()
chk("the file imports Mathlib, names the lesson, and numbers its theorems c1_ .. c6_", StzFindFirst("import Mathlib", cFile) > 0 and StzFindFirst("an-identity-is-not-a-self-check", cFile) > 0 and StzFindFirst("theorem c1_three_four_five", cFile) > 0 and StzFindFirst("theorem c6_one_and_a_half_is_not_the_root", cFile) > 0)
cPath = "lean/an-identity-is-not-a-self-check.lean"
chk("...and equals the committed file byte for byte, so a machine with Lean runs what the gate saw", read(cPath) = cFile)
oBad = StzMathClaimSetQ("a tampered lesson")
oBad.Add(StzMathClaimQ([ :kind = :Identity, :lhs = "3^2 + 4^2", :rhs = "5^2 + 1", :over = :Natural, :label = "three four five, made false" ]))
oBad.Add(StzMathClaimQ("1.5^2 != 3"))
aF = oBad.Diagnostics()
chk("NEGATIVE: a statement made false is an error, claim_false, at its label, with the sides", len(aF) = 1 and aF[1][:rule] = "claim_false" and aF[1][:severity] = "error" and aF[1][:where] = "three four five, made false" and StzFindFirst("25 and 26", aF[1][:message]) > 0)
chk("...and the tampered lesson's report is not sound", NOT oBad.IsSound())
aSw = oSet.CheckWithLean()
chk("the whole set through the door: floor errors 0, route '" + aSw[:route] + "', " + aSw[:because], aSw[:floor_errors] = 0 and (aSw[:route] = "door closed" or aSw[:route] = "lean"))
chk("a set needs a lesson name; a claim that is not a claim is refused", _McSetRefuses())

#---------------------------------------------------------------------------

if nSecClock > 0
	? "        [section took " + ((clock() - nSecClock) / clockspersecond()) + "s]"
ok
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
if StzLeanDoor()[:open]
	? " skipped: none -- the Lean door is open and was walked through"
else
	? " skipped: the Lean half of M6's done-when (one chapter machine-checked) -- the door is closed on this machine: " + StzLeanDoor()[:because]
ok
? "=============================================================="

func sec cTitle
	if nSecClock > 0
		? "        [section took " + ((clock() - nSecClock) / clockspersecond()) + "s]"
	ok
	nSecClock = clock()
	? cTitle

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func _McRefuses aSpec, cWords
	_b_ = FALSE
	_c_ = ""
	try
		_o_ = StzMathClaimQ(aSpec)
	catch
		_b_ = TRUE
		_c_ = cCatchError
	done
	if NOT _b_  return FALSE  ok
	return StzFindFirst(cWords, _c_) > 0

func _McSetRefuses
	_n_ = 0
	try
		StzMathClaimSetQ("")
	catch
		_n_++
	done
	try
		StzMathClaimSetQ("x").Add(42)
	catch
		_n_++
	done
	return _n_ = 2

func _McOpen aD
	if aD[:open]  return "open"  ok
	return "closed"

# the Unicode Lean spells, kept out of the console
func _McN
	return StzUnicodeToChar(8469)
func _McZ
	return StzUnicodeToChar(8484)
func _McR
	return StzUnicodeToChar(8477)
func _McDiv
	return StzUnicodeToChar(8739)
func _McNe
	return StzUnicodeToChar(8800)
func _McLe
	return StzUnicodeToChar(8804)
