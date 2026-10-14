/*
	stzSecuritySentinel -- the watcher (incident I4).

	A detection set judges when asked. The sentinel asks ON A CADENCE
	and turns verdict TRANSITIONS into alerts -- the same shape the
	perf system proved (stzPerfSentinel), pointed at security:

		oSent = StzSecuritySentinel(StzDefaultDetectionSet())
		oSent.OnDetection(func aFinding { ? "ALERT: " + aFinding[:message] })
		oSent.OnClear(func cWhere { ? "cleared: " + cWhere })
		oSent.Check()                 # one pass -> fires transitions

	EDGE-TRIGGERED, and the identity of "a thing that fired" is the
	finding's :where -- `credential-stuffing/victim`, not merely
	`credential-stuffing`. Two accounts under attack are two stories,
	and one account still under attack is not a new one every second.
	An alarm that repeats itself is how real alarms get ignored (the
	lesson I3 paid for in its sequence shape).

	Three ways to run it, the house trio:
	  PULL    Check() whenever you like.
	  TICK    Every(ms) + Tick() from any loop you already run.
	  HOSTED  Name_() + Cycle() -- any stzAgentHost supervises it, so
	          a served application watches itself while serving.

	Every transition also fans out on the process-global event bus
	(`sec.detection` / `sec.clear`), so an agent supervised ON that
	channel wakes exactly when something fires -- and any part of the
	process can poll the counts without holding the sentinel.

	THE CASE SNAPSHOT: when something fires, the sentinel photographs
	what was 1 at that moment -- the finding, the ledger's head
	digest (which commits to the whole history), how many events
	existed, and the events nearest the firing. This is the perf
	black box in security clothes, and it is what I5's incident will
	be built from: the investigation should not have to re-derive the
	moment of detection later, when the window may have moved on.

	Deliberately NOT done: the sentinel does not write its own firings
	into the ledger as events. Detections over detection-events invite
	feedback, and the ledger is a record of what the SYSTEM did, not
	of what the watcher thought about it. The alert log is the
	watcher's own memory, kept separately and bounded.
*/

func StzSecuritySentinel(poDetectionSet)
	return new stzSecuritySentinel(poDetectionSet)

# Watches a security ledger on a cadence and raises an alert only when a detection starts or stops firing.
#
# A detection set judges when asked; the sentinel asks and turns the change of verdict into alerts.
# A detection is identified by its where text, so one account still under attack is not a new alert
# at each pass, and a returning attack, after a real clear, fires again. Each start records a case,
# a snapshot holding the finding, the ledger's head digest and the events nearest the firing; each
# start and clear is logged in the sentinel's own bounded log and announced on two process-wide
# event-bus channels. It runs three ways: Check on demand, Tick from any loop, or Cycle under an
# agent host. It reads the ledger and never writes into it. Test it on an in-memory ledger with
# invented events.
#
#   receiver   o1 = StzSecuritySentinel(StzDefaultDetectionSet())
#   example    oLed = StzSecurityLedger(64)
#              o1.Watching(oLed)
#              ? o1.Check()
#              #--> 0
#              for i = 1 to 5
#              	oE = StzSecurityEvent("auth.login.failed")
#              	oE.ByActorNamed("victim", "external")
#              	oE.About("user:victim")
#              	oE.Refused("scripted")
#              	oE.OccurredAt(1785600000000 + (i * 3000))
#              	oLed.Record(oE)
#              next
#              ? o1.Check()
#              #--> 1
#              ? o1.ActiveDetections()[1]
#              #--> credential-stuffing/victim
#              ? o1.Check()
#              #--> 0
#              oLed.Destroy()
#   see        stzAgentHost, stzSecurityLedger, stzResponsePlan
class stzSecuritySentinel from stzObject

	@cName = "security-sentinel"
	@oSet = ""
	@oLedger = ""		# NULL = watch the process ledger
	@aActive = []		# :where keys currently firing
	@fOnDetection = ""
	@fOnClear = ""
	@bHasOnDetection = 0
	@bHasOnClear = 0
	@cDetectionChannel = "sec.detection"
	@cClearChannel = "sec.clear"
	@oBus = ""
	@aAlertLog = []		# [ atMs, "detection"|"clear", where, message ] (256)
	@aCases = []		# case snapshots, newest 16
	@nEveryMs = 1000
	@nNextDueMs = 0
	@nChecks = 0

	# Builds a sentinel that judges the ledger with the given detection set.
	#
	#   poDetectionSet   the detection set whose findings the sentinel turns into alerts, such as
	#                    the one StzDefaultDetectionSet returns
	#   returns          nothing; the object is built
	#   note             without Watching, the process-wide ledger is the one watched
	#   see              Watching, Check
	def init(poDetectionSet)
		@oSet = poDetectionSet
		@oBus = new stzEventBus()

	# Returns the sentinel's name, security-sentinel until it is renamed.
	#
	#   returns    a text
	#   see        SetName, Name_
	def Name()
		return @cName

	# Returns the sentinel's name, the way an agent host asks for it.
	#
	#   returns    a text
	#   see        Name, Cycle
	def Name_()
		return @cName

	# Gives the sentinel a name, which an agent host uses to tell its agents apart.
	#
	#   pcName     the new name
	#   returns    the sentinel itself, so calls chain
	#   see        Name, Cycle
	def SetName(pcName)
		if isString(pcName) and pcName != ""
			@cName = pcName
		ok
		return This

	# Points the sentinel at a given ledger instead of the process-wide one.
	#
	#   poLedger   the ledger to judge on every check
	#   returns    the sentinel itself, so calls chain
	#   see        Check, SetName
	#@ aka  Watch a specific ledger instead of the process one.
	def Watching(poLedger)
		@oLedger = poLedger
		return This

	# Sets the function called once for each detection that starts firing.
	#
	#   pfCallback   a function that receives the finding, a hash list with the keys rule, severity,
	#                where and message
	#   returns      the sentinel itself, so calls chain
	#   note         a detection already firing does not call it again until it has cleared
	#   see          OnClear, Check
	def OnDetection(pfCallback)
		@fOnDetection = pfCallback
		@bHasOnDetection = 1
		return This

	# Sets the function called once for each detection that stops firing.
	#
	#   pfCallback   a function that receives the where text of the detection that cleared
	#   returns      the sentinel itself, so calls chain
	#   see          OnDetection, Check
	def OnClear(pfCallback)
		@fOnClear = pfCallback
		@bHasOnClear = 1
		return This

	# Sets the two event-bus channels on which firings and clearings are announced.
	#
	#   pcDetection   the channel name for a detection that starts
	#   pcClear       the channel name for one that clears
	#   returns       the sentinel itself, so calls chain
	#   note          the defaults are sec.detection and sec.clear; the channels are process-wide,
	#                 so other code can wait on them
	#   see           DetectionChannel, ClearChannel
	def SetChannels(pcDetection, pcClear)
		@cDetectionChannel = "" + pcDetection
		@cClearChannel = "" + pcClear
		return This

	# Returns the event-bus channel on which new detections are announced.
	#
	#   returns    a text
	#   see        SetChannels, ClearChannel
	def DetectionChannel()
		return @cDetectionChannel

	# Returns the event-bus channel on which cleared detections are announced.
	#
	#   returns    a text
	#   see        SetChannels, DetectionChannel
	def ClearChannel()
		return @cClearChannel

	# Sets the cadence of Tick, in milliseconds.
	#
	#   pnMs       the minimum time between two ticks that check
	#   returns    the sentinel itself, so calls chain
	#   note       the default is 1000
	#   see        Tick, Cycle
	def Every(pnMs)
		if isNumber(pnMs) and pnMs >= 1
			@nEveryMs = pnMs
		ok
		return This

	# Judges the ledger once and fires only what changed since the last pass: new detections start, ended ones clear.
	#
	#   returns    a number, how many detections started firing in this pass
	#   note       the identity of a detection is its where text, such as credential-
	#              stuffing/victim, so two accounts under attack are two alerts and one account
	#              still under attack is not a new alert; each start also records a case
	#   see        Tick, ActiveDetections, OnDetection
	#@ aka  -- watching -----------------------------------------------------
	def Check()
		_oLed_ = This._Ledger()
		if _oLed_ = ""
			return 0
		ok
		@nChecks++
		_aF_ = @oSet.CheckAgainst(_oLed_)
		_aNow_ = []
		_nLen_ = ring_len(_aF_)
		for _i_ = 1 to _nLen_
			_aNow_ + _aF_[_i_][:where]
		next
		_nNew_ = 0
		for _i_ = 1 to _nLen_
			if ring_find(@aActive, _aF_[_i_][:where]) = 0
				This._FireDetection(_aF_[_i_], _oLed_)
				_nNew_++
			ok
		next
		_nA_ = ring_len(@aActive)
		for _i_ = 1 to _nA_
			if ring_find(_aNow_, @aActive[_i_]) = 0
				This._FireClear(@aActive[_i_])
			ok
		next
		@aActive = _aNow_
		return _nNew_

	# Checks the ledger when the cadence says it is due, and does nothing before.
	#
	#   returns    a number, how many detections started firing, or 0 when the tick was not due
	#   note       the clock is monotonic, so a change of the wall clock does not disturb it
	#   see        Check, Every, Cycle
	#@ aka  Cadence-gated on the monotonic clock -- call from any loop.
	def Tick()
		_nNow_ = StzEngineWatchTimestampMs()
		if _nNow_ < @nNextDueMs
			return 0
		ok
		@nNextDueMs = _nNow_ + @nEveryMs
		return This.Check()

	# The agent-host contract: watching IS this agent's act.
	def Cycle()
		return This.Tick()

	# Returns how many passes have judged the ledger.
	#
	#   returns    a number
	#   see        Check
	def CheckCount()
		return @nChecks

	# Returns the where text of every detection that is firing now.
	#
	#   returns    a list of texts, empty when quiet
	#   see        IsFiring, Check
	#@ aka  -- reading ------------------------------------------------------
	def ActiveDetections()
		return @aActive

	# TRUE if at least one detection is firing.
	#
	#   returns    TRUE or FALSE
	#   see        ActiveDetections
	def IsFiring()
		return ring_len(@aActive) > 0

	# Returns the sentinel's own log of starts and clears, oldest first.
	#
	#   returns    a list of entries, each a list of the monotonic time in milliseconds, the kind
	#              detection or clear, the where text and the message
	#   note       the log keeps the newest 256 entries; it is not written to the ledger, so
	#              detections over detections cannot feed back
	#   see        LastAlert
	def AlertLog()
		return @aAlertLog

	# Returns the newest entry of the alert log, or an empty list when nothing has fired.
	#
	#   returns    a list of time, kind, where and message
	#   see        AlertLog
	def LastAlert()
		_n_ = ring_len(@aAlertLog)
		if _n_ = 0
			return []
		ok
		return @aAlertLog[_n_]

	# Returns the snapshots taken when detections started firing, oldest first.
	#
	#   returns    a list of hash lists, each with the keys at, where, rule, severity, message,
	#              ledgercount, headdigest and recent
	#   note       only the newest 16 are kept; the keys are lower case: ledgercount, headdigest
	#   see        LastCase
	#@ aka  The case snapshots taken at firing time (newest last).
	def Cases()
		return @aCases

	# Returns the newest case snapshot, or an empty list when nothing has fired.
	#
	#   returns    a hash list with the keys at, where, rule, severity, message, ledgercount,
	#              headdigest and recent
	#   note       headdigest is a 64-character digest committing to the whole ledger history at
	#              that moment, and recent holds the events nearest the firing
	#   see        Cases
	def LastCase()
		_n_ = ring_len(@aCases)
		if _n_ = 0
			return []
		ok
		return @aCases[_n_]

	# Returns the sentinel's state as lines of text: its name, its check count and one line for each firing detection.
	#
	#   returns    a list of texts
	#   see        Show, ActiveDetections
	def Explain()
		_aL_ = []
		_cS_ = "quiet"
		if ring_len(@aActive) > 0
			_cS_ = "" + ring_len(@aActive) + " active detection(s)"
		ok
		_aL_ + ("Sentinel " + @cName + " -- " + @nChecks + " check(s), " + _cS_ + ".")
		_nA_ = ring_len(@aActive)
		for _i_ = 1 to _nA_
			_aL_ + ("  FIRING: " + @aActive[_i_])
		next
		return _aL_

	# Prints the lines of Explain.
	#
	#   returns    nothing; it prints lines
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	  #-- internals ----------------------------------------------------

	def _Ledger()
		if @oLedger != ""
			return @oLedger
		ok
		return StzSecurityLedgerQ()

	def _FireDetection(paFinding, poLedger)
		This._Log("detection", paFinding[:where], paFinding[:message])
		This._RecordCase(paFinding, poLedger)
		@oBus.Emit(@cDetectionChannel, paFinding[:where] + " | " + paFinding[:message])
		if @bHasOnDetection
			_f_ = @fOnDetection
			call _f_(paFinding)
		ok

	def _FireClear(pcWhere)
		This._Log("clear", pcWhere, "no longer firing")
		@oBus.Emit(@cClearChannel, pcWhere + " | cleared")
		if @bHasOnClear
			_f_ = @fOnClear
			call _f_(pcWhere)
		ok

	def _Log(pcKind, pcWhere, pcMessage)
		@aAlertLog + [ StzEngineWatchTimestampMs(), pcKind, pcWhere, pcMessage ]
		if ring_len(@aAlertLog) > 256
			del(@aAlertLog, 1)
		ok

	# The photograph: what was true at the moment of firing.
	def _RecordCase(paFinding, poLedger)
		@aCases + [
			:at = StzEngineTimeWallMs(),
			:where = paFinding[:where],
			:rule = paFinding[:rule],
			:severity = paFinding[:severity],
			:message = paFinding[:message],
			:ledgerCount = poLedger.Count(),
			:headDigest = poLedger.Digest(),
			:recent = poLedger.Recent(8)
		]
		if ring_len(@aCases) > 16
			del(@aCases, 1)
		ok
