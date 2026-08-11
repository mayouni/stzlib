# base/cluster/stzNode.ring
# -----------------------------------------------------------------------------
# DISTRIBUTION D1 -- stzNode: the message-driven citizen of the node plane.
# (SOFTANZA_DISTRIBUTION_PLAN.md; D0 fixed the wire: STZM frames, stzb
# payload encoding, over reactor TCP.)
#
# A node is an OS PROCESS running one of these: it listens in STZM mode,
# holds ONE bounded inbox with a declared overflow policy (enforced in
# the ENGINE, counted, never silent), and dispatches each arriving
# message [ tag, args... ] to the handler declared with On(tag, f).
#
#   oNode = new stzNode("indexer", nPort)
#   oNode.SetInbox(1000, :Refuse)
#   oNode.On("embed", func aMsg { return DoEmbed(aMsg[2]) })
#   oNode.Run(60000)          # dispatch until stz.stop / TTL
#
# Contracts this class keeps:
# - A handler's return value is sent back ONLY when the frame asked for
#   it (FLAG_REPLY_EXPECTED), tagged with the SAME correlation id --
#   that is the Ask() half of D2, already honored here.
# - A message with no handler is COUNTED (Unhandled()), never silent.
# - A handler that raises is NOT caught: the node dies loudly and its
#   exit is observable from outside (the let-it-crash half; supervisors
#   arrive in D3).
# - "stz.stop" is the built-in clean-shutdown message.
# -----------------------------------------------------------------------------

func StzNodeQ(pcName, pnPort)
	return new stzNode(pcName, pnPort)

class stzNode from stzObject

	@cName = "node"
	@cHost = "127.0.0.1"
	@nPort = 0
	@oReactor = NULL
	@nSrv = 0
	@aHandlerTags = []     # parallel lists (hash-list keys fold -- keep raw)
	@aHandlerFns = []
	@nProcessed = 0
	@nUnhandled = 0
	@nInboxCap = 0
	@cInboxPolicy = "none"
	@bStop = FALSE
	# D5 -- security by REUSE (one vocabulary, nothing minted):
	# stzRequestSigner authenticates senders; the stzSystemActor lattice
	# authorizes them. Refusals are COUNTED and, on an Ask, OBSERVABLE
	# (a [ stz.denied, why ] reply), never silent.
	@oSigner = NULL        # the shared-keyring signer (verification side)
	@bRequireSigned = FALSE
	@nRejected = 0         # bad signature / replay / unsigned-when-required
	@nDenied = 0           # capability refusals
	@aActorNames = []      # verified kid -> actor identity
	@aActorObjs = []
	@aAdmitTags = []       # tag -> required capability KIND
	@aAdmitKinds = []

	# pcName speaks the plane's address vocabulary: "indexer" binds
	# loopback; "indexer@10.0.0.7" binds that interface (the deployed
	# form -- same vocabulary Send/Ask resolve).
	def init(pcName, pnPort)
		@cName = StzLower("" + pcName)
		nAt = StzFindFirst("@", @cName)
		if nAt > 0
			@cHost = StzRight(@cName, StzLen(@cName) - nAt)
			@cName = StzLeft(@cName, nAt - 1)
		ok
		@nPort = 0 + pnPort
		@oReactor = new stzReactor()
		@nSrv = @oReactor.ListenStzm(@cHost, @nPort)

	def Name_()
		return @cName

	# The actually-bound port (pnPort 0 = ephemeral).
	def Port()
		return @oReactor.ServerPort(@nSrv)

	# Bounded inbox: at most nCap messages queued; on overflow the policy
	# applies (:DropOldest / :DropNewest / :Refuse) and the event is
	# COUNTED. Declare BEFORE Run().
	def SetInbox(nCap, cPolicy)
		@nInboxCap = 0 + nCap
		@cInboxPolicy = StzLower("" + cPolicy)
		@oReactor.ServerSetInbox(@nSrv, nCap, cPolicy)
		return This

	def On(pcTag, pfHandler)
		@aHandlerTags + StzLower("" + pcTag)
		@aHandlerFns + pfHandler
		return This

	#-- security (D5: reuse, never mint) -----------------------------------

	# Verify signed messages against this signer's keyring (the SAME
	# stzRequestSigner discipline the federation uses -- HMAC-SHA256,
	# freshness window, nonce replay cache).
	def SecureWith(poSigner)
		@oSigner = poSigner
		return This

	# Reject UNSIGNED messages too (counted; denied reply on an Ask).
	def RequireSigned(bYes)
		@bRequireSigned = bYes
		return This

	# Register an actor identity (stzSystemActor): the verified key id
	# names the actor whose capability KINDS gate admitted tags.
	def AddActor(poActor)
		@aActorNames + StzLower(poActor.Name())
		@aActorObjs + poActor
		return This

	# Serving pcTag requires the sender's actor to hold pcKind
	# (effectful / sensing / compute / inference -- the ONE lattice).
	def Admit(pcTag, pcKind)
		@aAdmitTags + StzLower("" + pcTag)
		@aAdmitKinds + StzLower("" + pcKind)
		return This

	def Rejected()
		return @nRejected

	def Denied()
		return @nDenied

	#-- observability ------------------------------------------------------

	def Processed()
		return @nProcessed

	def Unhandled()
		return @nUnhandled

	# Overflow events counted by the ENGINE's bounded inbox.
	def Overflow()
		return @oReactor.ServerOverflow(@nSrv)

	def Pending()
		return @oReactor.ServerPendingData(@nSrv)

	#-- the dispatch loop --------------------------------------------------

	# Serve messages until stz.stop arrives or nTtlMs elapses. Waiting
	# rides the engine await (1 ms resolution), never a sleep loop.
	def Run(nTtlMs)
		nDeadline = StzEngineWatchTimestampMs() + nTtlMs
		while StzEngineWatchTimestampMs() < nDeadline and NOT @bStop
			aEv = @oReactor.ServerAwait(@nSrv, 100)
			if ring_len(aEv) = 3 and aEv[1] = :data
				This._Dispatch(aEv[2], aEv[3])
			ok
		end
		@oReactor.ServerStop(@nSrv)
		@oReactor.Destroy()

	def Stop()
		@bStop = TRUE

	# One message: unpack, authenticate + authorize (D5), route by tag,
	# reply if the frame asked for it. A raising handler propagates --
	# the node dies LOUDLY, on purpose.
	def _Dispatch(nConn, cFrame)
		vMsg = StzEngineStzmUnpack(cFrame)
		if StzEngineStzmLastStatus() != 0
			@nUnhandled++
			return
		ok
		nCorr = StzEngineStzmLastCorrelation()
		nFlags = StzEngineStzmLastFlags()
		# authentication: a signed message is [ stz.signed, env, real ];
		# the envelope is verified over the CANONICAL packed bytes of the
		# real message (bad MAC, stale ts, or replayed nonce all fail)
		cKid = ""
		bSigned = FALSE
		bWrapped = FALSE
		if isList(vMsg) and ring_len(vMsg) = 3
			if isString(vMsg[1]) and StzLower(vMsg[1]) = "stz.signed"
				bWrapped = TRUE
			ok
		ok
		if bWrapped
			if isNull(@oSigner)
				This._Refuse(nConn, nCorr, nFlags, "no-signer")
				return
			ok
			aEnv = vMsg[2]
			vReal = vMsg[3]
			cSigTag = ""
			if isList(vReal) and ring_len(vReal) > 0 and isString(vReal[1])
				cSigTag = StzLower(vReal[1])
			ok
			cBody = StzEngineStzmPack(vReal, 0, 0, 0)
			if NOT @oSigner.VerifyEnvelope("STZM", cSigTag, cBody, aEnv, 30000)
				This._Refuse(nConn, nCorr, nFlags, "signature")
				return
			ok
			bSigned = TRUE
			cKid = StzLower("" + aEnv[:kid])
			vMsg = vReal
		else
			if @bRequireSigned
				This._Refuse(nConn, nCorr, nFlags, "unsigned")
				return
			ok
		ok
		cTag = ""
		if isList(vMsg) and ring_len(vMsg) > 0 and isString(vMsg[1])
			cTag = StzLower(vMsg[1])
		ok
		if cTag = "stz.stop"
			@bStop = TRUE
			@nProcessed++
			return
		ok
		if cTag = "stz.info"
			# the node's declaration, observable from OUTSIDE: identity,
			# binding, the inbox contract, and the security counters
			@nProcessed++
			if (nFlags & 2) = 2
				vInfo = [ @cName, @cHost, @nInboxCap, @cInboxPolicy,
					@nProcessed, This.Overflow(), @nRejected, @nDenied ]
				# NOT cR: that name IS the CR carriage-return constant.
				cReply = StzEngineStzmPack(vInfo, 0, nCorr, 0)
				@oReactor.ServerWrite(@nSrv, nConn, cReply, 0)
			ok
			return
		ok
		# authorization: an admitted tag demands a capability KIND the
		# sender's VERIFIED actor identity must hold (the one lattice)
		nAdm = 0
		nLenA = ring_len(@aAdmitTags)
		for i = 1 to nLenA
			if @aAdmitTags[i] = cTag
				nAdm = i
				exit
			ok
		next
		if nAdm > 0
			nAct = 0
			nLenN = ring_len(@aActorNames)
			for i = 1 to nLenN
				if @aActorNames[i] = cKid
					nAct = i
					exit
				ok
			next
			bMay = FALSE
			if bSigned and nAct > 0
				bMay = @aActorObjs[nAct].Can(@aAdmitKinds[nAdm])
			ok
			if NOT bMay
				@nDenied++
				if (nFlags & 2) = 2
					cD = StzEngineStzmPack([ "stz.denied", "capability" ], 0, nCorr, 0)
					@oReactor.ServerWrite(@nSrv, nConn, cD, FALSE)
				ok
				return
			ok
		ok
		nH = 0
		nLen = ring_len(@aHandlerTags)
		for i = 1 to nLen
			if @aHandlerTags[i] = cTag
				nH = i
				exit
			ok
		next
		if nH = 0
			@nUnhandled++
			return
		ok
		f = @aHandlerFns[nH]
		vRes = call f(vMsg)
		@nProcessed++
		# reply only when asked: flag bit 2 = REPLY_EXPECTED; the reply
		# carries the SAME correlation id so the asker can match it
		if (nFlags & 2) = 2
			cReply = StzEngineStzmPack(vRes, 0, nCorr, 0)
			@oReactor.ServerWrite(@nSrv, nConn, cReply, FALSE)
		ok

	# An authentication refusal: COUNTED, and observable on an Ask.
	def _Refuse(nConn, nCorr, nFlags, cWhy)
		@nRejected++
		if (nFlags & 2) = 2
			cD = StzEngineStzmPack([ "stz.denied", cWhy ], 0, nCorr, 0)
			@oReactor.ServerWrite(@nSrv, nConn, cD, FALSE)
		ok
