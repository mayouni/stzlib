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

# Resolves node names to addresses and carries location-transparent Send and Ask, so the caller's code is the same whether a node is local or remote.
#
# Register a name with a host and a port; Send then hands a message over without waiting and Ask
# waits for a reply, with a mandatory time limit (a limit of 0 or less is refused, never an infinite
# wait). Delivery is at most once, unreachable and dead are the same status, down, and links are
# cached by name and re-dialed after a close. LastStatus says which outcome the last call had. The
# plane the bare Send, Ask and NodeRegister functions ride is the one returned by StzNodePlane().
# The documentation run exercised only the calls that do not dial: unknown names and refused time
# limits.
#
#   receiver   o1 = new stzNodeRegistry()
#   example    ? o1.Send("ghost", [ "warm" ])
#              #--> 0
#              ? o1.LastStatus()
#              #--> unknown
#              o1.Ask("ghost", [ "x" ], 0)
#              ? o1.LastStatus()
#              #--> badtimeout
#   see        stzNode, stzNodeSupervisor, stzNodeApp
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

	# Creates a registry of node addresses with one reactor that will carry every link to them.
	#
	#   returns    nothing; the object is built
	#   see        Register, Send
	def init()
		@oReactor = new stzReactor()

	# Returns the outcome of the last Send or Ask: ok, timeout, down, unknown, badtimeout or denied, in lower case.
	#
	#   returns    a text
	#   warning    it reads ok on a new registry
	#   see        Send, Ask
	def LastStatus()
		return @cStatus

	# Makes the registry sign every outgoing message as a given key, so receivers can verify and refuse it.
	#
	#   poSigner   a stzRequestSigner holding the shared keyring
	#   pcKeyId    the key id the messages are signed as
	#   returns    the registry itself, so calls chain
	#   note       the signer was a stand-in during the run: only the storing was exercised
	#   warning    a receiver that refuses a signed Ask is reported as the status denied
	#   see        Send, Ask
	#@ aka  D5 -- sign everything this plane sends, as pcKeyId, with the SAME stzRequestSigner discipline the federation uses. The receiver verifies against the shared keyring; a denial comes back as an observable :Denied, never a silent drop.
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

	# Declares where a named node lives; registering a name again moves it, and the cached link is dropped so the next call dials the new place.
	#
	#   pcName     the node's name, matched without regard to case
	#   pcHost     the node's host or interface address
	#   pnPort     the node's port
	#   returns    the registry itself, so calls chain
	#   warning    nothing connects here: the link is dialed on the first Send or Ask
	#   see        Send, Ask
	#@ aka  Declare where a node lives. Re-registering a name moves it (the cached link is dropped so the next call dials the new place).
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

	# Hands a message to a node without waiting for an answer, and answers whether it reached the wire.
	#
	#   pcAddr     the node's name, or name@host to override the host
	#   pMsg       the message, a list [ tag, args... ]
	#   returns    1 if handed to the wire, 0 when the node is unknown or unreachable
	#   note       run only with a name that is not registered, so no link was dialed
	#   warning    at most once, with no retry; LastStatus tells unknown from down
	#   see        Ask, LastStatus
	#@ aka  Fire-and-forget. TRUE = handed to the wire; FALSE = :Down/:Unknown.
	def Send(pcAddr, pMsg)
		_aL_ = This._Link(pcAddr)
		if ring_len(_aL_) != 2
			return 0
		ok
		@cStatus = :Ok
		cFrame = StzEngineStzmPack(This._Outgoing(pMsg), 0, 0, 0)
		@oReactor.ServerWrite(_aL_[1], _aL_[2], cFrame, 0)
		return 1

	# Sends a message to a node and waits up to a time limit for the reply, which it returns.
	#
	#   pcAddr       the node's name, or name@host to override the host
	#   pMsg         the message, a list [ tag, args... ]
	#   nTimeoutMs   how long to wait, in milliseconds, which must be above 0
	#   returns      the reply value; an empty text on timeout, down, unknown, badtimeout or denied
	#   note         run only with a name that is not registered and with a refused limit, so no
	#                link was dialed
	#   warning      the limit is mandatory: 0 or less is refused with the status badtimeout and
	#                nothing is sent; delivery is at most once, so a timed-out Ask may still have
	#                been handled, and its late reply is dropped by correlation id
	#   see          Send, LastStatus
	#@ aka  Request/reply with a MANDATORY timeout. Returns the reply value; on anything else returns "" and LastStatus() says which anything: :Timeout (no reply in time -- at-most-once: it MAY have been handled), :Down (unreachable or died mid-wait), :Unknown (name never registered), :BadTimeout (a non-positive timeout is refused, infinite waits do not exist here).
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

	# Closes every cached link; the registered names stay and the next call dials again.
	#
	#   returns    the registry itself, so calls chain
	#   see        Register, Destroy
	def CloseAll()
		nLen = ring_len(@aChans)
		for i = 1 to nLen
			if ring_len(@aChans[i]) = 2
				@oReactor.ServerStop(@aChans[i][1])
				@aChans[i] = []
			ok
		next
		return This

	# Closes every link and destroys the registry's reactor.
	#
	#   returns    nothing
	#   warning    the registry cannot be used afterwards
	#   see        CloseAll
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
