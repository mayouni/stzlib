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
	         "engine-first", "q-has-plain-twin", "no-case-collision",
	         "dead-knob", "setter-resets-on-reject" ]

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

# THE KNOB RULES OVER A WHOLE TREE.
#
# StzCheckProject runs the GRAPH rules; the knob rules are text passes, so they
# need their own walk. Findings carry the file in :where -- one gate, one shape,
# whichever pass produced them.
#
# Recursive, because base/ is a tree of module folders and a rule that only
# looked at the top level would report a clean library by looking at nothing.
func StzCheckProjectKnobs(pcDir)
	_aOut_ = []
	_cDir_ = "" + pcDir
	if StzRight(_cDir_, 1) != "/" and StzRight(_cDir_, 1) != "\\"
		_cDir_ += "/"
	ok
	_aEntries_ = []
	try
		_aEntries_ = dir(_cDir_)
	catch
		return _aOut_
	done
	_n_ = len(_aEntries_)
	for _i_ = 1 to _n_
		_cName_ = _aEntries_[_i_][1]
		if _cName_ = "." or _cName_ = ".."
			loop
		ok
		if _aEntries_[_i_][2] = 1
			# a folder: recurse, but never into the tests or the archives
			_cLow_ = StzLower(_cName_)
			if _cLow_ = "test" or _cLow_ = "archive" or StzLeft(_cLow_, 1) = "_"
				loop
			ok
			_aSub_ = StzCheckProjectKnobs(_cDir_ + _cName_)
			_nS_ = len(_aSub_)
			for _j_ = 1 to _nS_
				_aOut_ + _aSub_[_j_]
			next
			loop
		ok
		if StzLower(StzRight(_cName_, 5)) != ".ring"
			loop
		ok
		_cPath_ = _cDir_ + _cName_
		_cSrc_ = ""
		try
			_cSrc_ = read(_cPath_)
		catch
			loop
		done
		_aK_ = _StzCheckDeadKnobs(_cSrc_)
		_aR_ = _StzCheckSetterResets(_cSrc_)
		_nK_ = len(_aK_)
		for _j_ = 1 to _nK_
			_aOut_ + [ :rule = _aK_[_j_][:rule], :subject = :code,
			           :where = _cPath_ + ":" + _aK_[_j_][:line],
			           :severity = _aK_[_j_][:severity],
			           :message = _aK_[_j_][:message] ]
		next
		_nR_ = len(_aR_)
		for _j_ = 1 to _nR_
			_aOut_ + [ :rule = _aR_[_j_][:rule], :subject = :code,
			           :where = _cPath_ + ":" + _aR_[_j_][:line],
			           :severity = _aR_[_j_][:severity],
			           :message = _aR_[_j_][:message] ]
		next
	next
	return _aOut_

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

	# 3. the knob rules -- also text passes: they need statement-level detail
	#    (WHICH attribute a line assigns, and whether an else-branch overwrites
	#    it) that the class/method/call graph does not carry.
	_aK_ = _StzCheckDeadKnobs(_cSrc_)
	_nK_ = len(_aK_)
	for _i_ = 1 to _nK_
		_aFindings_ + _aK_[_i_]
	next

	_aR_ = _StzCheckSetterResets(_cSrc_)
	_nR_ = len(_aR_)
	for _i_ = 1 to _nR_
		_aFindings_ + _aR_[_i_]
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

#=====================================================================#
#  THE KNOB RULES -- a setting that cannot change anything            #
#=====================================================================#
# Nine hand audits of one library found the same defect over and over: a
# public setting that does nothing. SetBarChar("=") and the bars keep their
# old character. SetTotalLabel("GRAND") and the table still says TOTAL.
# Nothing raises, nothing warns -- the setter runs, stores the value, and no
# code ever looks at it again.
#
# The law is one sentence: IF YOU CAN SET IT, IT MUST BE ABLE TO CHANGE
# SOMETHING. These two rules are the mechanical half of it.
#
#   dead-knob                an attribute a setter writes and nothing reads
#   setter-resets-on-reject  a setter that answers a value it dislikes by
#                            overwriting what was already there
#
# What they CANNOT do, and why a person is still needed: they do not know
# what a knob is FOR, only that nothing consumes it. They cannot see past the
# Ring/Zig boundary -- a value marshalled into a blob and dropped engine-side
# still looks alive here. And they cannot tell whether a TEST of a knob could
# ever fail (a lockout test using 900 against a default of 900 passes either
# way). Those three stay manual.

# Attribute names on a line, lowercased -- Ring folds case, so @nStep and
# @NSTEP are the same attribute and must count as one.
func _StzKnobAttrsIn(pcLine)
	_aOut_ = []
	_c_ = "" + pcLine
	_n_ = len(_c_)
	_i_ = 1
	while _i_ <= _n_
		if _c_[_i_] = "@"
			_cName_ = ""
			_j_ = _i_ + 1
			while _j_ <= _n_
				_ch_ = _c_[_j_]
				# BYTE VALUES, not string comparison: Ring's >= coerces a string
				# operand to a number and raises R41 on a letter.
				_nA_ = ascii(_ch_)
				if (_nA_ >= 97 and _nA_ <= 122) or (_nA_ >= 65 and _nA_ <= 90) or
				   (_nA_ >= 48 and _nA_ <= 57) or _ch_ = "_"
					_cName_ += _ch_
					_j_++
				else
					exit
				ok
			end
			if _cName_ != ""
				_aOut_ + StzLower(_cName_)
			ok
			_i_ = _j_
		else
			_i_++
		ok
	end
	return _aOut_

# Everything after an unquoted # is a comment: an attribute named there is
# prose, not a read. Quote-aware because colours like "#ff0000" are real.
func _StzKnobStrip(pcLine)
	_c_ = "" + pcLine
	_n_ = len(_c_)
	_cOut_ = ""
	_cQuote_ = ""
	for _i_ = 1 to _n_
		_ch_ = _c_[_i_]
		if _cQuote_ != ""
			if _ch_ = _cQuote_
				_cQuote_ = ""
			ok
			_cOut_ += _ch_
			loop
		ok
		if _ch_ = char(34) or _ch_ = char(39)
			_cQuote_ = _ch_
			_cOut_ += _ch_
			loop
		ok
		if _ch_ = "#"
			exit
		ok
		_cOut_ += _ch_
	next
	return _cOut_

# The attribute a line ASSIGNS, or "" when it assigns none.
#
# Ring spells equality and assignment the same way, so "if @x = :Horizontal"
# is a READ. Only a line that OPENS with the attribute is a write -- counting
# the comparison as one hides the very consumer this rule looks for, which is
# exactly what a first version of this scan did.
func _StzKnobAssignedAt(pcLine)
	_c_ = ring_trim(StzReplace("" + pcLine, char(9), " "))
	if StzLeft(_c_, 1) != "@"
		return ""
	ok
	_aAt_ = _StzKnobAttrsIn(_c_)
	if len(_aAt_) = 0
		return ""
	ok
	_cName_ = _aAt_[1]
	_cRest_ = ring_trim(StzMidToEnd(_c_, len(_cName_) + 2))
	if StzLeft(_cRest_, 2) = "=="
		return ""
	ok
	if StzLeft(_cRest_, 1) = "="
		return _cName_
	ok
	return ""

func _StzKnobIsSetterName(pcName)
	_c_ = StzLower("" + pcName)
	_aPrefix_ = [ "set", "with", "without", "use", "add", "enable", "disable",
	              "include", "exclude" ]
	_n_ = len(_aPrefix_)
	for _i_ = 1 to _n_
		if StzLeft(_c_, len(_aPrefix_[_i_])) = _aPrefix_[_i_]
			return TRUE
		ok
	next
	return FALSE

# def / class lines, so a scan can tell which method a line sits in.
func _StzKnobDefName(pcLine)
	_c_ = ring_trim(StzReplace("" + pcLine, char(9), " "))
	if StzLeft(_c_, 4) != "def "
		return ""
	ok
	_cRest_ = ring_trim(StzMidToEnd(_c_, 5))
	_aP_ = StzSplit(_cRest_, "(")
	return ring_trim(_aP_[1])

func _StzKnobClassName(pcLine)
	_c_ = ring_trim(StzReplace("" + pcLine, char(9), " "))
	if StzLower(StzLeft(_c_, 6)) != "class "
		return ""
	ok
	_cRest_ = ring_trim(StzMidToEnd(_c_, 7))
	_aP_ = StzSplit(_cRest_, " ")
	return ring_trim(_aP_[1])

# DEAD-KNOB: an attribute a setter writes and nothing reads.
#
# Two verdicts, because two things are wrong to different degrees:
#
#   :error    nothing reads it at all. @nSteps was written by SetNumberOfSteps
#             and read by no one -- the live attribute was @nStep, one letter
#             away, which Parse() set and NumberOfSteps() returned. A dead
#             attribute beside a live twin is how the next reader "fixes" a bug
#             by writing to the wrong one, so the message names the twin.
#
#   :warning  the ONLY reader is its own getter. @cEdgePenStyle returned exactly
#             what you set while nothing drew it -- a knob that answers you and
#             changes nothing. It is a warning and not an error because another
#             class may call that getter, which this per-file pass cannot see;
#             it is suppressed when the getter is named anywhere else in the
#             same source.
func _StzCheckDeadKnobs(pcSource)
	_aOut_ = []
	_cSrc_ = StzReplace("" + pcSource, char(13), "")
	_acLines_ = StzSplit(_cSrc_, char(10))
	_nLen_ = len(_acLines_)

	# class spans
	_acCls_ = []
	_anClsFrom_ = []
	for _i_ = 1 to _nLen_
		_cC_ = _StzKnobClassName(_acLines_[_i_])
		if _cC_ != ""
			_acCls_ + _cC_
			_anClsFrom_ + _i_
		ok
	next
	_nCls_ = len(_acCls_)
	if _nCls_ = 0
		return _aOut_
	ok

	for _k_ = 1 to _nCls_
		_nFrom_ = _anClsFrom_[_k_]
		_nTo_ = _nLen_
		if _k_ < _nCls_
			_nTo_ = _anClsFrom_[_k_ + 1] - 1
		ok
		# A parent DEFINED IN THIS FILE is one we can read: its uses were counted
		# with everything else. Only a parent living elsewhere forces a softer
		# verdict -- so stzListParser (whose stzParser sits above it in the same
		# file) still gets an error, while stzHttpClient (whose stzNetwork is in
		# another file) gets a warning naming the class to go and check.
		_cParent_ = _StzKnobParentName(_acLines_[_nFrom_])
		if _cParent_ != "" and StzFindFirst(StzLower(_cParent_), _StzKnobLower(_acCls_)) > 0
			_cParent_ = ""
		ok
		_aF_ = _StzKnobScanClass(_acLines_, _nFrom_, _nTo_, _cParent_, _cSrc_)
		_nF_ = len(_aF_)
		for _i_ = 1 to _nF_
			_aOut_ + _aF_[_i_]
		next
	next
	return _aOut_

func _StzKnobScanClass(pacLines, pnFrom, pnTo, pcParent, pcSrc)
	_aOut_ = []

	# A REAL DOMAIN PARENT LIVES IN ANOTHER FILE, and may be the one reading the
	# attribute -- stzHttpClient writes @timeout_seconds for stzNetwork.Timeout()
	# to return. This pass sees one file, so a class with such a parent gets a
	# warning where a standalone class gets an error. stzObject is not a real
	# parent for this purpose: everything descends from it and it reads nothing.
	_bInherits_ = (pcParent != "" and StzLower(pcParent) != "stzobject")

	# ── method spans inside the class
	_acM_ = []
	_anMFrom_ = []
	for _i_ = pnFrom to pnTo
		_cM_ = _StzKnobDefName(pacLines[_i_])
		if _cM_ != ""
			_acM_ + _cM_
			_anMFrom_ + _i_
		ok
	next
	_nM_ = len(_acM_)
	if _nM_ = 0
		return _aOut_
	ok

	# ── what each setter writes at statement start
	_acWrit_ = []
	_acWritBy_ = []
	_anWritAt_ = []
	for _j_ = 1 to _nM_
		if NOT _StzKnobIsSetterName(_acM_[_j_])
			loop
		ok
		if StzLower(_acM_[_j_]) = "init"
			loop
		ok
		_nMTo_ = pnTo
		if _j_ < _nM_
			_nMTo_ = _anMFrom_[_j_ + 1] - 1
		ok
		for _i_ = _anMFrom_[_j_] + 1 to _nMTo_
			_cA_ = _StzKnobAssignedAt(_StzKnobStrip(pacLines[_i_]))
			if _cA_ != "" and StzFindFirst(_cA_, _acWrit_) = 0
				_acWrit_ + _cA_
				_acWritBy_ + _acM_[_j_]
				_anWritAt_ + _i_
			ok
		next
	next
	_nW_ = len(_acWrit_)
	if _nW_ = 0
		return _aOut_
	ok

	# ── every attribute the class mentions, for the twin hint
	_acAll_ = []
	for _i_ = pnFrom to pnTo
		_aA_ = _StzKnobAttrsIn(_StzKnobStrip(pacLines[_i_]))
		_nA_ = len(_aA_)
		for _q_ = 1 to _nA_
			if StzFindFirst(_aA_[_q_], _acAll_) = 0
				_acAll_ + _aA_[_q_]
			ok
		next
	next

	# ── count the reads of each written attribute, and note which of them
	#    happen inside a method that does nothing but return it
	for _w_ = 1 to _nW_
		_cAttr_ = _acWrit_[_w_]
		_nReads_ = 0
		_nGetterReads_ = 0
		_cGetter_ = ""

		# every line of the FILE, because a sibling class in the same file may
		# read the attribute directly (@oDiagram.@cArrowHead) -- scoping this to
		# the declaring class called six live diagram knobs dead
		_nAll_ = len(pacLines)
		for _i_ = 1 to _nAll_
			if _i_ >= pnFrom and _i_ <= pnTo
				loop        # the declaring class is walked method by method below
			ok
			_cL_ = _StzKnobStrip(pacLines[_i_])
			_aA_ = _StzKnobAttrsIn(_cL_)
			_nA_ = len(_aA_)
			for _q_ = 1 to _nA_
				if _aA_[_q_] = _cAttr_
					_nReads_++
				ok
			next
		next

		for _j_ = 1 to _nM_
			_nMTo_ = pnTo
			if _j_ < _nM_
				_nMTo_ = _anMFrom_[_j_ + 1] - 1
			ok
			_bTrivial_ = _StzKnobIsTrivialGetter(pacLines, _anMFrom_[_j_], _nMTo_, _cAttr_)
			for _i_ = _anMFrom_[_j_] + 1 to _nMTo_
				_cL_ = _StzKnobStrip(pacLines[_i_])
				if _StzKnobAssignedAt(_cL_) = _cAttr_
					loop
				ok
				_aA_ = _StzKnobAttrsIn(_cL_)
				_nA_ = len(_aA_)
				for _q_ = 1 to _nA_
					if _aA_[_q_] = _cAttr_
						_nReads_++
						if _bTrivial_
							_nGetterReads_++
							_cGetter_ = _acM_[_j_]
						ok
					ok
				next
			next
		next

		if _nReads_ = 0
			_cMsg_ = "@" + _cAttr_ + " is written by " + _acWritBy_[_w_] +
			         "() and read by nothing -- the setting cannot change anything"
			_cTwin_ = _StzKnobTwinOf(_cAttr_, _acAll_)
			if _cTwin_ != ""
				_cMsg_ += " (@" + _cTwin_ + " is the live one, one letter away)"
			ok
			_cSev_ = :error
			if _bInherits_
				_cSev_ = :warning
				_cMsg_ += " here -- check " + pcParent + ", which may read it"
			ok
			_aOut_ + [ :rule = :dead_knob, :line = _anWritAt_[_w_],
			           :severity = _cSev_, :message = _cMsg_ ]

		but _nReads_ = _nGetterReads_ and _cGetter_ != ""
			# suppressed when something else in this source names the getter
			if _StzKnobGetterUsedElsewhere(pcSrc, _cGetter_)
				loop
			ok
			_aOut_ + [ :rule = :dead_knob, :line = _anWritAt_[_w_],
			           :severity = :warning,
			           :message = "@" + _cAttr_ + " is written by " + _acWritBy_[_w_] +
			           "() and read only by " + _cGetter_ +
			           "() -- it answers you and changes nothing" ]
		ok
	next
	return _aOut_

# A method whose whole body is "return @attr".
func _StzKnobIsTrivialGetter(pacLines, pnDef, pnTo, pcAttr)
	_nSeen_ = 0
	_bMatch_ = FALSE
	for _i_ = pnDef + 1 to pnTo
		_cL_ = ring_trim(StzReplace(_StzKnobStrip(pacLines[_i_]), char(9), " "))
		if _cL_ = ""
			loop
		ok
		_nSeen_++
		if _nSeen_ > 1
			return FALSE
		ok
		if StzLower(_cL_) = "return @" + pcAttr
			_bMatch_ = TRUE
		ok
	next
	return _bMatch_ and _nSeen_ = 1

# Does anything outside its own definition name this getter?
#
# The match must sit on a WORD BOUNDARY. Without that, SetGetterOnly() contains
# GetterOnly( and every getter looks used -- which silently switched this whole
# verdict off the first time it ran.
func _StzKnobGetterUsedElsewhere(pcSrc, pcGetter)
	_cNeedle_ = "" + pcGetter + "("
	_aHit_ = StzFindCS(_cNeedle_, "" + pcSrc, FALSE)
	_n_ = len(_aHit_)
	for _i_ = 1 to _n_
		_nAt_ = _aHit_[_i_]
		if _nAt_ > 1
			_nB_ = ascii(StzMid("" + pcSrc, _nAt_ - 1, 1))
			if (_nB_ >= 97 and _nB_ <= 122) or (_nB_ >= 65 and _nB_ <= 90) or
			   (_nB_ >= 48 and _nB_ <= 57) or _nB_ = 95
				loop        # a longer name ending in this one
			ok
		ok
		# its own definition does not count as a use
		_nLineStart_ = _nAt_ - 8
		if _nLineStart_ < 1
			_nLineStart_ = 1
		ok
		_cBefore_ = StzLower(StzMid("" + pcSrc, _nLineStart_, _nAt_ - _nLineStart_))
		if len(StzFindCS("def ", _cBefore_, FALSE)) > 0
			loop
		ok
		return TRUE
	next
	return FALSE

# @nSteps beside @nStep: the same name give or take a trailing s.
func _StzKnobTwinOf(pcAttr, pacAll)
	_c_ = "" + pcAttr
	if StzRight(_c_, 1) = "s"
		_cShort_ = StzLeft(_c_, len(_c_) - 1)
		if StzFindFirst(_cShort_, pacAll) > 0
			return _cShort_
		ok
	ok
	if StzFindFirst(_c_ + "s", pacAll) > 0
		return _c_ + "s"
	ok
	return ""

# SETTER-RESETS-ON-REJECT: a setter that answers a value it dislikes by
# overwriting what was already there.
#
# SetSplines("ortho") then SetSplines("dashed") left you with "spline" -- the
# default. Not the value you asked for the first time, not the one you asked
# for the second. Every other validating setter in that class leaves the knob
# alone when it refuses, which is what makes this one a defect and not a taste.
#
# The shape: inside a setter, an if-branch assigns an attribute from the
# parameter, and the else-branch assigns the SAME attribute something that does
# not mention the parameter.
func _StzCheckSetterResets(pcSource)
	_aOut_ = []
	_cSrc_ = StzReplace("" + pcSource, char(13), "")
	_acLines_ = StzSplit(_cSrc_, char(10))
	_nLen_ = len(_acLines_)

	_cMethod_ = ""
	_cParam_ = ""
	_nMethodAt_ = 0
	_acIfWrit_ = []
	_bInElse_ = FALSE

	for _i_ = 1 to _nLen_
		_cRaw_ = _StzKnobStrip(_acLines_[_i_])
		_cL_ = ring_trim(StzReplace(_cRaw_, char(9), " "))

		_cD_ = _StzKnobDefName(_acLines_[_i_])
		if _cD_ != "" or StzLower(StzLeft(_cL_, 6)) = "class "
			_cMethod_ = _cD_
			_nMethodAt_ = _i_
			_cParam_ = _StzKnobFirstParam(_acLines_[_i_])
			_acIfWrit_ = []
			_bInElse_ = FALSE
			loop
		ok

		if _cMethod_ = "" or NOT _StzKnobIsSetterName(_cMethod_)
			loop
		ok

		if StzLower(_cL_) = "else"
			_bInElse_ = TRUE
			loop
		ok
		if StzLower(_cL_) = "ok"
			_bInElse_ = FALSE
			_acIfWrit_ = []
			loop
		ok

		_cA_ = _StzKnobAssignedAt(_cRaw_)
		if _cA_ = ""
			loop
		ok

		if NOT _bInElse_
			if StzFindFirst(_cA_, _acIfWrit_) = 0
				_acIfWrit_ + _cA_
			ok
			loop
		ok

		# in the else branch, assigning something the if branch already set
		if StzFindFirst(_cA_, _acIfWrit_) = 0
			loop
		ok
		if _cParam_ != "" and len(StzFindCS(_cParam_, _cL_, FALSE)) > 0
			loop        # still derived from the caller's value -- not a reset
		ok
		_aOut_ + [ :rule = :setter_resets_on_reject, :line = _i_,
		           :severity = :warning,
		           :message = _cMethod_ + "() overwrites @" + _cA_ +
		           " when it refuses a value -- a rejected value should leave " +
		           "the knob as it was, not reset it" ]
	next
	return _aOut_

func _StzKnobFirstParam(pcLine)
	_c_ = ring_trim(StzReplace("" + pcLine, char(9), " "))
	_nOpen_ = StzFindFirst("(", _c_)
	if _nOpen_ = 0
		return ""
	ok
	_cRest_ = StzMidToEnd(_c_, _nOpen_ + 1)
	_nClose_ = StzFindFirst(")", _cRest_)
	if _nClose_ > 0
		_cRest_ = StzLeft(_cRest_, _nClose_ - 1)
	ok
	_aP_ = StzSplit(_cRest_, ",")
	if len(_aP_) = 0
		return ""
	ok
	return ring_trim(_aP_[1])

# "class stzHttpClient from stzNetwork" -> stzNetwork
func _StzKnobParentName(pcLine)
	_c_ = ring_trim(StzReplace("" + pcLine, char(9), " "))
	_nAt_ = StzFindFirst(" from ", StzLower(_c_))
	if _nAt_ = 0
		return ""
	ok
	_aP_ = StzSplit(ring_trim(StzMidToEnd(_c_, _nAt_ + 6)), " ")
	if len(_aP_) = 0
		return ""
	ok
	return ring_trim(_aP_[1])

func _StzKnobLower(paNames)
	_aOut_ = []
	_n_ = len(paNames)
	for _i_ = 1 to _n_
		_aOut_ + StzLower("" + paNames[_i_])
	next
	return _aOut_
