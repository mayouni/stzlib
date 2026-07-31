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
		[ "secret.reveal.granted",        "info",    "T1552",     "a secret was revealed to an entitled actor" ],
		[ "secret.reveal.refused",        "error",   "T1552",     "a secret reveal was refused" ],
		[ "capability.refused",           "error",   "T1068",     "an actor lacked the capability an operation required" ],
		[ "scope.refused",                "warning", "T1068",     "an operation fell outside the commit scope" ],
		[ "posture.refused",              "error",   "T1068",     "the executing posture was not admitted" ],
		[ "plan.op.failed",               "warning", "",          "a committed operation failed at the bridge" ],
		[ "http.request.unauthorized",    "warning", "T1190",     "a request failed the transport gate (401)" ],
		[ "http.request.forbidden",       "warning", "T1190",     "a request was refused by policy (403)" ],
		[ "ratelimit.shed",               "info",    "T1499",     "a caller was shed by the rate limiter" ],
		[ "service.production_fake_refused", "warning", "",       "a production deploy refused a virtualized service" ],
		[ "crossworld.call.refused",      "warning", "T1068",     "a cross-world call was refused" ],
		[ "federation.call.refused",      "warning", "T1068",     "a federated call was refused" ],
		[ "graph.escalation_path_found",  "error",   "T1078",     "a sandboxed actor can reach an effectful capability" ]
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

	  #-- reads ------------------------------------------------------

	def Kind()
		return @cKind

	def Severity()
		return @cSeverity

	def Technique()
		return @cTechnique

	def Meaning()
		_a_ = StzSecurityEventKindInfo(@cKind)
		if len(_a_) = 0
			return ""
		ok
		return _a_[4]

	def Actor()
		return @cActor

	def Posture()
		return @cPosture

	def ActorKinds()
		return @aActorKinds

	def Action()
		return @cAction

	def Risk()
		return @nRisk

	def Subject()
		return @cSubject

	def Origin()
		return @cOrigin

	def Outcome()
		return @cOutcome

	def Reason()
		return @cReason

	def AtWall()
		return @nAtWall

	def AtMono()
		return @nAtMono

	def TraceId()
		return @cTraceId

	def IsRefusal()
		return @cOutcome != "granted"

	  #-- building (fluent; every setter returns This) ---------------

	# WHO: an stzSystemActor contributes its own facts -- name, posture,
	# capability kinds. Nothing is invented here.
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

	# For a caller with no actor object yet (an unauthenticated request,
	# a username at the login door).
	def ByActorNamed(pcName, pcPosture)
		@cActor = "" + pcName
		@cPosture = StzLower("" + pcPosture)
		return This

	# WHICH thing. THE REDACTION LAW lives here: an object contributes
	# its DESCRIPTOR (stzSecret.Descriptor() is the redacted form), never
	# its value -- this class never calls Reveal(). A string is taken as
	# already-safe; callers pass descriptors like "user:admin",
	# "key:billing", "route:/pay".
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

	def Doing(pcAction)
		@cAction = StzLower(ring_trim("" + pcAction))
		return This

	def AtRisk(pnTier)
		if isNumber(pnTier)
			@nRisk = pnTier
		ok
		return This

	def FromOrigin(pcOrigin)
		@cOrigin = "" + pcOrigin
		return This

	  #-- outcomes ---------------------------------------------------

	def Granted()
		@cOutcome = "granted"
		return This

	def Refused(pcReason)
		@cOutcome = "refused"
		@cReason = "" + pcReason
		return This

	# The gate admitted it and the act still did not complete.
	def Failed(pcReason)
		@cOutcome = "failed"
		@cReason = "" + pcReason
		return This

	  #-- severity (the catalog's default, overridable) --------------

	def AsInfo()
		@cSeverity = "info"
		return This

	def AsWarning()
		@cSeverity = "warning"
		return This

	def AsError()
		@cSeverity = "error"
		return This

	  #-- the native record ------------------------------------------

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

	# The canonical form the I1 ledger hashes into its chain: every
	# field, fixed order, one line. Two events with identical facts
	# produce identical strings; any difference shows.
	def CanonicalString()
		_c_ = @cKind + "|" + @cSeverity + "|" + @cActor + "|" + @cPosture
		_c_ += ("|" + @cAction + "|" + @nRisk + "|" + @cSubject)
		_c_ += ("|" + @cOrigin + "|" + @cOutcome + "|" + @cReason)
		_c_ += ("|" + @nAtWall + "|" + @cTraceId)
		return _c_

	  #-- interop: OCSF (the SIEM schema) ----------------------------

	# OCSF severity_id: 1 Informational, 3 Medium, 4 High.
	def OcsfSeverityId()
		if @cSeverity = "error"
			return 4
		but @cSeverity = "warning"
			return 3
		ok
		return 1

	# OCSF status_id: 1 Success, 2 Failure.
	def OcsfStatusId()
		if @cOutcome = "granted"
			return 1
		ok
		return 2

	# Best-effort class mapping, honestly bounded: auth/sso/oauth are
	# Identity & Access Management (category 3, class 3002
	# Authentication); http.* is Network Activity (4 / 4002 HTTP
	# Activity); everything else is Application Activity (6 / 6003 API
	# Activity). Facts that do not map cleanly ride in "unmapped",
	# which is what that OCSF field is for.
	def OcsfClassUid()
		if This._StartsWith(@cKind, "auth.") or This._StartsWith(@cKind, "sso.") or This._StartsWith(@cKind, "oauth.")
			return 3002
		but This._StartsWith(@cKind, "http.")
			return 4002
		ok
		return 6003

	def OcsfCategoryUid()
		_n_ = This.OcsfClassUid()
		if _n_ = 3002
			return 3
		but _n_ = 4002
			return 4
		ok
		return 6

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

	  #-- legibility -------------------------------------------------

	# One line, human first: who did what to which, how it ended, why.
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

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	  #-- internals --------------------------------------------------

	def _StartsWith(pcStr, pcPrefix)
		return StzFindFirst(pcPrefix, pcStr) = 1

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
