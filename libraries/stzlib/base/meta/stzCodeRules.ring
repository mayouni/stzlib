# R2 -- stzCodeRules: THE MACHINE DOOR (LAW 6 made runnable)
#
# "Agents can't RUN folklore": the house rules become validators any
# programmer -- human or machine -- executes over source BEFORE it
# lands. Findings are STRUCTURED: [ :rule, :line, :severity, :message ].
#
#   ? StzCheckCode(cRingSource)          # source text
#   ? StzCheckCodeFile("path/x.ring")    # a file
#   ? StzCodeRuleNames()                 # what is checked
#
# The first rule set (grows with the doctrine; each rule = one house
# law the library actually enforces):
#   no-len-method    never define Len()/len() on a class (shadows the
#                    builtin and breaks every caller)
#   q-returns-object a ...Q() method must return a chainable OBJECT
#                    (return This / return new ...) -- the Q convention
#   no-aggressive-verbs  no Kill*/Destroy* method names (Softanza tone)
#   engine-first     Ring's substr()/lower()/upper() are byte-oriented;
#                    NEW code reaches for the Stz* engine forms
#                    (severity :warning -- existing hot-ASCII residue
#                    is deliberate, see the engine-first scope ruling)

func StzCodeRuleNames()
	return [ "no-len-method", "q-returns-object", "no-aggressive-verbs",
	         "engine-first", "q-has-plain-twin", "no-case-collision" ]

func StzCheckCodeFile(pcPath)
	return StzCheckCode(read(pcPath))

# StzCheckProject(dir): the whole-library check. Builds ONE code graph across
# every .ring file under pcDir (call edges and all), then runs the project rule
# set -- the snippet rules PLUS no-dead-code / no-cyclic-calls, which only mean
# something over a complete call graph. Returns findings in the UNIFIED shape
# [ :rule, :subject, :where, :severity, :message ] (a whole-graph check, not the
# per-line StzCheckCode adapter). This is what a rule can do that a text scan
# never could: see the library as a model. Cost is real -- see the guard, which
# measures it.
func StzCheckProject(pcDir)
	_oCG_ = new stzRingCodeGraph("" + pcDir)   # scans dir + resolves calls in init
	return StzCodeProjectRuleSetQ().Check(_oCG_)

# The DEEP audit: everything StzCheckProject runs PLUS no-cyclic-calls, which is
# expensive (the code graph's CyclicCalls is O(calls^2 . methods) -- measured
# ~36s over base/graph). For a periodic audit, not a per-commit gate.
func StzCheckProjectDeep(pcDir)
	_oCG_ = new stzRingCodeGraph("" + pcDir)
	return StzCodeDeepRuleSetQ().Check(_oCG_)

# TRUE when a whole project has no ERROR-severity finding (warnings advise).
func StzProjectIsClean(pcDir)
	_aF_ = StzCheckProject(pcDir)
	_n_ = len(_aF_)
	for _i_ = 1 to _n_
		if "" + _aF_[_i_][:severity] = "error"
			return FALSE
		ok
	next
	return TRUE

# StzCheckCode is now a THIN WRAPPER over the graph-rule engine (graph-rules
# plan, phase 3): it builds a Ring CODE GRAPH from the source, runs the
# stzCodeRuleSet (no-len-method / no-aggressive-verbs / engine-first -- each a
# rule over real method/function/call data, not a text scan), then runs the ONE
# rule the graph cannot model -- q-returns-object, which needs return statements
# -- as a text pass, and MERGES both into the unchanged [ :rule, :line,
# :severity, :message ] shape, sorted by line. The signature and the finding
# shape are frozen; callers (StzCodeIsClean, stzPredicateSet, the codegraph
# guard) do not move.
func StzCheckCode(pcSource)
	_cSrc_ = StzReplace("" + pcSource, char(13), "")
	_aFindings_ = []

	# 1. the graph-based rules, over a real Ring code graph
	_oCG_ = new stzRingCodeGraph("")
	_oCG_.ScanSource(_cSrc_, "src")
	_aG_ = StzCodeRuleSetQ().Check(_oCG_)
	_nG_ = len(_aG_)
	for _i_ = 1 to _nG_
		_aFindings_ + [ :rule = _aG_[_i_][:rule], :line = _aG_[_i_][:where],
			:severity = _StzCodeSevSym(_aG_[_i_][:severity]),
			:message = _aG_[_i_][:message] ]
	next

	# 2. q-returns-object -- a text pass (the code graph has no return model)
	_aQ_ = _StzCheckQReturns(_cSrc_)
	_nQ_ = len(_aQ_)
	for _i_ = 1 to _nQ_
		_aFindings_ + _aQ_[_i_]
	next

	return _StzCodeSortByLine(_aFindings_)

# The one house rule that stays TEXT-based: a ...Q() method must return a
# chainable object, which requires reading its BODY for a chainable return --
# something the code graph (classes/methods/calls, no returns) cannot see. Kept
# verbatim from the original scanner, returning the frozen finding shape.
func _StzCheckQReturns(pcSource)
	_acLines_ = StzSplit(pcSource, char(10))
	_nLen_ = len(_acLines_)
	_aOut_ = []
	for _i_ = 1 to _nLen_
		_cL_ = StzLower(ring_trim(StzReplace(_acLines_[_i_], char(9), " ")))
		if StzLeft(_cL_, 1) = "#" or StzLeft(_cL_, 2) = "//"
			loop
		ok
		if StzLeft(_cL_, 4) = "def "
			_acNm_ = StzSplit(_cL_, "(")
			_cM_ = ring_trim(StzReplace(_acNm_[1], "def ", ""))
			if StzRight(_cM_, 1) = "q" and StzLen(_cM_) > 1
				_bOk_ = 0
				_j_ = _i_ + 1
				while _j_ <= _nLen_ and _j_ <= _i_ + 40
					_cB_ = StzLower(ring_trim(StzReplace(_acLines_[_j_], char(9), " ")))
					if StzLeft(_cB_, 4) = "def " or StzLeft(_cB_, 6) = "class "
						exit
					ok
					if len(StzFind("return this", _cB_)) > 0 or
					   len(StzFind("return new ", _cB_)) > 0 or
					   len(StzFind("return @", _cB_)) > 0 or
					   len(StzFind("q(", _cB_)) > 0
						_bOk_ = 1
						exit
					ok
					_j_++
				end
				if _bOk_ = 0
					_aOut_ + [ :rule = "q-returns-object", :line = _i_,
						:severity = :error,
						:message = "'" + _cM_ + "' ends in Q but no chainable return found (return This / return new ...) -- the Q convention: Q = OBJECT, plain = data" ]
				ok
			ok
		ok
	next
	return _aOut_

# "error"/"warning"/"info" (the rule-object severity) -> the finding symbols the
# frozen shape uses.
func _StzCodeSevSym(pcSev)
	if pcSev = "warning"
		return :warning
	but pcSev = "info"
		return :info
	ok
	return :error

# stable insertion sort of findings by :line, so a merged (graph + text) result
# reads top-to-bottom like the old single-pass scanner did.
func _StzCodeSortByLine(paFindings)
	_a_ = paFindings
	_n_ = len(_a_)
	for _i_ = 2 to _n_
		_x_ = _a_[_i_]
		_j_ = _i_ - 1
		while _j_ >= 1 and _a_[_j_][:line] > _x_[:line]
			_a_[_j_ + 1] = _a_[_j_]
			_j_--
		end
		_a_[_j_ + 1] = _x_
	next
	return _a_

# convenience verdict: TRUE when no :error-severity finding remains
func StzCodeIsClean(pcSource)
	_aF_ = StzCheckCode(pcSource)
	_nLen_ = len(_aF_)
	for _i_ = 1 to _nLen_
		if _aF_[_i_][:severity] = :error
			return FALSE
		ok
	next
	return TRUE
