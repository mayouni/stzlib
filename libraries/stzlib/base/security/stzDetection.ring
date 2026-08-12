/*
	stzDetection / stzDetectionSet -- detection over SEQUENCES
	(incident I3).

	Every rule the library owns until now judges STRUCTURE AT ONE
	INSTANT: a graph rule asks whether a sandboxed actor can reach an
	effectful capability, a posture invariant asks what is 1 right
	now. But an incident is a STORY -- five failed logins inside a
	minute, or a failed login followed by a reach for a secret. No
	rule shape in the library could say that. This is that shape.

		oD = StzDetection("credential-stuffing")
		oD.WhenKind("auth.login.failed").PerActor().Repeats(5).Within(60000)

		oD2 = StzDetection("guess-then-reach")
		oD2.WhenKind("auth.login.failed").ThenKind("secret.reveal.refused")
		   .BySameActor().Within(300000)

		oD3 = StzDetection("cloned-authenticator")
		oD3.WhenKind("auth.passkey.clone_suspected").OnAnyOccurrence()

		aFindings = oD.CheckAgainst(oLedger)     # the unified rule shape

	THREE SHAPES, deliberately few, each computable over a bounded
	ledger without a query language:

	  BURST     WhenKind(k).Repeats(n).Within(ms)   [+ PerActor()]
	            n events of one kind inside a sliding window.
	  SEQUENCE  WhenKind(a).ThenKind(b).Within(ms)  [+ BySameActor()]
	            b arrives within ms after a.
	  ANY       WhenKind(k).OnAnyOccurrence()
	            for kinds where one occurrence is already the story
	            (a cloned authenticator, a replayed nonce).

	VERDICTS ARE FINDINGS in the house shape
	[ :rule, :subject, :where, :severity, :message ] with
	:subject = "security", so a detection joins stzRuleReport -- the
	ONE CI gate that already covers code, agents, security, workflow
	and orgcharts. A drill that trips a detection can fail a build
	exactly as a capability violation does.

	THE CORROBORATION LAW (incident law 4): Corroborated() marks a
	detection that must not raise an alarm on a single signal. Its
	finding reaches ERROR severity only when the matched evidence
	spans at least two distinct event kinds; on one kind it is
	emitted as a WARNING that says so. One anomalous read is a rumor.

	Evidence is kept: LastEvidence() returns the events that matched,
	so I5's incident can build a timeline from them rather than
	re-deriving it.
*/

func StzDetection(pcName)
	return new stzDetection(pcName)

func StzDetectionSet(pcName)
	return new stzDetectionSet(pcName)

/*
	The house detection content: what the library knows about its own
	catalog. An application adds its own; these ship because the kinds
	they watch are the library's own well-known names.
*/
func StzDefaultDetectionSet()
	_oS_ = new stzDetectionSet("softanza-default")

	_d1_ = new stzDetection("credential-stuffing")
	_d1_.WhenKind("auth.login.failed").PerActor().Repeats(5).Within(60000)
	_d1_.Explaining("repeated authentication failures against one account")
	_oS_.Add(_d1_)

	_d2_ = new stzDetection("secret-probing")
	_d2_.WhenKind("secret.reveal.refused").PerActor().Repeats(3).Within(300000)
	_d2_.Explaining("an actor repeatedly reaching for secrets it may not have")
	_oS_.Add(_d2_)

	_d3_ = new stzDetection("escalation-attempts")
	_d3_.WhenKind("capability.refused").PerActor().Repeats(3).Within(60000)
	_d3_.Explaining("an actor repeatedly attempting acts beyond its capabilities")
	_oS_.Add(_d3_)

	_d4_ = new stzDetection("guess-then-reach")
	_d4_.WhenKind("auth.login.failed").ThenKind("secret.reveal.refused")
	_d4_.BySameActor().Within(300000)
	_d4_.Explaining("a failed sign-in followed by a reach for a secret -- the classic shape of a stolen-credential attempt")
	_oS_.Add(_d4_)

	_d5_ = new stzDetection("cloned-authenticator")
	_d5_.WhenKind("auth.passkey.clone_suspected").OnAnyOccurrence()
	_d5_.Explaining("a signature counter that did not advance")
	_oS_.Add(_d5_)

	_d6_ = new stzDetection("replayed-request")
	_d6_.WhenKind("sig.nonce.replayed").OnAnyOccurrence()
	_d6_.Explaining("a nonce reused for the same key -- an active replay")
	_oS_.Add(_d6_)

	_d7_ = new stzDetection("forged-request")
	_d7_.WhenKind("sig.signature.forged").OnAnyOccurrence()
	_d7_.Explaining("a signature that did not verify -- forged, tampered, or wrong key")
	_oS_.Add(_d7_)

	_d8_ = new stzDetection("replayed-assertion")
	_d8_.WhenKind("sso.assertion.replayed").OnAnyOccurrence()
	_d8_.Explaining("a SAML assertion presented twice")
	_oS_.Add(_d8_)

	return _oS_


  #===============#
 #  A DETECTION  #
#===============#

class stzDetection from stzObject

	@cName = ""
	@cKind = ""		# the kind watched
	@cThenKind = ""		# sequence: the kind that must follow
	@cShape = ""		# burst | sequence | any
	@nRepeats = 0
	@nWindowMs = 0
	@bPerActor = 0
	@bSameActor = 0
	@bCorroborated = 0
	@cSeverity = "error"
	@cMeaning = ""
	@aEvidence = []		# the events that matched, last check
	@nMaxFindings = 16	# bounded: a storm reports, it does not flood

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	def Kind()
		return @cKind

	def Shape()
		return @cShape

	def Severity()
		return @cSeverity

	def Meaning()
		return @cMeaning

	  #-- declaring ---------------------------------------------------

	def WhenKind(pcKind)
		@cKind = StzLower(ring_trim("" + pcKind))
		if @cShape = ""
			@cShape = "any"
		ok
		return This

	# BURST: n of them...
	def Repeats(pnTimes)
		@nRepeats = pnTimes
		@cShape = "burst"
		return This

	# ...inside this window (ms of wall time).
	def Within(pnMs)
		@nWindowMs = pnMs
		return This

	# count per actor rather than across all actors -- credential
	# stuffing is per account, not per installation.
	def PerActor()
		@bPerActor = 1
		return This

	# SEQUENCE: this kind must follow the watched one.
	def ThenKind(pcKind)
		@cThenKind = StzLower(ring_trim("" + pcKind))
		@cShape = "sequence"
		return This

	def BySameActor()
		@bSameActor = 1
		return This

	# ANY: one occurrence is already the story.
	def OnAnyOccurrence()
		@cShape = "any"
		return This

	# The corroboration law: no error-severity alarm on a single
	# signal -- one anomalous read is a rumor.
	def Corroborated()
		@bCorroborated = 1
		return This

	def Explaining(pcMeaning)
		@cMeaning = "" + pcMeaning
		return This

	def AsError()
		@cSeverity = "error"
		return This

	def AsWarning()
		@cSeverity = "warning"
		return This

	def AsInfo()
		@cSeverity = "info"
		return This

	  #-- judging -----------------------------------------------------

	# Judge a ledger. Returns findings in the unified rule shape --
	# hand them to stzRuleReport.Ingest().
	def CheckAgainst(poLedger)
		@aEvidence = []
		if @cKind = ""
			stzraise("stzDetection '" + @cName + "': nothing is watched -- say WhenKind(...) first.")
		ok
		_aAll_ = poLedger.All()
		if @cShape = "burst"
			return This._CheckBurst(_aAll_)
		but @cShape = "sequence"
			return This._CheckSequence(_aAll_)
		ok
		return This._CheckAny(_aAll_)

	def LastEvidence()
		return @aEvidence

	  #-- legibility --------------------------------------------------

	def Explain()
		_aL_ = []
		_cD_ = "Detection " + @cName + " [" + @cSeverity + "] -- "
		if @cShape = "burst"
			_cD_ += ("" + @nRepeats + "x " + @cKind + " within " + @nWindowMs + "ms")
			if @bPerActor
				_cD_ += ", per actor"
			ok
		but @cShape = "sequence"
			_cD_ += (@cKind + " then " + @cThenKind + " within " + @nWindowMs + "ms")
			if @bSameActor
				_cD_ += ", same actor"
			ok
		else
			_cD_ += ("any " + @cKind)
		ok
		_aL_ + _cD_
		if @cMeaning != ""
			_aL_ + ("  " + @cMeaning)
		ok
		return _aL_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	  #-- internals ---------------------------------------------------

	# n events of the watched kind inside a sliding window.
	def _CheckBurst(paAll)
		_aOut_ = []
		_aGroups_ = This._GroupMatching(paAll, @cKind, @bPerActor)
		_nG_ = ring_len(_aGroups_)
		for _g_ = 1 to _nG_
			_cWho_ = _aGroups_[_g_][1]
			_aEv_ = _aGroups_[_g_][2]
			_nN_ = ring_len(_aEv_)
			if _nN_ < @nRepeats
				loop
			ok
			# sliding window over wall time (events arrive in order)
			_nStart_ = 1
			for _nEnd_ = 1 to _nN_
				while _aEv_[_nEnd_][:atWall] - _aEv_[_nStart_][:atWall] > @nWindowMs
					_nStart_++
				end
				if (_nEnd_ - _nStart_ + 1) >= @nRepeats
					_aWin_ = []
					for _k_ = _nStart_ to _nEnd_
						_aWin_ + _aEv_[_k_]
					next
					_cMsg_ = "" + ring_len(_aWin_) + " x " + @cKind + " within " +
						@nWindowMs + "ms"
					if @bPerActor
						_cMsg_ += (" by '" + _cWho_ + "'")
					ok
					_aOut_ + This._Finding(_cWho_, _cMsg_, _aWin_)
					exit   # one finding per group is enough
				ok
			next
			if ring_len(_aOut_) >= @nMaxFindings
				exit
			ok
		next
		return _aOut_

	# b within the window after a. ONE finding per actor: five failed
	# logins followed by one secret reach is ONE story, not five --
	# a detection that repeats itself per matching pair is how alert
	# fatigue starts (found in the I3 demo, fixed here).
	def _CheckSequence(paAll)
		_aOut_ = []
		_aFiredFor_ = []
		_nN_ = ring_len(paAll)
		for _i_ = 1 to _nN_
			if paAll[_i_][:kind] != @cKind
				loop
			ok
			_cWho_ = "*"
			if @bSameActor
				_cWho_ = "" + paAll[_i_][:actor]
			ok
			if ring_find(_aFiredFor_, _cWho_) > 0
				loop
			ok
			for _j_ = _i_ + 1 to _nN_
				if paAll[_j_][:kind] != @cThenKind
					loop
				ok
				if paAll[_j_][:atWall] - paAll[_i_][:atWall] > @nWindowMs
					exit
				ok
				if @bSameActor and paAll[_j_][:actor] != paAll[_i_][:actor]
					loop
				ok
				_aPair_ = [ paAll[_i_], paAll[_j_] ]
				_cMsg_ = @cKind + " then " + @cThenKind + " within " +
					(paAll[_j_][:atWall] - paAll[_i_][:atWall]) + "ms"
				if @bSameActor
					_cMsg_ += (" by '" + paAll[_i_][:actor] + "'")
				ok
				_aOut_ + This._Finding(paAll[_i_][:actor], _cMsg_, _aPair_)
				_aFiredFor_ + _cWho_
				exit
			next
			if ring_len(_aOut_) >= @nMaxFindings
				exit
			ok
		next
		return _aOut_

	# one occurrence is the story.
	def _CheckAny(paAll)
		_aOut_ = []
		_nN_ = ring_len(paAll)
		for _i_ = 1 to _nN_
			if paAll[_i_][:kind] = @cKind
				_aOut_ + This._Finding(paAll[_i_][:actor],
					@cKind + " occurred", [ paAll[_i_] ])
				if ring_len(_aOut_) >= @nMaxFindings
					exit
				ok
			ok
		next
		return _aOut_

	# Group matching events, optionally by actor. Returns
	# [ [ who, [events...] ], ... ] -- "*" when not grouping.
	def _GroupMatching(paAll, pcKind, pbPerActor)
		_aG_ = []
		_nN_ = ring_len(paAll)
		for _i_ = 1 to _nN_
			if paAll[_i_][:kind] != pcKind
				loop
			ok
			_cWho_ = "*"
			if pbPerActor
				_cWho_ = "" + paAll[_i_][:actor]
			ok
			_nAt_ = 0
			_nG_ = ring_len(_aG_)
			for _k_ = 1 to _nG_
				if _aG_[_k_][1] = _cWho_
					_nAt_ = _k_
					exit
				ok
			next
			if _nAt_ = 0
				_aG_ + [ _cWho_, [ paAll[_i_] ] ]
			else
				_aG_[_nAt_][2] + paAll[_i_]
			ok
		next
		return _aG_

	# Build one finding, applying the corroboration law.
	def _Finding(pcWho, pcMessage, paEvidence)
		_nE_ = ring_len(paEvidence)
		for _i_ = 1 to _nE_
			@aEvidence + paEvidence[_i_]
		next
		_cSev_ = @cSeverity
		_cMsg_ = pcMessage
		if @cMeaning != ""
			_cMsg_ += (" -- " + @cMeaning)
		ok
		if @bCorroborated and _cSev_ = "error"
			if This._DistinctKinds(paEvidence) < 2
				_cSev_ = "warning"
				_cMsg_ += " (single signal: reported as a warning until a second, independent signal corroborates it)"
			ok
		ok
		_cWhere_ = @cName
		if pcWho != "" and pcWho != "*"
			_cWhere_ += ("/" + pcWho)
		ok
		return [ :rule = @cName, :subject = "security", :where = _cWhere_,
			:severity = _cSev_, :message = _cMsg_ ]

	def _DistinctKinds(paEvidence)
		_aK_ = []
		_nE_ = ring_len(paEvidence)
		for _i_ = 1 to _nE_
			if ring_find(_aK_, paEvidence[_i_][:kind]) = 0
				_aK_ + paEvidence[_i_][:kind]
			ok
		next
		return ring_len(_aK_)


  #====================#
 #  A SET OF THEM     #
#====================#

class stzDetectionSet from stzObject

	@cName = ""
	@aDetections = []

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	def Add(poDetection)
		@aDetections + poDetection
		return This

	def NumberOfDetections()
		return ring_len(@aDetections)

	def Names()
		_a_ = []
		_n_ = ring_len(@aDetections)
		for _i_ = 1 to _n_
			_a_ + @aDetections[_i_].Name()
		next
		return _a_

	def DetectionQ(pcName)
		_n_ = ring_len(@aDetections)
		for _i_ = 1 to _n_
			if @aDetections[_i_].Name() = pcName
				return @aDetections[_i_]
			ok
		next
		stzraise("stzDetectionSet '" + @cName + "': no detection named '" + pcName + "'.")

	# Judge a ledger with every detection; findings in the unified
	# shape, ready for stzRuleReport.Ingest().
	def CheckAgainst(poLedger)
		_aOut_ = []
		_n_ = ring_len(@aDetections)
		for _i_ = 1 to _n_
			_aF_ = @aDetections[_i_].CheckAgainst(poLedger)
			_nF_ = ring_len(_aF_)
			for _j_ = 1 to _nF_
				_aOut_ + _aF_[_j_]
			next
		next
		return _aOut_

	# The names that fired, in order (what an incident is opened from).
	def FiredNames(poLedger)
		_a_ = []
		_aF_ = This.CheckAgainst(poLedger)
		_n_ = ring_len(_aF_)
		for _i_ = 1 to _n_
			if ring_find(_a_, _aF_[_i_][:rule]) = 0
				_a_ + _aF_[_i_][:rule]
			ok
		next
		return _a_

	def Explain()
		_aL_ = []
		_aL_ + ("Detection set " + @cName + " -- " + ring_len(@aDetections) + " detection(s).")
		_n_ = ring_len(@aDetections)
		for _i_ = 1 to _n_
			_aSub_ = @aDetections[_i_].Explain()
			_nS_ = ring_len(_aSub_)
			for _j_ = 1 to _nS_
				_aL_ + ("  " + _aSub_[_j_])
			next
		next
		return _aL_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next
