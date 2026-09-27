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

	def Kind()
		return @cKind
	def Relation()
		return @cRelation
	def Lhs()
		return @cLhs
	def Rhs()
		return @cRhs
	def Over()
		return @cOver
	def Vars()
		return @acVars
	def Label()
		return @cLabel
	def Tactic()
		return @cTactic

	def Statement()
		return @cLhs + " " + @cRelation + " " + @cRhs

	#-- THE FLOOR: the engine evaluates both sides at sampled points ---------------

	def _Compile(pcExpr)
		_acV_ = @acVars
		if ring_len(_acV_) = 0  _acV_ = [ "zz" ]  ok
		return new stzMathFunction(pcExpr, _acV_)

	# the points the floor samples: one for a closed statement, sixteen per
	# variable otherwise, integers where the domain is integers
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

	# the floor's verdict: every sampled point, the first counterexample kept
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

	def IsTrue()
		_a_ = This.Check()
		return _a_[:verdict]

	def LastCheck()
		return @aLastCheck

	#-- THE DOOR: the Lean statement, and the verdict when Lean is present --------

	def TheoremName()
		return _LcSlug(@cLabel)

	# the tactic: the author's, or the one the kind and the variables call for
	def LeanTactic()
		if @cTactic != ""  return @cTactic  ok
		if @cKind = "identity" and ring_len(@acVars) > 0  return "ring"  ok
		if @cKind = "inequality" and ring_len(@acVars) > 0  return "nlinarith"  ok
		return "norm_num"

	def LeanStatement()
		_cL_ = _LcExpr(@cLhs)
		_cR_ = _LcExpr(@cRhs)
		return "((" + _cL_ + " : " + _LcType(@cOver) + ") " + _LcRelation(@cRelation) + " " + _cR_ + ")"

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

	# through the door: a proof when Lean is here, the door's name when it is not;
	# the floor's verdict rides along either way
	def CheckWithLean()
		_f_ = This.Check()
		_d_ = StzLeanCheck("import Mathlib" + char(10) + char(10) + This.ToLean() + char(10), This.TheoremName())
		return [ :floor = _f_[:verdict], :route = _d_[:route], :proved = _d_[:proved], :because = _d_[:because], :file = _d_[:file] ]

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

class stzMathClaimSet from stzObject

	@cLesson = ""
	@aoClaims = []

	def init(pcLesson)
		@cLesson = ring_trim("" + pcLesson)
		if @cLesson = ""
			stzraise("stzMathClaimSet: name the lesson the claims belong to.")
		ok

	def Lesson()
		return @cLesson

	def Add(poClaim)
		if NOT isObject(poClaim) or StzLower(ring_classname(poClaim)) != "stzmathclaim"
			stzraise("stzMathClaimSet.Add: an stzMathClaim.")
		ok
		@aoClaims + poClaim
		return This

		def AddQ(poClaim)
			return This.Add(poClaim)

	def Claims()
		return @aoClaims

	def Count()
		return ring_len(@aoClaims)

	# one .lean file: Mathlib, the lesson, every theorem; names made unique by position
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

	def WriteLean(pcPath)
		write(pcPath, This.ToLean())
		return pcPath

	# the floor over every claim, in the house rule shape: a false claim is an error
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

	def Report()
		_o_ = new stzRuleReport(@cLesson)
		_o_.Ingest(This.Diagnostics())
		return _o_

	def IsSound()
		return This.Report().IsSound()

	# through the door, once for the whole file
	def CheckWithLean()
		_n_ = ring_len(This.Diagnostics())
		_d_ = StzLeanCheck(This.ToLean(), @cLesson)
		return [ :floor_errors = _n_, :route = _d_[:route], :proved = _d_[:proved], :because = _d_[:because], :file = _d_[:file] ]

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
