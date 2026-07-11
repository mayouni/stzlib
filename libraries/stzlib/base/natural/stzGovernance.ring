#---------------------------------------------------------------------------#
#  stzGovernance -- P5: the kit that makes the natural stack an AGENT        #
#  CONTRACT (doc/design/NNL_REVIEW.md section 7).                            #
#                                                                            #
#  Everything an intelligent system needs to be governed by language:        #
#    - StzPolicy: a NAMED, reusable set of natural QUESTIONS that allows     #
#      or denies a value -- and says WHY it denied (the AllYes gate made     #
#      a first-class object).                                                #
#    - StzAgentContract(lang): ONE deterministic text bundle -- the world,   #
#      the speakable vocabulary, the rules, the repair protocol -- handed    #
#      to an external agent (an LLM, a program) as its operating contract.   #
#    - Grounded strict mode lives in the engine: under strict, a narration   #
#      that RECALLS an unknown name refuses with the known roster.           #
#  Temporal guards (until/whenever loops) stay DEFERRED until a real agent   #
#  loop runtime exists -- recorded, not improvised.                          #
#---------------------------------------------------------------------------#

func StzPolicyQ(pcName)
	return new stzPolicy(pcName)

	func StzPolicy(pcName)
		return new stzPolicy(pcName)

# THE AGENT CONTRACT: what an external agent must know to speak Softanza
# safely -- deterministic, data-driven, regenerated from the live system.

func StzAgentContract(pcLang)
	_cLang_ = StzLower(pcLang)
	_nl_ = char(10)
	_c_ = "SOFTANZA NATURAL AGENT CONTRACT (" + _cLang_ + ")" + _nl_
	_c_ += "==============================================" + _nl_ + _nl_

	_c_ += "1. THE PROTOCOL" + _nl_
	_c_ += "   - Speak ONE narration at a time; every word must be known." + _nl_
	_c_ += "   - Your narration runs in STRICT mode: any word the language" + _nl_
	_c_ += "     cannot resolve REFUSES with a did-you-mean suggestion --" + _nl_
	_c_ += "     read it, regenerate, resubmit." + _nl_
	_c_ += "   - After a run, ALWAYS read Understood(): it paraphrases what" + _nl_
	_c_ += "     was actually executed, in your language. If it differs from" + _nl_
	_c_ += "     your intent, correct and resubmit." + _nl_
	_c_ += "   - Questions record answers; AllYesSoFar() gates your actions." + _nl_
	_c_ += "   - To reason hypothetically: SupposeQ(name).IsAQ(:Type), ask" + _nl_
	_c_ += "     WhatIs(name), then CommitSuppositions() or" + _nl_
	_c_ += "     ForgetSuppositions(). The world is never touched until you" + _nl_
	_c_ += "     commit." + _nl_ + _nl_

	_c_ += "2. THE WORLD (entities you may refer to)" + _nl_
	_aEnts_ = WorldEntities().Entities()
	_nE_ = len(_aEnts_)
	if _nE_ = 0
		_c_ += "   (empty -- name things with 'called <name>' to create them)" + _nl_
	else
		for _i_ = 1 to _nE_
			_c_ += "   - " + _aEnts_[_i_][:name] + " : " + _aEnts_[_i_][:type] + _nl_
		next
	ok
	_c_ += _nl_

	_c_ += "3. THE STRUCTURAL WORDS" + _nl_
	_c_ += "   creation: create/make/new + object word (string, list, number)" + _nl_
	_c_ += "   value:    with / holding" + _nl_
	_c_ += "   naming:   called / named / call ... ; switching: use <name>" + _nl_
	_c_ += "   binding:  keep it as <name> (recalled later as a variable)" + _nl_
	_c_ += "   asking:   'Is it ... ?' / 'Does it ... ?' -- answers recorded" + _nl_ + _nl_

	_c_ += "4. SAMPLE ACTION VOCABULARY (" + _cLang_ + ")" + _nl_
	_acShow_ = [ "METHOD_UPPERCASE", "METHOD_LOWERCASE", "METHOD_REVERSE",
		"METHOD_SORT", "METHOD_TRIM", "METHOD_REPLACE",
		"METHOD_REMOVEDUPLICATES", "METHOD_SPACIFY", "METHOD_BOX",
		"METHOD_INCREMENT", "METHOD_CONTAINS", "METHOD_ISEMPTY" ]
	_nP_ = len(_acShow_)
	for _i_ = 1 to _nP_
		_c_ += "   - " + StzLinearizeId(_cLang_, _acShow_[_i_]) + _nl_
	next
	_c_ += "   (the full lexicon is larger; unknown words are refused" + _nl_
	_c_ += "    with suggestions, so explore safely)" + _nl_ + _nl_

	_c_ += "5. ACCOUNTABILITY" + _nl_
	_c_ += "   - Why() explains the last check; WhyCheckFailed()/WhyStopped()" + _nl_
	_c_ += "     live on the chain itself." + _nl_
	_c_ += "   - Nothing is guessed: ambiguity refuses, silence never happens." + _nl_
	return _c_

	func @StzAgentContract(pcLang)
		return StzAgentContract(pcLang)

# THE POLICY: a named set of natural QUESTIONS; a value is ALLOWED only
# when every question answers yes -- and denial explains itself.
#   oP = StzPolicyQ("clean-word")
#   oP.RequireQ("Is it lowercase ?").RequireQ("Does it contain 'a' ?")
#   oP.Allows("banana")   --> 1
#   oP.Allows("SKY")      --> 0 ; oP.WhyDenied() names the question

class stzPolicy

	@cName = ""
	@acRequirements = []
	@cWhyDenied = ""

	def init(pcName)
		@cName = pcName

	def Name()
		return @cName

	def RequireQ(pcQuestion)
		@acRequirements + pcQuestion
		return This

	def Requirements()
		return @acRequirements

	def Allows(pValue)
		@cWhyDenied = ""
		_nR_ = len(@acRequirements)
		if _nR_ = 0
			@cWhyDenied = "the policy has no requirements"
			return 0
		ok
		# the subject clause per the value's type; the questions follow
		if isString(pValue)
			_cNarr_ = "Create a string with " + char(34) + pValue + char(34) + " "
		but isNumber(pValue)
			_cNarr_ = "Create a number with " + pValue + " "
		but isList(pValue)
			_cNarr_ = "Create a list with " + @@(pValue) + " "
		else
			@cWhyDenied = "unsupported value type"
			return 0
		ok
		for _i_ = 1 to _nR_
			_cNarr_ += @acRequirements[_i_] + " "
		next
		# STRICT: a policy whose words the language cannot resolve is a
		# broken policy, not a permissive one
		_oRun_ = NULL
		try
			_oRun_ = NaturallyStrict(_cNarr_)
		catch
			@cWhyDenied = "the policy itself was not understood: " + cCatchError
			return 0
		done
		_aV_ = _oRun_.Answers()
		if len(_aV_) != _nR_
			@cWhyDenied = "the policy asked " + _nR_ + " questions but " +
				len(_aV_) + " were answered"
			return 0
		ok
		for _i_ = 1 to _nR_
			_vA_ = _aV_[_i_]
			if isNumber(_vA_) and _vA_ = 0
				@cWhyDenied = "requirement " + _i_ + " (" +
					@acRequirements[_i_] + ") answered no"
				return 0
			ok
		next
		return 1

	def WhyDenied()
		if @cWhyDenied = ""
			return "it was not denied"
		ok
		return @cWhyDenied
