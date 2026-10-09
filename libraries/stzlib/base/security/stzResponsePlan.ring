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

# THE THIRD REAL RESPONDER: :RevokeCapability cuts the actor's paths to
# 'effectful' in the security graph AND revokes the kind from every live
# stzSystemActor registered under that name -- the graph is what audits and
# incidents ask, the live actor is what the runtime gates ask.
#
# Register live actors ONE AT A TIME with AddLiveActor(oActor): an object
# passed as an ARGUMENT arrives by reference, while an object placed in a
# list literal ([ oA, oB ]) is COPIED -- and revoking a copy changes nothing.
func StzCapabilityResponder(poSecurityGraph)
	return new stzCapabilityResponder(poSecurityGraph)

# THE FOURTH REAL RESPONDER: :ShedSource BLOCKS the source (a client ip, a
# caller, a key) at the rate limiter the application admits requests
# through -- for pnBlockMs milliseconds, or until Unblock when 0.
func StzRateLimiterResponder(poLimiter, pnBlockMs)
	return new stzRateLimiterResponder(poLimiter, pnBlockMs)

# THE FIFTH REAL RESPONDER: :QuarantinePart stops an agent the host
# supervises, keeps the reason, and refuses Resume() until an effectful
# actor Releases it. The "part" is the agent's name as the host knows it.
func StzAgentHostResponder(poHost)
	return new stzAgentHostResponder(poHost)

# ONE PLAN, SEVERAL OWNERS: a plan may lock an account AND rotate a secret,
# and no single object owns both. A responder set routes each verb to the
# first member that OWNS it (answers Owns(verb)); a verb no member owns is
# REFUSED, loudly -- a plan is never half-performed in silence.
#
# The list form copies the responders it is given (Ring copies objects in a
# list literal): harmless for a responder whose state lives behind a
# reference, wrong for one you want to read afterwards (LastCut). For those,
# build the set with Add(oResponder), which keeps the object itself.
func StzResponderSet(paResponders)
	return new stzResponderSet(paResponders)

func StzResponseActions()
	return [ "revokesession", "lockaccount", "rotatesecret",
		 "revokecapability", "shedsource", "quarantinepart" ]

# Holds a containment plan: a list of actions anyone may propose and only an effectful, non-sandboxed actor may commit.
#
# Containment is the only step that touches reality, so it is a plan. Expression is free: any actor,
# a language-model agent included, may compose it with Propose or derive it from an incident with
# ProposeForIncident. Admission is governed: ExecuteOn performs the actions on a responder only for
# an actor MayCommit admits, and audits every outcome, committed or refused, in the plan and in the
# security ledger. The catalog is closed to RevokeSession, LockAccount, RotateSecret,
# RevokeCapability, ShedSource and QuarantinePart. The responder is any object that answers those
# verbs: rehearse on a double, or on a responder over in-memory objects. Never point a plan at the
# real machine to try it.
#
#   receiver   o1 = new stzResponsePlan("contain-1")
#   example    o1.Propose(:LockAccount, "mallory", "stolen credentials")
#              o1.Propose(:RotateSecret, "signing-key", "read by the intruder")
#              ? o1.NumberOfActions()
#              #--> 2
#              ? o1.MayCommit(LLMActor("advisor"))
#              #--> 0
#              ? o1.MayCommit(HumanActor("oncall"))
#              #--> 1
#   see        stzResponderSet, stzSecretStoreResponder, stzCapabilityResponder, stzIncident,
#              StzResponsePlan
class stzResponsePlan from stzObject

	@cName = ""
	@aActions = []		# [ kind(lower), target, rationale ]
	@aAudit = []		# [ n, verdict, kind, target, actor, why ]
	@bExecuted = 0

	# Builds an empty containment plan with a name, to be proposed into and committed by an effectful actor.
	#
	#   pcName     the name of the plan, such as the incident it answers
	#   returns    nothing; the plan is built
	#   see        Propose, ExecuteOn
	def init(pcName)
		@cName = "" + pcName

	# Returns the name the plan was built with.
	#
	#   returns    a text
	#   see        init
	def Name()
		return @cName

	# Adds one containment action to the plan; the action is only recorded, nothing is performed.
	#
	#   pcAction      the kind of action, one of :RevokeSession, :LockAccount, :RotateSecret,
	#                 :RevokeCapability, :ShedSource, :QuarantinePart
	#   pcTarget      what the action is about, such as an account, a secret name or an address
	#   pcRationale   the reason, kept with the action in the audit
	#   returns       the plan itself, so calls chain
	#   note          the kind is folded to lower case
	#   warning       an action outside the closed catalog raises an error that lists the catalog
	#   see           ProposeForIncident, Actions, ExecuteOn
	#@ aka  -- proposing (expression is free) -------------------------------
	def Propose(pcAction, pcTarget, pcRationale)
		_cK_ = StzLower(ring_trim("" + pcAction))
		if ring_find(StzResponseActions(), _cK_) = 0
			stzraise("stzResponsePlan: unknown action ':" + _cK_ + "'. The catalog is closed: " +
				":RevokeSession, :LockAccount, :RotateSecret, :RevokeCapability, " +
				":ShedSource, :QuarantinePart.")
		ok
		@aActions + [ _cK_, "" + pcTarget, "" + pcRationale ]
		return This

	# Adds the actions an incident calls for: lock and revoke for its actor, a rotation per secret it implicates.
	#
	#   poIncident   the stzIncident to read
	#   returns      the plan itself, so calls chain
	#   note         it only proposes; the actions are performed by ExecuteOn
	#   see          Propose, Actions, MayCommit
	#@ aka  Derive a containment from what an incident actually holds -- the actor it names, the secrets it implicates, the origin it came from. THE MACHINE PROPOSES: this method invents nothing that is not in the incident, and commits nothing at all.
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

	# Returns the proposed actions, in the order proposed.
	#
	#   returns    a list of [ kind, target, rationale ] rows, the kind in lower case
	#   see        Propose, NumberOfActions
	def Actions()
		return @aActions

	# Returns how many actions the plan holds.
	#
	#   returns    a number
	#   see        Actions, Propose
	def NumberOfActions()
		return ring_len(@aActions)

	# TRUE if the actor may commit a plan: it must be effectful and not sandboxed.
	#
	#   poActor    the actor asking to commit
	#   returns    TRUE or FALSE; always FALSE for a language-model actor
	#   note       answered before any attempt, and nothing is audited
	#   see        WhyNot, ExecuteOn
	#@ aka  -- preflight -----------------------------------------------------
	def MayCommit(poActor)
		if NOT poActor.IsEffectful()
			return 0
		ok
		if StzLower("" + poActor.Posture()) = "sandboxed"
			return 0
		ok
		return 1

	# Returns the reason an actor may not commit, in words.
	#
	#   poActor    the actor to explain
	#   returns    a text; an empty text when the actor may commit
	#   see        MayCommit, ExecuteOn
	def WhyNot(poActor)
		if NOT poActor.IsEffectful()
			return "actor '" + poActor.Name() + "' is not effectful -- it may propose, not commit"
		ok
		if StzLower("" + poActor.Posture()) = "sandboxed"
			return "actor '" + poActor.Name() + "' is sandboxed -- nothing sandboxed crosses into reality"
		ok
		return ""

	# Performs the actions on a responder when the actor may commit, auditing each; otherwise performs none and audits refusals.
	#
	#   poResponder   the object that answers the six verbs, a rehearsal double or a responder over
	#                 in-memory objects
	#   poActor       the actor committing, effectful and not sandboxed
	#   returns       the number of actions committed; 0 when the actor may not, or when no
	#                 responder owns an action
	#   note          each outcome also reaches the security ledger as response.action.committed or
	#                 response.action.refused
	#   warning       a responder that answers Owns is asked about every action first, and one
	#                 action nobody owns refuses the whole plan before any is performed; a plan
	#                 executed twice performs its actions twice
	#   see           MayCommit, AuditTrail, StzResponderSet
	#@ aka  -- the crossing (admission is governed) --------------------------
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

	# TRUE if a commit has gone through for this plan.
	#
	#   returns    TRUE or FALSE
	#   note       a refused attempt does not set it
	#   see        ExecuteOn, CommittedCount
	def WasExecuted()
		return @bExecuted

	# Returns every outcome recorded, committed and refused alike, in the order they happened.
	#
	#   returns    a list of [ number, verdict, kind, target, actor, why ] rows
	#   see        CommittedCount, RefusedCount, ExecuteOn
	def AuditTrail()
		return @aAudit

	# Returns how many actions were committed over the life of the plan.
	#
	#   returns    a number
	#   see        RefusedCount, AuditTrail
	def CommittedCount()
		return This._CountVerdict("committed")

	# Returns how many actions were refused over the life of the plan, a signal worth watching.
	#
	#   returns    a number
	#   see        CommittedCount, AuditTrail
	def RefusedCount()
		return This._CountVerdict("refused")

	# Returns the plan as lines of text: each proposed action with its reason, then the audit.
	#
	#   returns    a list of text lines
	#   see        Show, AuditTrail
	#@ aka  -- legibility ----------------------------------------------------
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

	# Prints the lines of the plan.
	#
	#   returns    nothing; it prints
	#   see        Explain
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

# Performs the :RotateSecret action of a response plan by replacing a secret of a stzSecretStore with fresh random bytes.
#
# It holds the store by reference, not a copy, so the caller's store sees the new value, and it
# rotates as the service identity it is given, which must be effectful and not sandboxed. Only a
# secret the store owns can be rotated; one read from an environment variable, a file or a vault
# raises an error naming where to rotate it. It answers no other verb: each of those raises an error
# that names the responder to wire. A value is never printed.
#
#   receiver   oStore = StzSecretStoreQ("billing"); oStore.Register(StzApiKeyQ("signing-
#              key").FromLiteralQ("old-invented-value")); o1 = new stzSecretStoreResponder(oStore,
#              HumanActor("secrets-service"))
#   example    o1.RotateSecret("signing-key")
#              ? oStore.Reveal("signing-key", HumanActor("oncall")) != "old-invented-value"
#              #--> 1
#              ? o1.Owns("lockaccount")
#              #--> 0
#   see        stzResponsePlan, stzResponderSet, stzSecretStore, StzSecretStoreResponder
class stzSecretStoreResponder from stzObject

	@pStore = ""
	@oActor = ""

	# Builds a responder that rotates secrets in a secret store, holding the store by reference.
	#
	#   poStore    the stzSecretStore whose secrets are rotated, held by reference
	#   poActor    the service identity allowed to create credentials
	#   returns    nothing; the responder is built
	#   see        RotateSecret, Owns
	def init(poStore, poActor)
		@pStore = object2pointer(poStore)
		@oActor = poActor

	# TRUE if the verb is :RotateSecret, the only one this responder answers.
	#
	#   pcVerb     the verb, matched without regard to case
	#   returns    TRUE or FALSE
	#   see        RotateSecret
	def Owns(pcVerb)
		return StzLower("" + pcVerb) = "rotatesecret"

	# Replaces the value of a secret the store owns with fresh random bytes, keeping its name and kind.
	#
	#   pcTarget   the secret name, or the form secret:name an incident uses
	#   returns    nothing
	#   note       the access log gets a rotated entry; no value is returned or printed
	#   warning    raises an error for an unknown name, and for a secret read from an environment
	#              variable, a file or a vault, which the store cannot rotate
	#   see        Owns
	#@ aka  the target is the secret's NAME, as the incident names it
	def RotateSecret(pcTarget)
		_c_ = "" + pcTarget
		if StzLeft(StzLower(_c_), 7) = "secret:"
			_c_ = StzMidToEnd(_c_, 8)
		ok
		pointer2object(@pStore).RotateToFresh(_c_, @oActor)

	# Refuses by raising an error that names the responder to wire, because this responder does not lock accounts.
	#
	#   pcTarget   the account the plan named
	#   returns    nothing; it always raises
	#   warning    raises an error whatever the target
	#   see        Owns
	def LockAccount(pcTarget)
		stzraise("stzSecretStoreResponder cannot :LockAccount -- wire an auth responder.")

	# Refuses by raising an error that names the responder to wire, because this responder does not revoke sessions.
	#
	#   pcTarget   the actor the plan named
	#   returns    nothing; it always raises
	#   warning    raises an error whatever the target
	#   see        Owns
	def RevokeSession(pcTarget)
		stzraise("stzSecretStoreResponder cannot :RevokeSession -- wire an auth responder.")

	# Refuses by raising an error that names the responder to wire, because this responder does not revoke capabilities.
	#
	#   pcTarget   the actor the plan named
	#   returns    nothing; it always raises
	#   warning    raises an error whatever the target
	#   see        Owns
	def RevokeCapability(pcTarget)
		stzraise("stzSecretStoreResponder cannot :RevokeCapability -- wire a capability responder.")

	# Refuses by raising an error that names the responder to wire, because this responder does not block sources.
	#
	#   pcTarget   the source the plan named
	#   returns    nothing; it always raises
	#   warning    raises an error whatever the target
	#   see        Owns
	def ShedSource(pcTarget)
		stzraise("stzSecretStoreResponder cannot :ShedSource -- wire a rate-limiter responder.")

	# Refuses by raising an error that names the responder to wire, because this responder does not quarantine parts.
	#
	#   pcTarget   the part the plan named
	#   returns    nothing; it always raises
	#   warning    raises an error whatever the target
	#   see        Owns
	def QuarantinePart(pcTarget)
		stzraise("stzSecretStoreResponder cannot :QuarantinePart -- wire a quarantine responder.")


  #=========================================================#
 #  stzResponderSet -- each verb to the member that owns it  #
#=========================================================#

# Routes each verb of a response plan to the first responder in the set that owns it, so one plan can have several owners.
#
# A plan may lock an account and rotate a secret, and no single object owns both. The set asks each
# member Owns for the verb and passes the call to the first that says yes; a verb no member owns
# raises an error, and a plan that holds such an action is refused whole by ExecuteOn before
# anything is performed. The list given to the constructor copies its objects, which is harmless for
# a responder that holds its target by reference and wrong for one you want to read afterwards;
# build the set with Add to keep the object itself.
#
#   receiver   oAuth = new stzAuth(); oAuth.Register("mallory", "pw-invented-1"); o1 = new
#              stzResponderSet([ ])
#   example    o1.Add(StzAuthResponder(oAuth))
#              ? o1.Owns("lockaccount")
#              #--> 1
#              ? o1.Owns("rotatesecret")
#              #--> 0
#              o1.LockAccount("mallory")
#              ? oAuth.IsAccountLocked("mallory")
#              #--> 1
#   see        stzResponsePlan, stzSecretStoreResponder, stzCapabilityResponder, StzResponderSet
class stzResponderSet from stzObject

	@aMembers = []	# object2pointer of each responder

	# Builds a set of responders, each reached by reference, so one plan can span several owners.
	#
	#   paResponders   a list of responders
	#   returns        nothing; the set is built
	#   see            Add, Owns
	def init(paResponders)
		@aMembers = []
		_n_ = len(paResponders)
		for _i_ = 1 to _n_
			@aMembers + object2pointer(paResponders[_i_])
		next

	# Appends one responder to the set, keeping the object itself rather than a copy.
	#
	#   poResponder   the responder to add, an object that answers Owns and the verbs it owns
	#   returns       the set itself, so calls chain
	#   see           Owns, StzResponderSet
	#@ aka  add one responder BY REFERENCE (see StzResponderSet)
	def Add(poResponder)
		@aMembers + object2pointer(poResponder)
		return This

	# TRUE if some member of the set owns the verb.
	#
	#   pcVerb     the verb, such as lockaccount, matched as each member matches it
	#   returns    TRUE or FALSE
	#   see        Add, LockAccount
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

	# Passes an account lock to the first member that owns it; raises an error when no member does.
	#
	#   pcTarget   the account to lock
	#   returns    nothing
	#   warning    an unowned verb raises an error stating that the plan cannot be performed in full
	#   see        Owns, RevokeSession
	def LockAccount(pcTarget)
		This._Route("lockaccount").LockAccount(pcTarget)

	# Passes a session revocation to the first member that owns it; raises an error when no member does.
	#
	#   pcTarget   the actor whose sessions end
	#   returns    nothing
	#   warning    an unowned verb raises an error stating that the plan cannot be performed in full
	#   see        Owns, LockAccount
	def RevokeSession(pcTarget)
		This._Route("revokesession").RevokeSession(pcTarget)

	# Passes a secret rotation to the first member that owns it; raises an error when no member does.
	#
	#   pcTarget   the secret to rotate
	#   returns    nothing
	#   warning    an unowned verb raises an error stating that the plan cannot be performed in full
	#   see        Owns, StzSecretStoreResponder
	def RotateSecret(pcTarget)
		This._Route("rotatesecret").RotateSecret(pcTarget)

	# Passes a capability revocation to the first member that owns it; raises an error when no member does.
	#
	#   pcTarget   the actor whose capability is cut
	#   returns    nothing
	#   warning    an unowned verb raises an error stating that the plan cannot be performed in full
	#   see        Owns, StzCapabilityResponder
	def RevokeCapability(pcTarget)
		This._Route("revokecapability").RevokeCapability(pcTarget)

	# Passes a source block to the first member that owns it; raises an error when no member does.
	#
	#   pcTarget   the source to block
	#   returns    nothing
	#   warning    an unowned verb raises an error stating that the plan cannot be performed in full
	#   see        Owns
	def ShedSource(pcTarget)
		This._Route("shedsource").ShedSource(pcTarget)

	# Passes a quarantine to the first member that owns it; raises an error when no member does.
	#
	#   pcTarget   the part to stop
	#   returns    nothing
	#   warning    an unowned verb raises an error stating that the plan cannot be performed in full
	#   see        Owns
	def QuarantinePart(pcTarget)
		This._Route("quarantinepart").QuarantinePart(pcTarget)

  #=========================================================#
 #  stzCapabilityResponder -- :RevokeCapability, for real    #
#=========================================================#

# Performs the :RevokeCapability action of a response plan by cutting an actor's paths to the effectful capability in a security graph.
#
# The graph is what audits and incidents ask, the live actor is what the runtime gates ask, so the
# responder cuts both: the graph edges, and the effectful kind of each registered live actor of the
# same name. Register live actors one at a time with AddLiveActor, because an object placed in a
# list literal is copied and revoking a copy changes nothing. It answers no other verb: each of
# those raises an error that names the responder to wire. Other actors that use the same tool keep
# their capability.
#
#   receiver   g = StzSecurityGraphQ("prod"); o1 = new stzCapabilityResponder(g)
#   example    g.AddActor("billing-agent", "trusted")
#              g.AddTool("deploy-tool")
#              g.AddCapability("effectful")
#              g.Uses("billing-agent", "deploy-tool")
#              g.Grants("deploy-tool", "effectful")
#              ? g.ReachesEffectful("billing-agent")
#              #--> 1
#              o1.RevokeCapability("billing-agent")
#              ? g.ReachesEffectful("billing-agent")
#              #--> 0
#              ? @@( o1.LastCut() )
#              #--> [ [ "billing-agent", "uses", "deploy-tool" ] ]
#   see        stzResponsePlan, stzResponderSet, stzSecurityGraph, StzCapabilityResponder
class stzCapabilityResponder from stzObject

	@pGraph = ""
	@aActors = []	# object2pointer of each live stzSystemActor
	@aLastCut = []

	# Builds a responder that cuts an actor's capability paths in a security graph, holding the graph by reference.
	#
	#   poSecurityGraph   the stzSecurityGraph whose paths are cut
	#   returns           nothing; the responder is built
	#   see               AddLiveActor, RevokeCapability
	def init(poSecurityGraph)
		@pGraph = object2pointer(poSecurityGraph)
		@aActors = []

	# Registers a live actor whose effectful kind is revoked together with the graph paths, when the plan names it.
	#
	#   poActor    the live actor, passed as an argument one at a time, because an object inside a
	#              list literal is copied and revoking a copy changes nothing
	#   returns    the responder itself, so calls chain
	#   see        RevokeCapability, Owns
	#@ aka  a live actor whose capability kinds this responder may revoke
	def AddLiveActor(poActor)
		@aActors + object2pointer(poActor)
		return This

	# TRUE if the verb is :RevokeCapability, the only one this responder answers.
	#
	#   pcVerb     the verb, matched without regard to case
	#   returns    TRUE or FALSE
	#   see        RevokeCapability
	def Owns(pcVerb)
		return StzLower("" + pcVerb) = "revokecapability"

	# Cuts the actor paths to effectful in the graph and revokes that kind from each registered live actor of the same name.
	#
	#   pcTarget   the actor name, matched without regard to case
	#   returns    nothing; LastCut lists the edges removed
	#   note       other actors that use the same tool keep their capability
	#   warning    an actor with no path to effectful changes nothing and leaves LastCut empty
	#   see        LastCut, AddLiveActor
	#@ aka  the incident proposes this when an actor can REACH 'effectful'
	def RevokeCapability(pcTarget)
		_cA_ = StzLower(ring_trim("" + pcTarget))
		@aLastCut = pointer2object(@pGraph).CutCapability(_cA_, "effectful")
		_n_ = len(@aActors)
		for _i_ = 1 to _n_
			_o_ = pointer2object(@aActors[_i_])
			if StzLower("" + _o_.Name()) = _cA_
				_o_.RevokeKind("effectful")
			ok
		next

	# Returns the graph edges the last revocation removed.
	#
	#   returns    a list of [ from, label, to ] rows; an empty list before any revocation
	#   see        RevokeCapability
	#@ aka  the graph edges the last revocation removed, as [ from, label, to ]
	def LastCut()
		return @aLastCut

	# Refuses by raising an error that names the responder to wire, because this responder does not lock accounts.
	#
	#   pcTarget   the account the plan named
	#   returns    nothing; it always raises
	#   warning    raises an error whatever the target
	#   see        Owns
	def LockAccount(pcTarget)
		stzraise("stzCapabilityResponder cannot :LockAccount -- wire an auth responder.")

	# Refuses by raising an error that names the responder to wire, because this responder does not revoke sessions.
	#
	#   pcTarget   the actor the plan named
	#   returns    nothing; it always raises
	#   warning    raises an error whatever the target
	#   see        Owns
	def RevokeSession(pcTarget)
		stzraise("stzCapabilityResponder cannot :RevokeSession -- wire an auth responder.")

	# Refuses by raising an error that names the responder to wire, because this responder does not rotate secrets.
	#
	#   pcTarget   the secret the plan named
	#   returns    nothing; it always raises
	#   warning    raises an error whatever the target
	#   see        Owns
	def RotateSecret(pcTarget)
		stzraise("stzCapabilityResponder cannot :RotateSecret -- wire a secret-store responder.")

	# Refuses by raising an error that names the responder to wire, because this responder does not block sources.
	#
	#   pcTarget   the source the plan named
	#   returns    nothing; it always raises
	#   warning    raises an error whatever the target
	#   see        Owns
	def ShedSource(pcTarget)
		stzraise("stzCapabilityResponder cannot :ShedSource -- wire a rate-limiter responder.")

	# Refuses by raising an error that names the responder to wire, because this responder does not quarantine parts.
	#
	#   pcTarget   the part the plan named
	#   returns    nothing; it always raises
	#   warning    raises an error whatever the target
	#   see        Owns
	def QuarantinePart(pcTarget)
		stzraise("stzCapabilityResponder cannot :QuarantinePart -- wire a quarantine responder.")


  #=========================================================#
 #  stzRateLimiterResponder -- :ShedSource, for real         #
#=========================================================#

class stzRateLimiterResponder from stzObject

	@pLimiter = ""
	@nBlockMs = 0

	def init(poLimiter, pnBlockMs)
		@pLimiter = object2pointer(poLimiter)
		@nBlockMs = pnBlockMs

	def Owns(pcVerb)
		return StzLower("" + pcVerb) = "shedsource"

	def ShedSource(pcTarget)
		pointer2object(@pLimiter).BlockFor("" + pcTarget, "shed by a containment plan", @nBlockMs)

	def LockAccount(pcTarget)
		stzraise("stzRateLimiterResponder cannot :LockAccount -- wire an auth responder.")

	def RevokeSession(pcTarget)
		stzraise("stzRateLimiterResponder cannot :RevokeSession -- wire an auth responder.")

	def RotateSecret(pcTarget)
		stzraise("stzRateLimiterResponder cannot :RotateSecret -- wire a secret-store responder.")

	def RevokeCapability(pcTarget)
		stzraise("stzRateLimiterResponder cannot :RevokeCapability -- wire a capability responder.")

	def QuarantinePart(pcTarget)
		stzraise("stzRateLimiterResponder cannot :QuarantinePart -- wire a quarantine responder.")


  #=========================================================#
 #  stzAgentHostResponder -- :QuarantinePart, for real       #
#=========================================================#

class stzAgentHostResponder from stzObject

	@pHost = ""

	def init(poHost)
		@pHost = object2pointer(poHost)

	def Owns(pcVerb)
		return StzLower("" + pcVerb) = "quarantinepart"

	def QuarantinePart(pcTarget)
		_c_ = "" + pcTarget
		if StzLeft(StzLower(_c_), 6) = "agent:"
			_c_ = StzMidToEnd(_c_, 7)
		ok
		pointer2object(@pHost).Quarantine(_c_, "quarantined by a containment plan")

	def LockAccount(pcTarget)
		stzraise("stzAgentHostResponder cannot :LockAccount -- wire an auth responder.")

	def RevokeSession(pcTarget)
		stzraise("stzAgentHostResponder cannot :RevokeSession -- wire an auth responder.")

	def RotateSecret(pcTarget)
		stzraise("stzAgentHostResponder cannot :RotateSecret -- wire a secret-store responder.")

	def RevokeCapability(pcTarget)
		stzraise("stzAgentHostResponder cannot :RevokeCapability -- wire a capability responder.")

	def ShedSource(pcTarget)
		stzraise("stzAgentHostResponder cannot :ShedSource -- wire a rate-limiter responder.")
