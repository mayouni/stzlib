# R2 -- stzPredicateSet: THE CONSTITUTION MECHANISM (5.7 G10)
# A declared, diffable, SIGNABLE set of governance predicates that the
# validators enforce. Softanza ships the MECHANISM; any specific
# constitution (articles, jurisdictions) is product space.
#
#   oPS = new stzPredicateSet("house-rules")
#   oPS.AddRule("no-len-method")             # from StzCodeRuleNames()
#   oPS.AddInvariant("no-llm-effectful")     # from StzGovernanceInvariantNames()
#   oPS.Save("house.zrlz")                  # content + sha256 seal
#   oPS2 = new stzPredicateSet("")
#   oPS2.LoadFrom("house.zrlz")
#   ? oPS2.Verify()                          # seal intact?
#   ? oPS2.EnforceOnCode(cSource)            # only ITS code rules
#
# FORMAT (*.zrlz): readable lines --
#   predicateset "name"
#   rules        <one code-rule name per line>
#   invariants   <one graph-invariant name per line>
#   seal | <sha256 of the body above>


func StzSectionAfter(pcLine)
	_acParts_ = StzSplit(pcLine, "|")
	if len(_acParts_) >= 2
		return ring_trim(_acParts_[2])
	ok
	return ""


# Holds a declared set of governance predicates, house code rules and agent-graph invariants, that can be saved with a seal and enforced.
#
# The mechanism, not any particular constitution: a set names which code rules and which graph
# invariants apply, EnforceOnCode and EnforceOnGraph run only those, and Save writes the set as
# readable lines ending with a SHA-256 seal that Verify checks after LoadFrom. Names are checked
# against the library's lists when added or loaded, so a file cannot add a rule that does not exist.
# The seal is an unkeyed digest: it catches a silent edit of the rules but proves nothing about
# authorship, which a reviewer's signature must supply outside the file.
#
#   receiver   o1 = new stzPredicateSet("house-rules")
#   example    o1.AddRule("no-len-method")
#              o1.AddInvariant("no-llm-effectful")
#              ? @@( o1.Rules() )
#              #--> [ "no-len-method" ]
#              o2 = "class Foo" + nl + "def Len()" + nl + "  return 5" + nl
#              ? o1.EnforceOnCode(o2)[1][:rule]
#              #--> no-len-method
#              ? len(o1.Seal())
#              #--> 64
#   see        stzCodeRuleSet, stzAgentRuleSet, StzCheckCode
class stzPredicateSet from stzObject

	@cName = ""
	@acRules = []        # code rules (stzCodeRules names)
	@acInvariants = []   # agent-graph invariants (stzGovernanceChecks)
	@cSeal = ""

	# Builds an empty named set of governance predicates: code rules and agent-graph invariants.
	#
	#   pcName     the set's name, written into a saved file
	#   returns    nothing; the object is built
	#   see        AddRule, AddInvariant, Save
	def init(pcName)
		@cName = "" + pcName

	# Changes the name under which the set is saved, replacing the one it was built with.
	#
	#   pcName     the new name
	#   returns    the set itself, so calls chain
	#   note       LoadFrom also replaces the name with the one in the file
	#   see        Name_
	def SetName(pcName)
		@cName = "" + pcName
		return This

	# Returns the name of the set.
	#
	#   returns    a text
	#   see        SetName
	def Name_()
		return @cName

	# Adds a code rule to the set by name; adding one already held changes nothing.
	#
	#   pcRule     the name of a house code rule, in any case, as StzCodeRuleNames lists them
	#   returns    nothing; use AddRuleQ to chain
	#   note       names are stored in lower case
	#   warning    raises an error naming StzCodeRuleNames for a rule it does not know
	#   see        Rules, EnforceOnCode
	def AddRule(pcRule)
		_cR_ = StzLower(ring_trim("" + pcRule))
		if ring_find(StzCodeRuleNames(), _cR_) = 0
			stzraise("Unknown code rule '" + _cR_ + "' -- see StzCodeRuleNames().")
		ok
		if ring_find(@acRules, _cR_) = 0
			@acRules + _cR_
		ok

		def AddRuleQ(pcRule)
			This.AddRule(pcRule)
			return This

	# Adds an agent-graph invariant to the set by name; adding one already held changes nothing.
	#
	#   pcInv      the name of a governance invariant, in any case, as StzGovernanceInvariantNames
	#              lists them
	#   returns    nothing; use AddInvariantQ to chain
	#   note       names are stored in lower case
	#   warning    raises an error naming StzGovernanceInvariantNames for an invariant it does not
	#              know
	#   see        Invariants, EnforceOnGraph
	def AddInvariant(pcInv)
		_cI_ = StzLower(ring_trim("" + pcInv))
		if ring_find(StzGovernanceInvariantNames(), _cI_) = 0
			stzraise("Unknown governance invariant '" + _cI_ + "' -- see StzGovernanceInvariantNames().")
		ok
		if ring_find(@acInvariants, _cI_) = 0
			@acInvariants + _cI_
		ok

		def AddInvariantQ(pcInv)
			This.AddInvariant(pcInv)
			return This

	# Returns the code rules in the set, in the order added.
	#
	#   returns    a list of text
	#   see        AddRule, EnforceOnCode
	def Rules()
		return @acRules

	# Returns the agent-graph invariants in the set, in the order added.
	#
	#   returns    a list of text
	#   see        AddInvariant, EnforceOnGraph
	def Invariants()
		return @acInvariants

	def _Body()
		_c_ = 'predicateset "' + @cName + '"' + char(10) + "rules" + char(10)
		_n_ = len(@acRules)
		for _i_ = 1 to _n_
			_c_ += "    " + @acRules[_i_] + char(10)
		next
		_c_ += "invariants" + char(10)
		_n_ = len(@acInvariants)
		for _i_ = 1 to _n_
			_c_ += "    " + @acInvariants[_i_] + char(10)
		next
		return _c_

	# Returns the SHA-256 digest of the set's body: its name, its rules and its invariants.
	#
	#   returns    a text of 64 hexadecimal characters
	#   note       a reviewer's signature has to be added outside the file
	#   warning    the seal is a plain unkeyed digest: it shows that a file was edited without its
	#              seal line being redone, and it does not authenticate who wrote the file, since
	#              anyone who edits the body can recompute the seal
	#   see        Verify, Save
	def Seal()
		return StzEngineCryptoSha256(This._Body())

	# Reads a saved .zrlz file into this set: the name, the rules, the invariants and the seal recorded in it.
	#
	#   pcFile     the full path of the file, extension included
	#   returns    the set itself, so calls chain
	#   note       rules and invariants are added to those already held, not substituted for them
	#   warning    raises the file error when the file is missing, and the unknown-rule error when
	#              it names a rule or invariant that does not exist, so a file cannot add a rule the
	#              library lacks
	#   see        Save, Verify
	#@ aka  LOAD a sealed .stzrules back INTO this set -- the mirror of Save(), and the object's OWN act (LoadFrom: 'Load' is a Ring keyword).
	def LoadFrom(pcFile)
		_cContent_ = StzReplace(read(pcFile), char(13), "")
		_acLines_ = StzSplit(_cContent_, char(10))
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
					This.SetName(_acQ_[2])
				ok
			but _cL_ = "rules"
				_cSection_ = "rules"
			but _cL_ = "invariants"
				_cSection_ = "invariants"
			but StzLeft(_cL_, 6) = "seal |"
				This._SetSeal(StzSectionAfter(_cL_))
			but _cSection_ = "rules"
				This.AddRule(_cL_)
			but _cSection_ = "invariants"
				This.AddInvariant(_cL_)
			ok
		next
		return This

	# Writes the set to a .zrlz file as readable lines ending with its seal, adding the extension when it is missing.
	#
	#   pcFile     the path of the file to write
	#   returns    a text, the path written
	#   note       LoadFrom does not add the extension, so pass it the returned path
	#   see        LoadFrom, Seal
	def Save(pcFile)
		if StzRight(pcFile, 5) != ".zrlz"
			pcFile += ".zrlz"
		ok
		write(pcFile, This._Body() + "seal | " + This.Seal() + char(10))
		return pcFile

	# TRUE if a seal was loaded and it matches the body now held.
	#
	#   returns    TRUE or FALSE; FALSE for a set built in memory, which has loaded no seal
	#   note       it checks integrity, not authorship
	#   warning    a file whose rules were edited without redoing the seal answers FALSE, and one
	#              edited with the seal recomputed answers TRUE
	#   see        Seal, LoadFrom
	#@ aka  TRUE when the loaded seal matches the body -- a reviewer signs the seal; any silent edit to the rules breaks it.
	def Verify()
		if @cSeal = ""
			return 0
		ok
		return @cSeal = This.Seal()

	# Runs the house code checks on a source text and keeps only the findings of this set's rules.
	#
	#   pcSource   the Ring source text to check
	#   returns    a list of hash lists [ :rule, :line, :severity, :message ]; empty when the set
	#              holds no rules
	#   note       a source that breaks a rule the set does not hold gives no finding
	#   see        AddRule, EnforceOnGraph
	#@ aka  run ONLY this set's code rules over source; structured findings
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

	# Runs the agent-graph checks on a graph and keeps only the findings of this set's invariants.
	#
	#   poGraph    the agent graph to check, such as the graph an stzAgentGraph holds
	#   returns    a list of hash lists [ :invariant, :node, :severity, :message ]
	#   note       an invariant the set does not hold gives no finding
	#   see        AddInvariant, EnforceOnCode
	#@ aka  run ONLY this set's graph invariants over a colored agent graph
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
