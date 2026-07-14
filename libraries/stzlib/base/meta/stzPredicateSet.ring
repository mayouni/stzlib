# R2 -- stzPredicateSet: THE CONSTITUTION MECHANISM (5.7 G10)
# A declared, diffable, SIGNABLE set of governance predicates that the
# validators enforce. Softanza ships the MECHANISM; any specific
# constitution (articles, jurisdictions) is product space.
#
#   oPS = new stzPredicateSet("house-rules")
#   oPS.AddRule("no-len-method")             # from StzCodeRuleNames()
#   oPS.AddInvariant("no-llm-effectful")     # from StzGovernanceInvariantNames()
#   oPS.Save("house.zrlz")                  # content + sha256 seal
#   oPS2 = StzLoadPredicateSet("house.zrlz")
#   ? oPS2.Verify()                          # seal intact?
#   ? oPS2.EnforceOnCode(cSource)            # only ITS code rules
#
# FORMAT (*.zrlz): readable lines --
#   predicateset "name"
#   rules        <one code-rule name per line>
#   invariants   <one graph-invariant name per line>
#   seal | <sha256 of the body above>

func StzLoadPredicateSet(pcFile)
	_cContent_ = StzReplace(read(pcFile), char(13), "")
	_acLines_ = StzSplit(_cContent_, char(10))
	_oPS_ = new stzPredicateSet("")
	_cSection_ = ""
	_nLen_ = len(_acLines_)
	for _i_ = 1 to _nLen_
		_cL_ = ring_trim(_acLines_[_i_])
		if _cL_ = ""
			loop
		ok
		if StzLeft(_cL_, 13) = 'predicateset '
			_acQ_ = StzSplit(_cL_, '"')
			if len(_acQ_) >= 2
				_oPS_ = new stzPredicateSet(_acQ_[2])
			ok
		but _cL_ = "rules"
			_cSection_ = "rules"
		but _cL_ = "invariants"
			_cSection_ = "invariants"
		but StzLeft(_cL_, 6) = "seal |"
			_oPS_._SetSeal(StzSectionAfter(_cL_))
		but _cSection_ = "rules"
			_oPS_.AddRule(_cL_)
		but _cSection_ = "invariants"
			_oPS_.AddInvariant(_cL_)
		ok
	next
	return _oPS_

func StzSectionAfter(pcLine)
	_acParts_ = StzSplit(pcLine, "|")
	if len(_acParts_) >= 2
		return ring_trim(_acParts_[2])
	ok
	return ""


class stzPredicateSet from stzObject

	@cName = ""
	@acRules = []        # code rules (stzCodeRules names)
	@acInvariants = []   # agent-graph invariants (stzGovernanceChecks)
	@cSeal = ""

	def init(pcName)
		@cName = "" + pcName

	def Name_()
		return @cName

	def AddRule(pcRule)
		_cR_ = StzLower(ring_trim("" + pcRule))
		if ring_find(StzCodeRuleNames(), _cR_) = 0
			stzraise("Unknown code rule '" + _cR_ + "' -- see StzCodeRuleNames().")
		ok
		if ring_find(@acRules, _cR_) = 0
			@acRules + _cR_
		ok
		return This

	def AddInvariant(pcInv)
		_cI_ = StzLower(ring_trim("" + pcInv))
		if ring_find(StzGovernanceInvariantNames(), _cI_) = 0
			stzraise("Unknown governance invariant '" + _cI_ + "' -- see StzGovernanceInvariantNames().")
		ok
		if ring_find(@acInvariants, _cI_) = 0
			@acInvariants + _cI_
		ok
		return This

	def Rules()
		return @acRules

	def Invariants()
		return @acInvariants

	def _Body()
		_c_ = 'predicateset "' + @cName + '"' + NL + "rules" + NL
		_n_ = len(@acRules)
		for _i_ = 1 to _n_
			_c_ += "    " + @acRules[_i_] + NL
		next
		_c_ += "invariants" + NL
		_n_ = len(@acInvariants)
		for _i_ = 1 to _n_
			_c_ += "    " + @acInvariants[_i_] + NL
		next
		return _c_

	def Seal()
		return StzEngineCryptoSha256(This._Body())

	def Save(pcFile)
		if StzRight(pcFile, 5) != ".zrlz"
			pcFile += ".zrlz"
		ok
		write(pcFile, This._Body() + "seal | " + This.Seal() + NL)
		return pcFile

	# TRUE when the loaded seal matches the body -- a reviewer signs the
	# seal; any silent edit to the rules breaks it.
	def Verify()
		if @cSeal = ""
			return FALSE
		ok
		return @cSeal = This.Seal()

	# run ONLY this set's code rules over source; structured findings
	def EnforceOnCode(pcSource)
		_aAll_ = StzCheckCode(pcSource)
		_aF_ = []
		_n_ = len(_aAll_)
		for _i_ = 1 to _n_
			if ring_find(@acRules, _aAll_[_i_][:rule]) > 0
				_aF_ + _aAll_[_i_]
			ok
		next
		return _aF_

	# run ONLY this set's graph invariants over a colored agent graph
	def EnforceOnGraph(poGraph)
		_aAll_ = StzCheckAgentGraph(poGraph)
		_aF_ = []
		_n_ = len(_aAll_)
		for _i_ = 1 to _n_
			if ring_find(@acInvariants, _aAll_[_i_][:invariant]) > 0
				_aF_ + _aAll_[_i_]
			ok
		next
		return _aF_

	def _SetSeal(pcSeal)
		@cSeal = ring_trim("" + pcSeal)
