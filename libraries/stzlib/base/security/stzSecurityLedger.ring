/*
	stzSecurityLedger -- evidence, not logging (incident I1).

	I0 gave refusals a shape; the ledger gives them a memory. It is a
	BOUNDED, HASH-CHAINED ring of security events living in the engine
	(engine/src/seclog.zig):

	    digest[i] = sha256( digest[i-1] || "|" || canonical[i] )

	so an edit to any entry invalidates every digest after it, and
	Verify() names the first broken link. The chain is computed IN THE
	ENGINE, never handed in -- a caller able to supply its own digest
	could forge history.

	    oLed = StzSecurityLedger(1024)
	    oLed.Record(oEvent)                      # O(1), bounded, chained
	    ? oLed.Count()                           # ever recorded
	    ? len(oLed.OfActor("advisor"))           # the analyst's pivots
	    ? oLed.Verify()[:intact]
	    oLed.SealTo("evidence.stzledger", cKey)  # keyed, verifiable export

	THE PIVOTS an investigation actually uses: OfActor, OfSubject,
	OfKind, OfTrace, OfOutcome, OfSeverity, Refusals, Since, Between,
	Recent. Each returns records in the I0 shape, reconstructed from
	the canonical line the engine stores.

	COPY LAW: the ring is an engine handle materialized at birth, so
	the seam face that records and the analyst face that reads are one
	truth (the P8 lesson, applied to evidence).

	BOUNDED MEANS FORGETTING, and the doc says so: past capacity the
	oldest events give way. Count() keeps counting, Size() is what
	remains, and a long slow campaign outruns the window unless it is
	sealed out. Verification after eviction is a WINDOW property: the
	first retained entry's predecessor is gone, so Verify() checks the
	consistency of what remains.

	WHAT THIS IS NOT: protection against an attacker already running
	code in this process -- such an attacker can append or wipe the
	ring. Hash chaining detects RETROACTIVE EDITS; the keyed seal makes
	an EXPORT that an editor cannot silently rewrite. Evidence-grade
	means exported.
*/

func StzSecurityLedger(pnCapacity)
	return new stzSecurityLedger(pnCapacity)

  #=========================================================#
 #  THE PROCESS LEDGER -- what the seams record into (I2)  #
#=========================================================#

/*
	A seam lives deep inside stzAuth, stzRequestSigner, stzPasskey...
	-- classes an application never constructs itself. Handing each one
	a ledger would mean wiring a dozen objects; instead the process
	holds ONE, exactly as it holds one trace scope (perf P9), and the
	seams record into it if it is open:

		StzOpenSecurityLedger(4096)      # from now on, refusals persist
		... the app runs ...
		? StzSecurityLedgerQ().Refusals()
		StzCloseSecurityLedger()

	CLOSED IS THE DEFAULT, and closed costs one boolean test at each
	seam -- the event object is not even built (constructing one reads
	two clocks and the trace scope). Nothing changes for an application
	that never opens a ledger; that is the perf-P3 discipline applied
	to security.
*/

/*
	The current-ledger slot lives IN THE ENGINE (seclog.zig), not in a
	Ring global -- exactly like the P9 trace scope, and for the same
	reason: a function cannot reliably write a Ring global, and a Ring
	copy of one would fork. Every accessor below is a thin call over
	that slot, so any face reaches the same ledger.
*/

func StzOpenSecurityLedger(pnCapacity)
	if StzSecurityLedgerIsOpen()
		return StzSecurityLedgerQ()
	ok
	_oLed_ = new stzSecurityLedger(pnCapacity)
	StzEngineSecLogSetCurrent(_oLed_.Handle())
	return _oLed_

func StzSecurityLedgerIsOpen()
	return StzEngineSecLogHasCurrent() = 1

# A wrapper bound to the process ledger. All state is engine-side, so a
# freshly built face is the same ledger -- no Ring global needed.
func StzSecurityLedgerQ()
	if NOT StzSecurityLedgerIsOpen()
		return ""
	ok
	_oLed_ = new stzSecurityLedger(1)
	_oLed_.AdoptHandle(StzEngineSecLogCurrent())
	return _oLed_

func StzCloseSecurityLedger()
	if NOT StzSecurityLedgerIsOpen()
		return
	ok
	# destroying the current ledger clears the engine slot too
	StzEngineSecLogDestroy(StzEngineSecLogCurrent())

# THE SEAM CALL: record an already-built event, if anyone is listening.
func StzRecordSecurityEvent(poEvent)
	if StzEngineSecLogHasCurrent() != 1
		return
	ok
	StzEngineSecLogCurrentAppend(poEvent.CanonicalString(), poEvent.AtWall(),
		StzSecuritySeverityCode(poEvent.Severity()))

# The one-liners a seam actually writes. Each returns before building
# anything when no ledger is open -- that is the zero-cost-when-off
# property, and it is why a seam can call these unconditionally.
func StzNoteRefusal(pcKind, pcActor, pcSubject, pcReason)
	if StzEngineSecLogHasCurrent() != 1
		return
	ok
	_e_ = new stzSecurityEvent(pcKind)
	_e_.ByActorNamed(pcActor, "")
	_e_.About(pcSubject)
	_e_.Refused(pcReason)
	StzRecordSecurityEvent(_e_)

func StzNoteRefusalFrom(pcKind, pcActor, pcSubject, pcReason, pcOrigin)
	if StzEngineSecLogHasCurrent() != 1
		return
	ok
	_e_ = new stzSecurityEvent(pcKind)
	_e_.ByActorNamed(pcActor, "")
	_e_.About(pcSubject)
	_e_.FromOrigin(pcOrigin)
	_e_.Refused(pcReason)
	StzRecordSecurityEvent(_e_)

# Neither a grant nor a refusal -- a fact (incident I2's session
# lifecycle). Same zero-cost-when-off shape as its siblings.
func StzNoteFact(pcKind, pcActor, pcSubject, pcWhat)
	if StzEngineSecLogHasCurrent() != 1
		return
	ok
	_e_ = new stzSecurityEvent(pcKind)
	_e_.ByActorNamed(pcActor, "")
	_e_.About(pcSubject)
	_e_.Observed(pcWhat)
	StzRecordSecurityEvent(_e_)

func StzNoteFactFrom(pcKind, pcActor, pcSubject, pcWhat, pcOrigin)
	if StzEngineSecLogHasCurrent() != 1
		return
	ok
	_e_ = new stzSecurityEvent(pcKind)
	_e_.ByActorNamed(pcActor, "")
	_e_.About(pcSubject)
	_e_.FromOrigin(pcOrigin)
	_e_.Observed(pcWhat)
	StzRecordSecurityEvent(_e_)

func StzNoteGrant(pcKind, pcActor, pcSubject)
	if StzEngineSecLogHasCurrent() != 1
		return
	ok
	_e_ = new stzSecurityEvent(pcKind)
	_e_.ByActorNamed(pcActor, "")
	_e_.About(pcSubject)
	_e_.Granted()
	StzRecordSecurityEvent(_e_)

func StzSecuritySeverityCode(pcSeverity)
	if pcSeverity = "error"
		return 2
	but pcSeverity = "warning"
		return 1
	ok
	return 0

# Verify a sealed export written by SealTo(). Returns
# [ :ok, :why, :count, :seal, :brokenAt ]. Without a key the chain is
# still checked; the seal check needs the key it was sealed with.
func StzVerifySealedLedger(pcPath, pcKey)
	if NOT fexists(pcPath)
		return [ :ok = 0, :why = "no such file: " + pcPath, :count = 0, :seal = "", :brokenAt = 0 ]
	ok
	_cRaw_ = read(pcPath)
	_aLines_ = StzSplit(_cRaw_, Char(10))
	_cSeal_ = ""
	_nDeclared_ = 0
	_cAttestor_ = ""
	_nAt_ = 0
	_aRows_ = []
	_nLen_ = ring_len(_aLines_)
	for _i_ = 1 to _nLen_
		_cL_ = ring_trim(_aLines_[_i_])
		if _cL_ = ""
			loop
		ok
		if StzFindFirst("# seal=", _cL_) = 1
			_cSeal_ = StzMidToEnd(_cL_, 8)
			loop
		ok
		if StzFindFirst("# count=", _cL_) = 1
			_nDeclared_ = number(StzMidToEnd(_cL_, 9))
			loop
		ok
		if StzFindFirst("# attestor=", _cL_) = 1
			_cAttestor_ = StzMidToEnd(_cL_, 12)
			loop
		ok
		if StzFindFirst("# at=", _cL_) = 1
			_nAt_ = number(StzMidToEnd(_cL_, 6))
			loop
		ok
		if StzFindFirst("#", _cL_) = 1
			loop
		ok
		_nTab_ = StzFindFirst(Char(9), _cL_)
		if _nTab_ = 0
			loop
		ok
		_aRows_ + [ StzLeft(_cL_, _nTab_ - 1), StzMidToEnd(_cL_, _nTab_ + 1) ]
	next

	if ring_len(_aRows_) = 0
		return [ :ok = 0, :why = "the file carries no entries", :count = 0, :seal = _cSeal_, :brokenAt = 0 ]
	ok
	if _nDeclared_ != ring_len(_aRows_)
		return [ :ok = 0, :why = "entry count does not match the header (" +
			ring_len(_aRows_) + " found, " + _nDeclared_ + " declared)",
			:count = ring_len(_aRows_), :seal = _cSeal_, :brokenAt = 0 ]
	ok

	# recompute the chain over the file
	_nRows_ = ring_len(_aRows_)
	for _i_ = 2 to _nRows_
		_cWant_ = StzEngineCryptoSha256(_aRows_[_i_ - 1][1] + "|" + _aRows_[_i_][2])
		if _cWant_ != _aRows_[_i_][1]
			return [ :ok = 0, :why = "the chain breaks at entry " + _i_ +
				" -- that record (or one before it) was edited",
				:count = _nRows_, :seal = _cSeal_, :brokenAt = _i_ ]
		ok
	next

	if pcKey != "" and _cSeal_ != ""
		_cWantSeal_ = StzEngineCryptoHmacSha256(pcKey,
			_aRows_[_nRows_][1] + "|" + _nRows_)
		if _cWantSeal_ != _cSeal_
			return [ :ok = 0, :why = "the chain is intact but the SEAL does not match this key",
				:count = _nRows_, :seal = _cSeal_, :brokenAt = 0 ]
		ok
	ok
	return [ :ok = 1, :why = "chain intact over " + _nRows_ + " entries",
		:count = _nRows_, :seal = _cSeal_, :brokenAt = 0,
		:attestor = _cAttestor_, :attestedAt = _nAt_,
		:headDigest = _aRows_[_nRows_][1] ]


/*
	Acquire evidence produced by ANOTHER process (incident I8): verify
	the sealed file first, then rebuild a working ledger from it.

	Returns [ :ok, :why, :ledger, :attestor, :count ]. The rebuilt
	ledger recomputes its own chain over the imported records -- the
	ORIGINAL chain lives in the file and was just verified; the copy is
	a working artifact for analysis, not a second original. Saying so
	matters: an investigator must never mistake a re-derived chain for
	the one that was sealed.
*/
func StzLedgerFromSealedFile(pcPath, pcKey)
	_aV_ = StzVerifySealedLedger(pcPath, pcKey)
	if NOT _aV_[:ok]
		return [ :ok = 0, :why = _aV_[:why], :ledger = "",
			:attestor = "", :count = 0 ]
	ok
	_cRaw_ = read("" + pcPath)
	_aLines_ = StzSplit(_cRaw_, Char(10))
	_oLed_ = new stzSecurityLedger(_aV_[:count] + 8)
	_nLen_ = ring_len(_aLines_)
	for _i_ = 1 to _nLen_
		_cL_ = ring_trim(_aLines_[_i_])
		if _cL_ = "" or StzFindFirst("#", _cL_) = 1
			loop
		ok
		_nTab_ = StzFindFirst(Char(9), _cL_)
		if _nTab_ = 0
			loop
		ok
		_cCanon_ = StzMidToEnd(_cL_, _nTab_ + 1)
		_aF_ = StzSplit(_cCanon_, "|")
		_nWall_ = 0
		_cSev_ = "info"
		if ring_len(_aF_) >= 11
			_cSev_ = _aF_[2]
			_nWall_ = number(_aF_[11])
		ok
		_oLed_.AppendCanonical(_cCanon_, _nWall_, StzSecuritySeverityCode(_cSev_))
	next
	return [ :ok = 1, :why = "acquired " + _aV_[:count] + " verified entr(ies)",
		:ledger = _oLed_, :attestor = _aV_[:attestor], :count = _aV_[:count] ]


class stzSecurityLedger from stzObject

	pHandle = ""
	bReady = 0
	bAdopted = 0	# bound to a ledger owned elsewhere (the process one)
	@nCapacity = 1024

	def init(pnCapacity)
		if isNumber(pnCapacity) and pnCapacity >= 1
			@nCapacity = pnCapacity
		ok
		# eager materialization (the copy law)
		pHandle = StzEngineSecLogCreate(@nCapacity)
		bReady = 1

	def _Ensure()
		if bReady = 0
			pHandle = StzEngineSecLogCreate(@nCapacity)
			bReady = 1
		ok

	def Handle()
		This._Ensure()
		return pHandle

	# Bind this face to a ledger owned elsewhere (the process ledger).
	# Destroy() will not free an adopted handle -- the owner does.
	def AdoptHandle(pEngineHandle)
		if bReady and NOT bAdopted
			StzEngineSecLogDestroy(pHandle)
		ok
		pHandle = pEngineHandle
		bReady = 1
		bAdopted = 1
		return This

	# The engine's own answer -- a face bound to the process ledger
	# (AdoptHandle) never knew the capacity it was created with.
	def Capacity()
		This._Ensure()
		return StzEngineSecLogCapacity(pHandle)

	  #-- recording ---------------------------------------------------

	# Append an stzSecurityEvent. The engine chains it; nothing about
	# the digest is under the caller's control.
	def Record(poEvent)
		This._Ensure()
		StzEngineSecLogAppend(pHandle, poEvent.CanonicalString(),
			poEvent.AtWall(), This._SevCode(poEvent.Severity()))
		return This

	# Append a canonical line directly -- the acquisition path (I8),
	# used when rebuilding a ledger from verified evidence. The chain
	# is recomputed here; it does not carry the original file's.
	def AppendCanonical(pcCanonical, pnWallMs, pnSeverityCode)
		This._Ensure()
		StzEngineSecLogAppend(pHandle, pcCanonical, pnWallMs, pnSeverityCode)
		return This

	# Events ever recorded (keeps counting past capacity).
	def Count()
		This._Ensure()
		return StzEngineSecLogCount(pHandle)

	# Events still retained in the window.
	def Size()
		This._Ensure()
		return StzEngineSecLogSize(pHandle)

	  #-- reading -----------------------------------------------------

	# The record at 1-based position i (oldest retained first), in the
	# I0 field shape plus its chain digest.
	def At(pnIndex)
		This._Ensure()
		_cCanon_ = StzEngineSecLogCanonicalAt(pHandle, pnIndex)
		if _cCanon_ = ""
			return []
		ok
		_aR_ = This._Parse(_cCanon_)
		_aR_ + [ :digest, StzEngineSecLogDigestAt(pHandle, pnIndex) ]
		return _aR_

	def All()
		This._Ensure()
		_aOut_ = []
		_nN_ = StzEngineSecLogSize(pHandle)
		for _i_ = 1 to _nN_
			_aOut_ + This.At(_i_)
		next
		return _aOut_

	def Recent(pnHowMany)
		_aAll_ = This.All()
		_nN_ = ring_len(_aAll_)
		_nFrom_ = _nN_ - pnHowMany + 1
		if _nFrom_ < 1
			_nFrom_ = 1
		ok
		_aOut_ = []
		for _i_ = _nFrom_ to _nN_
			_aOut_ + _aAll_[_i_]
		next
		return _aOut_

	  #-- the analyst's pivots ---------------------------------------

	def OfActor(pcActor)
		return This._Where(:actor, pcActor)

	def OfSubject(pcSubject)
		return This._Where(:subject, pcSubject)

	def OfKind(pcKind)
		return This._Where(:kind, pcKind)

	def OfTrace(pcTraceId)
		return This._Where(:traceId, pcTraceId)

	def OfOutcome(pcOutcome)
		return This._Where(:outcome, pcOutcome)

	def OfSeverity(pcSeverity)
		return This._Where(:severity, pcSeverity)

	def OfOrigin(pcOrigin)
		return This._Where(:origin, pcOrigin)

	# Everything that was not granted -- the signal to watch.
	# Refused and failed -- NOT "everything that is not granted". The
	# negative form was here too, and it was wrong the moment the OBSERVED
	# outcome arrived (I2's session seams): an expired session would have
	# been counted as a refusal by this pivot, in a system whose whole
	# point is that a warning must mean something. Kept in step with
	# stzSecurityEvent.IsRefusal(), deliberately as one positive list.
	def Refusals()
		_aOut_ = []
		_aAll_ = This.All()
		_nN_ = ring_len(_aAll_)
		for _i_ = 1 to _nN_
			if _aAll_[_i_][:outcome] = "refused" or _aAll_[_i_][:outcome] = "failed"
				_aOut_ + _aAll_[_i_]
			ok
		next
		return _aOut_

	def Since(pnWallMs)
		_aOut_ = []
		_aAll_ = This.All()
		_nN_ = ring_len(_aAll_)
		for _i_ = 1 to _nN_
			if _aAll_[_i_][:atWall] >= pnWallMs
				_aOut_ + _aAll_[_i_]
			ok
		next
		return _aOut_

	def Between(pnFromMs, pnToMs)
		_aOut_ = []
		_aAll_ = This.All()
		_nN_ = ring_len(_aAll_)
		for _i_ = 1 to _nN_
			if _aAll_[_i_][:atWall] >= pnFromMs and _aAll_[_i_][:atWall] <= pnToMs
				_aOut_ + _aAll_[_i_]
			ok
		next
		return _aOut_

	  #-- the chain ---------------------------------------------------

	# The head digest: one string that commits to the ENTIRE history
	# ever recorded (including evicted entries).
	def Digest()
		This._Ensure()
		return StzEngineSecLogHeadDigest(pHandle)

	def DigestAt(pnIndex)
		This._Ensure()
		return StzEngineSecLogDigestAt(pHandle, pnIndex)

	# [ :intact, :brokenAt, :message ] -- brokenAt is the 1-based index
	# of the first entry whose stored digest disagrees with a
	# recomputation, 0 when the retained window is consistent.
	def Verify()
		This._Ensure()
		_n_ = StzEngineSecLogVerify(pHandle)
		if _n_ = 0
			return [ :intact = 1, :brokenAt = 0,
				:message = "chain intact over " + This.Size() + " retained entr(ies)" ]
		ok
		return [ :intact = 0, :brokenAt = _n_,
			:message = "the chain breaks at entry " + _n_ +
				" -- that record (or one before it) was altered" ]

	  #-- sealing (evidence leaves the process) -----------------------

	# Write the retained window as a verifiable file: one
	# "<digest>TAB<canonical>" line per entry, a header carrying the
	# count and an HMAC seal over (head digest | count). Re-check it
	# with StzVerifySealedLedger(path, key) -- editing any line breaks
	# the chain; editing the seal without the key is not possible.
	# As SealTo, plus WHO attested and WHEN -- the custody header that
	# turns a sealed file into an attested one (I7). Unknown "#" lines
	# are ignored by verifiers, so the format stayed compatible.
	def SealAttestedTo(pcPath, pcKey, pcAttestor)
		This._Ensure()
		This.SealTo(pcPath, pcKey)
		_cRaw_ = read("" + pcPath)
		_cHdr_ = "# attestor=" + pcAttestor + Char(10)
		_cHdr_ += ("# at=" + StzEngineTimeWallMs() + Char(10))
		write("" + pcPath, _cHdr_ + _cRaw_)
		return This

	def SealTo(pcPath, pcKey)
		This._Ensure()
		_nN_ = StzEngineSecLogSize(pHandle)
		_cLast_ = ""
		_cBody_ = ""
		for _i_ = 1 to _nN_
			_cD_ = StzEngineSecLogDigestAt(pHandle, _i_)
			_cBody_ += (_cD_ + Char(9) + StzEngineSecLogCanonicalAt(pHandle, _i_) + Char(10))
			_cLast_ = _cD_
		next
		_cSeal_ = ""
		if pcKey != ""
			_cSeal_ = StzEngineCryptoHmacSha256(pcKey, _cLast_ + "|" + _nN_)
		ok
		_cOut_ = "# stzledger v1" + Char(10)
		_cOut_ += ("# count=" + _nN_ + Char(10))
		_cOut_ += ("# seal=" + _cSeal_ + Char(10))
		_cOut_ += _cBody_
		write("" + pcPath, _cOut_)
		return This

	  #-- interop: the evidence leaves in the industry's formats ------

	# Rebuild an event object from a stored record, so the export can
	# reuse the I0 serializers rather than re-inventing them.
	def _EventOf(paRec)
		_e_ = new stzSecurityEvent(paRec[:kind])
		_e_.ByActorNamed(paRec[:actor], paRec[:posture])
		_e_.About(paRec[:subject])
		_e_.Doing(paRec[:action])
		_e_.AtRisk(paRec[:risk])
		_e_.FromOrigin(paRec[:origin])
		if paRec[:outcome] = "granted"
			_e_.Granted()
		but paRec[:outcome] = "failed"
			_e_.Failed(paRec[:reason])
		else
			_e_.Refused(paRec[:reason])
		ok
		_e_.OccurredAt(paRec[:atWall])
		return _e_

	# OCSF, newline-delimited: what a collector ingests as a stream.
	def ToOcsfNdJson()
		_c_ = ""
		_aAll_ = This.All()
		_n_ = ring_len(_aAll_)
		for _i_ = 1 to _n_
			_c_ += (This._EventOf(_aAll_[_i_]).ToOcsfJson() + Char(10))
		next
		return _c_

	# OCSF as one JSON array (the batch form).
	def ToOcsfJson()
		_c_ = "["
		_aAll_ = This.All()
		_n_ = ring_len(_aAll_)
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += ","
			ok
			_c_ += This._EventOf(_aAll_[_i_]).ToOcsfJson()
		next
		_c_ += "]"
		return _c_

	# The OTLP logs envelope -- the same shape stzLog ships (perf P9),
	# so security events and log lines arrive at one collector looking
	# like what they are: records of the same run, sharing trace ids.
	def ToOtelLogsJson()
		_cRecs_ = ""
		_aAll_ = This.All()
		_n_ = ring_len(_aAll_)
		for _i_ = 1 to _n_
			if _i_ > 1
				_cRecs_ += ","
			ok
			_r_ = _aAll_[_i_]
			_cR_ = '{"timeUnixNano":"' + ("" + _r_[:atWall]) + '000000"'
			_cR_ += (',"severityText":"' + StzUpper(_r_[:severity]) + '"')
			_cR_ += (',"severityNumber":' + This._OtelSeverity(_r_[:severity]))
			_cR_ += (',"body":{"stringValue":"' + This._Esc(_r_[:kind] + " " + _r_[:outcome] + " -- " + _r_[:reason]) + '"}')
			_cR_ += ',"attributes":[{"key":"actor","value":{"stringValue":"' + This._Esc(_r_[:actor]) + '"}}'
			_cR_ += ',{"key":"subject","value":{"stringValue":"' + This._Esc(_r_[:subject]) + '"}}'
			_cR_ += ',{"key":"kind","value":{"stringValue":"' + _r_[:kind] + '"}}]'
			if _r_[:traceId] != ""
				_cR_ += (',"traceId":"' + _r_[:traceId] + '"')
			ok
			_cR_ += "}"
			_cRecs_ += _cR_
		next
		_cJ_ = '{"resourceLogs":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"softanza.security"}}]},"scopeLogs":[{"scope":{"name":"softanza.incident"},"logRecords":['
		_cJ_ += _cRecs_
		_cJ_ += ']}]}]}'
		return _cJ_

	def _OtelSeverity(pcSev)
		if pcSev = "error"
			return 17
		but pcSev = "warning"
			return 13
		ok
		return 9

	def _Esc(pcStr)
		_s_ = StzReplace("" + pcStr, char(92), char(92) + char(92))
		_s_ = StzReplace(_s_, char(34), char(92) + char(34))
		return _s_

	  #-- legibility --------------------------------------------------

	def Explain()
		_aL_ = []
		_aV_ = This.Verify()
		_cV_ = "intact"
		if NOT _aV_[:intact]
			_cV_ = "BROKEN at " + _aV_[:brokenAt]
		ok
		_cH_ = "Security ledger -- " + This.Count() + " event(s) recorded, "
		_cH_ += ("" + This.Size() + " retained of " + This.Capacity() + ", chain " + _cV_ + ".")
		_aL_ + _cH_
		_aAll_ = This.All()
		_nN_ = ring_len(_aAll_)
		for _i_ = 1 to _nN_
			_r_ = _aAll_[_i_]
			_cLine_ = "  " + StzUpper(_r_[:outcome]) + " " + _r_[:kind]
			if _r_[:actor] != ""
				_cLine_ += (" by " + _r_[:actor])
			ok
			if _r_[:subject] != ""
				_cLine_ += (" on " + _r_[:subject])
			ok
			if _r_[:reason] != ""
				_cLine_ += (" -- " + _r_[:reason])
			ok
			_aL_ + _cLine_
		next
		return _aL_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	def Reset()
		This._Ensure()
		StzEngineSecLogReset(pHandle)
		return This

	def Destroy()
		if bReady
			if NOT bAdopted
				StzEngineSecLogDestroy(pHandle)
			ok
			pHandle = ""
			bReady = 0
			bAdopted = 0
		ok
		return This

	  #-- internals ---------------------------------------------------

	def _SevCode(pcSeverity)
		if pcSeverity = "error"
			return 2
		but pcSeverity = "warning"
			return 1
		ok
		return 0

	# The canonical line back into the I0 field shape (12 fields, fixed
	# order -- stzSecurityEvent.CanonicalString()).
	def _Parse(pcCanon)
		_a_ = StzSplit(pcCanon, "|")
		while ring_len(_a_) < 12
			_a_ + ""
		end
		return [
			:kind = _a_[1],
			:severity = _a_[2],
			:actor = _a_[3],
			:posture = _a_[4],
			:action = _a_[5],
			:risk = number(_a_[6]),
			:subject = _a_[7],
			:origin = _a_[8],
			:outcome = _a_[9],
			:reason = _a_[10],
			:atWall = number(_a_[11]),
			:traceId = _a_[12]
		]

	def _Where(pcField, pcValue)
		_aOut_ = []
		_aAll_ = This.All()
		_cV_ = "" + pcValue
		_nN_ = ring_len(_aAll_)
		for _i_ = 1 to _nN_
			if ("" + _aAll_[_i_][pcField]) = _cV_
				_aOut_ + _aAll_[_i_]
			ok
		next
		return _aOut_
