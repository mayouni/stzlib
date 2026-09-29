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

# THE FIRST REAL RESPONDER: stzAuth answers :LockAccount and
# :RevokeSession for real. It holds a REFERENCE to the caller's stzAuth
# (object2pointer), never a copy -- Ring copies an object it stores, and a
# copy of an auth with a memory store would lock an account nobody logs in
# through. Keep the stzAuth alive while the responder is in use.
func StzAuthResponder(poAuth)
	return new stzAuthResponder(poAuth)

# THE SECOND REAL RESPONDER: a secret store answers :RotateSecret for
# real (RotateToFresh), acting as poActor, the service identity allowed to
# create credentials. Held by reference, like the auth responder.
func StzSecretStoreResponder(poStore, poActor)
	return new stzSecretStoreResponder(poStore, poActor)

# ONE PLAN, SEVERAL OWNERS: a plan may lock an account AND rotate a secret,
# and no single object owns both. A responder set routes each verb to the
# first member that OWNS it (answers Owns(verb)); a verb no member owns is
# REFUSED, loudly -- a plan is never half-performed in silence.
func StzResponderSet(paResponders)
	return new stzResponderSet(paResponders)

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
		# PREFLIGHT: a responder that can say what it OWNS is asked about every
		# action BEFORE any is committed. A plan with an action nobody owns is
		# refused WHOLE -- never half-performed, leaving half an incident contained.
		if ismethod(poResponder, "owns")
			_nLen_ = ring_len(@aActions)
			for _i_ = 1 to _nLen_
				if NOT poResponder.Owns(@aActions[_i_][1])
					_cWhy_ = "no responder owns :" + @aActions[_i_][1] + " -- the plan was refused whole, nothing was committed"
					for _j_ = 1 to _nLen_
						@aAudit + [ _j_, "refused", @aActions[_j_][1], @aActions[_j_][2], _cActor_, _cWhy_ ]
						StzNoteRefusal("response.action.refused", _cActor_,
							@aActions[_j_][1] + ":" + @aActions[_j_][2], _cWhy_)
					next
					return 0
				ok
			next
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

  #=========================================================#
 #  stzAuthResponder -- containment over a real stzAuth     #
#=========================================================#

class stzAuthResponder from stzObject

	@pAuth = ""

	def init(poAuth)
		@pAuth = object2pointer(poAuth)

	def _Auth()
		return pointer2object(@pAuth)

	def Owns(pcVerb)
		return ring_find([ "lockaccount", "revokesession" ], StzLower("" + pcVerb)) > 0

	# The account is closed: every login path and every live session refuse.
	def LockAccount(pcTarget)
		This._Auth().LockAccount("" + pcTarget, "locked by a containment plan")

	# The plan targets an ACTOR, so every session of that user ends.
	def RevokeSession(pcTarget)
		This._Auth().RevokeAllSessions("" + pcTarget)

	# Not this responder's to perform: authentication owns accounts and
	# sessions, nothing else. A plan that proposes these needs another
	# responder -- refused loudly, never pretended.
	def RotateSecret(pcTarget)
		stzraise("stzAuthResponder cannot :RotateSecret '" + pcTarget + "' -- wire a secret-store responder.")

	def RevokeCapability(pcTarget)
		stzraise("stzAuthResponder cannot :RevokeCapability '" + pcTarget + "' -- wire a capability responder.")

	def ShedSource(pcTarget)
		stzraise("stzAuthResponder cannot :ShedSource '" + pcTarget + "' -- wire a rate-limiter responder.")

	def QuarantinePart(pcTarget)
		stzraise("stzAuthResponder cannot :QuarantinePart '" + pcTarget + "' -- wire a quarantine responder.")

  #=========================================================#
 #  stzSecretStoreResponder -- :RotateSecret, for real       #
#=========================================================#

class stzSecretStoreResponder from stzObject

	@pStore = ""
	@oActor = ""

	def init(poStore, poActor)
		@pStore = object2pointer(poStore)
		@oActor = poActor

	def Owns(pcVerb)
		return StzLower("" + pcVerb) = "rotatesecret"

	# the target is the secret's NAME, as the incident names it
	def RotateSecret(pcTarget)
		_c_ = "" + pcTarget
		if StzLeft(StzLower(_c_), 7) = "secret:"
			_c_ = StzMidToEnd(_c_, 8)
		ok
		pointer2object(@pStore).RotateToFresh(_c_, @oActor)

	def LockAccount(pcTarget)
		stzraise("stzSecretStoreResponder cannot :LockAccount -- wire an auth responder.")

	def RevokeSession(pcTarget)
		stzraise("stzSecretStoreResponder cannot :RevokeSession -- wire an auth responder.")

	def RevokeCapability(pcTarget)
		stzraise("stzSecretStoreResponder cannot :RevokeCapability -- wire a capability responder.")

	def ShedSource(pcTarget)
		stzraise("stzSecretStoreResponder cannot :ShedSource -- wire a rate-limiter responder.")

	def QuarantinePart(pcTarget)
		stzraise("stzSecretStoreResponder cannot :QuarantinePart -- wire a quarantine responder.")


  #=========================================================#
 #  stzResponderSet -- each verb to the member that owns it  #
#=========================================================#

class stzResponderSet from stzObject

	@aMembers = []	# object2pointer of each responder

	def init(paResponders)
		@aMembers = []
		_n_ = len(paResponders)
		for _i_ = 1 to _n_
			@aMembers + object2pointer(paResponders[_i_])
		next

	def Owns(pcVerb)
		return This._OwnerOf(pcVerb) > 0

	def _OwnerOf(pcVerb)
		_n_ = len(@aMembers)
		for _i_ = 1 to _n_
			if pointer2object(@aMembers[_i_]).Owns(pcVerb)
				return _i_
			ok
		next
		return 0

	def _Route(pcVerb)
		_i_ = This._OwnerOf(pcVerb)
		if _i_ = 0
			stzraise("No responder in this set owns :" + pcVerb + " -- the plan cannot be performed in full.")
		ok
		return pointer2object(@aMembers[_i_])

	def LockAccount(pcTarget)
		This._Route("lockaccount").LockAccount(pcTarget)

	def RevokeSession(pcTarget)
		This._Route("revokesession").RevokeSession(pcTarget)

	def RotateSecret(pcTarget)
		This._Route("rotatesecret").RotateSecret(pcTarget)

	def RevokeCapability(pcTarget)
		This._Route("revokecapability").RevokeCapability(pcTarget)

	def ShedSource(pcTarget)
		This._Route("shedsource").ShedSource(pcTarget)

	def QuarantinePart(pcTarget)
		This._Route("quarantinepart").QuarantinePart(pcTarget)
