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
	         "dead-knob", "setter-resets-on-reject",
	         "setter-only-moves-one-way", "misspelled-name", "library-prints",
	         "empty-method-body", "writes-a-mutable-constant",
	         "value-called-as-function" ]

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
		# ONE list of passes, walked once. This used to be a copy-pasted block per
		# rule, and when three new rules were added to StzCheckCode() they were not
		# added here -- so the project walk reported a clean library by running two
		# rules out of five. A list cannot half-land that way.
		_aPasses_ = _StzTextPassFindings(_cSrc_)
		_nP_ = len(_aPasses_)
		for _j_ = 1 to _nP_
			_aOut_ + [ :rule = _aPasses_[_j_][:rule], :subject = :code,
			           :where = _cPath_ + ":" + _aPasses_[_j_][:line],
			           :severity = _aPasses_[_j_][:severity],
			           :message = _aPasses_[_j_][:message] ]
		next
	next
	return _aOut_

# THE text-pass rule set, in one place. Both entry points read it from here:
# StzCheckCode() for a snippet, StzCheckProjectKnobs() for a tree. These are the
# rules that need statement-level detail -- which attribute a line assigns,
# whether an else-branch overwrites it -- that the class/method/call graph the
# graph rules run on does not carry.
func _StzTextPassFindings(pcSource)
	_aOut_ = []

	# DOCUMENTATION IS NOT CODE. Almost every method in this library carries a
	# worked sample in a /* */ block -- real Ring lines, showing real calls. The
	# text passes had no idea those blocks existed, so they read the samples as
	# statements: 245 of 259 reported prints were documentation. The same blindness
	# runs the other way for the knob rules, where a sample that merely MENTIONS an
	# attribute counted as a consumer and could hide a dead one.
	#
	# Blanked, not removed -- line numbers have to survive, or every finding points
	# at the wrong line.
	_cClean_ = _StzStripBlockComments(pcSource)

	_aPasses_ = [
		_StzCheckDeadKnobs(_cClean_),
		_StzCheckSetterResets(_cClean_),
		_StzCheckOneWaySetters(_cClean_),
		_StzCheckMisspelledNames(_cClean_),
		_StzCheckLibraryPrints(_cClean_),
		_StzCheckEmptyBodies(_cClean_),
		_StzCheckConstantWrites(_cClean_),
		_StzCheckValueCalls(_cClean_),
		_StzCheckForInLoops(_cClean_)
	]
	_nP_ = len(_aPasses_)
	for _i_ = 1 to _nP_
		_aOne_ = _aPasses_[_i_]
		_nQ_ = len(_aOne_)
		for _j_ = 1 to _nQ_
			_aOut_ + _aOne_[_j_]
		next
	next
	return _aOut_

# Blank out every /* ... */ region, keeping the line structure intact so a
# finding's :line still points where a reader would look. Comment characters
# become nothing rather than spaces -- no pass cares about a line's width, and
# an emptied line simply matches no rule.
#
# Block state is carried ACROSS lines, which is the whole point: a sample opens
# on one line and closes several lines later, and a per-line strip cannot see it.
func _StzStripBlockComments(pcSource)
	_cSrc_ = StzReplace("" + pcSource, char(13), "")
	if len(StzFindCS("/*", _cSrc_, 1)) = 0
		return _cSrc_
	ok

	_acLines_ = StzSplit(_cSrc_, char(10))
	_nLen_ = len(_acLines_)
	_bIn_ = 0
	_cOut_ = ""

	for _i_ = 1 to _nLen_
		_cKept_ = ""
		_cRest_ = _acLines_[_i_]

		while 1
			if _bIn_
				_nEnd_ = StzFindFirst("*/", _cRest_)
				if _nEnd_ = 0
					exit   # the block runs on into the next line
				ok
				_bIn_ = 0
				_cRest_ = StzMidToEnd(_cRest_, _nEnd_ + 2)
			else
				_nSt_ = StzFindFirst("/*", _cRest_)
				if _nSt_ = 0
					_cKept_ += _cRest_
					exit
				ok
				if _nSt_ > 1
					_cKept_ += StzMid(_cRest_, 1, _nSt_ - 1)
				ok
				_bIn_ = 1
				_cRest_ = StzMidToEnd(_cRest_, _nSt_ + 2)
			ok
		end

		_cOut_ += _cKept_ + char(10)
	next
	return _cOut_

# TRUE when a whole project has no ERROR-severity finding (warnings advise).
func StzProjectIsClean(pcDir)
	_aF_ = StzCheckProject(pcDir)
	_n_ = len(_aF_)
	for _i_ = 1 to _n_
		if "" + _aF_[_i_][:severity] = "error"
			return 0
		ok
	next
	return 1

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

	# 3. the text-pass rules -- knobs, ratchets, names, prints. They come from
	#    _StzTextPassFindings() so that this entry point and the project walk can
	#    never disagree about which rules exist.
	_aK_ = _StzTextPassFindings(_cSrc_)
	_nK_ = len(_aK_)
	for _i_ = 1 to _nK_
		_aFindings_ + _aK_[_i_]
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
			return 0
		ok
	next
	return 1

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
			return 1
		ok
	next
	return 0

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
	_bMatch_ = 0
	for _i_ = pnDef + 1 to pnTo
		_cL_ = ring_trim(StzReplace(_StzKnobStrip(pacLines[_i_]), char(9), " "))
		if _cL_ = ""
			loop
		ok
		_nSeen_++
		if _nSeen_ > 1
			return 0
		ok
		if StzLower(_cL_) = "return @" + pcAttr
			_bMatch_ = 1
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
	_aHit_ = StzFindCS(_cNeedle_, "" + pcSrc, 0)
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
		if len(StzFindCS("def ", _cBefore_, 0)) > 0
			loop
		ok
		return 1
	next
	return 0

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
	_bInElse_ = 0

	for _i_ = 1 to _nLen_
		_cRaw_ = _StzKnobStrip(_acLines_[_i_])
		_cL_ = ring_trim(StzReplace(_cRaw_, char(9), " "))

		_cD_ = _StzKnobDefName(_acLines_[_i_])
		if _cD_ != "" or StzLower(StzLeft(_cL_, 6)) = "class "
			_cMethod_ = _cD_
			_nMethodAt_ = _i_
			_cParam_ = _StzKnobFirstParam(_acLines_[_i_])
			_acIfWrit_ = []
			_bInElse_ = 0
			loop
		ok

		if _cMethod_ = "" or NOT _StzKnobIsSetterName(_cMethod_)
			loop
		ok

		if StzLower(_cL_) = "else"
			_bInElse_ = 1
			loop
		ok
		if StzLower(_cL_) = "ok"
			_bInElse_ = 0
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
		if _cParam_ != "" and len(StzFindCS(_cParam_, _cL_, 0)) > 0
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

#=====================================================================#
#  THREE SHAPES THE HAND AUDITS KEPT FINDING                          #
#=====================================================================#
# Sixteen module audits followed the first two knob rules. The gate caught the
# defect twice; the other fourteen were found by a person -- and each was a
# SHAPE that came back. These are the three that recurred often enough, and
# precisely enough, to be worth a rule.

# SETTER-ONLY-MOVES-ONE-WAY: max() or min() against the attribute being set.
#
#     @nVizHeight = max([@nVizHeight, n])
#
# That is a ratchet: the value can only ever rise, and a smaller one is
# swallowed without a word. The sibling setter one line up floors against a
# MINIMUM -- max([@nVizMinHeight, n]) -- which is what was meant. The same line
# had propagated into two classes, and the demo that exercised it only ever
# raised the value, where a ratchet and a working setter agree.
func _StzCheckOneWaySetters(pcSource)
	_aOut_ = []
	_acLines_ = StzSplit(StzReplace("" + pcSource, char(13), ""), char(10))
	_nLen_ = len(_acLines_)
	_cMethod_ = ""

	for _i_ = 1 to _nLen_
		_cD_ = _StzKnobDefName(_acLines_[_i_])
		if _cD_ != ""
			_cMethod_ = _cD_
			loop
		ok
		if _cMethod_ = "" or NOT _StzKnobIsSetterName(_cMethod_)
			loop
		ok

		_cL_ = _StzKnobStrip(_acLines_[_i_])
		_cA_ = _StzKnobAssignedAt(_cL_)
		if _cA_ = ""
			loop
		ok

		_cLow_ = StzLower(_cL_)
		if len(StzFindCS("max(", _cLow_, 0)) = 0 and
		   len(StzFindCS("min(", _cLow_, 0)) = 0
			loop
		ok

		# the attribute has to appear on the RIGHT of the assignment too
		_nEq_ = StzFindFirst("=", _cL_)
		if _nEq_ = 0
			loop
		ok
		_cRhs_ = StzMidToEnd(_cL_, _nEq_ + 1)
		_aRhs_ = _StzKnobAttrsIn(_cRhs_)
		if StzFindFirst(_cA_, _aRhs_) = 0
			loop
		ok

		_aOut_ + [ :rule = :setter_only_moves_one_way, :line = _i_,
		           :severity = :error,
		           :message = _cMethod_ + "() bounds @" + _cA_ + " against ITSELF" +
		           " -- the value can only move one way, and the other direction is" +
		           " swallowed. A floor belongs in a separate minimum." ]
	next
	return _aOut_

# MISSPELLED-NAME: a method whose name carries a known misspelling while the
# correctly spelled name does NOT exist.
#
# Recieve, RecieveMany, OnRecieved, SetCurrenCell -- four across three classes,
# and in every case the name a caller reaches for simply was not there. The old
# spelling is not the defect; the MISSING one is, so a file that offers both is
# left alone.

# TRUE when a name carries the camel segment "Curren" -- capital C, and the next
# character opens the next word (or the name ends). Current and Currency are the
# correct spellings and never fire.
func _StzNameHasCamelCurren(pcName)
	_c_ = "" + pcName
	if len(StzFindCS("Current", _c_, 1)) > 0 or
	   len(StzFindCS("Currenc", _c_, 1)) > 0
		return 0
	ok
	_aAt_ = StzFindCS("Curren", _c_, 1)
	_n_ = len(_aAt_)
	for _i_ = 1 to _n_
		_nAfter_ = _aAt_[_i_] + 6
		if _nAfter_ > StzLen(_c_)
			return 1
		ok
		# Uppercase = a character that DIFFERS from its own lowercase form. Ring
		# raises R41 comparing strings with >=, and ascii() raises on anything that
		# is not exactly one character -- this needs neither.
		#
		# StzMid is (start, COUNT): the second argument used to repeat the
		# position, so this compared the whole REST of the name against its
		# lowercase and answered "there is an uppercase somewhere after Curren"
		# instead of "the next character opens a word". It reached the right
		# verdict on SetCurrenCell by luck.
		_cNext_ = StzMid(_c_, _nAfter_, 1)
		if _cNext_ != "" and _cNext_ != StzLower(_cNext_)
			return 1
		ok
	next
	return 0

func _StzMisspellings()
	return [
		[ "recieve",   "receive"   ],
		[ "recieved",  "received"  ],
		[ "seperat",   "separat"   ],
		[ "occurence", "occurrence"],
		[ "lenght",    "length"    ],
		[ "adress",    "address"   ],
		[ "sucess",    "success"   ],
		[ "retreive",  "retrieve"  ],
		[ "existance", "existence" ],
		[ "independant","independent" ]
	]

func _StzCheckMisspelledNames(pcSource)
	_aOut_ = []
	_cSrc_ = StzReplace("" + pcSource, char(13), "")
	_acLines_ = StzSplit(_cSrc_, char(10))
	_nLen_ = len(_acLines_)
	_cLowSrc_ = StzLower(_cSrc_)
	_aPairs_ = _StzMisspellings()
	_nP_ = len(_aPairs_)
	_acSeen_ = []

	for _i_ = 1 to _nLen_
		_cD_ = _StzKnobDefName(_acLines_[_i_])
		if _cD_ = ""
			loop
		ok
		_cLowD_ = StzLower(_cD_)

		for _k_ = 1 to _nP_
			if len(StzFindCS(_aPairs_[_k_][1], _cLowD_, 0)) = 0
				loop
			ok
			_cRight_ = StzReplace(_cLowD_, _aPairs_[_k_][1], _aPairs_[_k_][2])
			# already offered? then the old spelling is a kept alias, not a gap
			if len(StzFindCS("def " + _cRight_ + "(", _cLowSrc_, 0)) > 0
				loop
			ok
			if StzFindFirst(_cLowD_, _acSeen_) > 0
				loop
			ok
			_acSeen_ + _cLowD_
			_aOut_ + [ :rule = :misspelled_name, :line = _i_,
			           :severity = :warning,
			           :message = _cD_ + "() is misspelled and " + _cRight_ +
			           "() does not exist -- the name a caller reaches for is missing" ]
		next

		# "Curren" without the t: SetCurrenCell.
		#
		# This must read the CAMEL segment, not the lowercased name. Occurrence
		# contains c-u-r-r-e-n -- O-c-CURREN-ce -- so a lowercase search called
		# every CountOccurrencesOf() in the library a typo: 878 findings, all of
		# them noise, from one fragment that is a real English substring.
		# The segment only counts when it OPENS a camel word.
		if _StzNameHasCamelCurren(_cD_)
			_cRight2_ = StzReplace(_cLowD_, "curren", "current")
			if len(StzFindCS("def " + _cRight2_ + "(", _cLowSrc_, 0)) = 0
				_aOut_ + [ :rule = :misspelled_name, :line = _i_,
				           :severity = :warning,
				           :message = _cD_ + "() is missing the T of Current, and " +
				           _cRight2_ + "() does not exist" ]
			ok
		ok
	next
	return _aOut_

# LIBRARY-PRINTS: a class method that writes to the console while it works.
#
# A stream at capacity printed four different warnings from inside its overflow
# switch -- with non-ASCII glyphs, against the house rule on console output --
# while an OnOverflow handler seam sat right above it, already being called.
# A library that prints during data flow is doing the caller's job.
#
# Methods whose whole purpose is to display are exempt: Show*, Narrate, Explain,
# Display, Print, Dump, and anything named *Report.
func _StzPrintExemptMethod(pcName)
	_c_ = StzLower("" + pcName)

	# a leading underscore marks an internal helper, it does not change what the
	# method is FOR: _showFormattedPivotTable1D displays, like ShowTable does.
	while StzLeft(_c_, 1) = "_"
		_c_ = StzMidToEnd(_c_, 2)
	end

	_aEx_ = [ "show", "narrate", "explain", "display", "print", "dump",
	          "trace", "log", "report", "emit" ]
	_n_ = len(_aEx_)
	for _i_ = 1 to _n_
		if StzLeft(_c_, len(_aEx_[_i_])) = _aEx_[_i_]
			return 1
		ok
	next
	if StzRight(_c_, 6) = "report"
		return 1
	ok
	return 0

# A print the caller ASKED for is not the library talking over you.
#
#     if @bDebugMode
#         ? "Tokens parsed: " + len(@aTokens)
#     ok
#
# That is the correct shape -- a knob, off by default, that the caller turns on
# -- and the regex classes use it consistently. Flagging it would have buried
# the handful of unconditional prints under a hundred correct ones.
func _StzUnderADebugFlag(pacOpenIfs)
	_aWords_ = [ "debug", "verbose", "trace", "tracing" ]
	_n_ = len(pacOpenIfs)
	_nW_ = len(_aWords_)
	for _i_ = 1 to _n_
		for _j_ = 1 to _nW_
			if len(StzFindCS(_aWords_[_j_], "" + pacOpenIfs[_i_], 0)) > 0
				return 1
			ok
		next
	next
	return 0

# A VALUE CANNOT BE CALLED, so `)(` is never valid Ring -- there is no
# currying and no call-on-result. It is, however, exactly what a blind token
# replacement leaves behind, and it PARSES: the failure waits until the line
# actually runs and then reads R20, "Calling function with extra number of
# parameters", which points at the arity of a function that was never wrong.
#
# Paid for: the NL sweep rewrote calls to the accessor NL() into `char(10)()`.
# Eighteen sites survived in stzGrid and stzTile, because the only guard that
# would have executed them was itself dead for an unrelated reason -- so the
# damage sat behind a failure that looked like someone else's problem.
#
# The same sweep damaged DEFINITION names (`func NL@@NL(p)` became
# `func char(10)@@NL(p)`), so a def whose name does not end where its
# parameter list begins is flagged by the same rule.
#
# Strings are blanked first, across the WHOLE source rather than line by line
# -- see _StzBlankStringsAll. That is not a detail: base/extercode/ holds C in
# multi-line literals, where `)(` is a legitimate function-pointer form, and
# stzStringArtData holds ASCII art full of it. A per-line blanker reported 549
# findings here, every one of them noise.
# THE LOOP BOUND IS READ ONCE -- and `for X in SOURCE` cannot read it
# once, which is why the form is refused rather than merely discouraged.
#
# Ring re-evaluates a for/in SOURCE on every step. Measured on Ring 1.27
# with a 400-element list:
#
#     for _x_ in This._Method()   ->  the method ran 801 TIMES
#     hoisted into a variable     ->  once
#
# Twice per iteration plus one. When the source is a method that sorts,
# filters or builds -- and in this library most of them are -- the loop
# is quadratic with a heavy constant, and nothing in the source looks
# slow. Over a plain list it is still 3x, because the list is copied.
#
# The Principal found it in stzDiagram at `for _cd_ in
# This._ClusterDepths()`, a method that SORTS, called once per cluster
# per cluster. The rule was already in this project's operating notes
# and had been ignored across 193 sites in that one file.
#
# THE FORM THAT IS ALWAYS RIGHT:
#
#     _aX_ = <source>
#     _nX_ = len(_aX_)
#     for _i_ = 1 to _nX_
#         _x_ = _aX_[_i_]
#
# Reported for library code only -- a test or a one-shot script may use
# whichever form reads best, since neither the size nor the source is a
# surprise there.
func _StzCheckForInLoops(pcSource)
	_aOut_ = []
	_cBlank_ = _StzBlankStringsAll(StzReplace("" + pcSource, char(13), ""))
	_acLines_ = StzSplit(_cBlank_, char(10))
	_nLen_ = len(_acLines_)

	for _i_ = 1 to _nLen_
		_cL_ = StzTrim("" + _acLines_[_i_])
		if StzLeft(_cL_, 1) = "#"  loop  ok
		if StzLeft(_cL_, 4) != "for "  loop  ok
		# `for X in ...` -- never `for X = 1 to N`, which is the form
		# this rule exists to ask for
		if StzFindFirst(" in ", _cL_) < 1  loop  ok
		if StzFindFirst(" = ", _cL_) > 0 and
		   StzFindFirst(" = ", _cL_) < StzFindFirst(" in ", _cL_)
			loop
		ok
		_aOut_ + [ :rule = :for_in_loop, :line = _i_,
			:severity = :warning,
			:message = "the loop source is re-read on every step -- " +
				"hoist it: aX = <source> / nX = len(aX) / " +
				"for i = 1 to nX" ]
	next
	return _aOut_

func _StzCheckValueCalls(pcSource)
	_aOut_ = []
	_cBlank_ = _StzBlankStringsAll(StzReplace("" + pcSource, char(13), ""))
	_acLines_ = StzSplit(_cBlank_, char(10))
	_nLen_ = len(_acLines_)

	for _i_ = 1 to _nLen_
		_cL_ = _acLines_[_i_]
		_n_ = len(_cL_)
		if _n_ < 2
			loop
		ok

		_bDef_ = 0
		_cT_ = StzLower(ring_trim(StzReplace(_cL_, char(9), " ")))
		if StzLeft(_cT_, 5) = "func " or StzLeft(_cT_, 4) = "def "
			_bDef_ = 1
		ok

		for _j_ = 1 to _n_ - 1
			if _cL_[_j_] != ")"
				loop
			ok

			# ADJACENCY IS REQUIRED, and it is what keeps this rule honest.
			# A token sweep substitutes in place, so the damage it leaves is
			# always glued: `char(10)()`, `char(10)@@NL(p)`. Allowing spaces
			# instead flagged 545 innocent lines -- every same-line method
			# body in the library, `def Width()   return @nW`, reads as a
			# name followed by more name once you skip the gap.
			_cNext_ = _cL_[_j_ + 1]

			if _cNext_ = "("
				_aOut_ + [ :rule = :value_called_as_function, :line = _i_,
				           :severity = :error,
				           :message = "')(' calls the RESULT of a call -- Ring has no" +
				           " such form. This is the shape a token sweep leaves when it" +
				           " rewrites a call like NL() into char(10)(). It parses, then" +
				           " dies R20 at run time." ]
				exit
			ok

			# On a definition line only: the name must END at its paren.
			# `func char(10)@@NL(p)` is a name glued to a call. `@` is not in
			# _StzIsIdentChar's alphabet (it lives in stzListFunc.ring and is
			# reused rather than redefined -- a second definition is a C22 that
			# takes the whole library's load down with it), so add it here.
			if _bDef_ and (_StzIsIdentChar(_cNext_) or _cNext_ = "@")
				_aOut_ + [ :rule = :value_called_as_function, :line = _i_,
				           :severity = :error,
				           :message = "a definition NAME does not end where its" +
				           " parameter list begins -- the shape a token sweep leaves" +
				           " when it rewrites the name of a func, not its body" ]
				exit
			ok
		next
	next
	return _aOut_

# Replace every string literal's CONTENT with spaces, over the WHOLE source
# rather than line by line, keeping newlines and line widths so a finding's
# :line still points where a reader would look.
#
# Whole-source is the entire point. A Ring literal spans newlines, so a
# per-line blanker resets its quote state at every line break and reads the
# INSIDE of a multi-line literal as code. Measured, not assumed: the per-line
# version of this rule reported 549 findings across the library -- ASCII art
# in stzStringArtData, C in extercode, SVG and DOT templates in graph and
# graphics, all of which legitimately contain ')('. This version reports the
# real damage only.
func _StzBlankStringsAll(pcSource)
	_c_ = "" + pcSource
	_n_ = len(_c_)
	_cOut_ = ""
	_cQuote_ = ""
	_i_ = 1

	while _i_ <= _n_
		_ch_ = _c_[_i_]

		if _cQuote_ != ""
			# Newlines survive so the line numbering does; everything else
			# inside the literal becomes a space.
			if _ch_ = char(10)
				_cOut_ += _ch_
			but _ch_ = _cQuote_
				_cOut_ += _ch_
				_cQuote_ = ""
			else
				_cOut_ += " "
			ok
			_i_++
			loop
		ok

		if _ch_ = char(34) or _ch_ = char(39)
			_cQuote_ = _ch_
			_cOut_ += _ch_
			_i_++
			loop
		ok

		# A comment runs to the end of ITS line, and a quote inside it must
		# not open a literal -- prose says "don't" often enough to matter.
		if _ch_ = "#" or (_ch_ = "/" and _i_ < _n_ and _c_[_i_+1] = "/")
			while _i_ <= _n_ and _c_[_i_] != char(10)
				_i_++
			end
			if _i_ <= _n_
				_cOut_ += char(10)
				_i_++
			ok
			loop
		ok

		_cOut_ += _ch_
		_i_++
	end
	return _cOut_

func _StzCheckLibraryPrints(pcSource)
	_aOut_ = []
	_acLines_ = StzSplit(StzReplace("" + pcSource, char(13), ""), char(10))
	_nLen_ = len(_acLines_)
	_cMethod_ = ""
	_bInClass_ = 0
	_acOpenIfs_ = []

	for _i_ = 1 to _nLen_
		if _StzKnobClassName(_acLines_[_i_]) != ""
			_bInClass_ = 1
			_cMethod_ = ""
			_acOpenIfs_ = []
			loop
		ok
		_cD_ = _StzKnobDefName(_acLines_[_i_])
		if _cD_ != ""
			_cMethod_ = _cD_
			_acOpenIfs_ = []
			loop
		ok

		# Which if-blocks is this line inside? Pushed on "if", popped on "ok" --
		# enough to answer the only question that matters below: is the print
		# CONDITIONAL on a debug flag.
		_cT_ = StzLower(ring_trim(StzReplace(_StzKnobStrip(_acLines_[_i_]), char(9), " ")))
		if StzLeft(_cT_, 3) = "if "
			_acOpenIfs_ + _cT_
		but _cT_ = "ok" and len(_acOpenIfs_) > 0
			del(_acOpenIfs_, len(_acOpenIfs_))
		ok

		if NOT _bInClass_ or _cMethod_ = ""
			loop
		ok
		if _StzPrintExemptMethod(_cMethod_)
			loop
		ok
		if _StzUnderADebugFlag(_acOpenIfs_)
			loop
		ok

		_cL_ = ring_trim(StzReplace(_StzKnobStrip(_acLines_[_i_]), char(9), " "))
		if StzLeft(_cL_, 2) != "? "
			loop
		ok
		_aOut_ + [ :rule = :library_prints, :line = _i_,
		           :severity = :warning,
		           :message = _cMethod_ + "() writes to the console -- a library" +
		           " reports through its return value or a handler, not stdout" ]
	next
	return _aOut_

# EMPTY-METHOD-BODY: a class method that is declared and does nothing.
#
# stzReactiveSystem.SetTimeoutXT was one. It sat between RunAfterXT and
# RunAfter, was declared, and the next line was the next method -- so every call
# scheduled no timer and answered nothing, while SetTimeout one screen down
# delegates correctly. Nothing raised, and nothing could: the method existed.
#
# A PREDICATE that does nothing is the worse half and gets the harsher verdict.
# A Ring method with no return answers NULL, which reads as FALSE -- so an empty
# ContainsValues() does not fail, it confidently says "no" about everything.
#
# THREE FORMS OF SAME-LINE BODY have to be excluded, and each was found the
# expensive way -- a first, second and third draft of this rule reported 83, 51
# and 32 sites where the truth was 23:
#
#     def Image(pc)      { @cImage = pc ; return This }      # brace form
#     def SetTopP(n) @nTopP = n                              # bare form
#     def Ping()  # nothing to do here                       # comment only
#
# The first two are ordinary Ring and must never be flagged. The third IS an
# empty method and is flagged -- a comment saying nothing happens does not make
# the caller any less misled.
#
# init() is exempt: a class that keeps its state in the engine, or has none at
# all, legitimately has nothing to initialise.
func _StzCheckEmptyBodies(pcSource)
	_aOut_ = []
	_acLines_ = StzSplit(StzReplace("" + pcSource, char(13), ""), char(10))
	_nLen_ = len(_acLines_)
	_bInClass_ = 0

	for _i_ = 1 to _nLen_
		if _StzKnobClassName(_acLines_[_i_]) != ""
			_bInClass_ = 1
			loop
		ok
		if NOT _bInClass_
			loop
		ok

		_cName_ = _StzKnobDefName(_acLines_[_i_])
		if _cName_ = "" or StzLower(_cName_) = "init"
			loop
		ok
		if _StzDefSameLineBody(_acLines_[_i_]) != ""
			loop
		ok

		# The body is whatever comes before the next def or class. Blank lines
		# and comments are not statements, so they are skipped rather than
		# counted -- which is what makes a comment-only body register as empty.
		_bEmpty_ = 1
		for _j_ = _i_ + 1 to _nLen_
			_cNext_ = ring_trim(_StzKnobStrip(_acLines_[_j_]))
			if _cNext_ = ""
				loop
			ok
			if StzLeft(StzLower(_cNext_), 4) = "def " or
			   StzLeft(StzLower(_cNext_), 6) = "class "
				exit
			ok
			_bEmpty_ = 0
			exit
		next

		if NOT _bEmpty_
			loop
		ok

		# A predicate MUST answer. Anything else merely fails to act.
		_cSev_ = :warning
		_cWhy_ = " is declared and does nothing"
		if _StzNameIsPredicate(_cName_)
			_cSev_ = :error
			_cWhy_ = " is a predicate that does nothing -- with no return it" +
			         " answers NULL, which reads as FALSE, so it says no about" +
			         " everything without ever failing"
		ok

		_aOut_ + [ :rule = :empty_method_body, :line = _i_,
		           :severity = _cSev_,
		           :message = _cName_ + "()" + _cWhy_ ]
	next
	return _aOut_

# The text after a def line's matching ")", or "" when the line ends there.
# Ring puts a whole body on the def line in two ordinary ways, and neither is
# an empty method.
func _StzDefSameLineBody(pcLine)
	_c_ = _StzKnobStrip(pcLine)
	_nOpen_ = StzFindFirst("(", _c_)
	if _nOpen_ = 0
		return ""
	ok

	# StzMid is (start, COUNT), not (start, end) -- StzMid(s, 20, 20) hands back
	# TWENTY characters from position 20, which made every one of these walks
	# fall straight through and report an empty body for a method that had one.
	_nDepth_ = 0
	_nLen_ = StzLen(_c_)
	for _i_ = _nOpen_ to _nLen_
		_ch_ = StzMid(_c_, _i_, 1)
		if _ch_ = "("
			_nDepth_++
		but _ch_ = ")"
			_nDepth_--
			if _nDepth_ = 0
				return ring_trim(StzMidToEnd(_c_, _i_ + 1))
			ok
		ok
	next
	return ""

# Is/Has/Contains/Can/Are/Was -- a name that promises a yes or a no.
func _StzNameIsPredicate(pcName)
	_c_ = StzLower("" + pcName)
	while StzLeft(_c_, 1) = "_"
		_c_ = StzMidToEnd(_c_, 2)
	end
	_aP_ = [ "is", "has", "contains", "can", "are", "was", "should" ]
	_n_ = len(_aP_)
	for _i_ = 1 to _n_
		if StzLeft(_c_, len(_aP_[_i_])) = _aP_[_i_]
			return 1
		ok
	next
	return 0

# WRITES-A-MUTABLE-CONSTANT: assigning to true, false, null, nl, tab or cr.
#
# In Ring these are ordinary global variables, and Ring is case-insensitive, so
#
#     nL = len(cPixels)
#
# silently replaces the NL newline constant with a NUMBER. That one was found in
# the field: library code built a string with NL and raised deep inside
# StzReplaceCS, with nothing in the message pointing back at the caller.
#
# TRUE / FALSE / NULL are the same mechanism with a far worse ending. NL raises;
# these do not. Set `true = 0` and every `= TRUE` comparison in reach quietly
# answers the opposite -- verified: with TRUE clobbered, `(1=1) = TRUE` is 0.
# Nothing errors, the logic simply runs backwards.
#
# This rule catches the WRITE, which is the trigger and is rare, rather than
# every read, which is common and is being retired module by module. It fires
# nowhere in the library today; it exists so that it keeps firing nowhere.
func _StzCheckConstantWrites(pcSource)
	_aOut_ = []
	_acLines_ = StzSplit(StzReplace("" + pcSource, char(13), ""), char(10))
	_nLen_ = len(_acLines_)
	_acNames_ = [ "true", "false", "null", "nl", "tab", "cr" ]
	_nN_ = len(_acNames_)

	for _i_ = 1 to _nLen_
		_cL_ = ring_trim(_StzKnobStrip(_acLines_[_i_]))
		if _cL_ = ""
			loop
		ok

		_nEq_ = StzFindFirst("=", _cL_)
		if _nEq_ < 2
			loop
		ok

		# what stands to the LEFT of the first "=" ...
		_cLhs_ = StzLower(ring_trim(StzMid(_cL_, 1, _nEq_ - 1)))

		# ...but not a comparison, and not += or similar
		_cAfter_ = StzMid(_cL_, _nEq_ + 1, 1)
		if _cAfter_ = "="
			loop
		ok
		if StzRight(_cLhs_, 1) = "!" or StzRight(_cLhs_, 1) = "<" or
		   StzRight(_cLhs_, 1) = ">" or StzRight(_cLhs_, 1) = "+"
			loop
		ok

		for _k_ = 1 to _nN_
			if _cLhs_ != _acNames_[_k_]
				loop
			ok
			_aOut_ + [ :rule = :writes_a_mutable_constant, :line = _i_,
			           :severity = :error,
			           :message = "assigns to " + StzUpper(_acNames_[_k_]) +
			           " -- Ring is case-insensitive, so this replaces the global" +
			           " constant for every caller. NL raises somewhere far away;" +
			           " TRUE and FALSE just invert the answer in silence." ]
		next
	next
	return _aOut_

#---------------------------------------------------------------------------
# THE PLAN OF RECORD IS A CLAIM ABOUT THE SUITE, AND A CLAIM GOES STALE.
#
# Every plane in this library keeps a plan of record -- a markdown file that
# says what shipped, what each guard section proves, and what is still open.
# Nothing checks it. Closing work and updating the plan are two acts and only
# the first is enforced, so the plan lags by exactly the amount its author
# forgot, and the lag is INVISIBLE FROM INSIDE THE SESSION THAT CAUSED IT --
# which is the whole difficulty. The graph plane's plan went stale twice in
# two days, 2026-09-03 and 2026-09-04, both times because a session closed an
# item and did not walk back to the paragraph that called it open.
#
# Two rules, running in OPPOSITE directions, because the plan can be wrong
# in two ways and only one of them was ever obvious:
#
#   plan_cites_a_missing_guard  -- the plan names a guard section that does
#       not exist. Fires when a section is renumbered or removed, and when a
#       plan claims proof it never had.
#
#   plan_calls_closed_work_open -- a heading says "still open" and every item
#       under it is struck through and marked closed. THIS IS THE ONE THE
#       DEFECT ACTUALLY RAN THROUGH: the citation direction was always fine,
#       because a session adding a guard cites it correctly in the same
#       breath. It is the paragraph three screens UP, the one that still says
#       the work is pending, that nobody goes back to.
#
# Findings come out in the unified shape, so this joins the one gate rather
# than becoming a second one.
#
# WHY THE SECTION SIGN IS BUILT FROM ITS BYTES AND NEVER WRITTEN AS A
# LITERAL: this project's notes forbid non-ASCII in console output, and a
# source file carrying one is a single bad save away from mojibake. A
# corrupted marker here does not raise -- it matches NOTHING, and the rule
# reports a clean plan by reading none of it. A rule that fails silent is
# worse than no rule, because it is also a green.
func StzCheckPlanOfRecord(pcPlanPath, pacSuitePaths)
	_cP_ = "" + pcPlanPath
	_cTxt_ = ""
	try
		_cTxt_ = read(_cP_)
	catch
		return []
	done
	return StzCheckPlanText(_cTxt_, _cP_, pacSuitePaths)

# The same rules over TEXT the caller already holds, labelled with whatever
# name should appear in :where.
#
# This split exists because of how the guard for these rules kept breaking.
# Its positive cases were perturbations of the LIVE plan -- strike an item,
# rename a heading -- and the first repair the rules provoked rewrote those
# very sentences, so every positive silently became a negative and the guard
# went green by testing nothing. A guard must not source its positives from
# the artefact it guards. It builds them.
func StzCheckPlanText(pcPlanText, pcLabel, pacSuitePaths)
	return StzCheckPlanTextXT("" + pcPlanText, "" + pcLabel,
	                          StzGuardSectionsOf(pacSuitePaths))

# Every section key the given suites define, read ONCE.
#
# This is separated because the guard for these rules made the exact defect
# the rules' own plane keeps finding. Seven checks against one suite parsed
# that suite seven times: 7.07s where a single parse is 0.95s, added to a
# gate whose whole budget is 66s -- a text pass costing more than two of the
# large-diagram renders it sits next to. A caller with several plans, or a
# guard with several cases, extracts once and passes the keys.
func StzGuardSectionsOf(pacSuitePaths)
	_acSections_ = []
	_aSuites_ = pacSuitePaths
	if isString(_aSuites_)  _aSuites_ = [ _aSuites_ ]  ok
	_nSu_ = len(_aSuites_)
	for _s_ = 1 to _nSu_
		_cSrc_ = ""
		try
			_cSrc_ = read("" + _aSuites_[_s_])
		catch
			loop
		done
		_aKeys_ = _StzGuardSectionKeys(_cSrc_)
		_nK_ = len(_aKeys_)
		for _k_ = 1 to _nK_
			_acSections_ + _aKeys_[_k_]
		next
	next
	return _acSections_

# The rules over plan TEXT and section keys the caller already holds.
func StzCheckPlanTextXT(pcPlanText, pcLabel, pacSectionKeys)
	_aOut_ = []
	_cPlanPath_ = "" + pcLabel
	_cPlan_ = "" + pcPlanText
	if _cPlan_ = ""  return _aOut_  ok
	_acSections_ = pacSectionKeys

	_acLines_ = StzSplit(StzReplace(_cPlan_, char(13), ""), char(10))
	_nL_ = len(_acLines_)
	_nSec_ = len(_acSections_)

	# ---- direction one: a cited guard must exist -------------------------
	_aRefs_ = _StzPlanGuardRefs(_acLines_)
	_nR_ = len(_aRefs_)
	for _i_ = 1 to _nR_
		_cRef_ = _aRefs_[_i_][2]
		_bFound_ = FALSE
		for _j_ = 1 to _nSec_
			if _acSections_[_j_] = _cRef_
				_bFound_ = TRUE
				exit
			ok
		next
		if NOT _bFound_
			_aOut_ + [ :rule = :plan_cites_a_missing_guard, :subject = :plan,
			  :where = _cPlanPath_ + ":" + _aRefs_[_i_][1],
			  :severity = :warning,
			  :message = "the plan cites guard section " + _cRef_ +
			    ", which no suite defines -- either the section was" +
			    " renumbered, or the plan claims a proof it never had" ]
		ok
	next

	# ---- direction two: a heading calling work open, over closed work ----
	for _i_ = 1 to _nL_
		_cH_ = StzTrim("" + _acLines_[_i_])
		if StzLeft(_cH_, 2) != "##"  loop  ok
		if StzFindFirst("still open", StzLower(_cH_)) < 1  loop  ok

		# the block runs to the next heading of any depth
		_nEnd_ = _nL_
		for _j_ = _i_ + 1 to _nL_
			if StzLeft(StzTrim("" + _acLines_[_j_]), 2) = "##"
				_nEnd_ = _j_ - 1
				exit
			ok
		next

		_nItems_ = 0
		_nClosed_ = 0
		# AN ITEM IS A PARAGRAPH, and this is the whole correctness of the
		# rule. The first version counted only bullets and struck-through
		# lines, so a LIVE item written as plain prose -- which is how an
		# open item is usually written -- was invisible, and a heading with
		# one live item and one closed one still read as all-closed. Worse
		# in the other direction: two headings in this plane's own plan sat
		# silent under that version and both were silent because their items
		# could not be SEEN, not because they were open. A rule that passes
		# for the wrong reason is a green nobody earned.
		#
		# So: an item begins at a non-blank line that opens a paragraph (the
		# line before it is blank) or that opens a list entry, and it runs
		# until the next such line. Its whole text votes, once.
		_cItem_ = ""
		_bPrevBlank_ = TRUE
		for _j_ = _i_ + 1 to _nEnd_ + 1
			if _j_ <= _nEnd_
				_cB_ = StzTrim("" + _acLines_[_j_])
			else
				_cB_ = ""          # a sentinel, so the last item is counted
			ok
			_bStarts_ = FALSE
			if _cB_ != "" and (_bPrevBlank_ or StzLeft(_cB_, 2) = "- ")
				_bStarts_ = TRUE
			ok
			if _bStarts_ or _j_ > _nEnd_
				if _cItem_ != ""
					_nItems_++
					# closed == struck through AND saying so
					if StzFindFirst("~~", _cItem_) > 0 and
					   StzFindFirst("closed", StzLower(_cItem_)) > 0
						_nClosed_++
					ok
				ok
				_cItem_ = ""
			ok
			if _cB_ != ""  _cItem_ += (" " + _cB_)  ok
			_bPrevBlank_ = (_cB_ = "")
		next

		if _nItems_ > 0 and _nClosed_ = _nItems_
			_aOut_ + [ :rule = :plan_calls_closed_work_open, :subject = :plan,
			  :where = _cPlanPath_ + ":" + _i_,
			  :severity = :warning,
			  :message = "this heading says work is still open and all " +
			    "" + _nItems_ + " items under it are struck through and " +
			    "marked closed -- the heading is the stale part, and it " +
			    "is what a reader of this plan sees first" ]
		ok
	next

	return _aOut_

# The keys a guard suite defines: sec("-- 43. TITLE ---") -> "43".
# Walks BYTES with s[i]. The tokens are ASCII, so byte walking is exact --
# and it is the cheap form. substr on a large buffer measured ~0.3ms per
# call in this project, which IS the entire cost of a per-byte scan.
func _StzGuardSectionKeys(pcSource)
	_aKeys_ = []
	_acL_ = StzSplit(StzReplace("" + pcSource, char(13), ""), char(10))
	_n_ = len(_acL_)
	for _i_ = 1 to _n_
		_cL_ = StzTrim("" + _acL_[_i_])
		if StzLeft(_cL_, 6) != 'sec("-'  loop  ok
		_cKey_ = ""
		_bSeen_ = FALSE
		_nC_ = len(_cL_)
		for _j_ = 7 to _nC_
			_c_ = _cL_[_j_]
			if _c_ = "."  exit  ok
			if _StzIsRefChar(_c_)
				_cKey_ += _c_
				_bSeen_ = TRUE
			but _c_ != "-" and _c_ != " "
				exit
			ok
		next
		if _bSeen_  _aKeys_ + _cKey_  ok
	next
	return _aKeys_

# Every guard reference in the plan, as [ line, key ].
func _StzPlanGuardRefs(pacLines)
	_aRefs_ = []
	_cB1_ = char(194)
	_cB2_ = char(167)
	_n_ = len(pacLines)
	for _i_ = 1 to _n_
		_cL_ = "" + pacLines[_i_]
		_nC_ = len(_cL_)
		_k_ = 1
		while _k_ < _nC_
			if _cL_[_k_] != _cB1_ or _cL_[_k_ + 1] != _cB2_
				_k_++
				loop
			ok
			_cRef_ = ""
			_m_ = _k_ + 2
			while _m_ <= _nC_
				_c_ = _cL_[_m_]
				if _StzIsRefChar(_c_)
					_cRef_ += _c_
					_m_++
				else
					exit
				ok
			end
			if _cRef_ != ""  _aRefs_ + [ _i_, _cRef_ ]  ok
			_k_ = _m_
		end
	next
	return _aRefs_

# ascii(), never _c_ >= "0". Ring coerces a numeric-looking string inside a
# comparison, so "-" >= "0" raises R41 rather than answering false. A
# character class has to be asked in code points.
func _StzIsRefChar(pcChar)
	_n_ = ascii(pcChar)
	return (_n_ >= 48 and _n_ <= 57) or (_n_ >= 97 and _n_ <= 122)

#---------------------------------------------------------------------------
# THE OTHER DIRECTION: A GUARD DECLARES WHAT IT DISCHARGES, AND THE PLAN'S
# STATUS IS GENERATED FROM THAT RATHER THAN REMEMBERED.
#
# The rules above check the plan's own claims. They close the cheap half of
# the staleness defect and they cannot close the rest, for a reason worth
# stating: A PLAN CITING GUARDS IS AMBIGUOUS BY CONSTRUCTION. This plane's
# plan carried two references that looked exactly like guard citations and
# were not -- one to another document's section, one to a section of the
# plan itself -- and the second RESOLVED BY COINCIDENCE, because a guard
# with that number happened to exist. A check that passes by coincidence is
# the thing this whole file exists to refuse.
#
# Inverted, the ambiguity disappears. A guard section says, in the suite,
# which plan item it discharges:
#
#     sec("-- 39. GG8: a picture larger than its medium is TILED ---")
#     discharges("GG8")
#
# There is nothing to resolve: the declaration sits inside the section that
# proves the thing, in the file that runs. From those declarations the
# plan's status table is GENERATED, and a rule compares the generated table
# against the one in the file -- so the table cannot drift, because drifting
# is what it is checked for.
#
# What this still does not do is decide whether an item is done. A human
# writes that, here as anywhere. What it removes is the SECOND place the
# answer had to be repeated, which is where every one of this plane's four
# stalenesses actually happened.

# Every [ itemId, sectionKey ] a suite declares.
func StzSuiteDischargesOf(pacSuitePaths)
	_aOut_ = []
	_aSuites_ = pacSuitePaths
	if isString(_aSuites_)  _aSuites_ = [ _aSuites_ ]  ok
	_nSu_ = len(_aSuites_)
	for _s_ = 1 to _nSu_
		_cSrc_ = ""
		try
			_cSrc_ = read("" + _aSuites_[_s_])
		catch
			loop
		done
		_aOne_ = _StzSuiteDischarges(_cSrc_)
		_nO_ = len(_aOne_)
		for _o_ = 1 to _nO_
			_aOut_ + _aOne_[_o_]
		next
	next
	return _aOut_

# Walks a suite once, carrying the section it is inside.
func _StzSuiteDischarges(pcSource)
	_aOut_ = []
	_acL_ = StzSplit(StzReplace("" + pcSource, char(13), ""), char(10))
	_n_ = len(_acL_)
	_cCur_ = ""
	for _i_ = 1 to _n_
		_cL_ = StzTrim("" + _acL_[_i_])
		if StzLeft(_cL_, 6) = 'sec("-'
			_aK_ = _StzGuardSectionKeys(_cL_)
			if len(_aK_) > 0  _cCur_ = _aK_[1]  ok
			loop
		ok
		if StzLeft(_cL_, 11) != "discharges("  loop  ok
		if _cCur_ = ""  loop  ok
		# discharges("GG8")  ->  GG8
		_cId_ = ""
		_nC_ = len(_cL_)
		_bIn_ = FALSE
		for _j_ = 12 to _nC_
			_c_ = _cL_[_j_]
			if _c_ = '"'
				if _bIn_  exit  ok
				_bIn_ = TRUE
				loop
			ok
			if _bIn_  _cId_ += _c_  ok
		next
		if _cId_ != ""  _aOut_ + [ _cId_, _cCur_ ]  ok
	next
	return _aOut_

# Every item the plan DEFINES, as [ id, status, line ].
#
# An item is defined where its id opens a heading or a bullet -- never
# mid-prose, or a sentence mentioning GG5 would define it a second time.
# The FIRST definition wins: this plan legitimately re-mentions an id in a
# later section heading, and that is a reference, not a redefinition.
func StzPlanItemsOf(pcPlanText)
	# THE GENERATED BLOCK IS NOT PART OF THE PLAN'S PROSE, and reading it as
	# if it were makes the table decide the statuses it is supposed to
	# report. An item's body runs to the next item, so an item standing last
	# before the table absorbed it -- and the table says "closed" on nearly
	# every row, so that item read as closed whatever its own words said. It
	# is a feedback loop with a plausible answer, which is the kind that
	# survives review: the table looked right, because it had made itself
	# right.
	_acL_ = StzSplit(StzReplace(_StzWithoutCoverage("" + pcPlanText),
	                            char(13), ""), char(10))
	_nL_ = len(_acL_)

	# pass one: where the definitions are
	_aSites_ = []
	for _i_ = 1 to _nL_
		_cId_ = _StzPlanItemIdAt("" + _acL_[_i_])
		if _cId_ = ""  loop  ok
		_aSites_ + [ _i_, _cId_ ]
	next

	# pass two: each definition's body runs to the next one
	_aOut_ = []
	_nS_ = len(_aSites_)
	for _k_ = 1 to _nS_
		_cId_ = _aSites_[_k_][2]
		_bSeen_ = FALSE
		_nO_ = len(_aOut_)
		for _q_ = 1 to _nO_
			if _aOut_[_q_][1] = _cId_
				_bSeen_ = TRUE
				exit
			ok
		next
		if _bSeen_  loop  ok
		_nFrom_ = _aSites_[_k_][1]
		_nTo_ = _nL_
		if _k_ < _nS_  _nTo_ = _aSites_[_k_ + 1][1] - 1  ok
		_cBody_ = ""
		for _b_ = _nFrom_ to _nTo_
			_cBody_ += (" " + _acL_[_b_])
		next
		_aOut_ + [ _cId_, _StzPlanItemStatus(_cBody_), _nFrom_ ]
	next
	return _aOut_

# "closed", "open", "undecided" or "unstated" -- read from the item's own
# words.
#
# UNDECIDED IS NOT A POLITE WORD FOR UNSTATED, and the difference is the
# point. Writing this rule turned up items whose status the author of the
# rule was not entitled to settle: GG3 has an implementation in stzScene
# and gpu_scene3d and no guard section named for it, and whether that is
# "shipped" is a judgement belonging to whoever owns that tier. A plan of
# record must say SOMETHING about every item it defines -- but "nobody has
# adjudicated this" is a legitimate thing to say, and saying it out loud is
# a different act from leaving the reader to guess. Only silence is
# reported.
#
# Checked before the closed words on purpose: an item explaining WHY it is
# undecided will often mention work that shipped around it.
func _StzPlanItemStatus(pcBody)
	_cU_ = StzUpper("" + pcBody)
	if StzFindFirst("UNDECIDED", _cU_) > 0  return "undecided"  ok
	if StzFindFirst("SHIPPED", _cU_) > 0 or
	   StzFindFirst("DELIVERED", _cU_) > 0 or
	   StzFindFirst("DONE", _cU_) > 0 or
	   StzFindFirst("CLOSED", _cU_) > 0
		return "closed"
	ok
	if StzFindFirst("NEXT", _cU_) > 0 or
	   StzFindFirst("NOT STARTED", _cU_) > 0 or
	   StzFindFirst("PLANNED", _cU_) > 0
		return "open"
	ok
	return "unstated"

# The id opening a heading or bullet, or "" -- MARKUP STRIPPED FIRST, since
# the same id arrives as "### GG8 ", "- **DN0 " and "**DN5b ".
func _StzPlanItemIdAt(pcLine)
	_cL_ = StzTrim("" + pcLine)
	if _cL_ = ""  return ""  ok
	_bOpener_ = FALSE
	if StzLeft(_cL_, 1) = "#" or StzLeft(_cL_, 1) = "-" or
	   StzLeft(_cL_, 2) = "**"
		_bOpener_ = TRUE
	ok
	if NOT _bOpener_  return ""  ok
	_nC_ = len(_cL_)
	_nAt_ = 0
	for _i_ = 1 to _nC_
		_c_ = _cL_[_i_]
		if _c_ != "#" and _c_ != "-" and _c_ != "*" and _c_ != " "
			_nAt_ = _i_
			exit
		ok
	next
	if _nAt_ = 0  return ""  ok
	# [A-Z][A-Z][0-9] then an optional lowercase letter
	if _nAt_ + 2 > _nC_  return ""  ok
	_n1_ = ascii(_cL_[_nAt_])
	_n2_ = ascii(_cL_[_nAt_ + 1])
	_n3_ = ascii(_cL_[_nAt_ + 2])
	if NOT (_n1_ >= 65 and _n1_ <= 90)  return ""  ok
	if NOT (_n2_ >= 65 and _n2_ <= 90)  return ""  ok
	if NOT (_n3_ >= 48 and _n3_ <= 57)  return ""  ok
	_cId_ = _cL_[_nAt_] + _cL_[_nAt_ + 1] + _cL_[_nAt_ + 2]
	if _nAt_ + 3 <= _nC_
		_n4_ = ascii(_cL_[_nAt_ + 3])
		if _n4_ >= 97 and _n4_ <= 122
			_cId_ += _cL_[_nAt_ + 3]
		ok
	ok
	return _cId_

# The generated status table, as markdown.
#
# Plan order, not alphabetical: the table is read next to the prose it
# summarises, and a reader looking for DN3b wants it where DN3 was.
func StzPlanCoverageTable(pcPlanText, paDischarges)
	_aItems_ = StzPlanItemsOf(pcPlanText)
	_nI_ = len(_aItems_)
	_nD_ = len(paDischarges)
	_cT_ = "| item | status | discharged by |" + char(10) +
	       "| ---- | ------ | ------------- |" + char(10)
	for _i_ = 1 to _nI_
		_cId_ = _aItems_[_i_][1]
		_cWho_ = ""
		for _d_ = 1 to _nD_
			if paDischarges[_d_][1] = _cId_
				if _cWho_ != ""  _cWho_ += ", "  ok
				_cWho_ += paDischarges[_d_][2]
			ok
		next
		if _cWho_ = ""  _cWho_ = "-"  ok
		_cT_ += ("| " + _cId_ + " | " + _aItems_[_i_][2] + " | " +
		         _cWho_ + " |" + char(10))
	next
	return _cT_

func StzPlanCoverageBeginMark()
	return "<!-- COVERAGE:BEGIN generated -- do not edit by hand -->"

func StzPlanCoverageEndMark()
	return "<!-- COVERAGE:END -->"

# THE RULES THAT MAKE THE DECLARATION WORTH MAKING.
func StzCheckPlanCoverage(pcPlanText, pcLabel, paDischarges)
	_aOut_ = []
	_cLabel_ = "" + pcLabel
	_cPlan_ = "" + pcPlanText
	if _cPlan_ = ""  return _aOut_  ok

	_aItems_ = StzPlanItemsOf(_cPlan_)
	_nI_ = len(_aItems_)
	_nD_ = len(paDischarges)

	# ---- a declaration naming an item the plan does not have -------------
	for _d_ = 1 to _nD_
		_cId_ = paDischarges[_d_][1]
		_bK_ = FALSE
		for _i_ = 1 to _nI_
			if _aItems_[_i_][1] = _cId_
				_bK_ = TRUE
				exit
			ok
		next
		if NOT _bK_
			_aOut_ + [ :rule = :guard_discharges_unknown_item,
			  :subject = :plan, :where = _cLabel_ + ":0", :severity = :warning,
			  :message = "guard section " + paDischarges[_d_][2] +
			    " declares it discharges plan item " + _cId_ + ", which " +
			    "this plan does not define -- the item was renamed, or the " +
			    "declaration is a typo that no run would ever notice" ]
		ok
	next

	for _i_ = 1 to _nI_
		_cId_ = _aItems_[_i_][1]
		_cSt_ = _aItems_[_i_][2]

		_bDis_ = FALSE
		_cWho_ = ""
		for _d_ = 1 to _nD_
			if paDischarges[_d_][1] = _cId_
				_bDis_ = TRUE
				if _cWho_ != ""  _cWho_ += ", "  ok
				_cWho_ += paDischarges[_d_][2]
			ok
		next

		# ---- THE DEFECT, now caught at the ITEM and not the heading ------
		#
		# NOT-CLOSED, never merely "open". The first version asked only about
		# items the plan called open, and it missed the larger group: five
		# items proved by guard sections 40 to 44 whose prose never said they
		# had shipped at all. A plan that UNDERSTATES proven work is stale in
		# exactly the same way as one that calls closed work open -- the
		# reader is misled in the same direction, about the same item, by the
		# same missing edit.
		if _cSt_ != "closed" and _bDis_
			_aOut_ + [ :rule = :plan_item_open_but_discharged,
			  :subject = :plan,
			  :where = _cLabel_ + ":" + _aItems_[_i_][3], :severity = :warning,
			  :message = "the plan does not call item " + _cId_ + " closed " +
			    "(it reads " + _cSt_ + "), and guard section " + _cWho_ +
			    " already proves it -- this is the shape this plane's plan " +
			    "went stale in four times" ]
		ok

		# ---- an item whose status a reader cannot determine --------------
		# Only where no guard discharges it, or the item above would be
		# reported twice for one defect.
		if _cSt_ = "unstated" and NOT _bDis_
			_aOut_ + [ :rule = :plan_item_status_unstated, :subject = :plan,
			  :where = _cLabel_ + ":" + _aItems_[_i_][3], :severity = :warning,
			  :message = "item " + _cId_ + " states no status a reader can " +
			    "find -- a plan of record whose items do not say where they " +
			    "stand is the condition staleness hides in" ]
		ok
	next

	# ---- the generated table, against the one in the file ----------------
	_cWant_ = StzPlanCoverageTable(_cPlan_, paDischarges)
	_cB_ = StzPlanCoverageBeginMark()
	_cE_ = StzPlanCoverageEndMark()
	_nB_ = _StzFindBytes(_cB_, _cPlan_)
	if _nB_ > 0
		_nE_ = _StzFindBytes(_cE_, _cPlan_)
		if _nE_ > _nB_
			_cGot_ = _StzBetween(_cPlan_, _nB_ + len(_cB_), _nE_ - 1)
			if StzTrim(StzReplace(_cGot_, char(13), "")) !=
			   StzTrim(_cWant_)
				_aOut_ + [ :rule = :plan_coverage_table_is_stale,
				  :subject = :plan, :where = _cLabel_ + ":0",
				  :severity = :warning,
				  :message = "the generated status table in this file no " +
				    "longer matches what the suite's declarations say -- " +
				    "regenerate it with StzPlanCoverageTable()" ]
			ok
		ok
	ok

	return _aOut_

# Characters n1..n2 of a string, by BYTE index. The callers here are
# markdown markers, which are ASCII by construction -- and the index came
# from StzFindFirst on the same buffer, so the two agree.
func _StzBetween(pcStr, pnFrom, pnTo)
	_c_ = ""
	_s_ = "" + pcStr
	_nN_ = len(_s_)
	_a_ = pnFrom
	_b_ = pnTo
	if _a_ < 1  _a_ = 1  ok
	if _b_ > _nN_  _b_ = _nN_  ok
	for _i_ = _a_ to _b_
		_c_ += _s_[_i_]
	next
	return _c_

# Rewrite the generated table in a plan file, in place.
#
# THIS is what makes the word "generated" true rather than aspirational.
# Regenerating has to be ONE call, or the table is still remembered -- and a
# thing that is remembered is the defect this whole file exists to close.
# Returns TRUE when the file changed.
func StzWritePlanCoverage(pcPlanPath, pacSuitePaths)
	_cP_ = "" + pcPlanPath
	_cSrc_ = ""
	try
		_cSrc_ = read(_cP_)
	catch
		return FALSE
	done
	_cB_ = StzPlanCoverageBeginMark()
	_cE_ = StzPlanCoverageEndMark()
	_nB_ = _StzFindBytes(_cB_, _cSrc_)
	if _nB_ < 1  return FALSE  ok
	_nE_ = _StzFindBytes(_cE_, _cSrc_)
	if _nE_ <= _nB_  return FALSE  ok

	_aDis_ = StzSuiteDischargesOf(pacSuitePaths)
	_cTab_ = StzPlanCoverageTable(_cSrc_, _aDis_)

	_cHead_ = _StzBetween(_cSrc_, 1, _nB_ + len(_cB_) - 1)
	_cTail_ = _StzBetween(_cSrc_, _nE_, len(_cSrc_))
	_cNew_ = _cHead_ + char(10) + _cTab_ + _cTail_
	if _cNew_ = _cSrc_  return FALSE  ok
	write(_cP_, _cNew_)
	return TRUE

# Position of a needle in a haystack, IN BYTES, or 0.
#
# StzFindFirst answers in CODEPOINTS, and `s[i]` and `len(s)` are BYTES.
# Mixing them is silent on ASCII and wrong on anything else, which is the
# worst way for it to be wrong: the plan this was written for is full of
# em-dashes at three bytes each, so a marker found at codepoint 4,100 sat
# at byte 4,240, and slicing to the codepoint index cut 140 bytes off the
# head. The generated table was written INTO the middle of its own opening
# marker, and the only reason it was caught is that the damage was visible
# in the file. On a pure-ASCII document it would have been correct, and
# would have stayed correct until the first accented character.
func _StzFindBytes(pcNeedle, pcHay)
	_cN_ = "" + pcNeedle
	_cH_ = "" + pcHay
	_nN_ = len(_cN_)
	_nH_ = len(_cH_)
	if _nN_ < 1 or _nN_ > _nH_  return 0  ok
	_c1_ = _cN_[1]
	_nLast_ = _nH_ - _nN_ + 1
	for _i_ = 1 to _nLast_
		if _cH_[_i_] != _c1_  loop  ok
		_bAll_ = TRUE
		for _j_ = 2 to _nN_
			if _cH_[_i_ + _j_ - 1] != _cN_[_j_]
				_bAll_ = FALSE
				exit
			ok
		next
		if _bAll_  return _i_  ok
	next
	return 0

# The plan with its generated block blanked out, LINE STRUCTURE INTACT so a
# finding's line number still points where a reader would look. The same
# discipline the block-comment stripper above uses, and for the same reason.
func _StzWithoutCoverage(pcText)
	_cT_ = "" + pcText
	_cB_ = StzPlanCoverageBeginMark()
	_cE_ = StzPlanCoverageEndMark()
	_nB_ = _StzFindBytes(_cB_, _cT_)
	if _nB_ < 1  return _cT_  ok
	_nE_ = _StzFindBytes(_cE_, _cT_)
	if _nE_ <= _nB_  return _cT_  ok
	_cOut_ = _StzBetween(_cT_, 1, _nB_ + len(_cB_) - 1)
	_nFrom_ = _nB_ + len(_cB_)
	_nTo_ = _nE_ - 1
	for _i_ = _nFrom_ to _nTo_
		if _cT_[_i_] = char(10)
			_cOut_ += char(10)
		but _cT_[_i_] = char(13)
			_cOut_ += char(13)
		else
			_cOut_ += " "
		ok
	next
	_cOut_ += _StzBetween(_cT_, _nE_, len(_cT_))
	return _cOut_
