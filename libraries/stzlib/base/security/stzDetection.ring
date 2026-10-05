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
	  UNUSUAL   WhenKind(k).Unusual().Buckets(ms).AgainstBaseline(n)
	            .Sigma(z).AtLeast(m)                [+ PerActor()]
	            the newest window judged against the SAME kind's own
	            history (threat-model R9). The three shapes above need a
	            threshold somebody wrote down; this one learns it. Password
	            spraying -- one failure on each of fifty accounts -- never
	            trips a per-account burst, and trips this at once.

	THE UNUSUAL SHAPE'S HONESTY RULES:
	  - LEAVE-ONE-OUT (perf law 6): the newest window is judged against
	    the windows BEFORE it, never a baseline that includes itself --
	    at n=10 an inclusive z can never exceed 3.0, so a z>3 test on it
	    could never fire;
	  - a jump off a FLAT baseline is infinitely surprising, so it fires
	    on the floor (AtLeast) alone;
	  - COLD START IS NOT AN ANOMALY: until the ledger reaches back over
	    at least three baseline windows, it says nothing;
	  - A STORM THAT EVICTED ITS OWN BASELINE IS REPORTED, not silenced:
	    the ledger's window is bounded, so a flood can push the history
	    out of reach -- when events were evicted and fewer than three
	    baseline windows remain, the finding says so, as a warning.

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

	_d9_ = new stzDetection("password-spraying")
	_d9_.WhenKind("auth.login.failed").Unusual().Buckets(60000).AgainstBaseline(30).Sigma(3).AtLeast(10)
	_d9_.Explaining("sign-in failures across the whole installation far above their own history -- one guess on each of many accounts never trips a per-account burst")
	_oS_.Add(_d9_)

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

# Declares one rule over a sequence of security events and judges a ledger against it, answering findings.
#
# Four shapes, each computable over a bounded ledger without a query language: a burst (n events of
# one kind inside a window), a sequence (one kind followed by another), any (one occurrence is the
# story) and unusual (the newest window judged against the same kind's own history, so the threshold
# is learned instead of written down). The unusual shape is honest: the newest window is judged
# against the windows before it, a cold start says nothing, and a flood that evicted its own
# baseline is reported as a warning. Findings come in the unified shape [ :rule, :subject, :where,
# :severity, :message ], so they join stzRuleReport. Corroborated holds an error back to a warning
# until two distinct event kinds agree. A detection with nothing watched raises when asked to judge.
#
#   receiver   o1 = new stzDetection("credential-stuffing")
#   example    o1.WhenKind("auth.login.failed").PerActor().Repeats(5).Within(60000)
#              ? o1.Shape()
#              #--> burst
#   see        stzDetectionSet, stzSecurityLedger, stzSecurityEvent
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
	@nBucketMs = 60000	# unusual: the width of one window
	@nBaseline = 12		# unusual: how many prior windows form the baseline
	@nSigma = 3		# unusual: how many standard deviations is unusual
	@nFloor = 3		# unusual: never fire under this many in the window
	@nAsOf = 0		# unusual: judge at this wall time (0 = the newest event)
	@nEvicted = 0		# events the ledger's window no longer holds
	@nMaxFindings = 16	# bounded: a storm reports, it does not flood

	# Builds a detection of that name, which watches nothing yet and reports its findings at error severity.
	#
	#   pcName     the detection's name, which becomes the rule of its findings
	#   returns    nothing; the object is built
	#   see        WhenKind, Explaining
	def init(pcName)
		@cName = "" + pcName

	# Returns the detection's name, the rule its findings carry.
	#
	#   returns    a text
	#   see        Explain
	def Name()
		return @cName

	# Returns the event kind the detection watches, trimmed and in lower case.
	#
	#   returns    a text; empty until WhenKind sets it
	#   see        WhenKind
	def Kind()
		return @cKind

	# Returns which shape the detection has: burst, sequence, any or unusual.
	#
	#   returns    a text; empty until a declaring call sets it
	#   see        WhenKind, Repeats, ThenKind, Unusual
	def Shape()
		return @cShape

	# Returns the severity its findings carry, which is error until AsWarning or AsInfo changes it.
	#
	#   returns    a text
	#   see        AsError, AsWarning, AsInfo
	def Severity()
		return @cSeverity

	# Returns the sentence given by Explaining, which is added to every finding message.
	#
	#   returns    a text; empty until Explaining sets it
	#   see        Explaining
	def Meaning()
		return @cMeaning

	# Sets the event kind to watch, and makes the shape any when no shape was chosen yet.
	#
	#   pcKind     the event kind to watch, trimmed and put in lower case
	#   returns    the detection itself, so calls chain
	#   note       start every detection with it
	#   warning    the kind is not checked against the catalog, so a misspelled kind watches nothing
	#              and never fires
	#   see        ThenKind, Repeats, OnAnyOccurrence
	#@ aka  -- declaring ---------------------------------------------------
	def WhenKind(pcKind)
		@cKind = StzLower(ring_trim("" + pcKind))
		if @cShape = ""
			@cShape = "any"
		ok
		return This

	# Makes the detection a burst: this many events of the watched kind inside the window fire it.
	#
	#   pnTimes    how many events make a burst
	#   returns    the detection itself, so calls chain
	#   note       the BURST shape of stzDetection
	#   warning    without Within the window is 0 ms, so only events stamped with the same
	#              millisecond count together
	#   see        Within, PerActor
	#@ aka  BURST: n of them...
	def Repeats(pnTimes)
		@nRepeats = pnTimes
		@cShape = "burst"
		return This

	# Sets the window of a burst or a sequence, in milliseconds of event wall time.
	#
	#   pnMs       the window length, in milliseconds
	#   returns    the detection itself, so calls chain
	#   see        Repeats, ThenKind
	#@ aka  ...inside this window (ms of wall time).
	def Within(pnMs)
		@nWindowMs = pnMs
		return This

	# Counts events actor by actor instead of across all actors, for a burst or an unusual rate.
	#
	#   returns    the detection itself, so calls chain
	#   note       credential stuffing is per account, not per installation
	#   see        Repeats, Unusual
	#@ aka  count per actor rather than across all actors -- credential stuffing is per account, not per installation.
	def PerActor()
		@bPerActor = 1
		return This

	# Makes the detection a sequence: an event of this kind must follow one of the watched kind.
	#
	#   pcKind     the event kind that must follow, trimmed and put in lower case
	#   returns    the detection itself, so calls chain
	#   warning    the kind is not checked against the catalog, so a misspelled kind never follows
	#              and the detection never fires
	#   see        WhenKind, Within, BySameActor
	#@ aka  SEQUENCE: this kind must follow the watched one.
	def ThenKind(pcKind)
		@cThenKind = StzLower(ring_trim("" + pcKind))
		@cShape = "sequence"
		return This

	# Requires both events of a sequence to come from the same actor.
	#
	#   returns    the detection itself, so calls chain
	#   note       without it the whole ledger counts as one actor and a sequence gives one finding
	#              in all
	#   see        ThenKind
	def BySameActor()
		@bSameActor = 1
		return This

	# Makes the detection fire on any single event of the watched kind, for kinds where one occurrence is already the story.
	#
	#   returns    the detection itself, so calls chain
	#   note       one finding per matching event, at most 16
	#   see        WhenKind
	#@ aka  ANY: one occurrence is already the story.
	def OnAnyOccurrence()
		@cShape = "any"
		return This

	# Makes the detection judge the newest window of the watched kind against the history of that same kind.
	#
	#   returns    the detection itself, so calls chain
	#   note       the defaults are windows of 60000 ms, a baseline of 12 windows, 3 sigma and a
	#              floor of 3 (threat model R9)
	#   see        Buckets, AgainstBaseline, Sigma, AtLeast
	#@ aka  UNUSUAL: the newest window against the kind's own history.
	def Unusual()
		@cShape = "unusual"
		return This

	# Sets the width of one window of the unusual shape, in milliseconds.
	#
	#   pnMs       the window width, in milliseconds, at least 1
	#   returns    the detection itself, so calls chain
	#   note       the baseline is this width times AgainstBaseline
	#   warning    a width below 1 raises an error, and a value that is not a number raises R41
	#   see        Unusual, AgainstBaseline
	def Buckets(pnMs)
		if pnMs < 1
			stzraise("stzDetection.Buckets: a window is at least 1 ms.")
		ok
		@nBucketMs = pnMs
		return This

	# Sets how many windows before the newest one form the baseline of the unusual shape.
	#
	#   pnBuckets   the number of baseline windows, at least 3
	#   returns     the detection itself, so calls chain
	#   note        the newest window is judged against the windows before it, never against a
	#               baseline that includes itself
	#   warning     fewer than 3 raises an error; until the ledger reaches back over 3 baseline
	#               windows nothing is said, because a cold start is not an anomaly
	#   see         Buckets, Sigma
	def AgainstBaseline(pnBuckets)
		if pnBuckets < 3
			stzraise("stzDetection.AgainstBaseline: a baseline is at least 3 windows.")
		ok
		@nBaseline = pnBuckets
		return This

	# Sets how many standard deviations above the baseline mean make a window unusual.
	#
	#   pnZ        the number of standard deviations
	#   returns    the detection itself, so calls chain
	#   note       on a flat baseline, where the windows before all hold the same count, sigma is
	#              not used: any count above that mean and at or over the floor fires
	#   see        AtLeast, Unusual
	def Sigma(pnZ)
		@nSigma = pnZ
		return This

	# Sets the floor of the unusual shape: a window with fewer events than this never fires.
	#
	#   pnCount    the smallest number of events in the newest window that can fire
	#   returns    the detection itself, so calls chain
	#   see        Sigma, Unusual
	def AtLeast(pnCount)
		@nFloor = pnCount
		return This

	# Judges the unusual shape at a given wall time instead of at the newest event, so a guard can be exact.
	#
	#   pnWallMs   the moment of judgement, in epoch milliseconds, 0 for the newest event
	#   returns    the detection itself, so calls chain
	#   see        Unusual, Buckets
	def AsOf(pnWallMs)
		@nAsOf = pnWallMs
		return This

	# Marks the detection so that an error finding drops to a warning unless the matched events span two distinct kinds.
	#
	#   returns    the detection itself, so calls chain
	#   note       the corroboration law: one anomalous signal is a rumor, and the message says it
	#              is a single signal
	#   see        AsError, CheckAgainst
	#@ aka  The corroboration law: no error-severity alarm on a single signal -- one anomalous read is a rumor.
	def Corroborated()
		@bCorroborated = 1
		return This

	# Sets the one-sentence meaning that is added to every finding message and to the explanation.
	#
	#   pcMeaning   what the detection means, as text
	#   returns     the detection itself, so calls chain
	#   see         Meaning, Explain
	def Explaining(pcMeaning)
		@cMeaning = "" + pcMeaning
		return This

	# Sets the severity of the findings to error.
	#
	#   returns    the detection itself, so calls chain
	#   see        AsWarning, AsInfo, Corroborated
	def AsError()
		@cSeverity = "error"
		return This

	# Sets the severity of the findings to warning.
	#
	#   returns    the detection itself, so calls chain
	#   see        AsError, AsInfo
	def AsWarning()
		@cSeverity = "warning"
		return This

	# Sets the severity of the findings to info.
	#
	#   returns    the detection itself, so calls chain
	#   see        AsError, AsWarning
	def AsInfo()
		@cSeverity = "info"
		return This

	# Judges a ledger and returns the findings in the unified rule shape, ready for stzRuleReport.
	#
	#   poLedger   the stzSecurityLedger to judge, read through its retained window
	#   returns    a list of [ :rule, :subject, :where, :severity, :message ] findings; [ ] when
	#              nothing matches
	#   note       the subject is security and where is the detection name, then a slash and the
	#              actor when there is one; at most 16 findings, so a storm reports and does not
	#              flood
	#   warning    raises an error when nothing is watched, so call WhenKind first
	#   see        LastEvidence, Corroborated, Explain
	#@ aka  -- judging -----------------------------------------------------
	def CheckAgainst(poLedger)
		@aEvidence = []
		if @cKind = ""
			stzraise("stzDetection '" + @cName + "': nothing is watched -- say WhenKind(...) first.")
		ok
		_aAll_ = poLedger.All()
		@nEvicted = poLedger.Count() - poLedger.Size()
		if @cShape = "unusual"
			return This._CheckUnusual(_aAll_)
		ok
		if @cShape = "burst"
			return This._CheckBurst(_aAll_)
		but @cShape = "sequence"
			return This._CheckSequence(_aAll_)
		ok
		return This._CheckAny(_aAll_)

	# Returns the events that matched in the last check, so an incident can build its timeline from them.
	#
	#   returns    a list of records; [ ] before any check or when nothing matched
	#   see        CheckAgainst
	def LastEvidence()
		return @aEvidence

	# Returns the detection told as lines of text: its shape with its numbers, and its meaning when given.
	#
	#   returns    a list of text
	#   note       the first line reads Detection name [severity] followed by the shape
	#   see        Show, Explaining
	#@ aka  -- legibility --------------------------------------------------
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
		but @cShape = "unusual"
			_cD_ += ("an unusual rate of " + @cKind + ": " + @nBucketMs +
				"ms windows against the " + @nBaseline + " before, over " +
				@nSigma + " sigma and at least " + @nFloor)
			if @bPerActor
				_cD_ += ", per actor"
			ok
		else
			_cD_ += ("any " + @cKind)
		ok
		_aL_ + _cD_
		if @cMeaning != ""
			_aL_ + ("  " + @cMeaning)
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

	# The newest window against the windows before it, per group.
	def _CheckUnusual(paAll)
		_aOut_ = []
		_nN_ = ring_len(paAll)
		if _nN_ = 0
			return _aOut_
		ok
		_nT_ = @nAsOf
		if _nT_ = 0
			_nT_ = paAll[_nN_][:atWall]
		ok
		_nW_ = @nBucketMs
		# how many prior windows the retained ledger fully covers
		_nOldest_ = paAll[1][:atWall]
		_nCovered_ = 0
		for _k_ = 1 to @nBaseline
			if _nOldest_ <= (_nT_ - ((_k_ + 1) * _nW_))
				_nCovered_ = _k_
			else
				exit
			ok
		next
		_aGroups_ = This._GroupMatching(paAll, @cKind, @bPerActor)
		_nG_ = ring_len(_aGroups_)
		for _g_ = 1 to _nG_
			_cWho_ = _aGroups_[_g_][1]
			_aEv_ = _aGroups_[_g_][2]
			_aCounts_ = []
			for _k_ = 0 to @nBaseline
				_aCounts_ + 0
			next
			_aNow_ = []
			_nE_ = ring_len(_aEv_)
			for _e_ = 1 to _nE_
				_nAt_ = _aEv_[_e_][:atWall]
				if _nAt_ > _nT_
					loop
				ok
				_nK_ = floor((_nT_ - _nAt_) / _nW_)
				if _nK_ > @nBaseline
					loop
				ok
				_aCounts_[_nK_ + 1] = _aCounts_[_nK_ + 1] + 1
				if _nK_ = 0
					_aNow_ + _aEv_[_e_]
				ok
			next
			_nCur_ = _aCounts_[1]
			if _nCur_ < @nFloor
				loop
			ok
			_cBy_ = ""
			if @bPerActor
				_cBy_ = " by '" + _cWho_ + "'"
			ok
			if _nCovered_ < 3
				if @nEvicted > 0
					_aF_ = This._Finding(_cWho_, "" + _nCur_ + " x " + @cKind + _cBy_ +
						" in the last " + _nW_ + "ms, and the ledger evicted " + @nEvicted +
						" older event(s): the flood pushed its own baseline out of reach", _aNow_)
					_aF_[:severity] = "warning"
					_aOut_ + _aF_
				ok
				loop
			ok
			_nSum_ = 0
			for _k_ = 1 to _nCovered_
				_nSum_ += _aCounts_[_k_ + 1]
			next
			_nMean_ = _nSum_ / _nCovered_
			_nVar_ = 0
			for _k_ = 1 to _nCovered_
				_nD_ = _aCounts_[_k_ + 1] - _nMean_
				_nVar_ += (_nD_ * _nD_)
			next
			_nSd_ = sqrt(_nVar_ / _nCovered_)
			_cMsg_ = "" + _nCur_ + " x " + @cKind + _cBy_ + " in the last " + _nW_ +
				"ms against a mean of " + (floor(_nMean_ * 100) / 100) + " over the " +
				_nCovered_ + " window(s) before"
			if _nSd_ = 0
				if _nCur_ <= _nMean_
					loop
				ok
				_cMsg_ += " -- off a flat baseline"
			else
				_nZ_ = (_nCur_ - _nMean_) / _nSd_
				if _nZ_ < @nSigma
					loop
				ok
				_cMsg_ += (" -- " + (floor(_nZ_ * 10) / 10) + " sigma")
			ok
			_aOut_ + This._Finding(_cWho_, _cMsg_, _aNow_)
			if ring_len(_aOut_) >= @nMaxFindings
				exit
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

# Groups detections under one name and judges a ledger with all of them at once.
#
# StzDefaultDetectionSet builds the house set: credential stuffing, secret probing, escalation
# attempts, guess-then-reach, password spraying, a cloned authenticator, a replayed request, a
# forged request and a replayed assertion. The set keeps a copy of each detection added, so
# configure a detection before Add, or change it through DetectionQ. FiredNames gives the names an
# incident is opened from.
#
#   receiver   o1 = StzDefaultDetectionSet()
#   example    ? o1.NumberOfDetections()
#              #--> 9
#   see        stzDetection, stzSecurityLedger
class stzDetectionSet from stzObject

	@cName = ""
	@aDetections = []

	# Builds an empty set of detections with a name.
	#
	#   pcName     the set's name, as text
	#   returns    nothing; the object is built
	#   see        Add, StzDefaultDetectionSet
	def init(pcName)
		@cName = "" + pcName

	# Returns the name of the set.
	#
	#   returns    a text
	#   see        Explain
	def Name()
		return @cName

	# Adds a detection to the set, kept in the order added.
	#
	#   poDetection   the stzDetection to add, already configured
	#   returns       the set itself, so calls chain
	#   note          no check for a repeated name; DetectionQ finds the first
	#   warning       the set stores a COPY, so a change made to the original afterwards does not
	#                 reach it: configure before adding, or reach the stored one through DetectionQ
	#   see           DetectionQ, Names
	def Add(poDetection)
		@aDetections + poDetection
		return This

	# Returns how many detections the set holds.
	#
	#   returns    a number
	#   see        Names, Add
	def NumberOfDetections()
		return ring_len(@aDetections)

	# Returns the names of the detections, in the order they were added.
	#
	#   returns    a list of text
	#   see        DetectionQ, NumberOfDetections
	def Names()
		_a_ = []
		_n_ = ring_len(@aDetections)
		for _i_ = 1 to _n_
			_a_ + @aDetections[_i_].Name()
		next
		return _a_

	# Returns the stored detection of that name, so it can be configured or explained.
	#
	#   pcName     the detection's name, matched with case
	#   returns    a stzDetection
	#   note       a change made through it persists, which a change to the original passed to Add
	#              does not
	#   warning    an unknown name raises an error
	#   see        Names, Add
	def DetectionQ(pcName)
		_n_ = ring_len(@aDetections)
		for _i_ = 1 to _n_
			if @aDetections[_i_].Name() = pcName
				return @aDetections[_i_]
			ok
		next
		stzraise("stzDetectionSet '" + @cName + "': no detection named '" + pcName + "'.")

	# Judges a ledger with every detection and returns all findings, in the unified rule shape.
	#
	#   poLedger   the stzSecurityLedger to judge
	#   returns    a list of [ :rule, :subject, :where, :severity, :message ] findings; [ ] when
	#              nothing matches
	#   note       ready for stzRuleReport; the findings come detection by detection, in order
	#   see        FiredNames, stzDetection
	#@ aka  Judge a ledger with every detection; findings in the unified shape, ready for stzRuleReport.Ingest().
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

	# Returns the names of the detections that fired on a ledger, once each, in order.
	#
	#   poLedger   the stzSecurityLedger to judge
	#   returns    a list of text
	#   note       what an incident is opened from
	#   see        CheckAgainst
	#@ aka  The names that fired, in order (what an incident is opened from).
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

	# Returns the set told as lines of text: a header with the count, then each detection indented.
	#
	#   returns    a list of text
	#   see        Show, Names
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
