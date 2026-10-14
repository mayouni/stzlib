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

# A node is an operating-system process that listens for STZM messages on a TCP port and dispatches each one to a handler by tag.
#
# It holds one bounded inbox with a declared overflow policy that the engine enforces and counts.
# On(tag, f) declares a handler; a handler's value is returned only when the sender asked for a
# reply. A message with no handler is counted, never silent; a handler that raises kills the node,
# on purpose, so that a supervisor sees the exit. stz.stop is the built-in clean shutdown and
# stz.info makes the node report its identity, binding and counters. Signing and capability gates
# reuse stzRequestSigner and stzSystemActor. Constructing a node opens a listening port, and Run
# blocks: none of the networked methods were run for this documentation.
#
#   receiver   o1 = StzNodeQ("indexer", 0)
#   see        stzNodeSupervisor, stzNodeApp, stzNodeRegistry
class stzNode from stzObject

	@cName = "node"
	@cHost = "127.0.0.1"
	@nPort = 0
	@oReactor = ""
	@nSrv = 0
	@aHandlerTags = []     # parallel lists (hash-list keys fold -- keep raw)
	@aHandlerFns = []
	@nProcessed = 0
	@nUnhandled = 0
	@nInboxCap = 0
	@cInboxPolicy = "none"
	@bStop = 0
	# D5 -- security by REUSE (one vocabulary, nothing minted):
	# stzRequestSigner authenticates senders; the stzSystemActor lattice
	# authorizes them. Refusals are COUNTED and, on an Ask, OBSERVABLE
	# (a [ stz.denied, why ] reply), never silent.
	@oSigner = ""        # the shared-keyring signer (verification side)
	@bRequireSigned = 0
	@nRejected = 0         # bad signature / replay / unsigned-when-required
	@nDenied = 0           # capability refusals
	@aActorNames = []      # verified kid -> actor identity
	@aActorObjs = []
	@aAdmitTags = []       # tag -> required capability KIND
	@aAdmitKinds = []

	# Starts a node: a reactor that listens for STZM messages on a TCP port, under a name, ready to dispatch each message to a handler.
	#
	#   pcName     the node's name
	#   pnPort     the port to listen on, 0 for any free port
	#   returns    nothing; the object is built
	#   note       not run: it opens a listening port, which this documentation pass does not do
	#   warning    binds a TCP port when it is built
	#   see        Run, Port, On
	#@ aka  pcName speaks the plane's address vocabulary: "indexer" binds loopback; "indexer@10.0.0.7" binds that interface (the deployed form -- same vocabulary Send/Ask resolve).
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

	# Returns the node's name, in lower case and without any @host part.
	#
	#   returns    a text
	#   see        init
	def Name_()
		return @cName

	# Returns the port the node is actually bound to, which differs from the one asked for when 0 was given.
	#
	#   returns    a number
	#   warning    not run: it needs a node that is listening
	#   see        init
	#@ aka  The actually-bound port (pnPort 0 = ephemeral).
	def Port()
		return @oReactor.ServerPort(@nSrv)

	# Declares the bounded inbox: at most nCap queued messages, and what to do with the next one when it is full.
	#
	#   nCap       the most messages the inbox may hold
	#   cPolicy    the overflow policy, :DropOldest, :DropNewest or :Refuse
	#   returns    the node itself, so calls chain
	#   note       not run: it needs a node that is listening
	#   warning    call it before Run; every overflow is counted by the engine and never silent
	#   see        Overflow, Pending
	#@ aka  Bounded inbox: at most nCap messages queued; on overflow the policy applies (:DropOldest / :DropNewest / :Refuse) and the event is COUNTED. Declare BEFORE Run().
	def SetInbox(nCap, cPolicy)
		@nInboxCap = 0 + nCap
		@cInboxPolicy = StzLower("" + cPolicy)
		@oReactor.ServerSetInbox(@nSrv, nCap, cPolicy)
		return This

	# Declares the handler for a message tag; a handler's return value is sent back only when the sender asked for a reply.
	#
	#   pcTag       the tag of the messages to handle, matched without regard to case
	#   pfHandler   a function that takes the message list [ tag, args... ] and returns the reply
	#   returns     the node itself, so calls chain
	#   note        run on a node built without a reactor, so only the registration was exercised
	#   warning     a handler that raises is not caught: the node dies loudly, on purpose, and its
	#               exit is visible from outside; a message with no handler is counted in Unhandled
	#   see         Unhandled, Processed
	def On(pcTag, pfHandler)
		@aHandlerTags + StzLower("" + pcTag)
		@aHandlerFns + pfHandler
		return This

	# Makes the node verify signed messages against a signer's keyring.
	#
	#   poSigner   a stzRequestSigner holding the shared keyring
	#   returns    the node itself, so calls chain
	#   note       read from the code, not run: it needs a signer and a live node
	#   warning    a message that fails verification (bad signature, stale, replayed) is refused and
	#              counted in Rejected
	#   see        RequireSigned, Rejected
	#@ aka  -- security (D5: reuse, never mint) -----------------------------------
	def SecureWith(poSigner)
		@oSigner = poSigner
		return This

	# Makes the node refuse every message that is not signed.
	#
	#   bYes       1 to refuse unsigned messages, 0 to accept them
	#   returns    the node itself, so calls chain
	#   note       run on a node built without a reactor, so only the flag was exercised
	#   warning    a refused message is counted in Rejected, and an Ask gets a [ stz.denied,
	#              unsigned ] reply
	#   see        SecureWith, Rejected
	#@ aka  Reject UNSIGNED messages too (counted; denied reply on an Ask).
	def RequireSigned(bYes)
		@bRequireSigned = bYes
		return This

	# Registers an actor identity, so the verified key id of a signed message names the actor whose capabilities gate the admitted tags.
	#
	#   poActor    a stzSystemActor, whose Name() is matched to the key id of the sender
	#   returns    the node itself, so calls chain
	#   warning    read from the code, not run
	#   see        Admit, SecureWith
	#@ aka  Register an actor identity (stzSystemActor): the verified key id names the actor whose capability KINDS gate admitted tags.
	def AddActor(poActor)
		@aActorNames + StzLower(poActor.Name())
		@aActorObjs + poActor
		return This

	# Requires the sender's actor to hold a capability kind before the node serves a tag.
	#
	#   pcTag      the tag to protect, matched without regard to case
	#   pcKind     the capability kind the actor must hold: effectful, sensing, compute or inference
	#   returns    the node itself, so calls chain
	#   note       run on a node built without a reactor, so only the registration was exercised
	#   warning    an unsigned sender or an unknown actor is denied; each denial is counted in
	#              Denied and, on an Ask, answered with [ stz.denied, capability ]
	#   see        AddActor, Denied
	#@ aka  Serving pcTag requires the sender's actor to hold pcKind (effectful / sensing / compute / inference -- the ONE lattice).
	def Admit(pcTag, pcKind)
		@aAdmitTags + StzLower("" + pcTag)
		@aAdmitKinds + StzLower("" + pcKind)
		return This

	# Returns how many messages were refused for authentication: a bad signature, a replay, or unsigned when signing is required.
	#
	#   returns    a number
	#   see        SecureWith, RequireSigned, Denied
	def Rejected()
		return @nRejected

	# Returns how many messages were refused for lack of capability.
	#
	#   returns    a number
	#   see        Admit, Rejected
	def Denied()
		return @nDenied

	# Returns how many messages were handled, including the built-in stz.stop and stz.info.
	#
	#   returns    a number
	#   see        Unhandled, Run
	#@ aka  -- observability ------------------------------------------------------
	def Processed()
		return @nProcessed

	# Returns how many messages were dropped because no handler matched their tag or because they did not unpack.
	#
	#   returns    a number
	#   see        On, Processed
	def Unhandled()
		return @nUnhandled

	# Returns how many messages the engine's bounded inbox dropped or refused for lack of room.
	#
	#   returns    a number
	#   warning    not run: it needs a node that is listening
	#   see        SetInbox, Pending
	#@ aka  Overflow events counted by the ENGINE's bounded inbox.
	def Overflow()
		return @oReactor.ServerOverflow(@nSrv)

	# Returns how much unread data the node's server holds.
	#
	#   returns    a number
	#   warning    not run: it needs a node that is listening
	#   see        Overflow, SetInbox
	def Pending()
		return @oReactor.ServerPendingData(@nSrv)

	# Serves messages until stz.stop arrives, Stop is called or the time limit elapses, then stops the server and destroys the reactor.
	#
	#   nTtlMs     how long to serve at most, in milliseconds
	#   returns    nothing
	#   note       not run: it blocks on a live port; read from the code
	#   warning    blocks the process while it serves, and the node cannot be reused afterwards
	#   see        Stop, On
	#@ aka  -- the dispatch loop --------------------------------------------------
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

	# Asks a running node to finish after its current wait.
	#
	#   returns    nothing
	#   note       run on a node built without a reactor, so only the flag was set
	#   warning    takes effect at the next 100 ms wait inside Run; it does not return the node
	#   see        Run
	def Stop()
		@bStop = 1

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
		bSigned = 0
		bWrapped = 0
		if isList(vMsg) and ring_len(vMsg) = 3
			if isString(vMsg[1]) and StzLower(vMsg[1]) = "stz.signed"
				bWrapped = 1
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
			bSigned = 1
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
			@bStop = 1
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
			bMay = 0
			if bSigned and nAct > 0
				bMay = @aActorObjs[nAct].Can(@aAdmitKinds[nAdm])
			ok
			if NOT bMay
				@nDenied++
				if (nFlags & 2) = 2
					cD = StzEngineStzmPack([ "stz.denied", "capability" ], 0, nCorr, 0)
					@oReactor.ServerWrite(@nSrv, nConn, cD, 0)
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
			@oReactor.ServerWrite(@nSrv, nConn, cReply, 0)
		ok

	# An authentication refusal: COUNTED, and observable on an Ask.
	def _Refuse(nConn, nCorr, nFlags, cWhy)
		@nRejected++
		if (nFlags & 2) = 2
			cD = StzEngineStzmPack([ "stz.denied", cWhy ], 0, nCorr, 0)
			@oReactor.ServerWrite(@nSrv, nConn, cD, 0)
		ok
