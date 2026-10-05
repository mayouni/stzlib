/*
	stzSecurityEvent -- the typed security record (incident I0).

	The library already DETECTS more than it remembers: a stalled
	WebAuthn counter, a replayed nonce, a forged signature, a refused
	escalation -- each detected perfectly, explained honestly to its
	caller, then dropped into a one-slot Why() the next call
	overwrites (SOFTANZA_INCIDENT_ANALYSIS.md section 1). This class
	is the record that makes remembering possible, and I0 is where
	its vocabulary is fixed, because every later phase speaks it.

	The house doctrine, in object form: "A refusal is an event, not a
	silent failure" (SOFTANZA_SECURITY.md).

		oE = StzSecurityEvent("secret.reveal.refused")
		oE.ByActor(oLlm).About(oSecret).Doing("reveal").Refused("actor is not effectful")
		? oE.AsLine()
		? oE.ToOcsfJson()          # the industry shape, from day one

	Or, for a seam that just needs one line:

		StzSecurityRefusal("sig.nonce.replayed", oActor, "key:billing", "nonce already used")

	Kinds are STRINGS, not :symbols -- Ring parses `:a.b.c` as `:a`
	followed by member access, so a dotted catalog name must be
	quoted (the same contract as the perf system's "http.request.ms").

	SIX QUESTIONS, CLOSED FIELDS -- what / who / which / how it ended /
	why / when + where:

	  :kind      what happened, from the closed catalog below
	  :actor :posture :actorKinds     WHO (an stzSystemActor's own facts)
	  :action :risk                   WHAT was attempted, at which tier
	  :subject                        WHICH thing -- a DESCRIPTOR (see below)
	  :origin                         from where (ip / host / endpoint)
	  :outcome                        granted | refused | failed
	  :reason                         the gate's own words, never re-derived
	  :atWall :atMono                 forensic absolute / ordering time
	  :traceId                        the active trace scope, automatically
	  :severity :technique            house severity + MITRE ATT&CK id

	THE REDACTION LAW (incident law 2): an event never carries a secret
	VALUE, only its DESCRIPTOR. About() enforces it structurally --
	hand it an stzSecret and it records `Descriptor()`, the redacted
	form, because the only way to get a value out of a secret is
	Reveal(effectfulActor), which this class never calls. An incident
	record must never become the breach it describes.

	CLOCKS ARE SCOPES (perf law 3): :atWall is epoch ms (the forensic
	"when"), :atMono is the monotonic clock (ordering that survives an
	NTP correction). Both are stamped at construction -- the moment of
	detection, not the moment of recording.

	CORRELATION IS FREE (perf P9): inside a trace scope -- and the
	observed appserver opens one per request -- the event stamps the
	active trace id, so events, log lines and spans of the same
	request already share an identity. Outside a scope it is "".
*/

  #=============#
 #  THE KINDS  #
#=============#

/*
	The closed catalog: [ kind, defaultSeverity, attackTechnique, meaning ].
	These names are an API (the perf lesson: http.request.ms is a
	contract) -- stable, dotted, lowercase. Each maps to a seam that
	ALREADY detects the condition today; I2 wires them.

	The technique column is the MITRE ATT&CK id an outbound consumer
	expects, "" where no honest mapping exists.
*/
func StzSecurityEventKinds()
	return [
		[ "auth.login.failed",            "warning", "T1110",     "a login attempt was rejected" ],
		[ "auth.twofactor.failed",        "warning", "T1111",     "a second-factor check failed" ],
		[ "auth.otp.failed",              "warning", "T1111",     "a one-time code was rejected" ],
		[ "auth.passkey.failed",          "warning", "T1556",     "a passkey assertion failed" ],
		[ "auth.passkey.clone_suspected", "error",   "T1550",     "the signature counter did not advance -- a cloned authenticator is possible" ],
		[ "auth.lockout.engaged",         "warning", "T1110",     "repeated failures locked the account" ],
		[ "auth.account.locked",          "warning", "",          "an account was locked by a responder or an operator" ],
		[ "auth.account.unlocked",        "info",    "",          "an administrative account lock was lifted" ],
		[ "auth.password.reset",          "warning", "T1098",     "a password was reset through a recovery link" ],
		[ "auth.session.revoked",         "info",    "",          "a session was revoked" ],
		[ "auth.session.expired",         "info",    "",          "a session reached its expiry" ],
		[ "sso.assertion.replayed",       "error",   "T1550.001", "a SAML assertion was presented twice" ],
		[ "sso.assertion.rejected",       "warning", "T1550.001", "a SAML assertion failed issuer/audience/window checks" ],
		[ "sso.token.rejected",           "warning", "T1550.001", "an id-token failed signature/issuer/audience/nonce checks" ],
		[ "oauth.code.replayed",          "error",   "T1550.001", "an authorization code was redeemed twice" ],
		[ "oauth.client.rejected",        "warning", "T1078",     "a client failed secret or PKCE verification" ],
		[ "sig.nonce.replayed",           "error",   "T1550",     "a request nonce was reused for the same key" ],
		[ "sig.signature.forged",         "error",   "T1550",     "an HMAC signature did not match (forged, tampered, or wrong key)" ],
		[ "sig.timestamp.stale",          "warning", "T1550",     "a signed request fell outside the freshness window" ],
		[ "sig.key.unknown",              "warning", "T1078",     "a request was signed with an unknown key id" ],
		# Webhooks (payments PY3): the hub tells the platform that money moved by POSTing an event,
		# and anyone who can reach the callback can POST too. Four refusals, four kinds.
		[ "webhook.unsigned",             "warning", "T1190",     "a webhook arrived with no signature at all" ],
		[ "webhook.signature.forged",     "error",   "T1550",     "a webhook signature did not recompute (tampered body, or a secret the platform does not hold)" ],
		[ "webhook.replayed",             "error",   "T1550",     "a webhook that was already believed was presented again" ],
		[ "webhook.malformed",            "warning", "T1190",     "a correctly signed webhook was not an event envelope" ],
		[ "secret.reveal.granted",        "info",    "T1552",     "a secret was revealed to an entitled actor" ],
		[ "secret.reveal.refused",        "error",   "T1552",     "a secret reveal was refused" ],
		[ "secret.rotated",               "info",    "",          "a secret was replaced by a fresh value" ],
		# Money out is a plan a human commits (payments PY4). A committed plan is the audit fact; a refused
		# plan is a warning; a payout that reached the port with no committed plan is the alarm.
		[ "payout.committed",             "info",    "",          "a payout plan was committed by an actor who may, and released through the port" ],
		[ "payout.refused",               "warning", "",          "a payout plan was refused: the policy, the actor, or the rehearsed document" ],
		[ "payout.unplanned",             "error",   "T1657",     "money out was attempted at the port with no committed plan, or for an amount the plan did not authorise" ],
		# Expiry is a detection the ledger raises (payments PY3): an mTLS certificate that lapses is
		# the outage nobody schedules. The watch writes these; a detection reads them.
		[ "secret.expiring",              "warning", "",          "a secret with an expiry date is inside its warning window" ],
		[ "secret.expired",               "error",   "",          "a secret with an expiry date is past it" ],
		[ "capability.revoked",           "info",    "",          "an actor's path to a capability was cut" ],
		[ "agent.quarantined",            "warning", "",          "an agent was quarantined -- containment's :QuarantinePart" ],
		[ "agent.released",               "info",    "",          "a quarantined agent was released" ],
		[ "agent.budget.exceeded",        "warning", "T1499",     "an agent exceeded its action budget and was quarantined" ],
		[ "capability.refused",           "error",   "T1068",     "an actor lacked the capability an operation required" ],
		[ "scope.refused",                "warning", "T1068",     "an operation fell outside the commit scope" ],
		[ "posture.refused",              "error",   "T1068",     "the executing posture was not admitted" ],
		[ "plan.op.failed",               "warning", "",          "a committed operation failed at the bridge" ],
		[ "http.request.unauthorized",    "warning", "T1190",     "a request failed the transport gate (401)" ],
		[ "http.request.forbidden",       "warning", "T1190",     "a request was refused by policy (403)" ],
		[ "ratelimit.shed",               "info",    "T1499",     "a caller was shed by the rate limiter" ],
		[ "ratelimit.blocked",            "warning", "T1499",     "a source was blocked -- containment's :ShedSource" ],
		[ "service.production_fake_refused", "warning", "",       "a production deploy refused a virtualized service" ],
		[ "crossworld.call.refused",      "warning", "T1068",     "a cross-world call was refused" ],
		[ "federation.call.refused",      "warning", "T1068",     "a federated call was refused" ],
		[ "graph.escalation_path_found",  "error",   "T1078",     "a sandboxed actor can reach an effectful capability" ],
		# The response is part of the story (incident I6): who contained
		# what, and who was refused the attempt. No detection watches
		# these kinds, so recording them cannot feed itself.
		[ "response.action.committed",    "info",    "",          "a containment action crossed into reality" ],
		[ "response.action.refused",      "warning", "",          "a containment action was refused -- the actor may not commit" ],
		# Evidence leaving the process is itself an act worth recording
		# (incident I7): who exported the ledger, and who was refused.
		[ "evidence.exported",            "info",    "",          "a sealed evidence file was written" ],
		[ "evidence.export_refused",      "warning", "",          "an actor without the sensing capability was refused the evidence" ]
	]

func StzSecurityEventKindIsKnown(pcKind)
	return len(StzSecurityEventKindInfo(pcKind)) > 0

# [ kind, severity, technique, meaning ] or [] when unknown.
func StzSecurityEventKindInfo(pcKind)
	_c_ = StzLower(ring_trim("" + pcKind))
	_a_ = StzSecurityEventKinds()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if _a_[_i_][1] = _c_
			return _a_[_i_]
		ok
	next
	return []

func StzSecurityEventKindNames()
	_out_ = []
	_a_ = StzSecurityEventKinds()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		_out_ + _a_[_i_][1]
	next
	return _out_


  #=================#
 #  CONSTRUCTORS   #
#=================#

func StzSecurityEvent(pcKind)
	return new stzSecurityEvent(pcKind)

# The one-line forms a seam reaches for (I2 wires dozens of these).
func StzSecurityRefusal(pcKind, poActor, pcSubject, pcReason)
	_e_ = new stzSecurityEvent(pcKind)
	_e_.ByActor(poActor)
	_e_.About(pcSubject)
	_e_.Refused(pcReason)
	return _e_

func StzSecurityGrant(pcKind, poActor, pcSubject)
	_e_ = new stzSecurityEvent(pcKind)
	_e_.ByActor(poActor)
	_e_.About(pcSubject)
	_e_.Granted()
	return _e_


  #===========#
 #  THE OBJECT  #
#===========#

# Holds one typed security record: what happened, who did it, to which thing, how it ended, why, and when.
#
# The kind comes from a closed catalog of dotted names (auth.login.failed, secret.reveal.refused
# ...), and an unknown kind raises. The setters return the event, so calls chain. An event never
# carries a secret value: About takes the descriptor of an object, never its value. Both clocks are
# stamped when the event is built, the wall clock for the forensic when and the monotonic clock for
# ordering, together with the active trace id. An event is recorded in a stzSecurityLedger, and
# CanonicalString, ToOcsfJson and AsLine are its three serial forms.
#
#   receiver   o1 = new stzSecurityEvent("auth.login.failed")
#   example    o1.ByActorNamed("bob", "external")
#              o1.About("user:bob")
#              o1.Refused("bad password")
#              ? o1.AsLine()
#              #--> REFUSED auth.login.failed by bob (external) on user:bob -- bad password
#   see        stzSecurityLedger, stzDetection, StzSecurityEventKinds
class stzSecurityEvent from stzObject

	@cKind = ""
	@cSeverity = "info"
	@cTechnique = ""
	@cActor = ""
	@cPosture = ""
	@aActorKinds = []
	@cAction = ""
	@nRisk = 0
	@cSubject = ""
	@cOrigin = ""
	@cOutcome = "refused"
	@cReason = ""
	@nAtWall = 0
	@nAtMono = 0
	@cTraceId = ""

	# Builds an event of one kind from the closed catalog, stamping both clocks and the active trace id at the moment of detection.
	#
	#   pcKind     the event kind, a dotted catalog name such as auth.login.failed, matched without
	#              regard to case
	#   returns    nothing; the object is built
	#   note       the outcome starts as refused; severity and technique start at the catalog values
	#              for the kind
	#   warning    an unknown kind raises an error that lists every known kind: the catalog is
	#              closed
	#   see        StzSecurityEventKindNames, Kind
	def init(pcKind)
		_aInfo_ = StzSecurityEventKindInfo(pcKind)
		if len(_aInfo_) = 0
			StzRaise("stzSecurityEvent: unknown kind '" + pcKind + "'." + Char(10) +
				"The catalog is closed (SOFTANZA_INCIDENT_ANALYSIS.md 6.1); known kinds: " +
				This._JoinNames())
		ok
		@cKind = _aInfo_[1]
		@cSeverity = _aInfo_[2]
		@cTechnique = _aInfo_[3]
		# Stamped at DETECTION time, both clocks (perf law 3).
		@nAtWall = StzEngineTimeWallMs()
		@nAtMono = StzEngineWatchTimestampMs()
		# Correlation, free: the active trace scope if there is one.
		@cTraceId = StzCurrentTraceId()

	# Returns the catalog name of the event, in lower case.
	#
	#   returns    a text
	#   see        Meaning, Severity
	#@ aka  -- reads ------------------------------------------------------
	def Kind()
		return @cKind

	# Returns the severity of the event: info, warning or error.
	#
	#   returns    a text
	#   note       it starts at the catalog default of the kind and the As calls override it
	#   see        AsInfo, AsWarning, AsError
	def Severity()
		return @cSeverity

	# Returns the MITRE ATT&CK technique id of the kind, or an empty text where no honest mapping exists.
	#
	#   returns    a text
	#   see        Kind
	def Technique()
		return @cTechnique

	# Returns the catalog's one-line sentence saying what the kind stands for.
	#
	#   returns    a text
	#   see        Kind, Explain
	def Meaning()
		_a_ = StzSecurityEventKindInfo(@cKind)
		if len(_a_) = 0
			return ""
		ok
		return _a_[4]

	# Returns the name of the actor that did it.
	#
	#   returns    a text; empty until an actor is given
	#   see        ByActor, ByActorNamed
	def Actor()
		return @cActor

	# Returns the actor's posture in lower case, such as trusted, sandboxed or external.
	#
	#   returns    a text; empty until an actor is given
	#   see        ByActor, ByActorNamed
	def Posture()
		return @cPosture

	# Returns the capability kinds the actor object held, as ByActor read them.
	#
	#   returns    a list of text; [ ] for an actor given by name
	#   see        ByActor
	def ActorKinds()
		return @aActorKinds

	# Returns the act that was attempted, trimmed and in lower case.
	#
	#   returns    a text; empty until Doing sets it
	#   see        Doing
	def Action()
		return @cAction

	# Returns the risk tier of the act that was attempted.
	#
	#   returns    a number, 0 until AtRisk sets one
	#   see        AtRisk
	def Risk()
		return @nRisk

	# Returns the descriptor of the thing acted on; the value of a secret is never in it.
	#
	#   returns    a text; empty until About sets it
	#   see        About
	def Subject()
		return @cSubject

	# Returns where the event came from, such as an address, a host or an endpoint.
	#
	#   returns    a text; empty until FromOrigin sets it
	#   see        FromOrigin
	def Origin()
		return @cOrigin

	# Returns how the attempt ended: granted, refused, failed or observed.
	#
	#   returns    a text, refused for a new event
	#   see        Granted, Refused, Failed, Observed
	def Outcome()
		return @cOutcome

	# Returns the gate's own words for a refused, failed or observed event.
	#
	#   returns    a text; empty for a grant
	#   see        Refused, Failed, Observed
	def Reason()
		return @cReason

	# Returns the wall-clock time of the event, in epoch milliseconds.
	#
	#   returns    a number
	#   note       stamped when the event was built, which is the moment of detection and not of
	#              recording
	#   see        AtMono, OccurredAt
	def AtWall()
		return @nAtWall

	# Returns the monotonic-clock stamp of the event, in milliseconds, which keeps its ordering across a clock correction.
	#
	#   returns    a number, which may have a fraction
	#   note       it orders the events of this process only and is not part of the canonical line
	#   see        AtWall
	def AtMono()
		return @nAtMono

	# Returns the id of the trace scope that was active when the event was built.
	#
	#   returns    a text; empty outside a trace scope
	#   see        Record
	def TraceId()
		return @cTraceId

	# TRUE if the outcome is refused or failed; a granted or an observed event is not a refusal.
	#
	#   returns    TRUE or FALSE
	#   see        Outcome, Refused
	#@ aka  "granted" and "observed" are not refusals; "refused" and "failed" are. Written as an explicit list rather than `!= "granted"` because a fourth outcome arrived later (see Observed) and the negative form would have silently swept it in -- an expired session would have counted as a refusal in every pivot.
	def IsRefusal()
		return @cOutcome = "refused" or @cOutcome = "failed"

	# Takes the actor's name, posture and capability kinds from an actor object, or only the name from a text.
	#
	#   poActor    an actor object such as HumanActor, or the actor's name as text
	#   returns    the event itself, so calls chain
	#   note       a text sets only the name, so a posture and kinds set earlier stay as they were;
	#              an object without Name records its class name
	#   see        ByActorNamed, Actor
	#@ aka  -- building (fluent; every setter returns This) ---------------
	def ByActor(poActor)
		if isObject(poActor)
			try
				@cActor = "" + poActor.Name()
			catch
				@cActor = "" + classname(poActor)
			done
			try
				@cPosture = StzLower("" + poActor.Posture())
			catch
				@cPosture = ""
			done
			try
				@aActorKinds = poActor.Kinds()
			catch
				@aActorKinds = []
			done
		but isString(poActor)
			@cActor = "" + poActor
		ok
		return This

	# Sets the actor from a name and a posture, for a caller with no actor object yet, such as a login door.
	#
	#   pcName      the actor name, as text
	#   pcPosture   the actor's posture, stored in lower case, such as external
	#   returns     the event itself, so calls chain
	#   see         ByActor, Actor
	#@ aka  For a caller with no actor object yet (an unauthenticated request, a username at the login door).
	def ByActorNamed(pcName, pcPosture)
		@cActor = "" + pcName
		@cPosture = StzLower("" + pcPosture)
		return This

	# Sets the subject: a text is taken as already safe, an object contributes its redacted descriptor and never its value.
	#
	#   pSubject   a descriptor text such as user:admin, or an object such as a secret
	#   returns    the event itself, so calls chain
	#   note       an object that has neither a descriptor nor a name records its class name
	#   warning    the redaction law lives here: given a secret it records the descriptor and never
	#              reveals it
	#   see        Subject
	#@ aka  WHICH thing. THE REDACTION LAW lives here: an object contributes its DESCRIPTOR (stzSecret.Descriptor() is the redacted form), never its value -- this class never calls Reveal(). A string is taken as already-safe; callers pass descriptors like "user:admin", "key:billing", "route:/pay".
	def About(pSubject)
		if isObject(pSubject)
			try
				@cSubject = "" + pSubject.Descriptor()
			catch
				try
					@cSubject = "" + pSubject.Name()
				catch
					@cSubject = "" + classname(pSubject)
				done
			done
		else
			@cSubject = "" + pSubject
		ok
		return This

	# Sets the act that was attempted, trimmed and put in lower case.
	#
	#   pcAction   the verb, such as reveal or login
	#   returns    the event itself, so calls chain
	#   see        Action, AtRisk
	def Doing(pcAction)
		@cAction = StzLower(ring_trim("" + pcAction))
		return This

	# Sets the risk tier of the act that was attempted; a value that is not a number is ignored.
	#
	#   pnTier     the risk tier, as a number
	#   returns    the event itself, so calls chain
	#   see        Risk, Doing
	def AtRisk(pnTier)
		if isNumber(pnTier)
			@nRisk = pnTier
		ok
		return This

	# Sets where the event came from.
	#
	#   pcOrigin   an address, a host or an endpoint, as text
	#   returns    the event itself, so calls chain
	#   see        Origin
	def FromOrigin(pcOrigin)
		@cOrigin = "" + pcOrigin
		return This

	# Sets the wall time of an event that did not happen now, such as an imported one or a guard needing exact windows.
	#
	#   pnWallMs   the event time, in epoch milliseconds
	#   returns    the event itself, so calls chain
	#   note       a value that is not a number is ignored; the monotonic stamp is left alone,
	#              because it cannot be borrowed
	#   see        AtWall
	#@ aka  The deterministic form (the house "...At(now)" convention): an event that did not happen NOW carries its own wall clock -- a replayed or imported record, or a guard that needs exact window arithmetic instead of machine speed. The monotonic stamp is left alone: it orders THIS process's events and cannot be borrowed.
	def OccurredAt(pnWallMs)
		if isNumber(pnWallMs)
			@nAtWall = pnWallMs
		ok
		return This

	# Sets the outcome to granted.
	#
	#   returns    the event itself, so calls chain
	#   note       the reason is left as it was
	#   see        Refused, IsRefusal
	#@ aka  -- outcomes ---------------------------------------------------
	def Granted()
		@cOutcome = "granted"
		return This

	# Sets the outcome to refused, with the gate's own words as the reason.
	#
	#   pcReason   the gate's own words, as text
	#   returns    the event itself, so calls chain
	#   see        Failed, IsRefusal
	def Refused(pcReason)
		@cOutcome = "refused"
		@cReason = "" + pcReason
		return This

	# Sets the outcome to failed: the gate admitted the act and it still did not complete.
	#
	#   pcReason   why it did not complete, as text
	#   returns    the event itself, so calls chain
	#   see        Refused, IsRefusal
	#@ aka  The gate admitted it and the act still did not complete.
	def Failed(pcReason)
		@cOutcome = "failed"
		@cReason = "" + pcReason
		return This

	# Sets the outcome to observed, a fact that carries no verdict, such as a session reaching its expiry.
	#
	#   pcReason   what was seen, as text
	#   returns    the event itself, so calls chain
	#   note       an observed event is not a refusal, so no pivot that counts refusals counts it
	#   see        Refused, IsRefusal
	#@ aka  NOT A VERDICT -- something simply happened (incident I2's session seams). A session reaching its expiry was neither granted nor refused: no gate ran, nobody was told no. Forcing such a fact into "refused" would have made every pivot that counts refusals over-count, and would have taught an investigator that routine housekeeping was an attack. The ledger's job is to witness, and some of what it wit
	def Observed(pcReason)
		@cOutcome = "observed"
		@cReason = "" + pcReason
		return This

	# Sets the severity of the event to info, overriding the catalog default.
	#
	#   returns    the event itself, so calls chain
	#   note       OcsfSeverityId and ToOcsfJson on the event itself do use the override
	#   warning    the ledger keeps the override, but the OCSF exports of the ledger read the
	#              catalog default again
	#   see        AsWarning, AsError
	#@ aka  -- severity (the catalog's default, overridable) --------------
	def AsInfo()
		@cSeverity = "info"
		return This

	# Sets the severity of the event to warning, overriding the catalog default.
	#
	#   returns    the event itself, so calls chain
	#   note       OcsfSeverityId and ToOcsfJson on the event itself do use the override
	#   warning    the ledger keeps the override, but the OCSF exports of the ledger read the
	#              catalog default again
	#   see        AsInfo, AsError
	def AsWarning()
		@cSeverity = "warning"
		return This

	# Sets the severity of the event to error, overriding the catalog default.
	#
	#   returns    the event itself, so calls chain
	#   note       OcsfSeverityId and ToOcsfJson on the event itself do use the override
	#   warning    the ledger keeps the override, but the OCSF exports of the ledger read the
	#              catalog default again
	#   see        AsInfo, AsWarning
	def AsError()
		@cSeverity = "error"
		return This

	# Returns the event as its native record, every field including the actor's kinds and the monotonic stamp.
	#
	#   returns    a list of [ key, value ] pairs: kind, severity, technique, actor, posture,
	#              actorKinds, action, risk, subject, origin, outcome, reason, atWall, atMono,
	#              traceId
	#   see        CanonicalString, AsLine
	#@ aka  -- the native record ------------------------------------------
	def Record()
		return [
			:kind = @cKind,
			:severity = @cSeverity,
			:technique = @cTechnique,
			:actor = @cActor,
			:posture = @cPosture,
			:actorKinds = @aActorKinds,
			:action = @cAction,
			:risk = @nRisk,
			:subject = @cSubject,
			:origin = @cOrigin,
			:outcome = @cOutcome,
			:reason = @cReason,
			:atWall = @nAtWall,
			:atMono = @nAtMono,
			:traceId = @cTraceId
		]

	# Returns the event as one fixed-order line of twelve fields, the form the ledger hashes into its chain.
	#
	#   returns    a text
	#   note       a vertical bar inside a field is folded to a slash so the line splits back
	#              cleanly; two events with the same facts give the same line; the technique, the
	#              actor kinds and the monotonic stamp are not in it
	#   see        Record, AsLine
	#@ aka  The canonical form the I1 ledger hashes into its chain: every field, fixed order, one line. Two events with identical facts produce identical strings; any difference shows.
	def CanonicalString()
		_c_ = @cKind + "|" + @cSeverity + "|" + This._NoPipe(@cActor) + "|" + @cPosture
		_c_ += ("|" + @cAction + "|" + @nRisk + "|" + This._NoPipe(@cSubject))
		_c_ += ("|" + This._NoPipe(@cOrigin) + "|" + @cOutcome + "|" + This._NoPipe(@cReason))
		_c_ += ("|" + @nAtWall + "|" + @cTraceId)
		return _c_

	# Returns the OCSF severity id: 1 informational, 3 medium for a warning, 4 high for an error.
	#
	#   returns    a number
	#   see        ToOcsfJson, Severity
	#@ aka  -- interop: OCSF (the SIEM schema) ----------------------------
	def OcsfSeverityId()
		if @cSeverity = "error"
			return 4
		but @cSeverity = "warning"
			return 3
		ok
		return 1

	# Returns the OCSF status id: 1 for a granted event, 2 for every other outcome.
	#
	#   returns    a number
	#   note       refused and failed both read 2 as well
	#   warning    an observed event also reads 2, so a fact with no verdict reaches a SIEM as a
	#              failure
	#   see        ToOcsfJson, Outcome
	#@ aka  OCSF status_id: 1 Success, 2 Failure.
	def OcsfStatusId()
		if @cOutcome = "granted"
			return 1
		ok
		return 2

	# Returns the OCSF class uid chosen from the kind: 3002 for auth, sso and oauth kinds, 4002 for http kinds, 6003 for the rest.
	#
	#   returns    a number
	#   note       a best-effort mapping: facts that map no field travel under unmapped
	#   see        OcsfCategoryUid, ToOcsfJson
	#@ aka  Best-effort class mapping, honestly bounded: auth/sso/oauth are Identity & Access Management (category 3, class 3002 Authentication); http.* is Network Activity (4 / 4002 HTTP Activity); everything else is Application Activity (6 / 6003 API Activity). Facts that do not map cleanly ride in "unmapped", which is what that OCSF field is for.
	def OcsfClassUid()
		if This._StartsWith(@cKind, "auth.") or This._StartsWith(@cKind, "sso.") or This._StartsWith(@cKind, "oauth.")
			return 3002
		but This._StartsWith(@cKind, "http.")
			return 4002
		ok
		return 6003

	# Returns the OCSF category uid of the event's class: 3, 4 or 6.
	#
	#   returns    a number
	#   see        OcsfClassUid
	def OcsfCategoryUid()
		_n_ = This.OcsfClassUid()
		if _n_ = 3002
			return 3
		but _n_ = 4002
			return 4
		ok
		return 6

	# Returns the event as one OCSF JSON object, with the facts that map no field riding under unmapped.
	#
	#   returns    a text of JSON
	#   note       the trace id appears as metadata_trace_id and the technique under unmapped;
	#              backslashes and quotes in the text are escaped
	#   see        OcsfClassUid, AsLine
	def ToOcsfJson()
		_cJ_ = '{"category_uid":' + This.OcsfCategoryUid()
		_cJ_ += (',"class_uid":' + This.OcsfClassUid())
		_cJ_ += (',"time":' + @nAtWall)
		_cJ_ += (',"severity_id":' + This.OcsfSeverityId())
		_cJ_ += (',"status_id":' + This.OcsfStatusId())
		_cJ_ += ',"message":"' + This._Esc(This.AsLine()) + '"'
		_cJ_ += ',"actor":{"user":{"name":"' + This._Esc(@cActor) + '"}}'
		_cJ_ += ',"metadata":{"product":{"name":"Softanza","vendor_name":"Softanza"},"version":"1.0.0"}'
		if @cTraceId != ""
			_cJ_ += (',"metadata_trace_id":"' + @cTraceId + '"')
		ok
		_cJ_ += ',"unmapped":{'
		_cJ_ += '"kind":"' + @cKind + '"'
		_cJ_ += ',"outcome":"' + @cOutcome + '"'
		_cJ_ += ',"reason":"' + This._Esc(@cReason) + '"'
		_cJ_ += ',"subject":"' + This._Esc(@cSubject) + '"'
		_cJ_ += ',"posture":"' + @cPosture + '"'
		_cJ_ += ',"action":"' + @cAction + '"'
		_cJ_ += ',"risk":' + @nRisk
		if @cOrigin != ""
			_cJ_ += ',"origin":"' + This._Esc(@cOrigin) + '"'
		ok
		if @cTechnique != ""
			_cJ_ += ',"attack_technique":"' + @cTechnique + '"'
		ok
		_cJ_ += "}}"
		return _cJ_

	# Returns the event as one readable line: outcome, kind, actor with posture, subject, origin and reason.
	#
	#   returns    a text, for example REFUSED auth.login.failed by bob (external) on route:/pay --
	#              bad password
	#   see        Explain, CanonicalString
	#@ aka  -- legibility -------------------------------------------------
	def AsLine()
		_c_ = StzUpper(@cOutcome) + " " + @cKind
		if @cActor != ""
			_c_ += (" by " + @cActor)
			if @cPosture != ""
				_c_ += (" (" + @cPosture + ")")
			ok
		ok
		if @cSubject != ""
			_c_ += (" on " + @cSubject)
		ok
		if @cOrigin != ""
			_c_ += (" from " + @cOrigin)
		ok
		if @cReason != ""
			_c_ += (" -- " + @cReason)
		ok
		return _c_

	# Returns the event told as lines of text: kind and severity, meaning, the readable line, both times and the ATT&CK id.
	#
	#   returns    a list of text
	#   see        Show, AsLine
	def Explain()
		_aL_ = []
		_aL_ + ("Security event " + @cKind + " [" + @cSeverity + "]")
		_aL_ + ("  " + This.Meaning())
		_aL_ + ("  " + This.AsLine())
		_cW_ = "  at " + @nAtWall + " (wall), " + @nAtMono + " (mono)"
		if @cTraceId != ""
			_cW_ += (", trace " + @cTraceId)
		ok
		_aL_ + _cW_
		if @cTechnique != ""
			_aL_ + ("  ATT&CK " + @cTechnique)
		ok
		return _aL_

	# Prints the lines Explain returns, one per line.
	#
	#   returns    nothing; it prints
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	  #-- internals --------------------------------------------------

	def _StartsWith(pcStr, pcPrefix)
		return StzFindFirst(pcPrefix, pcStr) = 1

	def _NoPipe(pcStr)
		return StzReplace("" + pcStr, "|", "/")

	def _Esc(pcStr)
		_s_ = StzReplace("" + pcStr, char(92), char(92) + char(92))
		_s_ = StzReplace(_s_, char(34), char(92) + char(34))
		return _s_

	def _JoinNames()
		_a_ = StzSecurityEventKindNames()
		_c_ = ""
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += ", "
			ok
			_c_ += _a_[_i_]
		next
		return _c_
