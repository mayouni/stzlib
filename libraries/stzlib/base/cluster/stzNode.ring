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
	@nPort = 0
	@oReactor = NULL
	@nSrv = 0
	@aHandlerTags = []     # parallel lists (hash-list keys fold -- keep raw)
	@aHandlerFns = []
	@nProcessed = 0
	@nUnhandled = 0
	@bStop = FALSE

	def init(pcName, pnPort)
		@cName = "" + pcName
		@nPort = 0 + pnPort
		@oReactor = new stzReactor()
		@nSrv = @oReactor.ListenStzm("127.0.0.1", @nPort)

	def Name_()
		return @cName

	# The actually-bound port (pnPort 0 = ephemeral).
	def Port()
		return @oReactor.ServerPort(@nSrv)

	# Bounded inbox: at most nCap messages queued; on overflow the policy
	# applies (:DropOldest / :DropNewest / :Refuse) and the event is
	# COUNTED. Declare BEFORE Run().
	def SetInbox(nCap, cPolicy)
		@oReactor.ServerSetInbox(@nSrv, nCap, cPolicy)
		return This

	def On(pcTag, pfHandler)
		@aHandlerTags + StzLower("" + pcTag)
		@aHandlerFns + pfHandler
		return This

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

	# One message: unpack, route by tag, reply if the frame asked for it.
	# A raising handler propagates -- the node dies LOUDLY, on purpose.
	def _Dispatch(nConn, cFrame)
		vMsg = StzEngineStzmUnpack(cFrame)
		if StzEngineStzmLastStatus() != 0
			@nUnhandled++
			return
		ok
		nCorr = StzEngineStzmLastCorrelation()
		nFlags = StzEngineStzmLastFlags()
		cTag = ""
		if isList(vMsg) and ring_len(vMsg) > 0 and isString(vMsg[1])
			cTag = StzLower(vMsg[1])
		ok
		if cTag = "stz.stop"
			@bStop = TRUE
			@nProcessed++
			return
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
