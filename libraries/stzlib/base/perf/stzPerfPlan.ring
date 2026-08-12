/*
	stzPerfPlan -- optimization as a GOVERNED act (perf P6).

	The last verb of the notebook's pipeline -- Monitor -> Alert ->
	Analyze -> OPTIMIZE -- crosses reality: scaling a fleet, draining
	workers, tightening a rate limit. In this library nothing crosses
	reality casually: expression is free, admission is governed --
	the same crossing rule as stzVirtualSystem's update plans and the
	delivery plane's deployments, applied to performance tuning.

		oPlan = StzPerfPlan("relieve-nlp")
		oPlan.Propose(:ScaleUp, "nlp", "measured load 0.92 > high-water 0.75")
		oPlan.Propose(:RestartDead, "nlp", "2 dead workers in FleetMetrics")

		oPlan.ExecuteOn(oCluster, LLMActor("advisor"))    # REFUSED, audited
		oPlan.ExecuteOn(oCluster, HumanActor("mansour"))  # commits, audited

	The closed action catalog (each maps to one effectful verb on the
	target -- a stzAppCluster or anything answering the same verbs):

	  :ScaleUp      -> target.ScaleUp(tag)
	  :ScaleDown    -> target.ScaleDown(tag)     (graceful drain)
	  :RestartDead  -> target.RestartDead()      (heal the fleet)

	The governance consequence, by construction: an actor whose
	effect-set is empty -- LLMActor is inference-only, sandboxed --
	can BUILD the plan, EXPLAIN it, and hand it over; ExecuteOn
	refuses it wholesale and audits the refusal. Agentic performance
	tuning is safe by the same rule that keeps agents from touching
	production anywhere else in the library: the machine proposes,
	an effectful actor commits.

	Every outcome lands in the audit trail:
	  [ n, "committed"|"refused", action, tag, actorName, why ]
	MayCommit(oActor) answers admissibility BEFORE any attempt --
	preflight is a first-class question. Refusals are never silent.
*/

func StzPerfPlan(pcName)
	return new stzPerfPlan(pcName)

class stzPerfPlan from stzObject

	@cName = ""
	@aActions = []		# [ kind(lower), tag, rationale ]
	@aAudit = []		# [ n, verdict, kind, tag, actor, why ]
	@bExecuted = 0

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	# -- Proposing (expression is free) ---------------------------

	def Propose(pcAction, pcTag, pcRationale)
		_cK_ = StzLower("" + pcAction)
		if _cK_ != "scaleup" and _cK_ != "scaledown" and _cK_ != "restartdead"
			stzraise("stzPerfPlan: unknown action ':" + _cK_ + "'. The catalog is closed: " +
				":ScaleUp, :ScaleDown, :RestartDead.")
		ok
		@aActions + [ _cK_, StzLower("" + pcTag), "" + pcRationale ]
		return This

	def Actions()
		return @aActions

	def NumberOfActions()
		return ring_len(@aActions)

	# -- Preflight ------------------------------------------------

	# May this actor commit this plan? Answered BEFORE any attempt:
	# admission demands the effectful capability, and a sandboxed
	# posture never crosses (the LLMActor doctrine).
	def MayCommit(poActor)
		if NOT poActor.IsEffectful()
			return 0
		ok
		if StzLower("" + poActor.Posture()) = "sandboxed"
			return 0
		ok
		return 1

	# -- The crossing (admission is governed) ---------------------

	# Apply the plan to the target -- a stzAppCluster, or any object
	# answering ScaleUp(tag)/ScaleDown(tag)/RestartDead() (a double in
	# rehearsal, per the service-virtualization pattern). Returns the
	# number of actions committed; 0 with a full refusal audit when
	# the actor may not commit.
	def ExecuteOn(poTarget, poActor)
		_cActor_ = poActor.Name()
		if NOT This.MayCommit(poActor)
			_cWhy_ = "actor is not effectful"
			if poActor.IsEffectful()
				_cWhy_ = "actor posture is sandboxed"
			ok
			_nLen_ = ring_len(@aActions)
			for _i_ = 1 to _nLen_
				@aAudit + [ _i_, "refused", @aActions[_i_][1], @aActions[_i_][2],
					_cActor_, _cWhy_ + " -- expression is free; admission is governed" ]
			next
			return 0
		ok
		_nDone_ = 0
		_bRestarted_ = 0
		_nLen_ = ring_len(@aActions)
		for _i_ = 1 to _nLen_
			_cK_ = @aActions[_i_][1]
			_cTag_ = @aActions[_i_][2]
			if _cK_ = "scaleup"
				poTarget.ScaleUp(_cTag_)
			but _cK_ = "scaledown"
				poTarget.ScaleDown(_cTag_)
			else
				# heal ALL dead in one pass; a second :RestartDead in the
				# same plan is already satisfied
				if NOT _bRestarted_
					poTarget.RestartDead()
					_bRestarted_ = 1
				ok
			ok
			@aAudit + [ _i_, "committed", _cK_, _cTag_, _cActor_,
				@aActions[_i_][3] ]
			_nDone_++
		next
		@bExecuted = 1
		return _nDone_

	def WasExecuted()
		return @bExecuted

	def AuditTrail()
		return @aAudit

	def RefusedCount()
		return This._CountVerdict("refused")

	def CommittedCount()
		return This._CountVerdict("committed")

	# -- Legibility -----------------------------------------------

	def Explain()
		_aL_ = []
		_aL_ + ("Perf plan " + @cName + " -- " + ring_len(@aActions) + " proposed action(s).")
		_nLen_ = ring_len(@aActions)
		for _i_ = 1 to _nLen_
			_aL_ + ("  " + _i_ + ". " + @aActions[_i_][1] + " '" + @aActions[_i_][2] +
				"' -- " + @aActions[_i_][3])
		next
		_nA_ = ring_len(@aAudit)
		if _nA_ > 0
			_aL_ + ("Audit (" + _nA_ + "):")
			for _i_ = 1 to _nA_
				_aL_ + ("  #" + @aAudit[_i_][1] + " " + StzUpper(@aAudit[_i_][2]) + " " +
					@aAudit[_i_][3] + " '" + @aAudit[_i_][4] + "' by " + @aAudit[_i_][5] +
					" -- " + @aAudit[_i_][6])
			next
		ok
		return _aL_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	# -- Internals ------------------------------------------------

	def _CountVerdict(pcVerdict)
		_n_ = 0
		_nLen_ = ring_len(@aAudit)
		for _i_ = 1 to _nLen_
			if @aAudit[_i_][2] = pcVerdict
				_n_++
			ok
		next
		return _n_
