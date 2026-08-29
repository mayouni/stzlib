#==============================================================#
#  STZPLASTICRULE -- a visual rule that knows what it GOVERNS   #
#==============================================================#

/*--- WHY THIS LAYER EXISTS, and it is not a general wish for rigour.

	One session of this plane produced SIX defects, and they were one
	defect. In every case a rule was correct about the thing it was
	written for and was being applied to something else:

	  _EdgeIsAlternative   said "labelled, and the source forks" while its
	                       NAME said "two answers to one question" -- so
	                       every labelled fan-out in the library was
	                       treated as a decision
	  centerParents        moved a parent AFTER a leaf had been aligned to
	                       where the parent used to be
	  the label gate       asked This.Edges() while the drawer read the
	                       messages, so nine labelled arrows came out bare
	  _SummitOf            asked POSITIONS for a fact about the graph, and
	                       the positions changed between the two moments
	                       it asked
	  the label exemption  covered the whole of an edge's own path when it
	                       was only ever meant to cover the run it names
	  the paper measurement  measured edges for a picture drawn from messages

	None of these is a wrong rule. Every one is a right rule OUTSIDE ITS
	SCOPE -- and not one of them was findable by testing the rule, because
	the rule passes its own tests. They are findable only by asking a
	question no rule asks about itself: WHAT DO YOU GOVERN, AND WHAT MUST
	YOU NOT?

	AND THIS FILE'S NEIGHBOUR ALREADY CARRIED THE EVIDENCE. stzGraphRule
	says, in its own comments: "COMPLETENESS NOW MEANS COMPLETENESS. This
	group used to hold exactly one rule -- no_bottlenecks -- which is the
	property ValidateBottleneck already reports, under a name that promises
	something else entirely." Same defect, found by hand, years apart, and
	nothing was built that would have found the second one.

--- THE ONE STRUCTURAL CHANGE

	Every rule in this library today is ONE function that both SELECTS its
	subjects and JUDGES them:

	    func(oGraph, params) { ...find the things... ...are they ok?... }

	The selection half has no tests anywhere, in any rule, in any domain.
	It cannot have any: a rule that selects the wrong subjects and judges
	them correctly returns "pass", and a suite that runs it sees a pass.
	That is exactly what shipped six times.

	So a plastic rule is a TRIPLE, and the two new members are the point:

	    SCOPE     which subjects this rule governs        <- new, checkable
	    CLAIM     what must be true of a governed subject
	    COUNTER   subjects it must NOT govern             <- new, checkable

	COUNTER is not documentation. It is the negative sibling this project
	already demands of every assertion, raised from the assertion to the
	RULE: a rule whose boundary is never exercised has a boundary that
	could be anywhere, and five of the six defects above are boundaries
	nobody had ever stood on.

--- WHAT THE GOVERNOR CAN THEN ASK

	These are questions about the RULES, asked over a corpus of real
	pictures. No individual rule can ask any of them about itself.

	  VACUOUS      a scope that selects every subject in every picture is
	               not a scope. _EdgeIsAlternative scored 1.00 here.
	  EMPTY        a scope that selects nothing anywhere is a dead rule or
	               a misspelt predicate, and both read as "passing".
	  UNWITNESSED  a COUNTER that no picture in the corpus contains: the
	               rule's boundary has never been tested.
	  CONTESTED    two rules governing one subject and wanting different
	               things, with no declared precedence between them.
	  STALE        a rule reading a quantity that a LATER rule writes --
	               the centerParents defect, stated structurally.

	Findings come out in the house shape, [ :rule, :subject, :where,
	:severity, :message ], so stzRuleReport collects them beside the code,
	agent and security domains. One gate, as phase 6 established.
*/

func StzPlasticRuleQ(pcName)
	return new stzPlasticRule(pcName)

func StzPlasticRule(pcName)
	return new stzPlasticRule(pcName)

class stzPlasticRule from stzObject

	@cName    = ""
	@cClaim   = ""
	@pScope   = NULL     # func(oDg) -> list of subject keys it governs
	@pClaimFn = NULL     # func(oDg, cSubject) -> [ bHolds, cWhy ]
	@pCounter = NULL     # func(oDg) -> list of subject keys it must NOT govern
	@acReads  = []
	@acWrites = []
	@nOrder   = 0
	@cSeverity = :error
	@cUniversal = ""

	def init(pcName)
		@cName = "" + pcName
		@acReads = []
		@acWrites = []

	def Name_()      return @cName
	def Claim()      return @cClaim
	def Reads()      return @acReads
	def Writes()     return @acWrites
	def Order()      return @nOrder
	def Severity()   return @cSeverity

	# THE SENTENCE THE RULE ASSERTS, in words a reader can disagree with.
	# Required, and not decoration: half the defects above are a name that
	# promised something the body did not do, and a name is not a sentence.
	def SetClaim(pcClaim)
		@cClaim = "" + pcClaim
		return This

	# WHICH SUBJECTS THIS RULE GOVERNS -- the half no rule in this library
	# has ever stated separately, and the half every scope defect lived in.
	def SetScope(pFunc)
		@pScope = pFunc
		return This

	# WHAT MUST BE TRUE of a subject the scope selected.
	def SetClaimCheck(pFunc)
		@pClaimFn = pFunc
		return This

	# SUBJECTS IT MUST NOT GOVERN. The negative sibling, at rule level.
	def SetCounter(pFunc)
		@pCounter = pFunc
		return This

	# WHAT IT READS AND WHAT IT WRITES, so an ordering defect is a fact
	# about declarations rather than something found by rendering a picture
	# and squinting at it.
	def SetReads(pacNames)
		@acReads = pacNames
		return This

	def SetWrites(pacNames)
		@acWrites = pacNames
		return This

	# WHEN IT RUNS, in the pipeline it belongs to. Only meaningful against
	# the other rules' orders; the governor compares, never this class.
	def SetOrder(pnOrder)
		@nOrder = pnOrder
		return This

	def SetSeverity(pcSeverity)
		@cSeverity = pcSeverity
		return This

	# A RULE THAT IS UNIVERSAL ON PURPOSE, and says why.
	#
	# Some claims genuinely have no boundary: equal air applies to every
	# picture there is, and no counter-example exists to witness. Without
	# a way to say so, the governor reports every such rule as vacuous
	# forever -- and a governor that reports work nobody can do is one
	# its readers learn to skim, which costs more than the check earns.
	#
	# The REASON is required and is the whole safeguard. "Universal"
	# asserted without one is indistinguishable from a scope predicate
	# that broke, which is the case this layer exists to catch, so the
	# escape hatch has to cost a sentence somebody can disagree with.
	def SetUniversal(pcWhy)
		@cUniversal = "" + pcWhy
		return This

	def IsUniversal()   return @cUniversal != ""
	def UniversalWhy()  return @cUniversal

	  #-- asking the rule about a picture ---------------------------------

	def SubjectsIn(poDg)
		if @pScope = NULL  return []  ok
		return call @pScope(poDg)

	def CounterSubjectsIn(poDg)
		if @pCounter = NULL  return []  ok
		return call @pCounter(poDg)

	# Findings for one picture, in the house shape. A rule with no claim
	# check governs subjects and judges nothing, which the governor reports
	# as its own kind of defect rather than silently passing.
	def Check(poDg, pcWhere)
		_aF_ = []
		if @pClaimFn = NULL  return _aF_  ok
		_aSub_ = This.SubjectsIn(poDg)
		_nSub_ = len(_aSub_)
		for _iSub_ = 1 to _nSub_
			_aV_ = call @pClaimFn(poDg, _aSub_[_iSub_])
			if isList(_aV_) and len(_aV_) = 2 and _aV_[1]  loop  ok
			_cWhy_ = ""
			if isList(_aV_) and len(_aV_) = 2  _cWhy_ = "" + _aV_[2]  ok
			_aF_ + [ :rule = @cName, :subject = :plastic,
				:where = "" + pcWhere + " / " + _aSub_[_iSub_],
				:severity = @cSeverity,
				:message = @cClaim + " -- " + _cWhy_ ]
		next
		return _aF_
