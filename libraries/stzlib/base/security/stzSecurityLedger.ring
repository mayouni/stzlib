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

# The process ledger, made DURABLE (HaroBase rung 2): every event the
# seams record is also written, in chain order, to pcPath -- an
# insert-only SQLite table whose stored chain is verified from genesis
# before recording resumes. Raises when the stored history is broken:
# a process must not add to evidence it cannot vouch for.
func StzOpenDurableSecurityLedger(pnCapacity, pcPath)
	if StzSecurityLedgerIsOpen()
		stzraise("A process ledger is already open -- close it before opening a durable one.")
	ok
	_oLed_ = new stzSecurityLedger(pnCapacity)
	_aV_ = _oLed_.PersistTo(pcPath)
	if NOT _aV_[:ok]
		_oLed_.Destroy()
		stzraise(_aV_[:why])
	ok
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
# An anchor, from Anchor()'s list or its line, as [ :count, :head ]; [] if
# it is not one.
func StzLedgerAnchorParse(pAnchor)
	if isList(pAnchor)
		_nC_ = 0  _cH_ = ""
		for _i_ = 1 to len(pAnchor)
			if isList(pAnchor[_i_]) and len(pAnchor[_i_]) = 2
				if pAnchor[_i_][1] = "count"  _nC_ = pAnchor[_i_][2]  ok
				if pAnchor[_i_][1] = "head"   _cH_ = "" + pAnchor[_i_][2]  ok
			ok
		next
		if NOT isNumber(_nC_) or _nC_ < 1 or len(_cH_) != 64  return []  ok
		return [ :count = _nC_, :head = _cH_ ]
	ok
	if NOT isString(pAnchor)  return []  ok
	_p_ = StzSplit(ring_trim(pAnchor), ":")
	if len(_p_) != 4  return []  ok
	if _p_[1] != "stzledger-anchor" or _p_[2] != "v1"  return []  ok
	if len(_p_[3]) = 0 or len(_p_[4]) != 64  return []  ok
	for _i_ = 1 to len(_p_[3])
		if ascii(_p_[3][_i_]) < 48 or ascii(_p_[3][_i_]) > 57  return []  ok
	next
	return [ :count = 0 + _p_[3], :head = _p_[4] ]

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


# Keeps security events as evidence: a bounded, hash-chained ring in the engine that can be made durable, anchored off the machine and sealed.
#
# Each entry's digest is the SHA-256 of the previous digest and the entry, computed in the engine
# and never handed in, so an edit to any entry breaks every digest after it and Verify names the
# first broken link. The ring forgets: past its capacity the oldest events give way, Count keeps
# counting and Size is what remains. PersistTo writes every event to an insert-only SQLite file and
# verifies it from the first entry on restart; an anchor sent off the machine shows a cut tail,
# which a chain alone cannot; SealTo exports a keyed file. A refused kind writes at most a budgeted
# number of lines per window, so a stranger cannot flush the evidence. The chain detects retroactive
# edits only, and protects nothing against an attacker already running code in the process. The
# pivots (OfActor, OfKind, Refusals, Since ...) return records rebuilt from the stored canonical
# line.
#
#   receiver   o1 = new stzSecurityLedger(8)
#   example    o1.Record(StzSecurityRefusal("auth.login.failed", "alice", "user:alice", "bad password"))
#              ? o1.Count()
#              #--> 1
#              ? o1.Verify()[:intact]
#              #--> 1
#   see        stzSecurityEvent, stzDetection, StzOpenSecurityLedger, StzVerifySealedLedger
class stzSecurityLedger from stzObject

	pHandle = ""
	bReady = 0
	bAdopted = 0	# bound to a ledger owned elsewhere (the process one)
	@nCapacity = 1024

	# Builds an empty ring ledger that keeps the newest pnCapacity events; a missing, non-numeric or sub-1 capacity gives 1024.
	#
	#   pnCapacity   how many events the ring keeps, at least 1
	#   returns      nothing; the object is built
	#   note         the ring lives in the engine and is created at birth, so every copy of the
	#                ledger object reads and writes the same events
	#   see          Capacity, PersistTo
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

	# Returns the engine handle of the ring, creating the ring again first if Destroy had freed it.
	#
	#   returns    an engine pointer
	#   note       StzOpenSecurityLedger passes this handle to the engine as the process ledger
	#   see        AdoptHandle, Destroy
	def Handle()
		This._Ensure()
		return pHandle

	# Binds this object to a ledger owned elsewhere, such as the process ledger, so both read and write the same events.
	#
	#   pEngineHandle   an engine ledger handle, as Handle gives
	#   returns         the ledger itself, so calls chain
	#   note            the ring this object made first is destroyed; Destroy later leaves an
	#                   adopted handle alone, because its owner frees it
	#   see             Handle, Destroy
	#@ aka  Bind this face to a ledger owned elsewhere (the process ledger). Destroy() will not free an adopted handle -- the owner does.
	def AdoptHandle(pEngineHandle)
		if bReady and NOT bAdopted
			StzEngineSecLogDestroy(pHandle)
		ok
		pHandle = pEngineHandle
		bReady = 1
		bAdopted = 1
		return This

	# Returns how many events the ring can keep, as the engine reports it, even for an object bound to the process ledger.
	#
	#   returns    a number
	#   see        Size, Count
	#@ aka  The engine's own answer -- a face bound to the process ledger (AdoptHandle) never knew the capacity it was created with.
	def Capacity()
		This._Ensure()
		return StzEngineSecLogCapacity(pHandle)

	# Appends an event to the ring; the engine chains its digest to the previous one, so the caller never supplies a digest.
	#
	#   poEvent    the stzSecurityEvent to append
	#   returns    the ledger itself, so calls chain
	#   note       a refused kind is subject to the refusal budget and grants never are; past
	#              capacity the oldest event is evicted while Count keeps counting
	#   warning    raises an error when the ledger is durable and the disk write fails: the event is
	#              then in memory only
	#   see        AppendCanonical, Count, Verify
	#@ aka  -- recording ---------------------------------------------------
	def Record(poEvent)
		This._Ensure()
		_nErr_ = StzEngineSecLogDurableErrors(pHandle)
		StzEngineSecLogAppend(pHandle, poEvent.CanonicalString(),
			poEvent.AtWall(), This._SevCode(poEvent.Severity()))
		# evidence that did not reach the disk is not quietly accepted
		if StzEngineSecLogDurableErrors(pHandle) > _nErr_
			stzraise("The durable security log refused a write -- the event is in memory only.")
		ok
		return This

	# Appends a canonical line as it is, with the wall time and severity code given, without building an event first.
	#
	#   pcCanonical      the twelve-field line as CanonicalString gives it
	#   pnWallMs         the event time, in epoch milliseconds
	#   pnSeverityCode   0 for info, 1 for warning, 2 for error
	#   returns          the ledger itself, so calls chain
	#   note             the path that rebuilds a working ledger from a verified sealed file
	#   warning          the chain is recomputed here and does not carry the digests of the file the
	#                    line came from; a line that is not canonical is accepted and reads back
	#                    with empty fields
	#   see              Record, StzLedgerFromSealedFile
	#@ aka  Append a canonical line directly -- the acquisition path (I8), used when rebuilding a ledger from verified evidence. The chain is recomputed here; it does not carry the original file's.
	def AppendCanonical(pcCanonical, pnWallMs, pnSeverityCode)
		This._Ensure()
		StzEngineSecLogAppend(pHandle, pcCanonical, pnWallMs, pnSeverityCode)
		return This

	# Makes the ledger durable: later events are also written, in chain order, to an insert-only SQLite file that is checked first.
	#
	#   pcPath     the SQLite file to create or to resume
	#   returns    a list [ :ok, :verified, :brokenAt, :why ]
	#   note       call it before recording; after a restart the ring shows the newest window while
	#              Count carries the whole history (durable_ledger_narrated)
	#   warning    a ledger that already holds events, one that is already durable, an unreadable
	#              path and a stored history with an edited or missing row are all refused with :ok
	#              0 and nothing is attached
	#   see        IsDurable, VerifyDurable, Anchor
	#@ aka  -- the durable log (HaroBase rung 2) ----------------------------
	def PersistTo(pcPath)
		This._Ensure()
		_n_ = StzEngineSecLogAttach(pHandle, "" + pcPath)
		if _n_ >= 0
			return [ :ok = 1, :verified = _n_, :brokenAt = 0,
				:why = "durable at " + pcPath + ": " + _n_ + " stored entr(ies) verified from genesis" ]
		ok
		if _n_ = -1000000003
			return [ :ok = 0, :verified = 0, :brokenAt = 0, :why = "this ledger is already durable" ]
		but _n_ = -1000000004
			return [ :ok = 0, :verified = 0, :brokenAt = 0,
				:why = "this ledger already holds events -- make it durable before recording" ]
		but _n_ <= -1000000001
			return [ :ok = 0, :verified = 0, :brokenAt = 0, :why = "cannot open or read the log at " + pcPath ]
		ok
		return [ :ok = 0, :verified = 0, :brokenAt = -_n_,
			:why = "the stored log breaks at entry " + (-_n_) +
				" (edited, or missing) -- refused, nothing attached" ]

	# TRUE if PersistTo succeeded, so that every event is also written to a file.
	#
	#   returns    TRUE or FALSE
	#   see        PersistTo, VerifyDurable
	def IsDurable()
		This._Ensure()
		return StzEngineSecLogIsDurable(pHandle) = 1

	# Checks the whole stored chain from the first entry, where Verify can only speak for the retained window.
	#
	#   returns    a list [ :intact, :brokenAt, :message ]
	#   note       an edited or removed row shows; a cut tail does not, which is what Anchor is for
	#   warning    a ledger that is not durable answers :intact 0 with :brokenAt 0 and that message,
	#              so ask IsDurable first
	#   see        PersistTo, Verify, VerifyAgainstAnchor
	#@ aka  Verify the WHOLE stored history from genesis -- where Verify() can only speak for the retained window. [ :intact, :brokenAt, :message ]
	def VerifyDurable()
		This._Ensure()
		_n_ = StzEngineSecLogVerifyDurable(pHandle)
		if _n_ = 0
			return [ :intact = 1, :brokenAt = 0,
				:message = "the stored chain is intact over " + This.Count() + " entr(ies), from genesis" ]
		but _n_ = -1
			return [ :intact = 0, :brokenAt = 0, :message = "this ledger is not durable" ]
		but _n_ = -2
			return [ :intact = 0, :brokenAt = 0, :message = "the stored log cannot be read" ]
		ok
		return [ :intact = 0, :brokenAt = _n_,
			:message = "the stored chain breaks at entry " + _n_ + " -- that row was altered or removed" ]

	# Returns how many events were ever recorded, including those the ring has already evicted.
	#
	#   returns    a number
	#   see        Size
	#@ aka  Events ever recorded (keeps counting past capacity).
	def Count()
		This._Ensure()
		return StzEngineSecLogCount(pHandle)

	# Returns how many events the ring still holds.
	#
	#   returns    a number, never above the capacity
	#   see        Count, Capacity
	#@ aka  Events still retained in the window.
	def Size()
		This._Ensure()
		return StzEngineSecLogSize(pHandle)

	# Returns the count and head digest of the ledger at this moment, with a one-line text to send off the machine.
	#
	#   returns    a list [ :count, :head, :atWall, :line ]
	#   note       the line reads stzledger-anchor:v1: then the count, a colon and the 64-character
	#              digest (threat model R5)
	#   warning    an anchor kept only on the machine that holds the file proves nothing; an empty
	#              ledger gives count 0 and 64 zeros, which VerifyAgainstAnchor rejects as malformed
	#              in the list form
	#   see        VerifyAgainstAnchor, Digest
	#@ aka  -- the anchor (threat-model R5) ----------------------------------
	def Anchor()
		This._Ensure()
		_n_ = This.Count()
		_h_ = This.Digest()
		return [ :count = _n_, :head = _h_, :atWall = StzEngineTimeNowMs(),
			:line = "stzledger-anchor:v1:" + _n_ + ":" + _h_ ]

	# Checks the durable history against an anchor taken earlier: does the stored file still reach that count with that digest.
	#
	#   pAnchor    the list Anchor returned, or its :line text
	#   returns    a list [ :holds, :state, :why ]
	#   note       :state is holds, truncated, diverged, broken, not-durable, unreadable or
	#              malformed; truncated means the tail was cut and diverged means the history was
	#              rewritten (ledger_anchor_narrated); only a durable ledger can be checked
	#   see        Anchor, VerifyDurable, PersistTo
	#@ aka  Check the durable history against an anchor -- the list Anchor() returned, or its :line. [ :holds, :state, :why ], where :state is one of holds, truncated, diverged, broken, not-durable, unreadable, malformed.
	def VerifyAgainstAnchor(pAnchor)
		This._Ensure()
		_a_ = StzLedgerAnchorParse(pAnchor)
		if len(_a_) = 0
			return [ :holds = 0, :state = "malformed", :why = "not an anchor: expected stzledger-anchor:v1:<count>:<digest>" ]
		ok
		_r_ = StzEngineSecLogVerifyAnchor(pHandle, _a_[:count], _a_[:head])
		if _r_ = 0
			return [ :holds = 1, :state = "holds",
				:why = "the stored history reaches entry " + _a_[:count] + " with the anchored digest, intact from genesis" ]
		but _r_ = -1
			return [ :holds = 0, :state = "not-durable", :why = "this ledger is not durable -- an anchor checks the stored file" ]
		but _r_ = -2
			return [ :holds = 0, :state = "unreadable", :why = "the stored log cannot be read" ]
		but _r_ = -3
			return [ :holds = 0, :state = "truncated",
				:why = "the stored history ends before entry " + _a_[:count] + ": its tail was cut" ]
		but _r_ = -4
			return [ :holds = 0, :state = "diverged",
				:why = "entry " + _a_[:count] + " exists with another digest: the history was rewritten" ]
		ok
		return [ :holds = 0, :state = "broken",
			:why = "the stored chain breaks at entry " + _r_ + " -- that row was altered or removed" ]

	# Sets how many lines per time window each refused kind may write; past it the engine counts the refusals, writes one marker, then a summary.
	#
	#   pnMax        the lines each refused kind may write per window, 0 turns the budget off
	#   pnWindowMs   the window length, in milliseconds
	#   returns      the ledger itself, so calls chain
	#   note         the default is 64 per 60000 ms; grants are never budgeted; the budget is
	#                counted per kind, so a flood of one kind cannot evict other evidence
	#                (ledger_flood_narrated)
	#   warning      a negative pnMax acts as 0 and turns the budget off, a negative window becomes
	#                1 ms, and neither raises an error
	#   see          RefusalBudget, Suppressed, FlushRefusalCounts
	#@ aka  -- the refusal budget (SECURITY-LEDGERFLOOD-01) -----------------
	def SetRefusalBudget(pnMax, pnWindowMs)
		This._Ensure()
		StzEngineSecLogSetRefusalBudget(pHandle, pnMax, pnWindowMs)
		return This

	# Returns the refusal budget now in force.
	#
	#   returns    a list [ :max, :windowMs ]
	#   warning    64 and 60000 by default
	#   see        SetRefusalBudget
	def RefusalBudget()
		This._Ensure()
		return [ :max = StzEngineSecLogBudgetMax(pHandle), :windowMs = StzEngineSecLogBudgetWindow(pHandle) ]

	# Returns how many refusals were counted instead of written, since the ledger was made.
	#
	#   returns    a number
	#   warning    a flush does not reset it
	#   see        SetRefusalBudget, FlushRefusalCounts
	#@ aka  Refusals counted rather than written, ever.
	def Suppressed()
		This._Ensure()
		return StzEngineSecLogSuppressed(pHandle)

	# Closes every open budget window now and writes each count of suppressed refusals into the chain as one summary line.
	#
	#   returns    the ledger itself, so calls chain
	#   note       the summary has the outcome observed and the actor ledger, and reads N further
	#              refusal(s) of this kind were counted; without a flush a window closes only when
	#              the next refusal of that kind arrives after it
	#   see        Suppressed, SetRefusalBudget
	#@ aka  Close every open budget window now, writing each count into the chain.
	def FlushRefusalCounts()
		This._Ensure()
		StzEngineSecLogFlushBudget(pHandle, StzEngineTimeNowMs())
		return This

	# Returns the retained record at a 1-based position, oldest retained first, with its chain digest.
	#
	#   pnIndex    the position among the retained events, 1 is the oldest
	#   returns    a list of [ key, value ] pairs, or [ ] when the position is out of range
	#   note       the keys are kind, severity, actor, posture, action, risk, subject, origin,
	#              outcome, reason, atWall, traceId and digest; atMono, technique and actorKinds are
	#              not stored
	#   see        All, DigestAt
	#@ aka  -- reading -----------------------------------------------------
	def At(pnIndex)
		This._Ensure()
		_cCanon_ = StzEngineSecLogCanonicalAt(pHandle, pnIndex)
		if _cCanon_ = ""
			return []
		ok
		_aR_ = This._Parse(_cCanon_)
		_aR_ + [ :digest, StzEngineSecLogDigestAt(pHandle, pnIndex) ]
		return _aR_

	# Returns every retained record, oldest first, each in the shape At gives.
	#
	#   returns    a list of records; [ ] when the ledger is empty
	#   note       every call rebuilds the records from the stored lines, so on a large ledger keep
	#              the result instead of calling it in a loop
	#   see        At, Recent, Refusals
	def All()
		This._Ensure()
		_aOut_ = []
		_nN_ = StzEngineSecLogSize(pHandle)
		for _i_ = 1 to _nN_
			_aOut_ + This.At(_i_)
		next
		return _aOut_

	# Returns the newest records, the oldest of them first.
	#
	#   pnHowMany   how many records to take from the end
	#   returns     a list of records; all of them when pnHowMany exceeds the size, [ ] for 0 or
	#               less
	#   see         All, Since
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

	# Returns the retained records made by one actor.
	#
	#   pcActor    the actor name
	#   returns    a list of records
	#   note       the match is exact and case-sensitive: ALICE does not find alice
	#   see        OfSubject, Refusals
	#@ aka  -- the analyst's pivots ---------------------------------------
	def OfActor(pcActor)
		return This._Where(:actor, pcActor)

	# Returns the retained records about one subject descriptor.
	#
	#   pcSubject   the subject text the event stored, such as user:bob
	#   returns     a list of records
	#   see         OfActor, OfKind
	def OfSubject(pcSubject)
		return This._Where(:subject, pcSubject)

	# Returns the retained records of one event kind.
	#
	#   pcKind     the event kind, a dotted catalog name
	#   returns    a list of records
	#   see        OfActor, Refusals
	def OfKind(pcKind)
		return This._Where(:kind, pcKind)

	# Returns the retained records stamped with one trace id, which ties events to the log lines and spans of one request.
	#
	#   pcTraceId   the trace id, as text
	#   returns     a list of records
	#   note        events recorded outside a trace scope carry an empty trace id, which this pivot
	#               finds when given an empty text
	#   see         OfKind
	def OfTrace(pcTraceId)
		return This._Where(:traceId, pcTraceId)

	# Returns the retained records that ended one way.
	#
	#   pcOutcome   granted, refused, failed or observed
	#   returns     a list of records
	#   note        the match is exact and case-sensitive
	#   see         Refusals
	def OfOutcome(pcOutcome)
		return This._Where(:outcome, pcOutcome)

	# Returns the retained records of one severity.
	#
	#   pcSeverity   info, warning or error
	#   returns      a list of records
	#   note         the severity is the one stored with the event, which may be an override of the
	#                catalog default
	#   see          OfOutcome
	def OfSeverity(pcSeverity)
		return This._Where(:severity, pcSeverity)

	# Returns the retained records that came from one origin.
	#
	#   pcOrigin   the address, host or endpoint the event stored
	#   returns    a list of records
	#   note       an empty text finds the events that carry no origin
	#   see        OfActor
	def OfOrigin(pcOrigin)
		return This._Where(:origin, pcOrigin)

	# Returns the retained records whose outcome is refused or failed, the signal to watch.
	#
	#   returns    a list of records
	#   note       granted and observed records are left out, so an expired session is never counted
	#              as a refusal
	#   see        OfOutcome, stzDetection
	#@ aka  Everything that was not granted -- the signal to watch. Refused and failed -- NOT "everything that is not granted". The negative form was here too, and it was wrong the moment the OBSERVED outcome arrived (I2's session seams): an expired session would have been counted as a refusal by this pivot, in a system whose whole point is that a warning must mean something. Kept in step with stzSecurityEven
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

	# Returns the retained records at or after a wall time.
	#
	#   pnWallMs   the earliest event time, in epoch milliseconds, included
	#   returns    a list of records
	#   see        Between, Recent
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

	# Returns the retained records inside a time range, both ends included.
	#
	#   pnFromMs   the start of the range, in epoch milliseconds
	#   pnToMs     the end of the range, in epoch milliseconds
	#   returns    a list of records; [ ] when the start is after the end
	#   see        Since
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

	# Returns the head digest, 64 hex characters, that commits to every event ever recorded, evicted ones included.
	#
	#   returns    a text
	#   note       an empty ledger answers 64 zeros
	#   see        DigestAt, Anchor, Verify
	#@ aka  -- the chain ---------------------------------------------------
	def Digest()
		This._Ensure()
		return StzEngineSecLogHeadDigest(pHandle)

	# Returns the chain digest stored with the retained entry at a position.
	#
	#   pnIndex    the position among the retained events, 1 is the oldest
	#   returns    a text; empty when the position is out of range
	#   see        Digest, At
	def DigestAt(pnIndex)
		This._Ensure()
		return StzEngineSecLogDigestAt(pHandle, pnIndex)

	# Recomputes the chain over the retained window and names the first entry whose stored digest disagrees with it.
	#
	#   returns    a list [ :intact, :brokenAt, :message ]
	#   note       it speaks for the retained window only: after eviction the first retained entry's
	#              predecessor is gone; chaining shows a retroactive edit and protects nothing
	#              against code already running in this process
	#   see        VerifyDurable, Digest
	#@ aka  [ :intact, :brokenAt, :message ] -- brokenAt is the 1-based index of the first entry whose stored digest disagrees with a recomputation, 0 when the retained window is consistent.
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

	# Writes the retained window as a sealed file like SealTo, with a custody header that names who attested it and when.
	#
	#   pcPath       the file to write, overwritten
	#   pcKey        the secret that keys the seal
	#   pcAttestor   who vouches for the export, as text
	#   returns      the ledger itself, so calls chain
	#   note         the verifier reads the two lines back as attestor and attestedAt (I7)
	#   warning      the attestor and time lines sit outside the seal: editing them breaks nothing,
	#                so the verifier accepts a file whose attestor was changed after sealing
	#   see          SealTo, StzVerifySealedLedger
	#@ aka  -- sealing (evidence leaves the process) -----------------------
	def SealAttestedTo(pcPath, pcKey, pcAttestor)
		This._Ensure()
		This.SealTo(pcPath, pcKey)
		_cRaw_ = read("" + pcPath)
		_cHdr_ = "# attestor=" + pcAttestor + Char(10)
		_cHdr_ += ("# at=" + StzEngineTimeWallMs() + Char(10))
		write("" + pcPath, _cHdr_ + _cRaw_)
		return This

	# Writes the retained window to a file, one digest and canonical line per event, under a header holding the count and a keyed seal.
	#
	#   pcPath     the file to write, overwritten
	#   pcKey      the secret that keys the HMAC seal, an empty text writes no seal
	#   returns    the ledger itself, so calls chain
	#   note       evidence-grade means exported: editing any line breaks the chain, and the seal
	#              needs the key to be made
	#   warning    StzVerifySealedLedger skips the seal check when the seal line is missing, so a
	#              tail cut that also deletes the seal line still verifies with the key
	#   see        SealAttestedTo, StzVerifySealedLedger, StzLedgerFromSealedFile
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

	# Returns the retained events as OCSF JSON objects, one per line, the stream form a collector ingests.
	#
	#   returns    a text of JSON lines
	#   note       each line is the stzSecurityEvent.ToOcsfJson of one record
	#   warning    the events are rebuilt from the stored record, so a severity override reads as
	#              the catalog default and an observed fact is exported as refused with status_id 2
	#   see        ToOcsfJson, ToOtelLogsJson
	#@ aka  OCSF, newline-delimited: what a collector ingests as a stream.
	def ToOcsfNdJson()
		_c_ = ""
		_aAll_ = This.All()
		_n_ = ring_len(_aAll_)
		for _i_ = 1 to _n_
			_c_ += (This._EventOf(_aAll_[_i_]).ToOcsfJson() + Char(10))
		next
		return _c_

	# Returns the retained events as one OCSF JSON array, the batch form.
	#
	#   returns    a text of JSON
	#   note       an empty ledger gives []
	#   warning    the events are rebuilt from the stored record, so a severity override reads as
	#              the catalog default and an observed fact is exported as refused with status_id 2
	#   see        ToOcsfNdJson, ToOtelLogsJson
	#@ aka  OCSF as one JSON array (the batch form).
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

	# Returns the retained events as one OTLP logs envelope, the shape stzLog ships, so events and log lines reach one collector.
	#
	#   returns    a text of JSON
	#   note       the severity and outcome come from the stored record; trace ids are carried when
	#              present; the service name is softanza.security
	#   see        ToOcsfJson
	#@ aka  The OTLP logs envelope -- the same shape stzLog ships (perf P9), so security events and log lines arrive at one collector looking like what they are: records of the same run, sharing trace ids.
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

	# Returns the ledger told as lines of text: a header with the counts and the chain state, then one line per retained event.
	#
	#   returns    a list of text
	#   note       the header reads N event(s) recorded, M retained of C, chain intact or BROKEN at
	#              K
	#   see        Show, Verify
	#@ aka  -- legibility --------------------------------------------------
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

	# Empties the ring and restarts the chain, as a ledger made fresh.
	#
	#   returns    the ledger itself, so calls chain
	#   note       the count and the digest start again from zero
	#   warning    raises an error for a durable ledger, whose chain continues on disk
	#   see        Destroy, PersistTo
	def Reset()
		This._Ensure()
		if This.IsDurable()
			stzraise("A durable ledger cannot be reset: its chain continues on disk.")
		ok
		StzEngineSecLogReset(pHandle)
		return This

	# Frees the engine ring; an object bound to the process ledger by AdoptHandle leaves it open.
	#
	#   returns    the ledger itself, so calls chain
	#   note       the next call that needs the ring creates a fresh empty one, so a destroyed
	#              ledger is not a closed one
	#   see        Handle, AdoptHandle
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
