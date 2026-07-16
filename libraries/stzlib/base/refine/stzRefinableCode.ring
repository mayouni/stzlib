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

class stzRefinableCode from stzObject

	@cSource = ""
	@aPoints = []       # [ name, kind, value, meta, spanStart, spanLen ]
	@aHistory = []      # reversibility: [ name, oldValue, newValue ]
	@cWhy = ""
	@cPending = ""      # the point Refine() targets

	# R6 DEEPENING: the two reserved gate stages, now wired.
	@aDerivations = []  # STAGE 3: [ name, fPredicate, message ] cross-point rules
	@oGov = NULL        # STAGE 4: stzGovernance (refining = a governed action)
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

	def init(pcSource)
		@cSource = "" + pcSource
		This._Parse()

	def Source()
		return @cSource

	def Why()
		return @cWhy

	#-- the declared change surface -----------------------------------------

	def RefinementPoints()
		_aOut_ = []
		_n_ = len(@aPoints)
		for _i_ = 1 to _n_
			_aOut_ + [ @aPoints[_i_][1], @aPoints[_i_][2], @aPoints[_i_][3] ]
		next
		return _aOut_

	def NumberOfPoints()
		return len(@aPoints)

	def ValueOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			return ""
		ok
		return @aPoints[_i_][3]

	def KindOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			return ""
		ok
		return @aPoints[_i_][2]

	#-- CASCADE: the pre-commit blast radius (the review artifact) -----------

	# which source LINES the point sits on, plus any point that shares a
	# line (the floor's cross-point impact). "What you read instead of
	# the diff" (5.8).
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

	#-- STAGE 3 wiring: cross-point DERIVATION rules ------------------------
	# A derivation rule is a named predicate over the code's POST-change
	# state: fPredicate(oCode) returns TRUE when the state is consistent.
	# It fires AFTER the value is tentatively applied and rolls the change
	# back if any rule rejects (so cross-point invariants -- "vat cannot
	# exceed the ceiling", "heap needs a threshold" -- are enforceable).
	# Same {name, function, message} record shape as stzGraphRule.
	def DeclareDerivation(pcName, fPredicate, pcMessage)
		@aDerivations + [ "" + pcName, fPredicate, "" + pcMessage ]
		return This

	def NumberOfDerivations()
		return len(@aDerivations)

	#-- STAGE 4 wiring: GOVERNANCE (refining is a governed action) ----------
	# Wire a (fully configured) stzGovernance. Each point's refinement is
	# the action "refine-<point>"; To() calls MayProceed(actor, action)
	# so a refinement needs permission (CAN) + authority (SHOULD) covering
	# the point's declared risk tier before it can mutate the source.
	# the NAME of the object that governs this code ("" if none)
	def GovernedBy()
		if @oGov = NULL
			return ""
		ok
		return @oGov.Name_()

	def SetGovernedBy(poGov)
		@oGov = poGov
		return This

	# the actor this code acts as
	def Actor()
		return @cActor

	def SetActor(pcActor)
		@cActor = "" + pcActor
		return This

	#-- EXECUTION TRUST POSTURES (5.8) --------------------------------------
	# A posture says WHERE a refinement came from. Trust rank (high -> low):
	# :trusted (3, in-process/verified) > :external (2, an external tool) >
	# :sandboxed (1, isolated run) > :llm (0, LLM-composed). A proposal
	# defaults to :trusted; As(posture) declares otherwise for the next
	# To(). The posture rides into the audit chain; a point's TrustFloor
	# refuses anything below the required rank (LLM-composed edits to a
	# critical knob can be forbidden without forbidding a human's).
	def As(pcPosture)
		@cPendingPosture = StzLower("" + pcPosture)
		return This

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

	# Governance config MUST go through these delegators: GovernedBy
	# stores a COPY (governance is pure Ring lists, no shared handle),
	# so mutating the caller's original would leave this copy stale (the
	# Ring aliasing doctrine). Delegating keeps @oGov the one live truth.

	# Declare a point's refinement risk tier ("refine-<point>").
	def SetRiskFor(pcPoint, nTier)
		This._NeedGov()
		@oGov.DeclareRisk("refine-" + StzLower("" + pcPoint), nTier)
		return This

	# Grant the actor permission (CAN) to refine a point.
	def SetAllowRefine(pcPoint)
		This._NeedGov()
		@oGov.GrantPermission(@cActor, "refine-" + StzLower("" + pcPoint))
		return This

	# Set the actor's authority (SHOULD): :Advisory/:Delegated/
	# :Autonomous/:EmergencyOverride.
	def SetAuthorityLevel(pcType)
		This._NeedGov()
		@oGov.SetAuthority(@cActor, pcType)
		return This

	# The wired governance as a chainable object (Q-convention) -- returns
	# a fresh copy each call; use for READS (Why/Lineage/NumberOfDecisions).
	def GovernanceQ()
		return @oGov

	def _NeedGov()
		if @oGov = NULL
			stzraise("This refinable code is not governed -- SetGovernedBy(oGov) first.")
		ok

	#-- the typed proposal + the gate ----------------------------------------

	def Refine(pcName)
		@cPending = "" + pcName
		return This

	# apply a value to the pending point THROUGH the gate. Returns
	# [ :admitted, :why ]; on rejection the source is unchanged.
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
		if @oGov != NULL
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
		if @oGov != NULL
			@oGov.RecordDecision("refine-" + StzLower(_cName_) + "-" + len(@aHistory),
				"refinement admitted (posture :" + _cPosture_ + ") through the gate",
				@cActor, "refine-" + StzLower(_cName_))
		ok
		@cWhy = "admitted: '" + _cName_ + "' " + _cOld_ + " -> " + _cVal_ +
			" [:" + _cPosture_ + "] (structural + constraint + derivation + governance + trust passed)"
		return [ :admitted = 1, :why = @cWhy ]

	#-- reversibility (a data-model primitive) -------------------------------

	def CanRevert()
		return len(@aHistory) > 0

	# undo the last admitted refinement -- a TYPED inverse (single step).
	def Revert()
		if len(@aHistory) = 0
			stzraise("Nothing to revert.")
		ok
		return This.RevertTo(len(@aHistory) - 1)

	# ATOMIC multi-step revert: roll the source back to exactly nStep applied
	# refinements (0 = the original source), undoing each step in reverse via
	# its typed inverse. Every undone step is pushed onto the REDO stack. This
	# is reversibility as a data-model primitive: time-travel over the
	# timeline, not a one-off undo button.
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

	def CanRedo()
		return len(@aRedo) > 0

	# RE-APPLY the most recently reverted step (undo the undo). A fresh
	# admitted Refine clears the redo stack (the timeline forked).
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

	# A named marker on the timeline; RevertToCheckpoint rewinds to it.
	def Checkpoint(pcName)
		@aCheckpoints + [ "" + pcName, len(@aHistory) ]
		return This

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

	# The ordered applied timeline: [ name, old, new, posture ] per step.
	def History()
		return @aHistory
	def Timeline()
		return @aHistory
	def NumberOfSteps()
		return len(@aHistory)

	# The posture recorded for a given applied step (1-based; "" if none).
	def PostureOf(nStep)
		if nStep < 1 or nStep > len(@aHistory)  return ""  ok
		return @aHistory[nStep][4]

	#-- rendering ------------------------------------------------------------

	# the source with every point's CURRENT value in place (the R-tags
	# stay -- the point is a living knob, not a one-shot substitution)
	def Rendered()
		return @cSource

	#-- persistence (*.zrfn) ------------------------------------------------------

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
		while TRUE
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
