#================================================================#
#  STZRULEGOVERNANCE -- the checks a rule cannot run on itself    #
#================================================================#

/*--- The five questions, and the defect each one was built from.

	A rule set is not governed by running it. Running it asks "does the
	claim hold where the rule looked" and never "did the rule look in the
	right place", which is where every scope defect of this plane has
	lived. These five ask the second question, over a CORPUS of real
	pictures, from the declarations stzPlasticRule now requires.

	VACUOUS SCOPE
	    A scope that selects every eligible subject in every picture is not
	    a scope; it is a universal claim wearing one. _EdgeIsAlternative
	    governed every labelled edge leaving any node with two children,
	    which in a diagramming library is very nearly all of them -- and
	    _ClaimChannel trusted it as a decision test. Measured over a corpus
	    this reads as coverage 1.00 and is the loudest signal here.

	EMPTY SCOPE
	    Selects nothing anywhere. A dead rule and a misspelt predicate
	    produce identical output -- silence -- and silence is what a
	    passing suite sounds like. stzGraphRule shipped its whole rule
	    registry unreachable for the library's entire history and every
	    validator built on it reported "pass" unconditionally.

	UNWITNESSED BOUNDARY
	    The rule declares subjects it must not govern, and the corpus
	    contains none of them. Then the boundary has never been stood on
	    and could be anywhere. This is the project's own law -- every
	    positive needs a negative sibling -- raised from the assertion to
	    the rule, which is the level the defects were at.

	CONTESTED SUBJECT
	    Two rules govern one subject and want different things. That is
	    not automatically wrong: leaf-follows and siblings-straddle both
	    reach for a lone child and the resolution is real. It is wrong
	    when the resolution lives only in which line runs first, because
	    then nobody can read the precedence and nobody can change the
	    order safely. The governor demands it be DECLARED.

	STALE READ
	    Rule A reads a quantity that rule B writes, and B runs after A.
	    That is centerParents and the leaf, stated structurally instead of
	    discovered by measuring half-slot offsets. It is also the label
	    gate reading Edges() while the drawer read Messages(): same shape,
	    different pipeline, and both invisible to any test of either rule.
*/

func StzRuleGovernanceQ(pcName)
	return new stzRuleGovernance(pcName)

func StzRuleGovernance(pcName)
	return new stzRuleGovernance(pcName)

func StzPlasticGovernanceQ(pcName)
	return new stzRuleGovernance(pcName)

func StzPlasticGovernance(pcName)
	return new stzRuleGovernance(pcName)

class stzRuleGovernance from stzObject

	@cName = ""
	@aoRules = []
	@aoCorpus = []      # [ [ cName, oDiagram ], ... ] -- already rendered
	@aFindings = []
	@aPrecedence = []   # [ [ cRuleA, cRuleB, cWhy ], ... ] -- A wins over B

	def init(pcName)
		@cName = "" + pcName
		@aoRules = []
		@aoCorpus = []
		@aFindings = []
		@aPrecedence = []

	def Name_()     return @cName
	def Rules()     return @aoRules
	def Findings()  return @aFindings

	def AddRule(poRule)
		@aoRules + poRule
		return This

	# A PICTURE THE RULES ARE JUDGED AGAINST. It must already be rendered:
	# every plastic rule reads render facts, and a diagram that has not
	# been drawn answers with empty lists -- which would read as an empty
	# scope and convict every rule in the set of being dead.
	# THE CASE a rule set is judged against -- a rendered picture for the
	# graph plane, a code graph for stzCodeRule, an agent graph, an org
	# chart. The governance never asks what kind it is; it asks the RULES
	# what they govern in it, which is the only thing that has to be
	# domain-specific.
	def AddCase(pcName, poSubject)
		@aoCorpus + [ "" + pcName, poSubject ]
		return This

	def AddPicture(pcName, poDg)
		return This.AddCase(pcName, poDg)

	# A DECLARED PRECEDENCE between two rules that reach for one subject.
	# The reason is required: a precedence without one is a coin toss that
	# somebody will later reverse in good faith.
	def DeclarePrecedence(pcWins, pcYields, pcWhy)
		@aPrecedence + [ StzLower("" + pcWins), StzLower("" + pcYields),
			"" + pcWhy ]
		return This

	  #-- the rules against the pictures -----------------------------------

	# What the rules say about the corpus -- the ordinary half, kept here
	# so one call answers both halves and neither can be run without the
	# other being available.
	def CheckPictures()
		return This.CheckCases()

	def CheckCases()
		_aF_ = []
		_nC_ = len(@aoCorpus)
		_nR_ = len(@aoRules)
		for _iC_ = 1 to _nC_
			for _iR_ = 1 to _nR_
				_aOne_ = @aoRules[_iR_].Check(@aoCorpus[_iC_][2],
					@aoCorpus[_iC_][1])
				_nOne_ = len(_aOne_)
				for _iO_ = 1 to _nOne_
					_aF_ + _aOne_[_iO_]
				next
			next
		next
		return _aF_

	  #-- the rules against themselves -------------------------------------

	# The five questions. Every finding here is about a RULE, so :where is
	# the rule's name and the corpus is the evidence, which is the inverse
	# of CheckPictures and the reason both exist.
	def CheckRules()
		_aF_ = []
		_nR_ = len(@aoRules)
		_nC_ = len(@aoCorpus)

		# how many subjects each rule governs, and how many it COULD, so
		# "vacuous" is a ratio rather than a feeling
		for _iR_ = 1 to _nR_
			_oR_ = @aoRules[_iR_]
			_nGov_ = 0
			_nCnt_ = 0
			for _iC_ = 1 to _nC_
				_nGov_ += len(_oR_.SubjectsIn(@aoCorpus[_iC_][2]))
				_nCnt_ += len(_oR_.CounterSubjectsIn(@aoCorpus[_iC_][2]))
			next

			# EMPTY -- governs nothing in the whole corpus
			if _nGov_ = 0
				_aF_ + [ :rule = :scope_empty, :subject = :plastic,
					:where = _oR_.Name_(), :severity = :error,
					:message = "governs nothing in " + _nC_ +
					" pictures -- a dead rule and a misspelt scope " +
					"predicate both report as passing" ]
			ok

			# VACUOUS -- governs everything it could ever govern, in every
			# picture. Measured against the union of every rule's subjects,
			# which is this corpus's idea of "an eligible subject".
			if _nGov_ > 0 and _nCnt_ = 0 and _nC_ > 1 and
			   NOT _oR_.IsUniversal()
				_bAll_ = 1
				for _iC_ = 1 to _nC_
					if len(_oR_.SubjectsIn(@aoCorpus[_iC_][2])) = 0
						_bAll_ = 0  exit
					ok
				next
				if _bAll_
					_aF_ + [ :rule = :scope_vacuous, :subject = :plastic,
						:where = _oR_.Name_(), :severity = :warning,
						:message = "governs subjects in every picture " +
						"and excludes none anywhere -- a scope that " +
						"never says no is a universal claim wearing one" ]
				ok
			ok

			# UNWITNESSED -- it declares a boundary the corpus never tests
			if _nCnt_ = 0 and NOT _oR_.IsUniversal()
				_aF_ + [ :rule = :boundary_unwitnessed, :subject = :plastic,
					:where = _oR_.Name_(), :severity = :warning,
					:message = "no picture in the corpus holds a subject " +
					"this rule must NOT govern -- its boundary has never " +
					"been stood on, so it could be anywhere" ]
			ok

			# JUDGES NOTHING -- a scope with no claim behind it
			if _oR_.Claim() = ""
				_aF_ + [ :rule = :claim_unstated, :subject = :plastic,
					:where = _oR_.Name_(), :severity = :error,
					:message = "governs subjects but states no claim -- " +
					"a name is not a sentence, and half this plane's " +
					"scope defects were a name promising what no body did" ]
			ok
		next

		# CONTESTED -- two rules reaching for one subject with no declared
		# precedence between them
		for _iA_ = 1 to _nR_
			for _iB_ = _iA_ + 1 to _nR_
				_oA_ = @aoRules[_iA_]
				_oB_ = @aoRules[_iB_]
				_cShared_ = ""
				_cPic_ = ""
				for _iC_ = 1 to _nC_
					_aSa_ = _oA_.SubjectsIn(@aoCorpus[_iC_][2])
					_aSb_ = _oB_.SubjectsIn(@aoCorpus[_iC_][2])
					_nSa_ = len(_aSa_)
					for _iSa_ = 1 to _nSa_
						_nSb_ = len(_aSb_)
						for _iSb_ = 1 to _nSb_
							if _aSa_[_iSa_] = _aSb_[_iSb_]
								_cShared_ = _aSa_[_iSa_]
								_cPic_ = @aoCorpus[_iC_][1]
								exit
							ok
						next
						if _cShared_ != ""  exit  ok
					next
					if _cShared_ != ""  exit  ok
				next
				if _cShared_ = ""  loop  ok
				if This._HasPrecedence(_oA_.Name_(), _oB_.Name_())  loop  ok
				# ...AND CONTESTED MEANS THEY WANT THE SAME PROPERTY.
				#
				# The first run reported siblings_straddle against
				# a_fan_leaves_on_one_stem over 'node:api' -- and they do
				# both govern it, because api has two children AND is a
				# plain cell with two lines leaving. But one moves the
				# children's POSITION and the other chooses a CHANNEL, so
				# they cannot contradict each other and the reader is
				# being asked to declare a precedence between rules that
				# never meet. A governor that reports work nobody can do
				# teaches its readers to skim it.
				if NOT This._WritesOverlap(_oA_, _oB_)  loop  ok
				_aF_ + [ :rule = :subject_contested, :subject = :plastic,
					:where = _oA_.Name_() + " vs " + _oB_.Name_(),
					:severity = :warning,
					:message = "both govern '" + _cShared_ + "' in " +
					_cPic_ + " and no precedence is declared -- a " +
					"resolution that lives only in which line runs " +
					"first cannot be read or safely reordered" ]
			next
		next

		# STALE -- reads a quantity a later rule writes
		for _iA_ = 1 to _nR_
			for _iB_ = 1 to _nR_
				if _iA_ = _iB_  loop  ok
				_oA_ = @aoRules[_iA_]
				_oB_ = @aoRules[_iB_]
				if _oB_.Order() <= _oA_.Order()  loop  ok
				# ...ON SUBJECTS THEY SHARE. A later write only
				# invalidates an earlier read when it lands on something
				# the earlier rule was actually looking at. The first run
				# reported siblings_straddle as reading a stale
				# node.cross because leaf_follows writes node.cross after
				# it -- true, and harmless: followLeaves moves only
				# leaves with no rank peer sharing their neighbour, which
				# is precisely the set siblingStraddle does not govern.
				# Disjoint scopes make a stale read a non-event, and the
				# governor already computes both scopes.
				if NOT This._SubjectsOverlap(_oA_, _oB_)  loop  ok
				_aRd_ = _oA_.Reads()
				_nRd_ = len(_aRd_)
				for _iRd_ = 1 to _nRd_
					_aWr_ = _oB_.Writes()
					_nWr_ = len(_aWr_)
					for _iWr_ = 1 to _nWr_
						if StzLower("" + _aRd_[_iRd_]) !=
						   StzLower("" + _aWr_[_iWr_])  loop  ok
						_aF_ + [ :rule = :read_is_stale, :subject = :plastic,
							:where = _oA_.Name_() + " reads " +
								_aRd_[_iRd_],
							:severity = :error,
							:message = "'" + _oB_.Name_() + "' writes " +
							_aRd_[_iRd_] + " at order " + _oB_.Order() +
							", after '" + _oA_.Name_() + "' read it at " +
							_oA_.Order() + " -- a derived value computed " +
							"before its input is final is not a rule, it " +
							"is a stale read" ]
					next
				next
			next
		next

		@aFindings = _aF_
		return _aF_

	# Do two rules write any quantity in common? Two rules over one
	# subject that write different things are not in contest.
	def _WritesOverlap(poA, poB)
		_aA_ = poA.Writes()
		_aB_ = poB.Writes()
		_nA_ = len(_aA_)
		for _iA_ = 1 to _nA_
			_nB_ = len(_aB_)
			for _iB_ = 1 to _nB_
				if StzLower("" + _aA_[_iA_]) = StzLower("" + _aB_[_iB_])
					return 1
				ok
			next
		next
		return 0

	# Do two rules govern any subject in common, anywhere in the corpus?
	def _SubjectsOverlap(poA, poB)
		_nC_ = len(@aoCorpus)
		for _iC_ = 1 to _nC_
			_aA_ = poA.SubjectsIn(@aoCorpus[_iC_][2])
			_aB_ = poB.SubjectsIn(@aoCorpus[_iC_][2])
			_nA_ = len(_aA_)
			for _iA_ = 1 to _nA_
				_nB_ = len(_aB_)
				for _iB_ = 1 to _nB_
					if _aA_[_iA_] = _aB_[_iB_]  return 1  ok
				next
			next
		next
		return 0

	def _HasPrecedence(pcA, pcB)
		_pA_ = StzLower("" + pcA)
		_pB_ = StzLower("" + pcB)
		_nP_ = len(@aPrecedence)
		for _iP_ = 1 to _nP_
			if @aPrecedence[_iP_][1] = _pA_ and
			   @aPrecedence[_iP_][2] = _pB_  return 1  ok
			if @aPrecedence[_iP_][1] = _pB_ and
			   @aPrecedence[_iP_][2] = _pA_  return 1  ok
		next
		return 0

	  #-- both halves, and the verdict --------------------------------------

	# Everything: what the rules say about the pictures, and what the
	# governor says about the rules.
	def CheckAll()
		_aF_ = This.CheckRules()
		_aP_ = This.CheckCases()
		_nP_ = len(_aP_)
		for _iP_ = 1 to _nP_
			_aF_ + _aP_[_iP_]
		next
		@aFindings = _aF_
		return _aF_

	def IsSound()
		_nF_ = len(@aFindings)
		for _iF_ = 1 to _nF_
			if @aFindings[_iF_][:severity] = :error  return 0  ok
		next
		return 1

	# How much of the corpus each rule actually governs -- the number that
	# turns "is this scope right" from an opinion into a reading.
	def ScopeTable()
		_a_ = []
		_nR_ = len(@aoRules)
		_nC_ = len(@aoCorpus)
		for _iR_ = 1 to _nR_
			_oR_ = @aoRules[_iR_]
			_nG_ = 0  _nX_ = 0  _nPics_ = 0
			for _iC_ = 1 to _nC_
				_nS_ = len(_oR_.SubjectsIn(@aoCorpus[_iC_][2]))
				_nG_ += _nS_
				if _nS_ > 0  _nPics_++  ok
				_nX_ += len(_oR_.CounterSubjectsIn(@aoCorpus[_iC_][2]))
			next
			_a_ + [ _oR_.Name_(), _nG_, _nX_, _nPics_, _nC_ ]
		next
		return _a_
