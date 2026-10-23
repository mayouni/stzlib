#==============================================================#
#  STZSCOPEDRULE -- a rule that knows what it GOVERNS            #
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

# NAMED FOR THE MECHANISM, NOT FOR ITS FIRST USE.
#
# This shipped as stzPlasticRule because the graph plane's visual rules
# were the first thing it governed -- and every member of it is
# domain-neutral. Naming a general mechanism after its first caller is
# the same error this file exists to catch, one level up: a thing whose
# name promises less than its body does, so the next domain that needs it
# writes a second copy instead. The code, agent, security and org rule
# sets need exactly this, and none of them is plastic.
#
# StzPlasticRule stays as the graph plane's spelling of it.
func StzScopedRuleQ(pcName)
	return new stzScopedRule(pcName)

func StzScopedRule(pcName)
	return new stzScopedRule(pcName)

func StzPlasticRuleQ(pcName)
	return new stzScopedRule(pcName)

func StzPlasticRule(pcName)
	return new stzScopedRule(pcName)

# Holds a rule as a triple, the subjects it governs, the claim it makes about them and the subjects it must not govern.
#
# Most rules are one function that both selects its subjects and judges them, so a rule that selects
# the wrong subjects and judges them correctly reports a pass. A scoped rule separates the two:
# SetScope says which subjects, SetClaimCheck says what must hold of one, SetCounter says which
# subjects it must leave alone, and SetClaim writes the sentence in words. SetReads, SetWrites and
# SetOrder let a governance find a stale read from declarations. A subject key is any text or number
# the scope returns. Check judges one case and returns findings in the house shape;
# stzRuleGovernance judges a set of rules over many cases. StzPlasticRule is the graph plane's
# spelling of the same class.
#
#   receiver   o1 = new stzScopedRule("evens_small") o1.SetClaim("an even number is below 10")
#              o1.SetScope(func oL { _a_ = []  for i = 1 to len(oL)  if oL[i] % 2 = 0  _a_ + oL[i]
#              ok  next  return _a_ }) o1.SetCounter(func oL { _a_ = []  for i = 1 to len(oL)  if
#              oL[i] % 2 = 1  _a_ + oL[i]  ok  next  return _a_ }) o1.SetClaimCheck(func oL, n { if
#              n < 10  return [ 1, "" ]  ok  return [ 0, "it is " + n ] })
#   example    ? @@( o1.SubjectsIn([ 1, 2, 3, 12 ]) )
#              #--> [ 2, 12 ]
#              ? @@( o1.CounterSubjectsIn([ 1, 2, 3, 12 ]) )
#              #--> [ 1, 3 ]
#              ? o1.Check([ 1, 2, 3, 12 ], "list one")[1][:message]
#              #--> an even number is below 10 -- it is 12
#              ? o1.Check([ 1, 2, 3, 12 ], "list one")[1][:where]
#              #--> list one / 12
#              ? len(o1.Check([ 4, 6 ], "list two"))
#              #--> 0
#   see        stzRuleGovernance, stzGraphRule, stzRuleReport
class stzScopedRule from stzObject

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

	# Builds a rule with a name and nothing else declared: no claim, scope, counter, reads or writes.
	#
	#   pcName     the name of the rule
	#   returns    nothing; the object is built
	#   note       severity starts as error and the order as 0; StzScopedRuleQ and StzPlasticRule
	#              build the same object
	#   see        SetClaim, SetScope
	def init(pcName)
		@cName = "" + pcName
		@acReads = []
		@acWrites = []

	# Returns the name the rule was built with.
	#
	#   returns    the name as text
	#   see        Claim
	def Name_()      return @cName
	# Returns the sentence the rule asserts.
	#
	#   returns    the sentence as text; an empty text until SetClaim is called
	#   note       the rule governance reports a rule with an empty claim as claim_unstated
	#   see        SetClaim, Check
	def Claim()      return @cClaim
	# Returns the quantities the rule reads, as it declared them.
	#
	#   returns    a list of text; [ ] until SetReads is called
	#   see        SetReads, Writes
	def Reads()      return @acReads
	# Returns the quantities the rule writes, as it declared them.
	#
	#   returns    a list of text; [ ] until SetWrites is called
	#   see        SetWrites, Reads
	def Writes()     return @acWrites
	# Returns when the rule runs relative to other rules.
	#
	#   returns    a number; 0 until SetOrder is called
	#   note       only the comparison with another rule's order means anything
	#   see        SetOrder
	def Order()      return @nOrder
	# Returns the severity the rule's findings carry.
	#
	#   returns    the severity as text; error until SetSeverity is called
	#   see        SetSeverity, Check
	def Severity()   return @cSeverity

	# Sets the sentence the rule asserts, in words a reader can disagree with.
	#
	#   pcClaim    the sentence, shown in the message of every finding
	#   returns    the rule itself, so calls chain
	#   see        Claim, SetClaimCheck
	#@ aka  THE SENTENCE THE RULE ASSERTS, in words a reader can disagree with. Required, and not decoration: half the defects above are a name that promised something the body did not do, and a name is not a sentence.
	def SetClaim(pcClaim)
		@cClaim = "" + pcClaim
		return This

	# Sets the function that selects the subjects the rule governs in a case.
	#
	#   pFunc      a function of one parameter, the case, that returns a list of subject keys
	#   returns    the rule itself, so calls chain
	#   note       with no scope the rule governs nothing and Check judges nothing
	#   see        SubjectsIn, SetCounter
	#@ aka  WHICH SUBJECTS THIS RULE GOVERNS -- the half no rule in this library has ever stated separately, and the half every scope defect lived in.
	def SetScope(pFunc)
		@pScope = pFunc
		return This

	# Sets the function that judges one governed subject.
	#
	#   pFunc      a function of two parameters, the case and one subject, that returns a pair [
	#              holds, why ]
	#   returns    the rule itself, so calls chain
	#   note       an answer that is not a pair is read as not holding, with an empty reason
	#   see        Check, SetScope
	#@ aka  WHAT MUST BE TRUE of a subject the scope selected.
	def SetClaimCheck(pFunc)
		@pClaimFn = pFunc
		return This

	# Sets the function that selects the subjects the rule must NOT govern in a case.
	#
	#   pFunc      a function of one parameter, the case, that returns a list of subject keys
	#   returns    the rule itself, so calls chain
	#   note       a counter no case in the governance corpus contains is reported as
	#              boundary_unwitnessed
	#   see        CounterSubjectsIn, SetScope
	#@ aka  SUBJECTS IT MUST NOT GOVERN. The negative sibling, at rule level.
	def SetCounter(pFunc)
		@pCounter = pFunc
		return This

	# Declares the quantities the rule reads, so a stale read can be found from declarations.
	#
	#   pacNames   the quantities read, a list of text
	#   returns    the rule itself, so calls chain
	#   see        Reads, SetWrites
	#@ aka  WHAT IT READS AND WHAT IT WRITES, so an ordering defect is a fact about declarations rather than something found by rendering a picture and squinting at it.
	def SetReads(pacNames)
		@acReads = pacNames
		return This

	# Declares the quantities the rule writes, so a stale read or a contest can be found from declarations.
	#
	#   pacNames   the quantities written, a list of text
	#   returns    the rule itself, so calls chain
	#   see        Writes, SetReads
	def SetWrites(pacNames)
		@acWrites = pacNames
		return This

	# Sets when the rule runs, relative to the orders of the other rules.
	#
	#   pnOrder    the order, a number
	#   returns    the rule itself, so calls chain
	#   note       the governance compares orders and this class never does
	#   see        Order, SetReads
	#@ aka  WHEN IT RUNS, in the pipeline it belongs to. Only meaningful against the other rules' orders; the governor compares, never this class.
	def SetOrder(pnOrder)
		@nOrder = pnOrder
		return This

	# Sets the severity that the findings of the rule carry.
	#
	#   pcSeverity   the severity, such as error or warning
	#   returns      the rule itself, so calls chain
	#   note         the text is not checked
	#   see          Severity, Check
	def SetSeverity(pcSeverity)
		@cSeverity = pcSeverity
		return This

	# Declares that the rule has no boundary on purpose, and says why.
	#
	#   pcWhy      the reason, which is required: the rule is universal only while this text is not
	#              empty
	#   returns    the rule itself, so calls chain
	#   note       the governance does not report a universal rule as vacuous or as having an
	#              unwitnessed boundary
	#   see        IsUniversal, SetCounter
	#@ aka  A RULE THAT IS UNIVERSAL ON PURPOSE, and says why.
	def SetUniversal(pcWhy)
		@cUniversal = "" + pcWhy
		return This

	# TRUE if the rule was declared universal with a reason.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        SetUniversal, UniversalWhy
	def IsUniversal()   return @cUniversal != ""
	# Returns the reason the rule was declared universal.
	#
	#   returns    the reason as text; an empty text when it was not
	#   see        SetUniversal, IsUniversal
	def UniversalWhy()  return @cUniversal

	# Returns the subjects the rule governs in a case, by calling its scope.
	#
	#   poDg       the case to look at, such as a rendered diagram or any object the scope
	#              understands
	#   returns    a list of subject keys; [ ] when no scope was set
	#   see        CounterSubjectsIn, Check
	#@ aka  -- asking the rule about a picture ---------------------------------
	def SubjectsIn(poDg)
		if @pScope = NULL  return []  ok
		_aS_ = call @pScope(poDg)
		This._RequireSubjectList(_aS_, "scope")
		return _aS_

	# Returns the subjects the rule must not govern that a case contains, by calling its counter.
	#
	#   poDg       the case to look at
	#   returns    a list of subject keys; [ ] when no counter was set
	#   see        SubjectsIn, SetCounter
	def CounterSubjectsIn(poDg)
		if @pCounter = NULL  return []  ok
		_aC_ = call @pCounter(poDg)
		This._RequireSubjectList(_aC_, "counter")
		return _aC_

	# A scope and a counter answer with a LIST of subject keys, and a caller
	# that returns a number (a count, a 0/1 flag) is handing the governor
	# something it takes len() of: the crash that follows says "bad parameter
	# type" and names neither the rule nor the file. Said here, at the one
	# place every answer passes through, it names both.
	def _RequireSubjectList(paAnswer, pcWhich)
		if isList(paAnswer)  return  ok
		_cKind_ = "value"
		_cShown_ = ""
		if isNumber(paAnswer)
			_cKind_ = "number"
			_cShown_ = " (" + paAnswer + ")"
		but isString(paAnswer)
			_cKind_ = "string"
			_cShown_ = " ('" + paAnswer + "')"
		but isObject(paAnswer)
			_cKind_ = "object"
		ok
		StzRaise("rule '" + @cName + "': its " + pcWhich + " answered a " +
			_cKind_ + _cShown_ + ", not a list of subject keys -- return " +
			"[ ] for none and [ 'key', ... ] otherwise")

	# Judges every governed subject of a case and returns a finding for each that fails the claim.
	#
	#   poDg       the case to judge
	#   pcWhere    the name of the case, put before the subject in the finding's where
	#   returns    a list of findings, each a hash list with rule, subject, where, severity and
	#              message; [ ] when all hold
	#   note       the message is the claim, then the reason; with no claim check set it judges
	#              nothing and answers [ ]; subject is always plastic
	#   see        SubjectsIn, SetClaimCheck
	#@ aka  Findings for one picture, in the house shape. A rule with no claim check governs subjects and judges nothing, which the governor reports as its own kind of defect rather than silently passing.
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
