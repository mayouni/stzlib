#=====================================================================#
#  STZMATHCLAIM -- a statement a lesson makes, checked on a floor and  #
#  emitted for Lean 4 (SOFTANZA_MATH_PLAN.md M6; plane stzlib-math)    #
#=====================================================================#
/*
	A claim is a statement with a kind, two sides and a domain:

	    oC = StzMathClaimQ([ :kind = :Identity, :lhs = "3^2 + 4^2", :rhs = "5^2",
	                         :over = :Natural, :label = "three four five" ])
	    ? oC.IsTrue()
	    #--> 1
	    ? oC.ToLean()
	    #--> theorem three_four_five : ((3^2 + 4^2 : N) = 5^2) := by norm_num

	Three kinds: an identity (=), an inequality (<, <=, >, >=, !=) and a
	divisibility fact (|). Four domains: natural, integer, rational, real.
	Variables are named (:vars = [ "a", "b" ]) and become the theorem's
	binders; the expression subset is what stzMathFunction reads and Lean
	spells: + - * / ^, parentheses, numerals, sqrt, abs, exp, log, sin, cos,
	tan, pi. Anything else is refused by name.

	TWO ROUTES, ONE FLOOR (charter law 9, decision 5). The floor is numeric:
	the two sides are compiled by the engine and evaluated at sampled points,
	so a false statement fails HERE, on any machine, with a counterexample.
	Lean is a door: StzLeanDoor() says whether `lean` and a Mathlib project
	are on this machine; StzLeanCheck() runs the emitted theorem there when
	they are and carries the verdict back, and reports the door closed by
	name when they are not. Lean is never a dependency of the library.

	A set of claims (StzMathClaimSetQ) is one lesson's statements: one .lean
	file, one report in the house rule shape (rule claim_false is an error),
	and IsSound() over it.
*/

func StzMathClaimQ(paSpec)
	return new stzMathClaim(paSpec)

func StzMathClaimSetQ(pcLesson)
	return new stzMathClaimSet(pcLesson)

func StzMathClaimKinds()
	return [ "identity", "inequality", "divisibility" ]

func StzMathClaimDomains()
	return [ "natural", "integer", "rational", "real" ]

func StzMathClaimRelations()
	return [ "=", "!=", "<", "<=", ">", ">=", "|" ]

# the names the Lean subset spells, and how
func StzMathClaimLeanNames()
	return [ [ "sqrt", "Real.sqrt" ], [ "abs", "abs" ], [ "exp", "Real.exp" ], [ "log", "Real.log" ],
	         [ "sin", "Real.sin" ], [ "cos", "Real.cos" ], [ "tan", "Real.tan" ], [ "pi", "Real.pi" ] ]

func StzMathClaimSamples()
	return [ 0, 1, -1, 0.5, 2, -2, 3, 0.25, 1.5, -0.75, 7, -3, 10, 0.1, -0.1, 4 ]

func StzMathClaimNaturalSamples()
	return [ 0, 1, 2, 3, 5, 7, 10, 12, 15, 20, 4, 6, 8, 9, 11, 13 ]

#-- THE DOOR --------------------------------------------------------------------

# is Lean on this machine? `lean` on PATH (or STZ_LEAN naming it) and a Lake
# project holding Mathlib named by STZ_LEAN_PROJECT. Answers by name either way.
func StzLeanDoor()
	return StzLeanDoorXT(sysget("STZ_LEAN"), sysget("STZ_LEAN_PROJECT"))

func StzLeanDoorXT(pcLean, pcProject)
	_cLean_ = "" + pcLean
	if _cLean_ != "" and NOT fexists(_cLean_)
		_cLean_ = ""
	ok
	if _cLean_ = ""
		_cExe_ = "lean"
		if isWindows()  _cExe_ = "lean.exe"  ok
		_cSep_ = ":"
		if isWindows()  _cSep_ = ";"  ok
		_acDirs_ = StzSplit("" + sysget("PATH"), _cSep_)
		for _i_ = 1 to len(_acDirs_)
			_cD_ = ring_trim(_acDirs_[_i_])
			if _cD_ = ""  loop  ok
			if fexists(_cD_ + "/" + _cExe_)
				_cLean_ = _cD_ + "/" + _cExe_
				exit
			ok
		next
	ok
	_cProj_ = "" + pcProject
	if _cProj_ != "" and NOT (fexists(_cProj_ + "/lakefile.lean") or fexists(_cProj_ + "/lakefile.toml"))
		_cProj_ = ""
	ok
	_bOpen_ = 0
	_cWhy_ = ""
	if _cLean_ = "" and _cProj_ = ""
		_cWhy_ = "no lean executable on PATH or in STZ_LEAN, and STZ_LEAN_PROJECT names no Lake project"
	but _cLean_ = ""
		_cWhy_ = "no lean executable on PATH or in STZ_LEAN"
	but _cProj_ = ""
		_cWhy_ = "lean found at " + _cLean_ + " but STZ_LEAN_PROJECT names no Lake project holding Mathlib"
	else
		_bOpen_ = 1
		_cWhy_ = "lean at " + _cLean_ + ", project at " + _cProj_
	ok
	return [ :open = _bOpen_, :lean = _cLean_, :project = _cProj_, :because = _cWhy_ ]

# Lean's verdict from what it printed: an empty, exit-0 run is a proof; an
# error line, a non-zero exit, or a 'sorry' warning is not
func StzLeanParseOutput(pcOutput, pnExit)
	_c_ = "" + pcOutput
	if pnExit != 0
		_cLine_ = _LcFirstLineWith(_c_, "error")
		if _cLine_ = ""  _cLine_ = "lean exited with " + pnExit  ok
		return [ :proved = 0, :because = _cLine_ ]
	ok
	_cErr_ = _LcFirstLineWith(_c_, "error")
	if _cErr_ != ""
		return [ :proved = 0, :because = _cErr_ ]
	ok
	_cSorry_ = _LcFirstLineWith(_c_, "sorry")
	if _cSorry_ != ""
		return [ :proved = 0, :because = "the file compiled with a sorry, which is not a proof: " + _cSorry_ ]
	ok
	return [ :proved = 1, :because = "lean accepted the file" ]

func StzLeanTimeoutMs()
	return 600000

func _LcFirstLineWith(pcText, pcWord)
	_ac_ = StzSplit(pcText, char(10))
	for _i_ = 1 to len(_ac_)
		if StzFindFirst(pcWord, StzLower(_ac_[_i_])) > 0  return ring_trim(_ac_[_i_])  ok
	next
	return ""

# run one .lean text through the door: written into the project as
# stz_claims/<name>.lean and checked with `lake env lean`; the answer carries
# the route it took, so a closed door is never mistaken for a proof
func StzLeanCheck(pcLeanText, pcName)
	_d_ = StzLeanDoor()
	if NOT _d_[:open]
		return [ :route = "door closed", :proved = "", :because = _d_[:because], :file = "" ]
	ok
	_cDir_ = _d_[:project] + "/stz_claims"
	if NOT direxists(_cDir_)  system('mkdir "' + _cDir_ + '"')  ok
	_cFile_ = _cDir_ + "/" + _LcSlug(pcName) + ".lean"
	write(_cFile_, pcLeanText)
	# THE RUNNER is a two-line batch file beside the claims, so no quoting
	# crosses cmd: it steps into the project and hands lake the file
	_cRun_ = _cDir_ + "/run.cmd"
	if NOT fexists(_cRun_)
		write(_cRun_, 'cd /d "%~dp0.."' + char(13) + char(10) + 'lake env lean "%~1"' + char(13) + char(10))
	ok
	_o_ = StzSystemCallQ("cmd.exe")
	_o_.SetArgs([ "/c", StzReplace(_cRun_, "/", char(92)), StzReplace(_cFile_, "/", char(92)) ])
	_o_.HideConsole()
	# a Mathlib import takes about 25 s on this machine and more when the
	# files are cold; the call's default timeout killed lean at exit 143
	# (SIGTERM) once the disk cache had moved on, so the door waits ten minutes
	_o_.SetTimeout(StzLeanTimeoutMs())
	_o_.Run()
	_v_ = StzLeanParseOutput(_o_.Output() + char(10) + _o_.Error(), _o_.ExitCode())
	return [ :route = "lean", :proved = _v_[:proved], :because = _v_[:because], :file = _cFile_ ]

# a theorem name from a label: lowercase, runs of anything else become one
# underscore, and a name that would start with a digit is prefixed
func _LcSlug(pcLabel)
	_c_ = StzLower(ring_trim("" + pcLabel))
	_r_ = ""
	_bUnder_ = 0
	for _i_ = 1 to len(_c_)
		_ch_ = _c_[_i_]
		if isalnum(_ch_)
			_r_ += _ch_
			_bUnder_ = 0
		else
			if NOT _bUnder_ and _r_ != ""  _r_ += "_"  ok
			_bUnder_ = 1
		ok
	next
	if len(_r_) > 0 and _r_[len(_r_)] = "_"  _r_ = StzLeft(_r_, len(_r_) - 1)  ok
	if _r_ = ""  _r_ = "claim"  ok
	if isdigit(_r_[1])  _r_ = "claim_" + _r_  ok
	return _r_

# an expression in Lean's spelling: the subset's names mapped by the table
# above, everything else passed through, an unknown name refused
func _LcExpr(pcExpr)
	_c_ = "" + pcExpr
	_n_ = len(_c_)
	_r_ = ""
	_i_ = 1
	_aMap_ = StzMathClaimLeanNames()
	while _i_ <= _n_
		_ch_ = _c_[_i_]
		if isalpha(_ch_) or _ch_ = "_"
			_cW_ = ""
			while _i_ <= _n_ and (isalnum(_c_[_i_]) or _c_[_i_] = "_")
				_cW_ += _c_[_i_]
				_i_++
			end
			_cM_ = ""
			for _k_ = 1 to len(_aMap_)
				if _aMap_[_k_][1] = StzLower(_cW_)  _cM_ = _aMap_[_k_][2]  ok
			next
			if _cM_ != ""
				_r_ += _cM_
				# a function name is followed by its argument in parentheses: Lean wants a space
				if _i_ <= _n_ and _c_[_i_] = "("  _r_ += " "  ok
			but StzLower(_cW_) = "e"
				_r_ += "(Real.exp 1)"
			but len(_cW_) <= 2 or _LcIsKnownName(_cW_)
				_r_ += _cW_
			else
				stzraise("stzMathClaim: '" + _cW_ + "' is not in the Lean subset -- the names are " + _LcNames() + " and single-letter variables.")
			ok
		else
			_r_ += _ch_
			_i_++
		ok
	end
	return _r_

func _LcIsKnownName(pcW)
	return 0

func _LcNames()
	_aMap_ = StzMathClaimLeanNames()
	_c_ = ""
	for _k_ = 1 to len(_aMap_)
		if _c_ != ""  _c_ += ", "  ok
		_c_ += _aMap_[_k_][1]
	next
	return _c_

func _LcType(pcOver)
	if pcOver = "natural"  return "ℕ"  ok
	if pcOver = "integer"  return "ℤ"  ok
	if pcOver = "rational"  return "ℚ"  ok
	return "ℝ"

func _LcRelation(pcRel)
	if pcRel = "!="  return "≠"  ok
	if pcRel = "<="  return "≤"  ok
	if pcRel = ">="  return "≥"  ok
	if pcRel = "|"  return "∣"  ok
	return pcRel

#-- THE CLAIM --------------------------------------------------------------------

# States one mathematical claim, an identity, an inequality or a divisibility, checks it numerically and writes it as a Lean 4 theorem.
#
# A claim has a kind, a left and a right side, a relation and a domain (natural, integer, rational
# or real); name its variables with vars and they become the theorem's binders. Check evaluates both
# sides at sampled points, so a false claim fails with a counterexample on any machine, and IsTrue
# answers 1 or 0. This floor is a test, not a proof: ToLean writes the theorem for the Lean door,
# and CheckWithLean runs it through Lean when Lean and a Mathlib project are installed. A side that
# evaluates to infinity makes the claim hold today (1/0 = 5 passes). The expression subset is + - *
# / ^, parentheses, numerals, sqrt, abs, exp, log, sin, cos, tan, pi.
#
#   receiver   o1 = StzMathClaimQ([ :kind = :Identity, :lhs = "(a+b)^2", :rhs = "a^2 + 2*a*b + b^2",
#              :vars = [ "a", "b" ], :label = "square of a sum" ])
#   example    ? o1.IsTrue()
#              #--> 1
#              ? @@( o1.ToLean() )
#              #--> "theorem square_of_a_sum (a b : ℝ) : (((a+b)^2 : ℝ) = a^2 + 2*a*b + b^2) := by ring"
#              o2 = StzMathClaimQ([ :kind = :Identity, :lhs = "3^2 + 4^2", :rhs = "6^2", :label = "a false one" ])
#              ? o2.IsTrue()
#              #--> 0
#              ? @@( o2.Check()[:evidence] )
#              #--> "the sides are 25 and 36"
#              o3 = StzMathClaimQ("3^2 + 4^2 = 5^2")
#              ? o3.IsTrue()
#              #--> 1
#              ? @@( o3.Statement() )
#              #--> "3^2 + 4^2 = 5^2"
#   see        stzMathClaimSet, stzMathFunction, StzLeanDoor
class stzMathClaim from stzObject

	@cKind = ""
	@cRelation = ""
	@cLhs = ""
	@cRhs = ""
	@cOver = "real"
	@acVars = []
	@cLabel = ""
	@cTactic = ""
	@aLastCheck = []

	# Builds a claim, a statement with two sides and a domain, from a list of keys or from one written statement such as 3^2 + 4^2 = 5^2.
	#
	#   paSpec     either keys kind, lhs, rhs, relation, over, vars, label and tactic, such as [
	#              :kind = :Identity, :lhs = "3^2", :rhs = "9" ], or one text holding the statement
	#   returns    nothing; the object is built
	#   note       kind defaults to identity and over to real; a written statement is labelled with
	#              its own text
	#   warning    Raises an error naming the problem for an unknown key or kind, a relation that
	#              does not fit the kind, an expression outside the subset (sqrt, abs, exp, log,
	#              sin, cos, tan, pi, single-letter variables), a divisibility not declared over
	#              Integer or Natural, and text with no relation in it
	#   see        Check, ToLean, StzMathClaimQ
	def init(paSpec)
		if isString(paSpec)
			paSpec = This._FromStatement(paSpec)
		ok
		if NOT isList(paSpec) or ring_len(paSpec) = 0
			stzraise("stzMathClaim: a claim is declared as keys, like [ :kind = :Identity, :lhs = '3^2 + 4^2', :rhs = '5^2' ], or as one statement '3^2 + 4^2 = 5^2'.")
		ok
		_acKeys_ = [ "kind", "lhs", "rhs", "relation", "over", "vars", "label", "tactic" ]
		for _i_ = 1 to ring_len(paSpec)
			_e_ = paSpec[_i_]
			if NOT isList(_e_) or ring_len(_e_) != 2 or NOT isString(_e_[1])
				stzraise("stzMathClaim: entry " + _i_ + " of the declaration is not a key and a value.")
			ok
			if StzFindFirst(StzLower(_e_[1]), _acKeys_) = 0
				stzraise("stzMathClaim: ':" + _e_[1] + "' is not a key of a claim -- the keys are " + @@(_acKeys_) + ".")
			ok
		next
		_cK_ = StzLower("" + _FfGet(paSpec, "kind", "identity"))
		if StzFindFirst(_cK_, StzMathClaimKinds()) = 0
			stzraise("stzMathClaim: the kinds are :Identity, :Inequality and :Divisibility -- not '" + _cK_ + "'.")
		ok
		@cKind = _cK_
		_cR_ = "" + _FfGet(paSpec, "relation", "")
		if _cR_ = ""
			if _cK_ = "identity"  _cR_ = "="  but _cK_ = "divisibility"  _cR_ = "|"  else  _cR_ = "<"  ok
		ok
		if StzFindFirst(_cR_, StzMathClaimRelations()) = 0
			stzraise("stzMathClaim: the relations are " + @@(StzMathClaimRelations()) + " -- not '" + _cR_ + "'.")
		ok
		if _cK_ = "identity" and _cR_ != "="
			stzraise("stzMathClaim: an identity's relation is '='.")
		ok
		if _cK_ = "divisibility" and _cR_ != "|"
			stzraise("stzMathClaim: a divisibility fact's relation is '|', read 'divides'.")
		ok
		if _cK_ = "inequality" and (_cR_ = "=" or _cR_ = "|")
			stzraise("stzMathClaim: an inequality's relation is one of <, <=, >, >=, !=.")
		ok
		@cRelation = _cR_
		@cLhs = ring_trim("" + _FfGet(paSpec, "lhs", ""))
		@cRhs = ring_trim("" + _FfGet(paSpec, "rhs", ""))
		if @cLhs = "" or @cRhs = ""
			stzraise("stzMathClaim: both sides are needed, :lhs and :rhs.")
		ok
		_cO_ = StzLower("" + _FfGet(paSpec, "over", "real"))
		if StzFindFirst(_cO_, StzMathClaimDomains()) = 0
			stzraise("stzMathClaim: the domains are :Natural, :Integer, :Rational and :Real -- not '" + _cO_ + "'.")
		ok
		if _cK_ = "divisibility" and (_cO_ = "real" or _cO_ = "rational")
			stzraise("stzMathClaim: divisibility is a fact about integers -- declare it :over = :Integer or :Natural.")
		ok
		@cOver = _cO_
		_aV_ = _FfGet(paSpec, "vars", [])
		if NOT isList(_aV_)
			stzraise("stzMathClaim: :vars is a list of names.")
		ok
		@acVars = []
		for _i_ = 1 to ring_len(_aV_)
			_cV_ = ring_trim("" + _aV_[_i_])
			if _cV_ = "" or NOT isalpha(_cV_[1])
				stzraise("stzMathClaim: variable " + _i_ + " is not a name.")
			ok
			@acVars + _cV_
		next
		@cLabel = ring_trim("" + _FfGet(paSpec, "label", ""))
		if @cLabel = ""  @cLabel = @cLhs + " " + @cRelation + " " + @cRhs  ok
		@cTactic = ring_trim("" + _FfGet(paSpec, "tactic", ""))
		# the sides must be readable by both routes: the Lean subset first (its
		# refusal names the subset), then the engine, so a bad name is refused at birth
		_LcExpr(@cLhs)
		_LcExpr(@cRhs)
		This._Compile(@cLhs)
		This._Compile(@cRhs)

	# "3^2 + 4^2 = 5^2" -> keys; the relation found is the kind
	def _FromStatement(pcStatement)
		_c_ = "" + pcStatement
		_acR_ = [ "<=", ">=", "!=", "=", "<", ">", "|" ]
		for _i_ = 1 to ring_len(_acR_)
			_n_ = StzFindFirst(_acR_[_i_], _c_)
			if _n_ > 0
				_cRel_ = _acR_[_i_]
				_cK_ = "inequality"
				if _cRel_ = "="  _cK_ = "identity"  but _cRel_ = "|"  _cK_ = "divisibility"  ok
				_cO_ = "real"
				if _cRel_ = "|"  _cO_ = "integer"  ok
				return [ :kind = _cK_, :relation = _cRel_, :lhs = StzLeft(_c_, _n_ - 1),
				         :rhs = StzStringSection(_c_, _n_ + len(_cRel_), len(_c_)), :over = _cO_ ]
			ok
		next
		stzraise("stzMathClaim: no relation in '" + _c_ + "' -- one of " + @@(StzMathClaimRelations()) + ".")

	# Returns the kind of the claim, in lowercase.
	#
	#   returns    a text: identity, inequality or divisibility
	#   see        Relation
	def Kind()
		return @cKind
	# Returns the relation between the two sides.
	#
	#   returns    a text: =, !=, <, <=, >, >= or the bar of divisibility
	#   note       an identity has =, a divisibility has the bar, and an inequality defaults to <
	#   see        Kind, Statement
	def Relation()
		return @cRelation
	# Returns the expression on the left side.
	#
	#   returns    a text such as 3^2 + 4^2
	#   see        Rhs, Statement
	def Lhs()
		return @cLhs
	# Returns the expression on the right side.
	#
	#   returns    a text such as 5^2
	#   see        Lhs, Statement
	def Rhs()
		return @cRhs
	# Returns the domain the claim is stated over, in lowercase.
	#
	#   returns    a text: natural, integer, rational or real
	#   see        Vars
	def Over()
		return @cOver
	# Returns the names of the variables of the claim, which become the binders of the Lean theorem.
	#
	#   returns    a list of text; [ ] for a closed statement
	#   see        SamplePoints, Over
	def Vars()
		return @acVars
	# Returns the label given to the claim, which names its theorem.
	#
	#   returns    a text
	#   see        TheoremName
	def Label()
		return @cLabel
	# Returns the Lean tactic the author chose, or empty text when none was chosen.
	#
	#   returns    a text such as decide; empty text by default
	#   see        LeanTactic
	def Tactic()
		return @cTactic

	# Returns the claim as one line: the left side, the relation and the right side.
	#
	#   returns    a text such as 3^2 + 4^2 = 5^2
	#   see        Lhs, Rhs, Relation
	def Statement()
		return @cLhs + " " + @cRelation + " " + @cRhs

	#-- THE FLOOR: the engine evaluates both sides at sampled points ---------------

	def _Compile(pcExpr)
		_acV_ = @acVars
		if ring_len(_acV_) = 0  _acV_ = [ "zz" ]  ok
		return new stzMathFunction(pcExpr, _acV_)

	# Returns the points at which the numeric check evaluates both sides: one for a closed statement, sixteen otherwise.
	#
	#   returns    a list of points, each a list with one number per variable
	#   note       integers are used when the domain is natural or integer
	#   see        Check, Vars
	#@ aka  the points the floor samples: one for a closed statement, sixteen per variable otherwise, integers where the domain is integers
	def SamplePoints()
		_nV_ = ring_len(@acVars)
		if _nV_ = 0  return [ [ 0 ] ]  ok
		_aS_ = StzMathClaimSamples()
		if @cOver = "natural"  _aS_ = StzMathClaimNaturalSamples()  ok
		if @cOver = "integer"
			_aS_ = [ 0, 1, -1, 2, -2, 3, -3, 5, 7, -7, 10, 12, -12, 4, 6, 9 ]
		ok
		_a_ = []
		for _k_ = 1 to ring_len(_aS_)
			_p_ = []
			for _v_ = 1 to _nV_
				_idx_ = ((_k_ - 1) + (_v_ - 1) * 5) % ring_len(_aS_) + 1
				_p_ + _aS_[_idx_]
			next
			_a_ + _p_
		next
		return _a_

	def _HoldsAt(pnL, pnR)
		_nTol_ = 0.000000001 * (1 + fabs(pnL) + fabs(pnR))
		if @cRelation = "="  return fabs(pnL - pnR) <= _nTol_  ok
		if @cRelation = "!="  return fabs(pnL - pnR) > _nTol_  ok
		if @cRelation = "<"  return pnL < pnR - _nTol_  ok
		if @cRelation = "<="  return pnL <= pnR + _nTol_  ok
		if @cRelation = ">"  return pnL > pnR + _nTol_  ok
		if @cRelation = ">="  return pnL >= pnR - _nTol_  ok
		# divisibility: L | R -- R is a whole multiple of L (and 0 divides only 0)
		_nLi_ = floor(pnL + 0.5)
		_nRi_ = floor(pnR + 0.5)
		if fabs(pnL - _nLi_) > _nTol_ or fabs(pnR - _nRi_) > _nTol_  return 0  ok
		if _nLi_ = 0  return _nRi_ = 0  ok
		return (_nRi_ % _nLi_) = 0

	# Evaluates both sides at the sample points and returns the verdict, the first counterexample if any, and the evidence.
	#
	#   returns    a hash-list with verdict (1 or 0), route, points, evidence and counterexample
	#   note       this is the numeric floor, not a proof: a claim that holds at the sampled points
	#              is only likely true
	#   warning    a side that is infinite makes the claim hold at that point: 1/0 = 5 and 1/0 = 1
	#              both give verdict 1 (confirmed on two claims), because the tolerance grows to
	#              infinity with the side; a side that is not a number at every point gives verdict
	#              0 with the evidence that no point gave both sides a value
	#   see        IsTrue, LastCheck, Why
	#@ aka  the floor's verdict: every sampled point, the first counterexample kept
	def Check()
		_oL_ = This._Compile(@cLhs)
		_oR_ = This._Compile(@cRhs)
		_aP_ = This.SamplePoints()
		_nSeen_ = 0
		_aBad_ = []
		_nBadL_ = 0
		_nBadR_ = 0
		for _i_ = 1 to ring_len(_aP_)
			_nL_ = _oL_.ValueAt(_aP_[_i_])
			_nR_ = _oR_.ValueAt(_aP_[_i_])
			if NOT (_nL_ = _nL_) or NOT (_nR_ = _nR_)  loop  ok
			_nSeen_++
			if NOT This._HoldsAt(_nL_, _nR_)
				_aBad_ = _aP_[_i_]
				_nBadL_ = _nL_
				_nBadR_ = _nR_
				exit
			ok
		next
		_oL_.Free()
		_oR_.Free()
		if ring_len(_aBad_) > 0
			_cAt_ = ""
			for _v_ = 1 to ring_len(@acVars)
				if _cAt_ != ""  _cAt_ += ", "  ok
				_cAt_ += @acVars[_v_] + " = " + _FfNum(_aBad_[_v_], 4)
			next
			_cE_ = "the sides are " + _FfNum(_nBadL_, 6) + " and " + _FfNum(_nBadR_, 6)
			if _cAt_ != ""  _cE_ += " at " + _cAt_  ok
			@aLastCheck = [ :verdict = 0, :route = "numeric floor", :points = _nSeen_, :evidence = _cE_, :counterexample = _aBad_ ]
			return @aLastCheck
		ok
		if _nSeen_ = 0
			@aLastCheck = [ :verdict = 0, :route = "numeric floor", :points = 0, :evidence = "no sampled point gave both sides a value", :counterexample = [] ]
			return @aLastCheck
		ok
		@aLastCheck = [ :verdict = 1, :route = "numeric floor", :points = _nSeen_,
		                :evidence = "holds at " + _nSeen_ + " sampled point(s) to 1e-9", :counterexample = [] ]
		return @aLastCheck

	# TRUE if the claim holds at every sampled point; a false claim fails with a counterexample.
	#
	#   returns    1 or 0
	#   warning    see Check for the infinite-side case
	#   see        Check, Why
	def IsTrue()
		_a_ = This.Check()
		return _a_[:verdict]

	# Returns the result of the most recent Check, without evaluating again.
	#
	#   returns    a hash-list as Check returns; [ ] before any check
	#   see        Check
	def LastCheck()
		return @aLastCheck

	# Returns the name of the Lean theorem, made from the label with underscores.
	#
	#   returns    a text such as three_four_five
	#   see        Label, ToLean
	#@ aka  -- THE DOOR: the Lean statement, and the verdict when Lean is present --------
	def TheoremName()
		return _LcSlug(@cLabel)

	# Returns the Lean tactic that will close the theorem: the author's, or ring, nlinarith or norm_num according to the kind and the variables.
	#
	#   returns    a text
	#   note       with variables an identity gets ring and an inequality nlinarith; a closed
	#              statement gets norm_num
	#   see        Tactic, ToLean
	#@ aka  the tactic: the author's, or the one the kind and the variables call for
	def LeanTactic()
		if @cTactic != ""  return @cTactic  ok
		if @cKind = "identity" and ring_len(@acVars) > 0  return "ring"  ok
		if @cKind = "inequality" and ring_len(@acVars) > 0  return "nlinarith"  ok
		return "norm_num"

	# Returns the statement spelt for Lean, with the domain symbol attached to the left side.
	#
	#   returns    a text such as ((3^2 + 4^2 : ℕ) = 5^2)
	#   see        ToLean
	def LeanStatement()
		_cL_ = _LcExpr(@cLhs)
		_cR_ = _LcExpr(@cRhs)
		return "((" + _cL_ + " : " + _LcType(@cOver) + ") " + _LcRelation(@cRelation) + " " + _cR_ + ")"

	# Returns the whole theorem as one line of Lean 4 text, with binders for the variables and the tactic.
	#
	#   returns    a text such as theorem three_four_five : ((3^2 + 4^2 : ℕ) = 5^2) := by norm_num
	#   see        LeanStatement, CheckWithLean, WriteLean
	def ToLean()
		_cB_ = ""
		if ring_len(@acVars) > 0
			_cB_ = " ("
			for _i_ = 1 to ring_len(@acVars)
				if _i_ > 1  _cB_ += " "  ok
				_cB_ += @acVars[_i_]
			next
			_cB_ += " : " + _LcType(@cOver) + ")"
		ok
		return "theorem " + This.TheoremName() + _cB_ + " : " + This.LeanStatement() + " := by " + This.LeanTactic()

	# Runs the emitted theorem through Lean when it is installed on this machine, and returns the verdict beside the numeric check.
	#
	#   returns    a hash-list with floor, route, proved, because and file
	#   warning    proved is 0 with the reason in because when Lean fails or is stopped, and Lean
	#              with Mathlib can take minutes: one run on a cold machine was stopped after 5
	#              minutes and answered proved 0 because lean exited with 143
	#   see        ToLean, Check
	#@ aka  through the door: a proof when Lean is here, the door's name when it is not; the floor's verdict rides along either way
	def CheckWithLean()
		_f_ = This.Check()
		_d_ = StzLeanCheck("import Mathlib" + char(10) + char(10) + This.ToLean() + char(10), This.TheoremName())
		return [ :floor = _f_[:verdict], :route = _d_[:route], :proved = _d_[:proved], :because = _d_[:because], :file = _d_[:file] ]

	# Explains the claim in one sentence: its kind and domain, the numeric verdict with its evidence, and whether the Lean door is open.
	#
	#   returns    a text
	#   see        Check, ToLean
	def Why()
		_a_ = This.Check()
		_cArt_ = "a "
		if @cKind != "divisibility"  _cArt_ = "an "  ok
		_c_ = _cArt_ + @cKind + " over the " + @cOver + "s, '" + This.Statement() + "'"
		if ring_len(@acVars) > 0  _c_ += " in " + @@(@acVars)  ok
		if _a_[:verdict]
			_c_ += ": true on the floor, " + _a_[:evidence]
		else
			_c_ += ": FALSE on the floor, " + _a_[:evidence]
		ok
		_d_ = StzLeanDoor()
		if _d_[:open]
			_c_ += "; the Lean door is open (" + _d_[:because] + ")"
		else
			_c_ += "; the Lean door is closed: " + _d_[:because]
		ok
		return _c_

#-- A LESSON'S CLAIMS ----------------------------------------------------------------

# Gathers the claims of one lesson, checks them all on the numeric floor and writes them as a single Lean 4 file.
#
# Build it with the lesson's name and Add the claims, each an stzMathClaim. Diagnostics returns one
# error record for every false claim, Report wraps them in the house rule report that a single CI
# gate reads, and IsSound answers 1 when none is false. ToLean writes one file for the lesson, with
# theorems numbered by position so their names stay unique, and WriteLean puts it on disk.
# CheckWithLean sends the file through Lean when Lean is installed.
#
#   receiver   o1 = StzMathClaimSetQ("pythagoras")
#   example    o1.Add(StzMathClaimQ([ :kind = :Identity, :lhs = "3^2 + 4^2", :rhs = "5^2", :label = "three four five" ]))
#              ? o1.Count()
#              #--> 1
#              ? o1.IsSound()
#              #--> 1
#              o1.Add(StzMathClaimQ([ :kind = :Identity, :lhs = "3^2 + 4^2", :rhs = "6^2", :label = "false one" ]))
#              ? o1.IsSound()
#              #--> 0
#              ? @@( o1.Diagnostics()[1][:where] )
#              #--> "false one"
#              ? @@( o1.Lesson() )
#              #--> "pythagoras"
#   see        stzMathClaim, stzRuleReport
class stzMathClaimSet from stzObject

	@cLesson = ""
	@aoClaims = []

	# Builds an empty set of claims for one lesson.
	#
	#   pcLesson   the name of the lesson the claims belong to
	#   returns    nothing; the object is built
	#   warning    Raises an error when the name is empty
	#   see        Add, Lesson
	def init(pcLesson)
		@cLesson = ring_trim("" + pcLesson)
		if @cLesson = ""
			stzraise("stzMathClaimSet: name the lesson the claims belong to.")
		ok

	# Returns the name of the lesson, with the spaces around it removed.
	#
	#   returns    a text
	#   see        Count
	def Lesson()
		return @cLesson

	# Appends one claim to the set.
	#
	#   poClaim    an stzMathClaim
	#   returns    the set itself, so calls chain
	#   warning    raises an error for anything that is not an stzMathClaim
	#   see        Claims, Count
	def Add(poClaim)
		if NOT isObject(poClaim) or StzLower(ring_classname(poClaim)) != "stzmathclaim"
			stzraise("stzMathClaimSet.Add: an stzMathClaim.")
		ok
		@aoClaims + poClaim
		return This

		def AddQ(poClaim)
			return This.Add(poClaim)

	# Returns the claims of the set, in the order they were added.
	#
	#   returns    a list of stzMathClaim objects
	#   see        Add, Count
	def Claims()
		return @aoClaims

	# Returns how many claims the set holds.
	#
	#   returns    a number
	#   see        Claims
	def Count()
		return ring_len(@aoClaims)

	# Returns one Lean 4 file for the whole lesson: a comment header, the Mathlib import and one theorem per claim, numbered to stay unique.
	#
	#   returns    a text
	#   see        WriteLean, CheckWithLean
	#@ aka  one .lean file: Mathlib, the lesson, every theorem; names made unique by position
	def ToLean()
		_c_ = "-- " + @cLesson + ": " + ring_len(@aoClaims) + " claim(s) emitted by stzMathClaimSet (plane stzlib-math, M6)" + char(10)
		_c_ += "-- check with: lake env lean <this file>   inside a Lake project holding Mathlib" + char(10)
		_c_ += "import Mathlib" + char(10) + char(10)
		for _i_ = 1 to ring_len(@aoClaims)
			_cT_ = @aoClaims[_i_].ToLean()
			_cN_ = @aoClaims[_i_].TheoremName()
			_cT_ = StzReplace(_cT_, "theorem " + _cN_ + " ", "theorem c" + _i_ + "_" + _cN_ + " ")
			_c_ += "-- " + @aoClaims[_i_].Label() + ": " + @aoClaims[_i_].Statement() + char(10)
			_c_ += _cT_ + char(10) + char(10)
		next
		return _c_

	# Writes the Lean file of the lesson to a path.
	#
	#   pcPath     the file to write
	#   returns    the path, as text
	#   see        ToLean
	def WriteLean(pcPath)
		write(pcPath, This.ToLean())
		return pcPath

	# Checks every claim on the numeric floor and returns one error record for each false claim.
	#
	#   returns    a list of rule records with rule claim_false, subject, where, severity and
	#              message; [ ] when all hold
	#   see        Report, IsSound
	#@ aka  the floor over every claim, in the house rule shape: a false claim is an error
	def Diagnostics()
		_a_ = []
		for _i_ = 1 to ring_len(@aoClaims)
			_o_ = @aoClaims[_i_]
			_r_ = _o_.Check()
			if NOT _r_[:verdict]
				_a_ + [ :rule = "claim_false", :subject = @cLesson, :where = _o_.Label(), :severity = :error,
				        :message = "'" + _o_.Statement() + "' fails on the numeric floor: " + _r_[:evidence] ]
			ok
		next
		return _a_

	# Returns the diagnostics as a rule report, the house shape that one CI gate reads.
	#
	#   returns    an stzRuleReport
	#   see        Diagnostics, IsSound
	def Report()
		_o_ = new stzRuleReport(@cLesson)
		_o_.Ingest(This.Diagnostics())
		return _o_

	# TRUE if no claim of the set fails on the numeric floor.
	#
	#   returns    1 or 0; 1 for an empty set
	#   see        Diagnostics, Why
	def IsSound()
		return This.Report().IsSound()

	# Runs the whole lesson file through Lean when it is installed on this machine, and returns the verdict beside the count of false claims.
	#
	#   returns    a hash-list with floor_errors, route, proved, because and file
	#   warning    proved is 0 with the reason in because when Lean fails or is stopped, and Lean
	#              with Mathlib can take minutes: one run on a cold machine was stopped after 5
	#              minutes and answered proved 0 because lean exited with 143
	#   see        ToLean, Diagnostics
	#@ aka  through the door, once for the whole file
	def CheckWithLean()
		_n_ = ring_len(This.Diagnostics())
		_d_ = StzLeanCheck(This.ToLean(), @cLesson)
		return [ :floor_errors = _n_, :route = _d_[:route], :proved = _d_[:proved], :because = _d_[:because], :file = _d_[:file] ]

	# Explains the set in one sentence: how many statements it holds, how many are false on the numeric floor, and whether the Lean door is open.
	#
	#   returns    a text
	#   see        Diagnostics
	def Why()
		_n_ = ring_len(This.Diagnostics())
		_c_ = "the claims of '" + @cLesson + "': " + ring_len(@aoClaims) + " statement(s), " + _n_ + " false on the numeric floor"
		_d_ = StzLeanDoor()
		if _d_[:open]
			_c_ += "; the Lean door is open"
		else
			_c_ += "; the Lean door is closed (" + _d_[:because] + "), so the floor is the verdict"
		ok
		return _c_
