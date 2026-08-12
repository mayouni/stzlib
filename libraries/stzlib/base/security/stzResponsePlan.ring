/*
	stzResponsePlan -- containment as a GOVERNED act (incident I6).

	The last verb of the pipeline -- Witness, Detect, Reconstruct,
	CONTAIN, Attest -- is the only one that touches reality: revoking
	a session, locking an account, rotating a secret, shedding a
	source. In this library nothing touches reality casually:

	    "Expression is free; admission is governed."

	So containment is a plan. Anyone -- including an inference-only
	agent that just finished the investigation -- may compose it,
	explain it, and hand it over. Only an EFFECTFUL, non-sandboxed
	actor may commit it, and every outcome is audited:

		oPlan = StzResponsePlan("contain-INC-1")
		oPlan.ProposeForIncident(oIncident)     # the machine proposes
		? oPlan.MayCommit(oLlmActor)            #--> FALSE, always
		oPlan.ExecuteOn(oResponder, oHumanActor)

	THE CLOSED CATALOG (each maps to one verb the responder must
	answer):

	  :RevokeSession    -> RevokeSession(target)
	  :LockAccount      -> LockAccount(target)
	  :RotateSecret     -> RotateSecret(target)
	  :RevokeCapability -> RevokeCapability(target)
	  :ShedSource       -> ShedSource(target)
	  :QuarantinePart   -> QuarantinePart(target)

	A RESPONDER is any object answering those verbs -- a double in
	rehearsal (the service-virtualization pattern), or a thin adapter
	over the real classes: stzAuth already knows how to revoke
	sessions and lock accounts, stzSecretStore how to rotate, the
	rate limiter how to shed. Deliberately NOT auto-wired here: which
	object owns which action is an application's decision, and a
	containment plan that guesses is worse than one that asks.

	EVERY COMMITTED ACTION IS ALSO AN EVENT (response.action.committed
	/ .refused), so the ledger carries the response beside the attack
	and the chain covers both. No detection watches those kinds, so
	recording them cannot feed itself.

	The consequence the whole plan was built for: an LLMActor holds
	`inference` only, so `MayCommit` is 0 for it -- structurally,
	not by policy. It can investigate, narrate, and propose the exact
	containment it is unable to perform.
*/

func StzResponsePlan(pcName)
	return new stzResponsePlan(pcName)

func StzResponseActions()
	return [ "revokesession", "lockaccount", "rotatesecret",
		 "revokecapability", "shedsource", "quarantinepart" ]

class stzResponsePlan from stzObject

	@cName = ""
	@aActions = []		# [ kind(lower), target, rationale ]
	@aAudit = []		# [ n, verdict, kind, target, actor, why ]
	@bExecuted = 0

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	  #-- proposing (expression is free) -------------------------------

	def Propose(pcAction, pcTarget, pcRationale)
		_cK_ = StzLower(ring_trim("" + pcAction))
		if ring_find(StzResponseActions(), _cK_) = 0
			stzraise("stzResponsePlan: unknown action ':" + _cK_ + "'. The catalog is closed: " +
				":RevokeSession, :LockAccount, :RotateSecret, :RevokeCapability, " +
				":ShedSource, :QuarantinePart.")
		ok
		@aActions + [ _cK_, "" + pcTarget, "" + pcRationale ]
		return This

	# Derive a containment from what an incident actually holds -- the
	# actor it names, the secrets it implicates, the origin it came
	# from. THE MACHINE PROPOSES: this method invents nothing that is
	# not in the incident, and commits nothing at all.
	def ProposeForIncident(poIncident)
		_cWhy_ = "incident " + poIncident.Id() + ": " + poIncident.Message()
		_cActor_ = poIncident.Actor()
		if _cActor_ != ""
			This.Propose(:LockAccount, _cActor_, _cWhy_)
			This.Propose(:RevokeSession, _cActor_, _cWhy_)
			if poIncident.ReachesEffectful()
				This.Propose(:RevokeCapability, _cActor_,
					_cWhy_ + " -- and this actor can reach an effectful capability")
			ok
		ok
		_aSec_ = poIncident.SecretsInvolved()
		_nS_ = ring_len(_aSec_)
		for _i_ = 1 to _nS_
			This.Propose(:RotateSecret, _aSec_[_i_],
				_cWhy_ + " -- the secret was reached for")
		next
		return This

	def Actions()
		return @aActions

	def NumberOfActions()
		return ring_len(@aActions)

	  #-- preflight -----------------------------------------------------

	# Answered BEFORE any attempt: admission demands the effectful
	# capability, and a sandboxed posture never crosses.
	def MayCommit(poActor)
		if NOT poActor.IsEffectful()
			return 0
		ok
		if StzLower("" + poActor.Posture()) = "sandboxed"
			return 0
		ok
		return 1

	def WhyNot(poActor)
		if NOT poActor.IsEffectful()
			return "actor '" + poActor.Name() + "' is not effectful -- it may propose, not commit"
		ok
		if StzLower("" + poActor.Posture()) = "sandboxed"
			return "actor '" + poActor.Name() + "' is sandboxed -- nothing sandboxed crosses into reality"
		ok
		return ""

	  #-- the crossing (admission is governed) --------------------------

	# Apply the plan to a responder. Returns the number of actions
	# committed; 0 with a full refusal audit when the actor may not.
	def ExecuteOn(poResponder, poActor)
		_cActor_ = "" + poActor.Name()
		if NOT This.MayCommit(poActor)
			_cWhy_ = This.WhyNot(poActor)
			_nLen_ = ring_len(@aActions)
			for _i_ = 1 to _nLen_
				@aAudit + [ _i_, "refused", @aActions[_i_][1], @aActions[_i_][2],
					_cActor_, _cWhy_ + " -- expression is free; admission is governed" ]
				StzNoteRefusal("response.action.refused", _cActor_,
					@aActions[_i_][1] + ":" + @aActions[_i_][2], _cWhy_)
			next
			return 0
		ok
		_nDone_ = 0
		_nLen_ = ring_len(@aActions)
		for _i_ = 1 to _nLen_
			_cK_ = @aActions[_i_][1]
			_cT_ = @aActions[_i_][2]
			This._Apply(poResponder, _cK_, _cT_)
			@aAudit + [ _i_, "committed", _cK_, _cT_, _cActor_, @aActions[_i_][3] ]
			StzNoteGrant("response.action.committed", _cActor_, _cK_ + ":" + _cT_)
			_nDone_++
		next
		@bExecuted = 1
		return _nDone_

	def WasExecuted()
		return @bExecuted

	def AuditTrail()
		return @aAudit

	def CommittedCount()
		return This._CountVerdict("committed")

	def RefusedCount()
		return This._CountVerdict("refused")

	  #-- legibility ----------------------------------------------------

	def Explain()
		_aL_ = []
		_aL_ + ("Response plan " + @cName + " -- " + ring_len(@aActions) + " proposed action(s).")
		_nLen_ = ring_len(@aActions)
		for _i_ = 1 to _nLen_
			_aL_ + ("  " + _i_ + ". " + @aActions[_i_][1] + " '" + @aActions[_i_][2] + "'")
			_aL_ + ("     because " + @aActions[_i_][3])
		next
		_nA_ = ring_len(@aAudit)
		if _nA_ > 0
			_aL_ + ("Audit (" + _nA_ + "):")
			for _i_ = 1 to _nA_
				_aL_ + ("  #" + @aAudit[_i_][1] + " " + StzUpper(@aAudit[_i_][2]) + " " +
					@aAudit[_i_][3] + " '" + @aAudit[_i_][4] + "' by " + @aAudit[_i_][5])
			next
		ok
		return _aL_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	  #-- internals -----------------------------------------------------

	def _Apply(poResponder, pcKind, pcTarget)
		if pcKind = "revokesession"
			poResponder.RevokeSession(pcTarget)
		but pcKind = "lockaccount"
			poResponder.LockAccount(pcTarget)
		but pcKind = "rotatesecret"
			poResponder.RotateSecret(pcTarget)
		but pcKind = "revokecapability"
			poResponder.RevokeCapability(pcTarget)
		but pcKind = "shedsource"
			poResponder.ShedSource(pcTarget)
		else
			poResponder.QuarantinePart(pcTarget)
		ok

	def _CountVerdict(pcVerdict)
		_n_ = 0
		_nLen_ = ring_len(@aAudit)
		for _i_ = 1 to _nLen_
			if @aAudit[_i_][2] = pcVerdict
				_n_++
			ok
		next
		return _n_
