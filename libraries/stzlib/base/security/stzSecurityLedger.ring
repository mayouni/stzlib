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

# Verify a sealed export written by SealTo(). Returns
# [ :ok, :why, :count, :seal, :brokenAt ]. Without a key the chain is
# still checked; the seal check needs the key it was sealed with.
func StzVerifySealedLedger(pcPath, pcKey)
	if NOT fexists(pcPath)
		return [ :ok = FALSE, :why = "no such file: " + pcPath, :count = 0, :seal = "", :brokenAt = 0 ]
	ok
	_cRaw_ = read(pcPath)
	_aLines_ = StzSplit(_cRaw_, Char(10))
	_cSeal_ = ""
	_nDeclared_ = 0
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
		return [ :ok = FALSE, :why = "the file carries no entries", :count = 0, :seal = _cSeal_, :brokenAt = 0 ]
	ok
	if _nDeclared_ != ring_len(_aRows_)
		return [ :ok = FALSE, :why = "entry count does not match the header (" +
			ring_len(_aRows_) + " found, " + _nDeclared_ + " declared)",
			:count = ring_len(_aRows_), :seal = _cSeal_, :brokenAt = 0 ]
	ok

	# recompute the chain over the file
	_nRows_ = ring_len(_aRows_)
	for _i_ = 2 to _nRows_
		_cWant_ = StzEngineCryptoSha256(_aRows_[_i_ - 1][1] + "|" + _aRows_[_i_][2])
		if _cWant_ != _aRows_[_i_][1]
			return [ :ok = FALSE, :why = "the chain breaks at entry " + _i_ +
				" -- that record (or one before it) was edited",
				:count = _nRows_, :seal = _cSeal_, :brokenAt = _i_ ]
		ok
	next

	if pcKey != "" and _cSeal_ != ""
		_cWantSeal_ = StzEngineCryptoHmacSha256(pcKey,
			_aRows_[_nRows_][1] + "|" + _nRows_)
		if _cWantSeal_ != _cSeal_
			return [ :ok = FALSE, :why = "the chain is intact but the SEAL does not match this key",
				:count = _nRows_, :seal = _cSeal_, :brokenAt = 0 ]
		ok
	ok
	return [ :ok = TRUE, :why = "chain intact over " + _nRows_ + " entries",
		:count = _nRows_, :seal = _cSeal_, :brokenAt = 0 ]


class stzSecurityLedger from stzObject

	pHandle = NULL
	bReady = FALSE
	@nCapacity = 1024

	def init(pnCapacity)
		if isNumber(pnCapacity) and pnCapacity >= 1
			@nCapacity = pnCapacity
		ok
		# eager materialization (the copy law)
		pHandle = StzEngineSecLogCreate(@nCapacity)
		bReady = TRUE

	def _Ensure()
		if bReady = FALSE
			pHandle = StzEngineSecLogCreate(@nCapacity)
			bReady = TRUE
		ok

	def Handle()
		This._Ensure()
		return pHandle

	def Capacity()
		return @nCapacity

	  #-- recording ---------------------------------------------------

	# Append an stzSecurityEvent. The engine chains it; nothing about
	# the digest is under the caller's control.
	def Record(poEvent)
		This._Ensure()
		StzEngineSecLogAppend(pHandle, poEvent.CanonicalString(),
			poEvent.AtWall(), This._SevCode(poEvent.Severity()))
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
	def Refusals()
		_aOut_ = []
		_aAll_ = This.All()
		_nN_ = ring_len(_aAll_)
		for _i_ = 1 to _nN_
			if _aAll_[_i_][:outcome] != "granted"
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
			return [ :intact = TRUE, :brokenAt = 0,
				:message = "chain intact over " + This.Size() + " retained entr(ies)" ]
		ok
		return [ :intact = FALSE, :brokenAt = _n_,
			:message = "the chain breaks at entry " + _n_ +
				" -- that record (or one before it) was altered" ]

	  #-- sealing (evidence leaves the process) -----------------------

	# Write the retained window as a verifiable file: one
	# "<digest>TAB<canonical>" line per entry, a header carrying the
	# count and an HMAC seal over (head digest | count). Re-check it
	# with StzVerifySealedLedger(path, key) -- editing any line breaks
	# the chain; editing the seal without the key is not possible.
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

	  #-- legibility --------------------------------------------------

	def Explain()
		_aL_ = []
		_aV_ = This.Verify()
		_cV_ = "intact"
		if NOT _aV_[:intact]
			_cV_ = "BROKEN at " + _aV_[:brokenAt]
		ok
		_cH_ = "Security ledger -- " + This.Count() + " event(s) recorded, "
		_cH_ += ("" + This.Size() + " retained of " + @nCapacity + ", chain " + _cV_ + ".")
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
			StzEngineSecLogDestroy(pHandle)
			pHandle = NULL
			bReady = FALSE
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
