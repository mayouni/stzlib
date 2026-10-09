# R6 -- stzRefinableCode: REFINEMENT PROGRAMMING (stzPolyCode home)
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.8 + the DLM-era ruling.)
# Code carries typed REFINEMENT POINTS -- named "adjustment knobs" --
# and a change is a TYPED PROPOSAL, not a diff: the cascade is previewed,
# the four-stage gate validates, the audit chain records, and one call
# reverts (reversibility as a data-model primitive).
#
#   cSrc = 'rate = <R:PARAM name="vat" value="0.20" min="0" max="0.25">' + nl +
#          'engine = <R:ALGO name="sort" value="quick" options="quick|merge|heap">'
#   o = new stzRefinableCode(cSrc)
#   ? o.RefinementPoints()            # the declared change surface
#   ? o.Cascade("vat")                # what a change to 'vat' touches
#   o.Refine("vat").To("0.22")        # a typed proposal through the gate
#   ? o.Rendered()                    # the refined source
#   o.Revert()                        # the typed inverse
#
# THE GATE (5 stages): STRUCTURAL (the point exists + the value parses) ->
# CONSTRAINT (bounds / allowed options) -> GOVERNANCE (stzGovernance:
# CAN + SHOULD vs the point's risk tier) -> TRUST POSTURE (the origin's
# trust rank clears the point's floor) -> DERIVATION (cross-point rules on
# the post-change state). A rejected proposal NEVER mutates (LAW 3).
#
# R6 DEEPENING (5.8):
#   TRUST POSTURES -- Refine(p).As(:llm|:sandboxed|:external|:trusted).To(v):
#     every refinement records WHERE it came from (into the audit chain), and
#     TrustFloor(point, posture) refuses lower-trust origins -- an LLM edit to
#     a critical knob can be forbidden without forbidding a human's.
#   REVERSIBILITY AS A DATA-MODEL PRIMITIVE -- a full undo/redo TIMELINE:
#     RevertTo(step) / Checkpoint(name) + RevertToCheckpoint / Redo(), atomic
#     and typed, not a single-step button. FORMAT: *.zrfn.

# Treats tagged values in source code as typed, reversible knobs: a change is a proposal that passes a gate, never a diff.
#
# Mark the adjustable values of a piece of code with tags such as <R:PARAM name="vat" value="0.20"
# min="0" max="0.9"> or <R:ALGO name="sort" value="quick" options="quick|merge|heap">.
# RefinementPoints lists them and Cascade previews what a change touches. Refine(name).To(value)
# sends the proposal through the gate: the point must exist, the value must respect min and max or
# the options, then governance (when wired), the trust floor and the derivation rules decide. The
# answer is a hash-list with admitted and why, and a refused change never alters the source. Every
# admitted change goes on a timeline that Revert, RevertTo, Checkpoint and Redo walk, and Rendered
# returns the refined source. Refine only code you own: Save writes a file with the extension zrfn.
#
#   receiver   o1 = new stzRefinableCode('vat = <R:PARAM name="vat" value="0.20" min="0" max="0.9">'
#              + char(10) + 'engine = <R:ALGO name="sort" value="quick"
#              options="quick|merge|heap">')
#   example    ? @@( o1.RefinementPoints() )
#              #--> [ [ "vat", "param", "0.20" ], [ "sort", "algo", "quick" ] ]
#              ? o1.Refine("vat").To("0.22")[:admitted]
#              #--> 1
#              ? o1.Refine("vat").To("0.95")[:admitted]
#              #--> 0
#              ? @@( o1.Why() )
#              #--> "constraint: 0.95 above max 0.9"
#              ? @@( o1.ValueOf("vat") )
#              #--> "0.22"
#              o1.Refine("sort").To("heap")
#              ? o1.NumberOfSteps()
#              #--> 2
#              o1.Revert()
#              ? @@( o1.ValueOf("sort") )
#              #--> "quick"
#              ? o1.CanRedo()
#              #--> 1
#   see        stzGovernance, stzPolyCode
class stzRefinableCode from stzObject

	@cSource = ""
	@aPoints = []       # [ name, kind, value, meta, spanStart, spanLen ]
	@aHistory = []      # reversibility: [ name, oldValue, newValue ]
	@cWhy = ""
	@cPending = ""      # the point Refine() targets

	# R6 DEEPENING: the two reserved gate stages, now wired.
	@aDerivations = []  # STAGE 3: [ name, fPredicate, message ] cross-point rules
	@oGov = ""        # STAGE 4: stzGovernance (refining = a governed action)
	@cActor = "refiner" # the actor whose permission/authority is checked

	# R6 DEEPENING 2: EXECUTION TRUST POSTURES + REVERSIBILITY-AS-PRIMITIVE.
	# Every refinement carries a POSTURE (where it came from -- trusted in-
	# process / external / sandboxed / llm-composed) that lands in the audit
	# chain; a point can set a TRUST FLOOR that refuses lower-trust origins.
	@cPendingPosture = "trusted"  # posture of the Refine()..To() in flight
	@aTrustFloors = []            # [ pointLower, minRank ] per-point trust gate
	# reversibility as a data-model primitive: a full undo/redo timeline +
	# named checkpoints, not a single-step LIFO.
	@aRedo = []                   # undone steps available to Redo()
	@aCheckpoints = []            # [ name, historyLen-at-mark ]

	# Reads source code for its refinement points, the tags that mark a value as an adjustable knob, and keeps the text.
	#
	#   pcSource   the code as text, holding tags such as <R:PARAM name="vat" value="0.20" min="0"
	#              max="0.9"> or <R:ALGO name="sort" value="quick" options="quick
	#   returns    nothing; the object is built
	#   note       RefinementPoints, Refine
	#   warning    heap">
	#   see        merge
	def init(pcSource)
		@cSource = "" + pcSource
		This._Parse()

	# Returns the code as it stands now, with the current value of every point in place.
	#
	#   returns    a text
	#   see        Rendered, Save
	def Source()
		return @cSource

	# Returns the reason given by the last gate decision or timeline move.
	#
	#   returns    a text such as admitted: 'vat' 0.20 -> 0.22, or the stage and cause of a refusal;
	#              empty text before any
	#   see        To, RevertTo
	def Why()
		return @cWhy

	# Returns the declared change surface: one triple of name, kind and current value for each point, in source order.
	#
	#   returns    a list of triples such as [ "vat", "param", "0.20" ]
	#   see        NumberOfPoints, ValueOf, KindOf
	#@ aka  -- the declared change surface -----------------------------------------
	def RefinementPoints()
		_aOut_ = []
		_n_ = len(@aPoints)
		for _i_ = 1 to _n_
			_aOut_ + [ @aPoints[_i_][1], @aPoints[_i_][2], @aPoints[_i_][3] ]
		next
		return _aOut_

	# Returns how many refinement points the code declares.
	#
	#   returns    a number
	#   see        RefinementPoints
	def NumberOfPoints()
		return len(@aPoints)

	# Returns the current value of a point as text.
	#
	#   pcName     the name of the point, with the case it was declared in
	#   returns    a text; empty text when the point does not exist
	#   see        KindOf, RefinementPoints
	def ValueOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			return ""
		ok
		return @aPoints[_i_][3]

	# Returns the kind of a point, in lowercase: param for a bounded value, algo or lib for a choice among options.
	#
	#   pcName     the name of the point
	#   returns    a text such as param; empty text when the point does not exist
	#   see        ValueOf
	def KindOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			return ""
		ok
		return @aPoints[_i_][2]

	# Previews what a change to a point touches: the line it sits on and any other point on the same line.
	#
	#   pcName     the name of the point
	#   returns    a hash-list with point, exists, lines and alsoTouches; exists is 0 and the lists
	#              are empty for an unknown point
	#   see        Refine, RefinementPoints
	#@ aka  -- CASCADE: the pre-commit blast radius (the review artifact) -----------
	def Cascade(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			return [ :point = "" + pcName, :exists = 0, :lines = [], :alsoTouches = [] ]
		ok
		_nLine_ = This._LineOfSpan(@aPoints[_i_][5])
		_acAlso_ = []
		_n_ = len(@aPoints)
		for _j_ = 1 to _n_
			if _j_ != _i_ and This._LineOfSpan(@aPoints[_j_][5]) = _nLine_
				_acAlso_ + @aPoints[_j_][1]
			ok
		next
		return [ :point = @aPoints[_i_][1], :exists = 1,
			:lines = [ _nLine_ ], :alsoTouches = _acAlso_ ]

	# Adds a rule between points that every later change must satisfy, checked on the state the change would produce.
	#
	#   pcName       the name of the rule, quoted in the refusal
	#   fPredicate   a function taking the refinable code and returning 1 when the state is
	#                consistent
	#   pcMessage    the text shown when the rule refuses a change
	#   returns      the code itself, so calls chain
	#   warning      a change that breaks a rule is rolled back and refused with a derivation reason
	#   see          NumberOfDerivations, To
	#@ aka  -- STAGE 3 wiring: cross-point DERIVATION rules ------------------------ A derivation rule is a named predicate over the code's POST-change state: fPredicate(oCode) returns TRUE when the state is consistent. It fires AFTER the value is tentatively applied and rolls the change back if any rule rejects (so cross-point invariants -- "vat cannot exceed the ceiling", "heap needs a threshold" -- are enf
	def DeclareDerivation(pcName, fPredicate, pcMessage)
		@aDerivations + [ "" + pcName, fPredicate, "" + pcMessage ]
		return This

	# Returns how many derivation rules are declared.
	#
	#   returns    a number
	#   see        DeclareDerivation
	def NumberOfDerivations()
		return len(@aDerivations)

	# Returns the name of the governance object wired to this code, or empty text when there is none.
	#
	#   returns    a text
	#   see        SetGovernedBy, Actor
	#@ aka  -- STAGE 4 wiring: GOVERNANCE (refining is a governed action) ---------- Wire a (fully configured) stzGovernance. Each point's refinement is the action "refine-<point>"; To() calls MayProceed(actor, action) so a refinement needs permission (CAN) + authority (SHOULD) covering the point's declared risk tier before it can mutate the source. the NAME of the object that governs this code ("" if none)
	def GovernedBy()
		if @oGov = ""
			return ""
		ok
		return @oGov.Name_()

	# Wires a governance object, so that every change becomes the governed action refine-point and needs permission and authority.
	#
	#   poGov      a stzGovernance, a copy of which is kept
	#   returns    the code itself, so calls chain
	#   warning    configure the governance through this code, not through the object you passed:
	#              the code keeps its own copy
	#   see        SetRiskFor, SetAllowRefine, SetAuthorityLevel, GovernedBy
	def SetGovernedBy(poGov)
		@oGov = poGov
		return This

	# Returns the name of the actor on whose behalf changes are judged by the governance; refiner by default.
	#
	#   returns    a text
	#   see        SetActor
	#@ aka  the actor this code acts as
	def Actor()
		return @cActor

	# Sets the actor on whose behalf changes are judged by the governance.
	#
	#   pcActor    the name of the actor, such as release-bot
	#   returns    the code itself, so calls chain
	#   see        Actor, SetAllowRefine
	def SetActor(pcActor)
		@cActor = "" + pcActor
		return This

	# Declares where the next change comes from, so the gate can compare it with a trust floor; it applies to the next To only.
	#
	#   pcPosture   trusted, external, sandboxed or llm, in order of trust from highest to lowest
	#   returns     the code itself, so calls chain
	#   note        the posture is recorded in the timeline
	#   warning     an unknown posture counts as trusted and passes every floor (confirmed: a floor
	#               of trusted admitted a change made as weird); the posture goes back to trusted
	#               after each To
	#   see         TrustFloor, To
	#@ aka  -- EXECUTION TRUST POSTURES (5.8) -------------------------------------- A posture says WHERE a refinement came from. Trust rank (high -> low): :trusted (3, in-process/verified) > :external (2, an external tool) > :sandboxed (1, isolated run) > :llm (0, LLM-composed). A proposal defaults to :trusted; As(posture) declares otherwise for the next To(). The posture rides into the audit chain; a point'
	def As(pcPosture)
		@cPendingPosture = StzLower("" + pcPosture)
		return This

	# Sets the lowest posture allowed to change a point; changes from a lower posture are refused.
	#
	#   pcPoint        the name of the point, in any case
	#   pcMinPosture   trusted, external, sandboxed or llm
	#   returns        the code itself, so calls chain
	#   note           setting it again replaces the earlier floor
	#   warning        an unknown posture sets the strictest floor, trusted, instead of none
	#   see            TrustFloorOf, As
	def TrustFloor(pcPoint, pcMinPosture)
		_cP_ = StzLower("" + pcPoint)
		_r_ = This._PostureRank(pcMinPosture)
		_i_ = 0
		_n_ = len(@aTrustFloors)
		for _k_ = 1 to _n_
			if @aTrustFloors[_k_][1] = _cP_  _i_ = _k_  ok
		next
		if _i_ = 0
			@aTrustFloors + [ _cP_, _r_ ]
		else
			@aTrustFloors[_i_][2] = _r_
		ok
		return This

	# Returns the floor of a point as a rank: 3 trusted, 2 external, 1 sandboxed, 0 llm.
	#
	#   pcPoint    the name of the point, in any case
	#   returns    a number; -1 when the point has no floor
	#   see        TrustFloor
	def TrustFloorOf(pcPoint)
		_cP_ = StzLower("" + pcPoint)
		_n_ = len(@aTrustFloors)
		for _k_ = 1 to _n_
			if @aTrustFloors[_k_][1] = _cP_  return @aTrustFloors[_k_][2]  ok
		next
		return -1   # no floor

	def _PostureRank(pcPosture)
		_p_ = StzLower("" + pcPosture)
		if _p_ = "trusted"    return 3  ok
		if _p_ = "external"   return 2  ok
		if _p_ = "sandboxed"  return 1  ok
		if _p_ = "llm"        return 0  ok
		return 3   # unknown -> most permissive (an explicit posture opts IN)

	# Declares how risky it is to change a point, as a tier, in the governance wired to this code.
	#
	#   pcPoint    the name of the point
	#   nTier      the risk tier, a number such as 3
	#   returns    the code itself, so calls chain
	#   note       a point with no declared tier can never be changed under governance
	#   warning    raises an error when no governance is wired yet
	#   see        SetAllowRefine, SetAuthorityLevel, SetGovernedBy
	#@ aka  Governance config MUST go through these delegators: GovernedBy stores a COPY (governance is pure Ring lists, no shared handle), so mutating the caller's original would leave this copy stale (the Ring aliasing doctrine). Delegating keeps @oGov the one live truth.
	def SetRiskFor(pcPoint, nTier)
		This._NeedGov()
		@oGov.DeclareRisk("refine-" + StzLower("" + pcPoint), nTier)
		return This

	# Grants the current actor the permission to change a point.
	#
	#   pcPoint    the name of the point
	#   returns    the code itself, so calls chain
	#   warning    raises an error when no governance is wired yet
	#   see        SetRiskFor, SetActor
	#@ aka  Grant the actor permission (CAN) to refine a point.
	def SetAllowRefine(pcPoint)
		This._NeedGov()
		@oGov.GrantPermission(@cActor, "refine-" + StzLower("" + pcPoint))
		return This

	# Sets the authority of the current actor, which must cover the risk tier of a point for the change to pass.
	#
	#   pcType     advisory, delegated, autonomous or emergencyoverride
	#   returns    the code itself, so calls chain
	#   note       delegated is level 2 and autonomous is level 3
	#   warning    raises an error when no governance is wired yet
	#   see        SetRiskFor, SetActor
	#@ aka  Set the actor's authority (SHOULD): :Advisory/:Delegated/ :Autonomous/:EmergencyOverride.
	def SetAuthorityLevel(pcType)
		This._NeedGov()
		@oGov.SetAuthority(@cActor, pcType)
		return This

	# Returns the governance object wired to this code, as a copy for reading its decisions.
	#
	#   returns    the stzGovernance; empty text when none
	#   see        SetGovernedBy
	#@ aka  The wired governance as a chainable object (Q-convention) -- returns a fresh copy each call; use for READS (Why/Lineage/NumberOfDecisions).
	def GovernanceQ()
		return @oGov

	def _NeedGov()
		if @oGov = ""
			stzraise("This refinable code is not governed -- SetGovernedBy(oGov) first.")
		ok

	# Sets the point that the next To will change, which opens a typed proposal.
	#
	#   pcName     the name of the point to change
	#   returns    the code itself, so calls chain
	#   warning    nothing is checked until To
	#   see        To, As, Cascade
	#@ aka  -- the typed proposal + the gate ----------------------------------------
	def Refine(pcName)
		@cPending = "" + pcName
		return This

	# Sends the value to the point named by Refine through the gate and applies it only if every stage passes.
	#
	#   pValue     the new value, taken as text
	#   returns    a hash-list with admitted, 1 or 0, and why
	#   note       an admitted change is recorded on the timeline and clears what could be redone
	#   warning    raises an error when Refine was not called first; the stages in order are the
	#              point exists, the value is within min and max or among the options, governance,
	#              trust floor, then the derivation rules; a refused change leaves the source
	#              untouched
	#   see        Refine, Why, Revert
	#@ aka  apply a value to the pending point THROUGH the gate. Returns [ :admitted, :why ]; on rejection the source is unchanged.
	def To(pValue)
		if @cPending = ""
			stzraise("Refine(pointName) first, then To(value).")
		ok
		_cName_ = @cPending
		@cPending = ""
		_cPosture_ = @cPendingPosture
		@cPendingPosture = "trusted"    # posture is per-proposal; reset
		_cVal_ = "" + pValue
		_i_ = This._IndexOf(_cName_)

		# STAGE 1 -- STRUCTURAL: the point must exist
		if _i_ = 0
			@cWhy = "structural: no refinement point '" + _cName_ + "'"
			return [ :admitted = 0, :why = @cWhy ]
		ok

		# STAGE 2 -- CONSTRAINT: bounds (PARAM) / options (ALGO/LIB)
		_aGate_ = This._ConstraintCheck(_i_, _cVal_)
		if _aGate_[1] = 0
			@cWhy = "constraint: " + _aGate_[2]
			return [ :admitted = 0, :why = @cWhy ]
		ok

		# STAGE 4 -- GOVERNANCE (checked BEFORE any mutation): refining
		# this point is the action "refine-<point>"; the actor needs
		# permission + authority covering its risk tier. Undeclared-risk
		# actions are refused by stzGovernance (nothing mutates).
		if @oGov != ""
			_cAction_ = "refine-" + StzLower(_cName_)
			if @oGov.MayProceed(@cActor, _cAction_) = 0
				@cWhy = "governance: " + @oGov.Why()
				return [ :admitted = 0, :why = @cWhy ]
			ok
		ok

		# STAGE 4b -- TRUST POSTURE: the origin's trust rank must clear the
		# point's floor (an LLM-composed edit to a floored knob is refused
		# even if the actor's governance would allow it -- origin != identity).
		_nFloor_ = This.TrustFloorOf(_cName_)
		if _nFloor_ >= 0 and This._PostureRank(_cPosture_) < _nFloor_
			@cWhy = "trust: posture :" + _cPosture_ + " below the required floor for '" +
				_cName_ + "'"
			return [ :admitted = 0, :why = @cWhy ]
		ok

		# Tentatively apply, then STAGE 3 -- DERIVATION: cross-point
		# rules evaluate the POST-change state; any rejection rolls the
		# value back so the source never keeps an inconsistent state.
		_cOld_ = @aPoints[_i_][3]
		This._SetValueAt(_i_, _cVal_)
		_aD_ = This._DerivationCheck()
		if _aD_[1] = 0
			_iBack_ = This._IndexOf(_cName_)
			This._SetValueAt(_iBack_, _cOld_)
			@cWhy = "derivation: " + _aD_[2]
			return [ :admitted = 0, :why = @cWhy ]
		ok

		# ADMITTED: record the reversible step (WITH its posture) and (if
		# governed) the decision lineage. A fresh admit invalidates the redo
		# stack -- the timeline forked (standard undo/redo semantics).
		@aHistory + [ _cName_, _cOld_, _cVal_, _cPosture_ ]
		@aRedo = []
		if @oGov != ""
			@oGov.RecordDecision("refine-" + StzLower(_cName_) + "-" + len(@aHistory),
				"refinement admitted (posture :" + _cPosture_ + ") through the gate",
				@cActor, "refine-" + StzLower(_cName_))
		ok
		@cWhy = "admitted: '" + _cName_ + "' " + _cOld_ + " -> " + _cVal_ +
			" [:" + _cPosture_ + "] (structural + constraint + derivation + governance + trust passed)"
		return [ :admitted = 1, :why = @cWhy ]

	# TRUE if at least one admitted change can be undone.
	#
	#   returns    1 or 0
	#   see        Revert, CanRedo
	#@ aka  -- reversibility (a data-model primitive) -------------------------------
	def CanRevert()
		return len(@aHistory) > 0

	# Undoes the last admitted change and keeps it available to redo.
	#
	#   returns    the code itself, so calls chain
	#   warning    raises an error when there is nothing to revert
	#   see        RevertTo, Redo, CanRevert
	#@ aka  undo the last admitted refinement -- a TYPED inverse (single step).
	def Revert()
		if len(@aHistory) = 0
			stzraise("Nothing to revert.")
		ok
		return This.RevertTo(len(@aHistory) - 1)

	# Rolls the source back to the state after exactly this many admitted changes, undoing the later ones in reverse.
	#
	#   nStep      how many changes to keep, 0 for the original source
	#   returns    the code itself, so calls chain
	#   note       the undone changes can be redone, the last undone first
	#   see        Revert, Checkpoint, Redo
	#@ aka  ATOMIC multi-step revert: roll the source back to exactly nStep applied refinements (0 = the original source), undoing each step in reverse via its typed inverse. Every undone step is pushed onto the REDO stack. This is reversibility as a data-model primitive: time-travel over the timeline, not a one-off undo button.
	def RevertTo(nStep)
		if nStep < 0  nStep = 0  ok
		_nCnt_ = 0
		while len(@aHistory) > nStep
			_aLast_ = @aHistory[len(@aHistory)]
			del(@aHistory, len(@aHistory))
			_i_ = This._IndexOf(_aLast_[1])
			if _i_ > 0
				This._SetValueAt(_i_, _aLast_[2])   # restore the prior value
			ok
			@aRedo + _aLast_
			_nCnt_++
		end
		@cWhy = "reverted " + _nCnt_ + " step(s) -> timeline at " + nStep
		return This

	# TRUE if some undone change can be applied again.
	#
	#   returns    1 or 0
	#   see        Redo, CanRevert
	def CanRedo()
		return len(@aRedo) > 0

	# Applies again the change that was undone most recently.
	#
	#   returns    the code itself, so calls chain
	#   note       the change is applied without passing the gate again
	#   warning    raises an error when there is nothing to redo
	#   see        Revert, CanRedo
	#@ aka  RE-APPLY the most recently reverted step (undo the undo). A fresh admitted Refine clears the redo stack (the timeline forked).
	def Redo()
		if len(@aRedo) = 0
			stzraise("Nothing to redo.")
		ok
		_r_ = @aRedo[len(@aRedo)]
		del(@aRedo, len(@aRedo))
		_i_ = This._IndexOf(_r_[1])
		if _i_ > 0
			This._SetValueAt(_i_, _r_[3])           # re-apply the new value
		ok
		@aHistory + _r_
		@cWhy = "redid: '" + _r_[1] + "' -> " + _r_[3]
		return This

	# Marks the current place on the timeline under a name, to come back to it later.
	#
	#   pcName     the name of the checkpoint
	#   returns    the code itself, so calls chain
	#   see        RevertToCheckpoint
	#@ aka  A named marker on the timeline; RevertToCheckpoint rewinds to it.
	def Checkpoint(pcName)
		@aCheckpoints + [ "" + pcName, len(@aHistory) ]
		return This

	# Rolls the source back to the place marked by a checkpoint.
	#
	#   pcName     the name given to Checkpoint
	#   returns    the code itself, so calls chain
	#   warning    raises an error naming the checkpoint when none has that name
	#   see        Checkpoint, RevertTo
	def RevertToCheckpoint(pcName)
		_cN_ = "" + pcName
		_nStep_ = -1
		_n_ = len(@aCheckpoints)
		for _k_ = 1 to _n_
			if @aCheckpoints[_k_][1] = _cN_  _nStep_ = @aCheckpoints[_k_][2]  ok
		next
		if _nStep_ < 0
			stzraise("No checkpoint '" + pcName + "'.")
		ok
		return This.RevertTo(_nStep_)

	# Returns the applied changes in order, each as name, old value, new value and posture.
	#
	#   returns    a list of lists such as [ "vat", "0.20", "0.22", "trusted" ]
	#   see        Timeline, NumberOfSteps
	#@ aka  The ordered applied timeline: [ name, old, new, posture ] per step.
	def History()
		return @aHistory
	# Returns the applied changes in order, each as name, old value, new value and posture.
	#
	#   returns    a list of lists such as [ "vat", "0.20", "0.22", "trusted" ]
	#   see        History
	def Timeline()
		return @aHistory
	# Returns how many changes are applied now, which is the position on the timeline.
	#
	#   returns    a number
	#   see        History, RevertTo
	def NumberOfSteps()
		return len(@aHistory)

	# Returns the posture recorded for one applied change.
	#
	#   nStep      the position of the change, from 1
	#   returns    a text such as trusted or llm; empty text for a step that does not exist
	#   see        History, As
	#@ aka  The posture recorded for a given applied step (1-based; "" if none).
	def PostureOf(nStep)
		if nStep < 1 or nStep > len(@aHistory)  return ""  ok
		return @aHistory[nStep][4]

	# Returns the source with every point's current value in place; the tags stay, so the points remain adjustable.
	#
	#   returns    a text
	#   see        Source, Save
	#@ aka  -- rendering ------------------------------------------------------------
	def Rendered()
		return @cSource

	# Writes the source to a file with the extension zrfn, adding the extension when it is missing.
	#
	#   pcFile     the path to write
	#   returns    the path actually written, as text
	#   see        Rendered
	#@ aka  -- persistence (*.zrfn) ------------------------------------------------------
	def Save(pcFile)
		if StzRight(pcFile, 5) != ".zrfn"
			pcFile += ".zrfn"
		ok
		write(pcFile, @cSource)
		return pcFile

	#-- internals -------------------------------------------------------------

	# tag grammar: <R:KIND name="x" value="v" [min= max= | options=]>
	def _Parse()
		@aPoints = []
		_cS_ = @cSource
		_nFrom_ = 1
		while 1
			_aOpen_ = This._FirstAtOrAfter(_cS_, "<R:", _nFrom_)
			if _aOpen_ = 0
				exit
			ok
			_aClose_ = This._FirstAtOrAfter(_cS_, ">", _aOpen_)
			if _aClose_ = 0
				exit
			ok
			_cTag_ = This._Slice(_cS_, _aOpen_, _aClose_)
			_cKind_ = StzLower(This._Attr(_cTag_, ""))   # after "<R:"
			_cName_ = This._Attr(_cTag_, "name")
			_cVal_ = This._Attr(_cTag_, "value")
			_aMeta_ = [
				:min = This._Attr(_cTag_, "min"),
				:max = This._Attr(_cTag_, "max"),
				:options = This._Attr(_cTag_, "options")
			]
			# value span: inside value="..."
			_nVS_ = This._ValueSpanStart(_cS_, _aOpen_, _aClose_)
			_nVL_ = StzLen(_cVal_)
			if _cName_ != ""
				@aPoints + [ _cName_, _cKind_, _cVal_, _aMeta_, _nVS_, _nVL_ ]
			ok
			_nFrom_ = _aClose_ + 1
		end

	# STAGE 3 evaluator: every declared cross-point rule must hold on the
	# current (post-tentative-change) state. Returns [ ok, message ].
	def _DerivationCheck()
		_n_ = len(@aDerivations)
		for _i_ = 1 to _n_
			_f_ = @aDerivations[_i_][2]   # plain var: `call` needs it, not an index
			if call _f_(This) = 0
				return [ 0, "rule '" + @aDerivations[_i_][1] + "' violated -- " +
					@aDerivations[_i_][3] ]
			ok
		next
		return [ 1, "" ]

	def _ConstraintCheck(nIdx, pcVal)
		_cKind_ = @aPoints[nIdx][2]
		_aMeta_ = @aPoints[nIdx][4]
		if _cKind_ = "param"
			# numeric bounds when min/max present
			if _aMeta_[:min] != "" and ring_number(pcVal) < ring_number(_aMeta_[:min])
				return [ 0, pcVal + " below min " + _aMeta_[:min] ]
			ok
			if _aMeta_[:max] != "" and ring_number(pcVal) > ring_number(_aMeta_[:max])
				return [ 0, pcVal + " above max " + _aMeta_[:max] ]
			ok
			return [ 1, "" ]
		but _cKind_ = "algo" or _cKind_ = "lib"
			if _aMeta_[:options] != ""
				_acO_ = StzSplit(_aMeta_[:options], "|")
				if ring_find(_acO_, pcVal) = 0
					return [ 0, "'" + pcVal + "' not in options " + _aMeta_[:options] ]
				ok
			ok
			return [ 1, "" ]
		ok
		return [ 1, "" ]

	# rewrite the value span in the source and re-parse spans
	def _SetValueAt(nIdx, pcVal)
		_nS_ = @aPoints[nIdx][5]
		_nL_ = @aPoints[nIdx][6]
		_cBefore_ = This._SliceLen(@cSource, 1, _nS_ - 1)
		_cAfter_ = This._SliceFrom(@cSource, _nS_ + _nL_)
		@cSource = _cBefore_ + pcVal + _cAfter_
		This._Parse()

	def _IndexOf(pcName)
		_cN_ = "" + pcName
		_n_ = len(@aPoints)
		for _i_ = 1 to _n_
			if @aPoints[_i_][1] = _cN_
				return _i_
			ok
		next
		return 0

	def _Attr(pcTag, pcAttr)
		# named attr: pcAttr="x" -> value inside x="..."
		if pcAttr = ""
			# KIND: the token right after "<R:" up to a space
			_cRest_ = This._SliceFrom(pcTag, 4)
			_acP_ = StzSplit(_cRest_, " ")
			return _acP_[1]
		ok
		_cKey_ = pcAttr + '="'
		_aP_ = StzFindCS(_cKey_, pcTag, 1)
		if len(_aP_) = 0
			return ""
		ok
		_nStart_ = _aP_[1] + StzLen(_cKey_)
		_cTail_ = This._SliceFrom(pcTag, _nStart_)
		_aQ_ = StzFindCS('"', _cTail_, 1)
		if len(_aQ_) = 0
			return ""
		ok
		return This._SliceLen(_cTail_, 1, _aQ_[1] - 1)

	def _ValueSpanStart(pcS, nOpen, nClose)
		_cTag_ = This._Slice(pcS, nOpen, nClose)
		_aP_ = StzFindCS('value="', _cTag_, 1)
		if len(_aP_) = 0
			return nOpen
		ok
		return nOpen + (_aP_[1] - 1) + StzLen('value="')

	def _FirstAtOrAfter(pcS, pcNeedle, nFrom)
		_aAll_ = StzFindCS(pcNeedle, pcS, 1)
		_n_ = len(_aAll_)
		for _i_ = 1 to _n_
			if _aAll_[_i_] >= nFrom
				return _aAll_[_i_]
			ok
		next
		return 0

	def _Slice(pcS, nA, nB)
		return This._SliceLen(pcS, nA, nB - nA + 1)

	def _SliceLen(pcS, nStart, nLen)
		if nLen <= 0
			return ""
		ok
		return StzMid(pcS, nStart, nLen)

	def _SliceFrom(pcS, nStart)
		if nStart > StzLen(pcS)
			return ""
		ok
		return StzMidToEnd(pcS, nStart)

	def _LineOfSpan(nPos)
		_cHead_ = This._SliceLen(@cSource, 1, nPos)
		return len(StzFindCS(char(10), _cHead_, 1)) + 1
