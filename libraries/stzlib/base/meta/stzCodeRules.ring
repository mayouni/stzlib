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
	return [ "no-len-method", "q-returns-object",
	         "no-aggressive-verbs", "engine-first" ]

func StzCheckCodeFile(pcPath)
	return StzCheckCode(read(pcPath))

func StzCheckCode(pcSource)
	_acLines_ = StzSplit(StzReplace("" + pcSource, char(13), ""), char(10))
	_nLen_ = len(_acLines_)
	_aFindings_ = []

	for _i_ = 1 to _nLen_
		_cL_ = StzLower(ring_trim(StzReplace(_acLines_[_i_], char(9), " ")))

		# comments don't testify
		if StzLeft(_cL_, 1) = "#" or StzLeft(_cL_, 2) = "//"
			loop
		ok

		# -- no-len-method ------------------------------------------------
		if StzLeft(_cL_, 8) = "def len(" or _cL_ = "def len"
			_aFindings_ + [ :rule = "no-len-method", :line = _i_,
				:severity = :error,
				:message = "never define Len() on a class -- it shadows Ring's builtin and breaks every caller; use Count()/Size()/NumberOf...()" ]
		ok

		# -- no-aggressive-verbs -------------------------------------------
		if StzLeft(_cL_, 8) = "def kill" or StzLeft(_cL_, 11) = "def destroy"
			_aFindings_ + [ :rule = "no-aggressive-verbs", :line = _i_,
				:severity = :warning,
				:message = "aggressive verb in a method name -- prefer Remove/Delete/Dispose/Clear/Close (Softanza tone)" ]
		ok

		# -- engine-first ---------------------------------------------------
		if len(StzFind(" substr(", _cL_)) > 0 or StzLeft(_cL_, 7) = "substr("
			_aFindings_ + [ :rule = "engine-first", :line = _i_,
				:severity = :warning,
				:message = "Ring's substr() is byte-oriented (breaks UTF-8) -- new code uses StzFind/StzReplace/StzSplit (the engine forms)" ]
		ok

		# -- q-returns-object (span check) ----------------------------------
		if StzLeft(_cL_, 4) = "def "
			_acNm_ = StzSplit(_cL_, "(")
			_cM_ = ring_trim(StzReplace(_acNm_[1], "def ", ""))
			if StzRight(_cM_, 1) = "q" and StzLen(_cM_) > 1
				# scan this method's span for a chainable return
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
					_aFindings_ + [ :rule = "q-returns-object", :line = _i_,
						:severity = :error,
						:message = "'" + _cM_ + "' ends in Q but no chainable return found (return This / return new ...) -- the Q convention: Q = OBJECT, plain = data" ]
				ok
			ok
		ok
	next

	return _aFindings_

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
