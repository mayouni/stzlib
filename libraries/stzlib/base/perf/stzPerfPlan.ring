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

# Holds a performance tuning plan as proposed actions that only an effectful actor may commit, with every outcome audited.
#
# Optimization crosses reality: scaling a fleet, draining workers, healing the dead. Expression is
# free and admission is governed. The plan's catalog is closed: ScaleUp, ScaleDown and RestartDead,
# each mapping to one verb on the target. An actor whose effects are empty, such as an inference-
# only LLMActor, can build the plan, explain it and hand it over, but ExecuteOn refuses it wholesale
# and audits each refusal; a HumanActor commits. MayCommit answers admissibility before any attempt.
# The audit trail holds [ n, verdict, action, tag, actor, why ] for every outcome, so refusals are
# never silent.
#
#   receiver   o1 = StzPerfPlan("relieve-nlp") o1.Propose(:ScaleUp, "nlp", "measured load 0.92 >
#              high-water 0.75") o1.Propose(:RestartDead, "nlp", "2 dead workers") oAdvisor =
#              LLMActor("advisor") oChief = HumanActor("mansour")
#   example    ? o1.NumberOfActions()
#              #--> 2
#              ? o1.Actions()[1][1]
#              #--> scaleup
#              ? o1.MayCommit(oAdvisor)
#              #--> 0
#              ? o1.MayCommit(oChief)
#              #--> 1
#              ? o1.WasExecuted()
#              #--> 0
#              ? o1.Explain()[1]
#              #--> Perf plan relieve-nlp -- 2 proposed action(s).
#   see        stzAppCluster, stzSla, stzPerfSentinel
class stzPerfPlan from stzObject

	@cName = ""
	@aActions = []		# [ kind(lower), tag, rationale ]
	@aAudit = []		# [ n, verdict, kind, tag, actor, why ]
	@bExecuted = 0

	# Builds an empty plan of tuning actions under a name.
	#
	#   pcName     the name of the plan
	#   returns    nothing; the object is built
	#   note       StzPerfPlan builds the same object; building and explaining a plan is free, only
	#              committing it is governed
	#   see        Propose, ExecuteOn
	def init(pcName)
		@cName = "" + pcName

	# Returns the name the plan was built with.
	#
	#   returns    the name as text
	#   see        Explain
	def Name()
		return @cName

	# Adds one action to the plan, with the reason for it; nothing is executed.
	#
	#   pcAction      ScaleUp, ScaleDown or RestartDead, in any letter case
	#   pcTag         the tag of the part of the fleet it concerns, kept in lower case
	#   pcRationale   why, as a sentence, kept in the audit
	#   returns       the plan itself, so calls chain
	#   note          the action is stored in lower case, such as scaleup
	#   warning       an action outside the closed catalog, such as Reboot, raises error
	#                 stzPerfPlan: unknown action ... The catalog is closed
	#   see           Actions, ExecuteOn
	#@ aka  -- Proposing (expression is free) ---------------------------
	def Propose(pcAction, pcTag, pcRationale)
		_cK_ = StzLower("" + pcAction)
		if _cK_ != "scaleup" and _cK_ != "scaledown" and _cK_ != "restartdead"
			stzraise("stzPerfPlan: unknown action ':" + _cK_ + "'. The catalog is closed: " +
				":ScaleUp, :ScaleDown, :RestartDead.")
		ok
		@aActions + [ _cK_, StzLower("" + pcTag), "" + pcRationale ]
		return This

	# Returns the proposed actions in order.
	#
	#   returns    a list of [ action, tag, rationale ]
	#   see        Propose, NumberOfActions
	def Actions()
		return @aActions

	# Returns how many actions the plan holds.
	#
	#   returns    a number
	#   see        Actions, Propose
	def NumberOfActions()
		return ring_len(@aActions)

	# TRUE if an actor is admitted to commit the plan, asked before any attempt.
	#
	#   poActor    the actor, such as LLMActor or HumanActor
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       an actor that is not effectful, or whose posture is sandboxed, is refused, so an
	#              inference-only advisor may build and explain a plan but never commit it
	#   see        ExecuteOn, AuditTrail
	#@ aka  -- Preflight ------------------------------------------------
	def MayCommit(poActor)
		if NOT poActor.IsEffectful()
			return 0
		ok
		if StzLower("" + poActor.Posture()) = "sandboxed"
			return 0
		ok
		return 1

	# Applies the plan to a target when the actor may commit it, and audits every action as committed or refused.
	#
	#   poTarget   a stzAppCluster or any object answering ScaleUp(tag), ScaleDown(tag) and
	#              RestartDead()
	#   poActor    the actor asking to commit
	#   returns    the number of actions committed; 0 when the actor was refused, with one refused
	#              line for each action in the audit
	#   note       a RestartDead heals every dead worker in one call, and a second RestartDead in
	#              the same plan is counted as committed without calling the target again; refused
	#              attempts stay in the trail beside later committed ones
	#   see        MayCommit, AuditTrail, WasExecuted
	#@ aka  -- The crossing (admission is governed) ---------------------
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

	# TRUE if the plan was committed at least once.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a refusal does not set it
	#   see        ExecuteOn, CommittedCount
	def WasExecuted()
		return @bExecuted

	# Returns every outcome so far, refusals included.
	#
	#   returns    a list of [ n, verdict, action, tag, actor name, why ], verdict being committed
	#              or refused, n the action's position in the plan; [ ] before any attempt
	#   note       a refusal says the actor is not effectful or sandboxed and that expression is
	#              free while admission is governed
	#   see        RefusedCount, CommittedCount
	def AuditTrail()
		return @aAudit

	# Returns how many audit lines are refusals.
	#
	#   returns    a number
	#   note       an attempt by a refused actor adds one for each action in the plan
	#   see        CommittedCount, AuditTrail
	def RefusedCount()
		return This._CountVerdict("refused")

	# Returns how many audit lines are commits.
	#
	#   returns    a number
	#   see        RefusedCount, AuditTrail
	def CommittedCount()
		return This._CountVerdict("committed")

	# Returns the plan as lines of text: a header, each proposed action with its reason, then the audit if there is one.
	#
	#   returns    a list of text lines
	#   see        Show, AuditTrail
	#@ aka  -- Legibility -----------------------------------------------
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

	# Prints the explanation to the console, one line per line.
	#
	#   returns    nothing
	#   note       it prints with the ? statement
	#   see        Explain
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
