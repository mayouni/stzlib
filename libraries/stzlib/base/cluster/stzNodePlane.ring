# base/cluster/stzNodePlane.ring
# -----------------------------------------------------------------------------
# DISTRIBUTION D2 -- the registry + location-transparent Send/Ask.
#
# A node ADDRESS is a name ("indexer") or name@host ("indexer@10.0.0.7").
# The registry resolves either to a live STZM link; the CALLER'S CODE IS
# IDENTICAL both ways -- that is this phase's one job, and its guard runs
# the same test body against a local child and a remote-simulated one.
#
#   NodeRegister("indexer", "127.0.0.1", 45810)
#   Send("indexer", [ "warm" ])                  # fire-and-forget
#   v = Ask("indexer", [ "embed", cText ], 2000) # reply or a TIMEOUT
#
# Contracts:
# - Ask's timeout is MANDATORY: a non-positive timeout is refused
#   (:BadTimeout), never an infinite wait.
# - Delivery is AT-MOST-ONCE: a timed-out Ask may still have been
#   handled; its LATE reply is discarded by correlation id, never
#   mis-delivered to the next Ask.
# - Unreachable and dead are the SAME observable: :Down.
# - Links are cached per name and re-dialed transparently after :closed.
# -----------------------------------------------------------------------------

$oStzNodePlane = ""

func StzNodeRegistryQ()
	return new stzNodeRegistry()

# The default plane the bare Send()/Ask() globals ride. One per process.
func StzNodePlane()
	if isNull($oStzNodePlane)
		$oStzNodePlane = new stzNodeRegistry()
	ok
	return $oStzNodePlane

func NodeRegister(pcName, pcHost, pnPort)
	return StzNodePlane().Register(pcName, pcHost, pnPort)

func Send(pcAddr, pMsg)
	return StzNodePlane().Send(pcAddr, pMsg)

func Ask(pcAddr, pMsg, nTimeoutMs)
	return StzNodePlane().Ask(pcAddr, pMsg, nTimeoutMs)

func NodeAskStatus()
	return StzNodePlane().LastStatus()

class stzNodeRegistry from stzObject

	@oReactor = ""       # ONE reactor carries every link of this plane
	@aNames = []           # parallel lists (hash-list keys fold; stay raw)
	@aHosts = []
	@aPorts = []
	@aChans = []           # cached [ nChan, nConn ] per name, [] = not dialed
	@nCorr = 0
	@cStatus = :Ok         # :Ok/:Timeout/:Down/:Unknown/:BadTimeout/:Denied
	@nDialMs = 2000        # per-dial budget inside Send/Ask
	@oSigner = ""        # D5: sign every outgoing message (reuse, not mint)
	@cKeyId = ""

	def init()
		@oReactor = new stzReactor()

	def LastStatus()
		return @cStatus

	# D5 -- sign everything this plane sends, as pcKeyId, with the SAME
	# stzRequestSigner discipline the federation uses. The receiver
	# verifies against the shared keyring; a denial comes back as an
	# observable :Denied, never a silent drop.
	def SecureWith(poSigner, pcKeyId)
		@oSigner = poSigner
		@cKeyId = "" + pcKeyId
		return This

	# Wrap an outgoing message in the signed envelope form. The signature
	# covers the CANONICAL packed bytes of the real message; the path is
	# its tag.
	def _Outgoing(pMsg)
		if isNull(@oSigner)
			return pMsg
		ok
		cTag = ""
		if isList(pMsg) and ring_len(pMsg) > 0 and isString(pMsg[1])
			cTag = StzLower(pMsg[1])
		ok
		cBody = StzEngineStzmPack(pMsg, 0, 0, 0)
		aEnv = @oSigner.SignNow(@cKeyId, "STZM", cTag, cBody)
		return [ "stz.signed", aEnv, pMsg ]

	# Declare where a node lives. Re-registering a name moves it (the
	# cached link is dropped so the next call dials the new place).
	def Register(pcName, pcHost, pnPort)
		_c_ = StzLower("" + pcName)
		_i_ = This._NameIndex(_c_)
		if _i_ > 0
			@aHosts[_i_] = "" + pcHost
			@aPorts[_i_] = 0 + pnPort
			This._DropLink(_i_)
		else
			@aNames + _c_
			@aHosts + ("" + pcHost)
			@aPorts + (0 + pnPort)
			@aChans + []
		ok
		return This

	# Fire-and-forget. TRUE = handed to the wire; FALSE = :Down/:Unknown.
	def Send(pcAddr, pMsg)
		_aL_ = This._Link(pcAddr)
		if ring_len(_aL_) != 2
			return 0
		ok
		@cStatus = :Ok
		cFrame = StzEngineStzmPack(This._Outgoing(pMsg), 0, 0, 0)
		@oReactor.ServerWrite(_aL_[1], _aL_[2], cFrame, 0)
		return 1

	# Request/reply with a MANDATORY timeout. Returns the reply value;
	# on anything else returns "" and LastStatus() says which anything:
	# :Timeout (no reply in time -- at-most-once: it MAY have been
	# handled), :Down (unreachable or died mid-wait), :Unknown (name
	# never registered), :BadTimeout (a non-positive timeout is refused,
	# infinite waits do not exist here).
	def Ask(pcAddr, pMsg, nTimeoutMs)
		if nTimeoutMs <= 0
			@cStatus = :BadTimeout
			return ""
		ok
		_aL_ = This._Link(pcAddr)
		if ring_len(_aL_) != 2
			return ""
		ok
		@nCorr++
		nWant = @nCorr
		cFrame = StzEngineStzmPack(This._Outgoing(pMsg), 0, nWant, 2)
		@oReactor.ServerWrite(_aL_[1], _aL_[2], cFrame, 0)
		nDeadline = StzEngineWatchTimestampMs() + nTimeoutMs
		while StzEngineWatchTimestampMs() < nDeadline
			aEv = @oReactor.ServerPoll(_aL_[1])
			if ring_len(aEv) = 3
				if aEv[1] = :data
					vR = StzEngineStzmUnpack(aEv[3])
					if StzEngineStzmLastCorrelation() = nWant
						# a refusal is an OBSERVABLE verdict, not a value
						if isList(vR) and ring_len(vR) = 2
							if isString(vR[1]) and StzLower(vR[1]) = "stz.denied"
								@cStatus = :Denied
								return ""
							ok
						ok
						@cStatus = :Ok
						return vR
					ok
					# a LATE reply from an earlier timed-out Ask:
					# at-most-once residue, discarded by correlation
				but aEv[1] = :closed
					This._DropLinkByAddr(pcAddr)
					@cStatus = :Down
					return ""
				ok
			ok
		end
		@cStatus = :Timeout
		return ""

	def CloseAll()
		nLen = ring_len(@aChans)
		for i = 1 to nLen
			if ring_len(@aChans[i]) = 2
				@oReactor.ServerStop(@aChans[i][1])
				@aChans[i] = []
			ok
		next
		return This

	def Destroy()
		This.CloseAll()
		@oReactor.Destroy()

	#-- internals ----------------------------------------------------------

	def _NameIndex(pcName)
		nLen = ring_len(@aNames)
		for i = 1 to nLen
			if @aNames[i] = pcName
				return i
			ok
		next
		return 0

	# Resolve an address to a LIVE link, dialing (or re-dialing) if
	# needed. Returns [ nChan, nConn ] or [] (with @cStatus set).
	def _Link(pcAddr)
		cAddr = StzLower("" + pcAddr)
		cName = cAddr
		cHostOverride = ""
		nAt = StzFindFirst("@", cAddr)
		if nAt > 0
			cName = StzLeft(cAddr, nAt - 1)
			cHostOverride = StzRight(cAddr, StzLen(cAddr) - nAt)
		ok
		_i_ = This._NameIndex(cName)
		if _i_ = 0
			@cStatus = :Unknown
			return []
		ok
		# a live cached link answers first -- but a :closed queued on it
		# means the peer is gone: drop and re-dial
		if ring_len(@aChans[_i_]) = 2
			aEv = @oReactor.ServerPoll(@aChans[_i_][1])
			if ring_len(aEv) = 3 and aEv[1] = :closed
				This._DropLink(_i_)
			but ring_len(aEv) = 3
				# not ours to drop: a data event polled here belongs to
				# no outstanding Ask (stale reply) -- discard is correct
			ok
		ok
		if ring_len(@aChans[_i_]) = 2
			return @aChans[_i_]
		ok
		cHost = @aHosts[_i_]
		if StzLen(cHostOverride) > 0
			cHost = cHostOverride
		ok
		nChan = @oReactor.ConnectStzm(cHost, @aPorts[_i_])
		nConn = @oReactor.WaitLinkUp(nChan, @nDialMs)
		if nConn = 0
			@oReactor.ServerStop(nChan)
			@cStatus = :Down
			return []
		ok
		@aChans[_i_] = [ nChan, nConn ]
		@cStatus = :Ok
		return @aChans[_i_]

	def _DropLink(i)
		if ring_len(@aChans[i]) = 2
			@oReactor.ServerStop(@aChans[i][1])
		ok
		@aChans[i] = []

	def _DropLinkByAddr(pcAddr)
		cAddr = StzLower("" + pcAddr)
		nAt = StzFindFirst("@", cAddr)
		if nAt > 0
			cAddr = StzLeft(cAddr, nAt - 1)
		ok
		_i_ = This._NameIndex(cAddr)
		if _i_ > 0
			This._DropLink(_i_)
		ok
