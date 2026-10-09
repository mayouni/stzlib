/*
	stzIncident -- the case file (incident I5).

	I4 photographs a case when a detection fires. An incident is what
	an investigator reads: the same firing, correlated into a story
	with a timeline, the actors and subjects involved, the path the
	attacker could have taken, the blast radius of whatever secret is
	implicated, and a status that moves forward as the response
	happens.

		oInc = StzIncidentFromCase("INC-1", oSent.LastCase(), oLedger)
		oInc.WithGraph(oSecGraph)          # optional: path + blast radius
		oInc.Show()
		oInc.Contain("session revoked, key rotated")
		oInc.Close("credentials rotated; no data left the process")

	CORRELATION, one honest hop: start from the firing's actor, take
	every event that actor produced, then pull in everything sharing a
	TRACE ID with those (the P9 backbone -- a request's events, log
	lines and spans already share an identity). When the firing names
	no actor, the case's own nearest-events are the seed. Bounded at
	64 events, oldest dropped, because an incident is a story and not
	an archive.

	THE TIMELINE is wall-clock ordered, because that is the axis a
	human reasons on ("at 14:02 ... then at 14:03 ..."). Ordering
	inside one process is monotonic and exact; across processes it is
	wall time and therefore only as good as the clocks -- stated
	rather than hidden.

	STATUS is forward-only -- open -> contained -> closed -- the same
	discipline stzGovernance applies to commitments: "regressions are
	new commitments, deliberately". A reopened incident is a NEW
	incident with a reference, not a rewritten one.

	The redaction law still holds: everything here is built from
	events, and an event carries descriptors, never values.
*/

func StzIncident(pcId)
	return new stzIncident(pcId)

# The usual construction: a sentinel's case + the ledger it fired on.
func StzIncidentFromCase(pcId, paCase, poLedger)
	_o_ = new stzIncident(pcId)
	_o_.FromCase(paCase, poLedger)
	return _o_

# Holds an investigator's case file: a fired detection correlated into a wall-ordered story, with a response status that only moves forward.
#
# Build it from a sentinel's case and the ledger it fired on (StzIncidentFromCase), or from a bare
# finding. It takes the actor's own events and everything that shares a trace id with them, up to
# 64, and keeps their descriptors, never values. Give it a security graph and it also answers the
# attack path and the blast radius of the secrets involved. Status runs open, contained, closed and
# never back: a reopened incident is a new incident. ToOcsfFindingJson exports it as an OCSF
# security finding.
#
#   receiver   o1 = new stzIncident("INC-1")
#   example    o1.FromFinding([ :where = "guess/billing-agent", :rule = "guess", :severity = "error", :message = "a guess" ], StzSecurityLedger(16))
#              o1.Contain("session revoked")
#              ? o1.Actor()
#              #--> billing-agent
#              ? o1.Status()
#              #--> contained
#   see        stzSecuritySentinel, stzSecurityLedger, stzSecurityGraph
class stzIncident from stzObject

	@cId = ""
	@cRule = ""
	@cWhere = ""
	@cSeverity = "error"
	@cMessage = ""
	@cActor = ""
	@nOpenedAt = 0
	@cHeadDigest = ""
	@aEvents = []		# the correlated story, wall-ordered
	@oGraph = ""		# an stzSecurityGraph, when one is available
	@cStatus = "open"
	@aNotes = []		# [ atWall, status, note ]
	@nMaxEvents = 64

	# Builds an empty case file with the given identifier, status open and the opening time set to now.
	#
	#   pcId       the incident's identifier, such as INC-1
	#   returns    nothing; the object is built
	#   see        FromCase, FromFinding
	def init(pcId)
		@cId = "" + pcId
		@nOpenedAt = StzEngineTimeWallMs()
		@aNotes = []

	# Fills the incident from a sentinel case and the ledger it fired on, and correlates the story of the case's actor.
	#
	#   paCase     a sentinel case, a hash-list with rule, where, severity, message, headDigest, at
	#              and recent (from a sentinel's LastCase)
	#   poLedger   the stzSecurityLedger the case fired on
	#   returns    the incident itself, so calls chain
	#   note       the actor is the text after the first slash of the case's where; with no actor
	#              the case's recent events are the seed; the story is bounded at 64 events, oldest
	#              dropped
	#   see        FromFinding, StzIncidentFromCase, WithGraph
	#@ aka  -- building -----------------------------------------------------
	def FromCase(paCase, poLedger)
		@cRule = "" + paCase[:rule]
		@cWhere = "" + paCase[:where]
		@cSeverity = "" + paCase[:severity]
		@cMessage = "" + paCase[:message]
		@cHeadDigest = "" + paCase[:headDigest]
		@nOpenedAt = paCase[:at]
		@cActor = This._ActorOf(@cWhere)
		@aEvents = This._Correlate(paCase, poLedger)
		return This

	# Fills the incident from a bare finding judged outside a sentinel, taking a snapshot of the ledger at this moment.
	#
	#   paFinding   a hash-list with where, rule, severity and message
	#   poLedger    the stzSecurityLedger to correlate against
	#   returns     the incident itself, so calls chain
	#   note        the opening time is now, not the time of the finding
	#   see         FromCase, WithGraph
	#@ aka  Build from a bare finding (a detection judged outside a sentinel).
	def FromFinding(paFinding, poLedger)
		_aCase_ = [
			:at = StzEngineTimeWallMs(),
			:where = paFinding[:where],
			:rule = paFinding[:rule],
			:severity = paFinding[:severity],
			:message = paFinding[:message],
			:ledgerCount = poLedger.Count(),
			:headDigest = poLedger.Digest(),
			:recent = poLedger.Recent(8)
		]
		return This.FromCase(_aCase_, poLedger)

	# Gives the incident a security graph so that it can answer the attack path and the blast radius.
	#
	#   poSecurityGraph   the stzSecurityGraph that knows the actors, tools, capabilities and
	#                     secrets
	#   returns           the incident itself, so calls chain
	#   note              the graph is read, never changed
	#   see               AttackPath, BlastRadius, ReachesEffectful
	#@ aka  Give the incident the security graph, and it can answer HOW far the actor could have reached and WHAT a leaked secret exposes.
	def WithGraph(poSecurityGraph)
		@oGraph = poSecurityGraph
		return This

	# Returns the identifier the incident was built with.
	#
	#   returns    a text
	#   see        Rule, Status
	#@ aka  -- reading ------------------------------------------------------
	def Id()
		return @cId

	# Returns the name of the detection rule that fired.
	#
	#   returns    a text, empty before the incident is filled
	#   see        Where, Severity, Message
	def Rule()
		return @cRule

	# Returns the place the detection pointed at, such as rule/actor.
	#
	#   returns    a text, empty before the incident is filled
	#   see        Actor, Rule
	def Where()
		return @cWhere

	# Returns how serious the firing was, such as error or warning.
	#
	#   returns    a text; error by default
	#   see        Rule, ToOcsfFindingJson
	def Severity()
		return @cSeverity

	# Returns the sentence the detection gave to explain what it saw.
	#
	#   returns    a text, empty before the incident is filled
	#   see        Rule, Explain
	def Message()
		return @cMessage

	# Returns the single actor the story is about, taken from the text after the first slash of the where.
	#
	#   returns    a text; empty when the where names no actor
	#   see        Actors, Where
	def Actor()
		return @cActor

	# Returns the moment the incident opened, in epoch milliseconds.
	#
	#   returns    a number
	#   see        Timeline, Notes
	def OpenedAt()
		return @nOpenedAt

	# Returns the ledger's chain head as it stood when the detection fired, to compare with the ledger's later head.
	#
	#   returns    a text of 64 hex characters
	#   see        Events
	#@ aka  The chain head as it stood when this fired -- compare it with the ledger's later head to know whether history was rewritten.
	def HeadDigest()
		return @cHeadDigest

	# Returns the correlated story as the ledger's event records, in wall-clock order.
	#
	#   returns    a list of event records, at most 64
	#   see        Timeline, NumberOfEvents
	def Events()
		return @aEvents

	# Returns how many events the correlated story holds.
	#
	#   returns    a number
	#   see        Events, Timeline
	def NumberOfEvents()
		return ring_len(@aEvents)

	# Returns the story as plain rows, oldest first.
	#
	#   returns    a list of [ atWall, kind, actor, subject, reason ] rows
	#   note       wall time is only as good as the clocks across processes
	#   see        Events, Explain
	#@ aka  The story, wall-ordered: [ [ atWall, kind, actor, subject, reason ], ... ]
	def Timeline()
		_a_ = []
		_n_ = ring_len(@aEvents)
		for _i_ = 1 to _n_
			_a_ + [ @aEvents[_i_][:atWall], @aEvents[_i_][:kind],
				@aEvents[_i_][:actor], @aEvents[_i_][:subject],
				@aEvents[_i_][:reason] ]
		next
		return _a_

	# Returns the distinct actors that appear in the story, in order of first appearance.
	#
	#   returns    a list of text
	#   see        Actor, Subjects, Kinds
	def Actors()
		return This._DistinctOf(:actor)

	# Returns the distinct subjects that the story touched, in order of first appearance.
	#
	#   returns    a list of text
	#   see        Actors, SecretsInvolved
	def Subjects()
		return This._DistinctOf(:subject)

	# Returns the distinct kinds of event that the story holds, in order of first appearance.
	#
	#   returns    a list of text
	#   see        Actors, Subjects
	def Kinds()
		return This._DistinctOf(:kind)

	# Returns the distinct trace ids that the story touched, to hand to stzLog.OfTrace.
	#
	#   returns    a list of text; empty when no event carried a trace
	#   see        Events, Explain
	#@ aka  The trace ids the story touched -- hand one to stzLog.OfTrace() and the handler's own words come back.
	def TraceIds()
		_a_ = []
		_n_ = ring_len(@aEvents)
		for _i_ = 1 to _n_
			_c_ = "" + @aEvents[_i_][:traceId]
			if _c_ != "" and ring_find(_a_, _c_) = 0
				_a_ + _c_
			ok
		next
		return _a_

	# Returns the names of the secrets that appear among the story's subjects, with the secret: prefix removed.
	#
	#   returns    a list of text (descriptors, never values)
	#   see        Subjects, BlastRadius
	#@ aka  The secrets named in the story (descriptors, never values).
	def SecretsInvolved()
		_a_ = []
		_aS_ = This.Subjects()
		_n_ = ring_len(_aS_)
		for _i_ = 1 to _n_
			if StzFindFirst("secret:", _aS_[_i_]) = 1
				_a_ + StzMidToEnd(_aS_[_i_], 8)
			ok
		next
		return _a_

	# Returns the route by which the actor could reach an effectful capability, as the graph sees it.
	#
	#   returns    a list of node names from the actor to the capability; [ ] with no graph, no
	#              actor or no route
	#   see        ReachesEffectful, WithGraph
	#@ aka  -- what the graph knows ----------------------------------------
	def AttackPath()
		if @oGraph = "" or @cActor = ""
			return []
		ok
		return @oGraph.PathToEffectful(@cActor)

	# TRUE if the graph says that the actor can reach an effectful capability.
	#
	#   returns    TRUE or FALSE; FALSE with no graph or no actor
	#   see        AttackPath, WithGraph
	def ReachesEffectful()
		if @oGraph = "" or @cActor = ""
			return 0
		ok
		return @oGraph.ReachesEffectful(@cActor)

	# Returns, for each secret in the story, the graph nodes that the secret exposes.
	#
	#   returns    a list of [ secret, [ nodes ] ] rows; [ ] with no graph
	#   see        SecretsInvolved, WithGraph
	#@ aka  What each implicated secret exposes: [ [ secret, [reachers] ], ... ]
	def BlastRadius()
		_a_ = []
		if @oGraph = ""
			return _a_
		ok
		_aSec_ = This.SecretsInvolved()
		_n_ = ring_len(_aSec_)
		for _i_ = 1 to _n_
			_a_ + [ _aSec_[_i_], @oGraph.BlastRadius(_aSec_[_i_]) ]
		next
		return _a_

	# Returns where the response stands: open, contained or closed.
	#
	#   returns    a text
	#   see        IsOpen, IsClosed, Contain, Close
	#@ aka  -- the response (status is forward-only) ------------------------
	def Status()
		return @cStatus

	# TRUE if no response step has been taken yet.
	#
	#   returns    TRUE or FALSE
	#   see        IsClosed, Contain
	def IsOpen()
		return @cStatus = "open"

	# TRUE if the incident has been closed.
	#
	#   returns    TRUE or FALSE
	#   see        IsOpen, Close
	def IsClosed()
		return @cStatus = "closed"

	# Moves an open incident to contained and records the note with the time.
	#
	#   pcNote     what was done to contain it
	#   returns    the incident itself, so calls chain
	#   note       status moves forward only; a reopened incident is a new incident
	#   warning    raises an error unless the incident is still open, so a contained or closed one
	#              cannot be contained again
	#   see        Close, Notes
	def Contain(pcNote)
		if @cStatus != "open"
			stzraise("stzIncident '" + @cId + "': only an OPEN incident can be contained (this one is " + @cStatus + ").")
		ok
		@cStatus = "contained"
		This._Note(pcNote)
		return This

	# Moves the incident to closed and records the note with the time.
	#
	#   pcNote     what the closing response was
	#   returns    the incident itself, so calls chain
	#   note       status moves forward only
	#   warning    raises an error when the incident is already closed; closing straight from open
	#              is allowed
	#   see        Contain, Notes
	def Close(pcNote)
		if @cStatus = "closed"
			stzraise("stzIncident '" + @cId + "': already closed. Reopening is a NEW incident referencing this one -- regressions are new commitments, deliberately.")
		ok
		@cStatus = "closed"
		This._Note(pcNote)
		return This

	# Returns the response notes in the order they were written.
	#
	#   returns    a list of [ atWall, status, note ] rows
	#   see        Contain, Close
	def Notes()
		return @aNotes

	# Returns the incident as an OCSF Security Finding (class 2001) in JSON text, for a SIEM.
	#
	#   returns    a text holding a JSON object
	#   note       the attack path, secret names and trace ids ride in the unmapped field; severity
	#              error maps to 4, warning to 3, any other to 1
	#   see        AttackPath, TraceIds
	#@ aka  -- interop: the incident as an OCSF finding (I7) ----------------
	def ToOcsfFindingJson()
		_cJ_ = '{"category_uid":2,"class_uid":2001'
		_cJ_ += (',"time":' + @nOpenedAt)
		_cJ_ += (',"severity_id":' + This._OcsfSeverityId())
		_cJ_ += (',"status":"' + @cStatus + '"')
		_cJ_ += ',"finding":{"title":"' + This._Esc(@cRule) + '","uid":"' + This._Esc(@cId) + '"'
		_cJ_ += (',"desc":"' + This._Esc(@cMessage) + '"}')
		_cJ_ += ',"metadata":{"product":{"name":"Softanza","vendor_name":"Softanza"},"version":"1.0.0"}'
		_cJ_ += ',"unmapped":{'
		_cJ_ += '"actor":"' + This._Esc(@cActor) + '"'
		_cJ_ += ',"eventCount":' + ring_len(@aEvents)
		_cJ_ += ',"headDigest":"' + @cHeadDigest + '"'
		_cJ_ += ',"attackPath":' + This._JsonList(This.AttackPath())
		_cJ_ += ',"secrets":' + This._JsonList(This.SecretsInvolved())
		_cJ_ += ',"traceIds":' + This._JsonList(This.TraceIds())
		_cJ_ += "}}"
		return _cJ_

	def _OcsfSeverityId()
		if @cSeverity = "error"
			return 4
		but @cSeverity = "warning"
			return 3
		ok
		return 1

	def _JsonList(paList)
		_c_ = "["
		_n_ = ring_len(paList)
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += ","
			ok
			_c_ += ('"' + This._Esc("" + paList[_i_]) + '"')
		next
		return _c_ + "]"

	def _Esc(pcStr)
		_s_ = StzReplace("" + pcStr, char(92), char(92) + char(92))
		_s_ = StzReplace(_s_, char(34), char(92) + char(34))
		return _s_

	# Returns the narrated account of the incident, one line per fact.
	#
	#   returns    a list of text lines: header, message, events, attack path, blast radius, traces
	#              and notes
	#   see        Show, Timeline
	#@ aka  -- the narrated account ----------------------------------------
	def Explain()
		_aL_ = []
		_cH_ = "Incident " + @cId + " (" + @cSeverity + ", " + @cStatus + ") -- " + @cRule
		if @cActor != ""
			_cH_ += (" involving '" + @cActor + "'")
		ok
		_aL_ + _cH_
		_aL_ + ("  " + @cMessage)
		_aL_ + ("  " + ring_len(@aEvents) + " correlated event(s):")
		_nN_ = ring_len(@aEvents)
		for _i_ = 1 to _nN_
			_e_ = @aEvents[_i_]
			_cLine_ = "    " + _e_[:atWall] + "  " + _e_[:kind]
			if _e_[:actor] != ""
				_cLine_ += (" by " + _e_[:actor])
			ok
			if _e_[:subject] != ""
				_cLine_ += (" on " + _e_[:subject])
			ok
			_aL_ + _cLine_
		next
		_aPath_ = This.AttackPath()
		if ring_len(_aPath_) > 0
			_aL_ + ("  Attack path: " + This._Join(_aPath_, " -> ") +
				"  (" + (ring_len(_aPath_) - 1) + " hop(s))")
		but @oGraph != "" and @cActor != ""
			_aL_ + "  Attack path: none -- this actor cannot reach an effectful capability."
		ok
		_aBlast_ = This.BlastRadius()
		_nB_ = ring_len(_aBlast_)
		for _i_ = 1 to _nB_
			_aL_ + ("  Blast radius of '" + _aBlast_[_i_][1] + "': " +
				ring_len(_aBlast_[_i_][2]) + " node(s) -- " +
				This._Join(_aBlast_[_i_][2], ", "))
		next
		_aT_ = This.TraceIds()
		if ring_len(_aT_) > 0
			_aL_ + ("  Traces (ask stzLog.OfTrace): " + This._Join(_aT_, ", "))
		ok
		_nNotes_ = ring_len(@aNotes)
		for _i_ = 1 to _nNotes_
			_aL_ + ("  [" + @aNotes[_i_][2] + "] " + @aNotes[_i_][3])
		next
		return _aL_

	# Prints the narrated account of the incident, one line per fact.
	#
	#   returns    nothing; it prints
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	  #-- internals ----------------------------------------------------

	# "credential-stuffing/victim" -> "victim"; "" when the story names
	# no single actor.
	def _ActorOf(pcWhere)
		_n_ = StzFindFirst("/", pcWhere)
		if _n_ = 0
			return ""
		ok
		return StzMidToEnd(pcWhere, _n_ + 1)

	# One honest hop: the actor's own events, plus everything sharing a
	# trace id with them.
	def _Correlate(paCase, poLedger)
		_aSeed_ = []
		if @cActor != ""
			_aSeed_ = poLedger.OfActor(@cActor)
		ok
		if ring_len(_aSeed_) = 0
			_aSeed_ = paCase[:recent]
		ok
		_aOut_ = []
		_nS_ = ring_len(_aSeed_)
		for _i_ = 1 to _nS_
			This._AddUnique(_aOut_, _aSeed_[_i_])
		next
		# expand by trace id
		_aTraces_ = []
		for _i_ = 1 to ring_len(_aOut_)
			_c_ = "" + _aOut_[_i_][:traceId]
			if _c_ != "" and ring_find(_aTraces_, _c_) = 0
				_aTraces_ + _c_
			ok
		next
		_nT_ = ring_len(_aTraces_)
		for _i_ = 1 to _nT_
			_aByTrace_ = poLedger.OfTrace(_aTraces_[_i_])
			_nB_ = ring_len(_aByTrace_)
			for _j_ = 1 to _nB_
				This._AddUnique(_aOut_, _aByTrace_[_j_])
			next
		next
		_aOut_ = This._SortByWall(_aOut_)
		# bounded: a story, not an archive (keep the NEWEST)
		_nO_ = ring_len(_aOut_)
		if _nO_ > @nMaxEvents
			_aTrim_ = []
			for _i_ = _nO_ - @nMaxEvents + 1 to _nO_
				_aTrim_ + _aOut_[_i_]
			next
			return _aTrim_
		ok
		return _aOut_

	def _AddUnique(paList, paEvent)
		_cKey_ = "" + paEvent[:atWall] + "|" + paEvent[:kind] + "|" +
			paEvent[:actor] + "|" + paEvent[:subject]
		_n_ = ring_len(paList)
		for _i_ = 1 to _n_
			_cOther_ = "" + paList[_i_][:atWall] + "|" + paList[_i_][:kind] + "|" +
				paList[_i_][:actor] + "|" + paList[_i_][:subject]
			if _cOther_ = _cKey_
				return
			ok
		next
		paList + paEvent

	# insertion sort on wall time -- the axis a human reasons on
	def _SortByWall(paList)
		_aOut_ = []
		_n_ = ring_len(paList)
		for _i_ = 1 to _n_
			_nAt_ = ring_len(_aOut_) + 1
			for _j_ = 1 to ring_len(_aOut_)
				if paList[_i_][:atWall] < _aOut_[_j_][:atWall]
					_nAt_ = _j_
					exit
				ok
			next
			_aNew_ = []
			for _k_ = 1 to _nAt_ - 1
				_aNew_ + _aOut_[_k_]
			next
			_aNew_ + paList[_i_]
			for _k_ = _nAt_ to ring_len(_aOut_)
				_aNew_ + _aOut_[_k_]
			next
			_aOut_ = _aNew_
		next
		return _aOut_

	def _DistinctOf(pcField)
		_a_ = []
		_n_ = ring_len(@aEvents)
		for _i_ = 1 to _n_
			_c_ = "" + @aEvents[_i_][pcField]
			if _c_ != "" and ring_find(_a_, _c_) = 0
				_a_ + _c_
			ok
		next
		return _a_

	def _Note(pcNote)
		@aNotes + [ StzEngineTimeWallMs(), @cStatus, "" + pcNote ]

	def _Join(paList, pcSep)
		_c_ = ""
		_n_ = ring_len(paList)
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += pcSep
			ok
			_c_ += ("" + paList[_i_])
		next
		return _c_
