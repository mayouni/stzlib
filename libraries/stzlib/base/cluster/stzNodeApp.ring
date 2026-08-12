# base/cluster/stzNodeApp.ring
# -----------------------------------------------------------------------------
# DISTRIBUTION D4 -- stzNodeApp: the declarative surface. "This part
# runs elsewhere" becomes a DEPLOYMENT statement, not a rewrite.
#
#   oApp = new stzNodeApp("shop")
#   oApp.Node("indexer").On("embed", 'return DoEmbed(aMsg[2])')
#   oApp.Node("search").Requires([ :neural ])
#   oApp.Supervise([ "indexer", "search" ], :OneForOne)
#   oApp.InboxOf("indexer", 1000, :Refuse)
#   oApp.RunLocal()                      # whole topology, one machine
#   # oApp.Deploy("indexer", "10.0.0.7") # one line moves a node
#   ? Ask("indexer", [ "embed", "bread" ], 2000)
#
# The topology declaration IS DATA (the W-string spirit): handlers are
# Ring code strings (a closure cannot cross an OS process boundary --
# code-as-data can, and is inspectable and printable on the way), and
# the whole topology lives in plain lists. Describe() emits the
# declaration; StzNodeAppFromDescription() rebuilds an identical app
# from it -- the D4 kill criterion is that round trip.
#
# Ring note: Node() returns This (the app) with the node made CURRENT,
# so the sketch's fluent chain works without handing out spec objects
# -- Ring copies objects on assignment (the engine-wrapper copy law),
# and a copied spec would silently swallow declarations.
#
# RunLocal() IS the pseudo-distributed mode: every node becomes a REAL
# child OS process (a generated script over stzNode) under a REAL
# stzNodeSupervisor, all on loopback -- the same wire, mailboxes and
# supervision a multi-machine run uses, so moving a node later changes
# latency, not semantics. Deploy(name, host) regenerates the node bound
# to the new host, kills the old process, lets SUPERVISION respawn it
# (deployment rides the same mechanics as healing), and re-points the
# registry -- the caller's Send/Ask never change.
# -----------------------------------------------------------------------------

func StzNodeAppQ(pcName)
	return new stzNodeApp(pcName)

# The rebuild half of the D4 kill criterion: description -> app.
func StzNodeAppFromDescription(aDesc)
	_oApp_ = new stzNodeApp(aDesc[2])
	_aNodes_ = aDesc[3]
	_nNodes_ = ring_len(_aNodes_)
	for _i_ = 1 to _nNodes_
		_aN_ = _aNodes_[_i_]
		_oApp_.Node(_aN_[2])
		if len(_aN_[3]) > 0
			_oApp_.AtHost(_aN_[3])
		ok
		if _aN_[4] > 0
			_oApp_.AtPort(_aN_[4])
		ok
		_aOn_ = _aN_[5]
		_nOn_ = ring_len(_aOn_)
		for _h_ = 1 to _nOn_
			_oApp_.On(_aOn_[_h_][1], _aOn_[_h_][2])
		next
		if ring_len(_aN_[6]) > 0
			_oApp_.Requires(_aN_[6])
		ok
		if _aN_[7] > 0
			_oApp_.InboxOf(_aN_[2], _aN_[7], _aN_[8])
		ok
		if ring_len(_aN_) >= 9
			if ring_len(_aN_[9]) > 0
				_oApp_.Node(_aN_[2])
				_oApp_.Boot(_aN_[9])
			ok
		ok
	next
	_aGroups_ = aDesc[4]
	_nGroups_ = ring_len(_aGroups_)
	for _g_ = 1 to _nGroups_
		_oApp_.Supervise(_aGroups_[_g_][1], _aGroups_[_g_][2])
	next
	_oApp_.RestartBudget(aDesc[5][1], aDesc[5][2])
	return _oApp_

class stzNodeApp from stzObject

	@cName = "app"
	# one spec ROW per node: [ cName, cHost, nPort, aOn, aRequires,
	#                          nInboxCap, cInboxPolicy, cBootCode ]
	@aSpecs = []
	@nCurrent = 0          # the node fluent On/Requires/At* apply to
	@aGroups = []          # [ [ aNames, cStrategy ], ... ]
	@nBudgetMax = 5
	@nBudgetWindowMs = 30000
	@nNodeTtlMs = 120000
	@oSup = ""           # the ONE supervisor of the running topology
	@bRunning = 0
	@aScriptFiles = []

	def init(pcName)
		@cName = StzLower("" + pcName)

	def Name_()
		return @cName

	#-- declaration (fluent: Node() makes a node current) ------------------

	def Node(pcName)
		cN = StzLower("" + pcName)
		nLen = ring_len(@aSpecs)
		for i = 1 to nLen
			if @aSpecs[i][1] = cN
				@nCurrent = i
				return This
			ok
		next
		@aSpecs + [ cN, "", 0, [], [], 0, "none", "" ]
		@nCurrent = ring_len(@aSpecs)
		return This

	# Handler = tag + RING CODE (a string; aMsg is in scope, return the
	# reply value). Code-as-data is what crosses the process boundary.
	def On(pcTag, pcRingCode)
		@aSpecs[@nCurrent][4] + [ StzLower("" + pcTag), "" + pcRingCode ]
		return This

	def Requires(paList)
		_a_ = []
		if isString(paList)
			_a_ + ("" + paList)
		but isList(paList)
			nLen = ring_len(paList)
			for i = 1 to nLen
				_a_ + ("" + paList[i])
			next
		ok
		@aSpecs[@nCurrent][5] = _a_
		return This

	# Node BOOT code (a Ring code string, top-level in the generated
	# process, after handlers, before Run). This is where a node builds
	# its RESIDENT state -- and because it runs on EVERY (re)start, a
	# supervised restart rebuilds that state: a fresh process has no
	# memory, so its boot must know how to make some.
	def Boot(pcRingCode)
		@aSpecs[@nCurrent][8] = "" + pcRingCode
		return This

	def AtHost(pcHost)
		@aSpecs[@nCurrent][2] = StzLower("" + pcHost)
		return This

	def AtPort(pnPort)
		@aSpecs[@nCurrent][3] = 0 + pnPort
		return This

	def InboxOf(pcName, nCap, cPolicy)
		This.Node(pcName)
		@aSpecs[@nCurrent][6] = 0 + nCap
		@aSpecs[@nCurrent][7] = StzLower("" + cPolicy)
		return This

	def Supervise(paNames, pcStrategy)
		_a_ = []
		nLen = ring_len(paNames)
		for i = 1 to nLen
			_a_ + StzLower("" + paNames[i])
		next
		@aGroups + [ _a_, StzLower("" + pcStrategy) ]
		return This

	def RestartBudget(nMax, nWindowMs)
		@nBudgetMax = 0 + nMax
		@nBudgetWindowMs = 0 + nWindowMs
		return This

	def NodeTtl(nMs)
		@nNodeTtlMs = 0 + nMs
		return This

	# The whole declaration as plain DATA -- inspectable, printable,
	# sufficient to rebuild the app.
	def Describe()
		aNodes = []
		nLen = ring_len(@aSpecs)
		for i = 1 to nLen
			aNodes + [ "node", @aSpecs[i][1], @aSpecs[i][2], @aSpecs[i][3],
				@aSpecs[i][4], @aSpecs[i][5], @aSpecs[i][6], @aSpecs[i][7],
				@aSpecs[i][8] ]
		next
		return [ "app", @cName, aNodes, @aGroups,
			[ @nBudgetMax, @nBudgetWindowMs ] ]

	#-- the running topology -----------------------------------------------

	# Every node = a child OS process on this machine, under REAL
	# supervision, over the REAL wire (loopback). Same semantics as a
	# multi-machine run; only the latency differs. (D4 scope: the first
	# Supervise() group sets the strategy; every node is supervised.)
	def RunLocal()
		if @bRunning
			return This
		ok
		nBase = 46500 + (StzEngineTimeNowMs() % 250)
		nLen = ring_len(@aSpecs)
		for i = 1 to nLen
			if @aSpecs[i][3] = 0
				@aSpecs[i][3] = nBase + i
			ok
		next
		@oSup = new stzNodeSupervisor()
		@oSup.SetName(@cName + "-supervisor")
		@oSup.RestartBudget(@nBudgetMax, @nBudgetWindowMs)
		if ring_len(@aGroups) > 0
			@oSup.Strategy(@aGroups[1][2])
		ok
		for i = 1 to nLen
			cScript = This._GenerateScript(i)
			@oSup.Child(@aSpecs[i][1], cScript, @aSpecs[i][3])
			if ring_len(@aSpecs[i][2]) > 0
				@oSup.SetChildHost(@aSpecs[i][1], @aSpecs[i][2])
			ok
		next
		@oSup.StartAll()
		@bRunning = 1
		return This

	# Drive supervision (the app keeps the house Name_()/Cycle()
	# contract, so it is hostable like any periodic citizen).
	def Cycle()
		if NOT isNull(@oSup)
			@oSup.Cycle()
		ok
		return This

	def RestartsOf(pcName)
		if isNull(@oSup)
			return -1
		ok
		return @oSup.RestartsOf(pcName)

	def Escalated()
		if isNull(@oSup)
			return 0
		ok
		return @oSup.Escalated()

	# Kill a node's OS process (chaos/testing); supervision observes the
	# death on its next Cycle and heals it like any other.
	def KillNode(pcName)
		if NOT isNull(@oSup)
			@oSup.KillChild(pcName)
		ok
		return This

	# ONE line moves a node; nothing else changes for any caller.
	def Deploy(pcName, pcHost)
		This.Node(pcName)
		This.AtHost(pcHost)
		if NOT @bRunning
			return This
		ok
		i = @nCurrent
		This._GenerateScript(i)
		@oSup.SetChildHost(@aSpecs[i][1], @aSpecs[i][2])
		@oSup.KillChild(@aSpecs[i][1])
		# supervision observes the death on its next Cycle and respawns
		# from the regenerated (re-hosted) script; the registry re-points
		# NOW so callers already resolve to the new place
		NodeRegister(@aSpecs[i][1], @aSpecs[i][2], @aSpecs[i][3])
		return This

	def StopAll()
		nLen = ring_len(@aSpecs)
		for i = 1 to nLen
			StzNodePlane().Send(@aSpecs[i][1], [ "stz.stop" ])
		next
		if NOT isNull(@oSup)
			@oSup.Destroy()
			@oSup = ""
		ok
		nFiles = ring_len(@aScriptFiles)
		for i = 1 to nFiles
			remove(@aScriptFiles[i])
		next
		@aScriptFiles = []
		@bRunning = 0
		return This

	#-- internals ----------------------------------------------------------

	# The node process source, generated from the DECLARATION. Handler
	# bodies are the declared code strings, verbatim.
	# RING TRAP, learned here the hard way: a method called MID-EXPRESSION
	# shares the caller's local namespace (case-insensitively) -- the
	# original _BaseRing() had a local `nL` (path length, 40) that
	# clobbered this method's `nl` newline var THROUGH the call, turning
	# every generated newline into the literal "40". Hence the fetch-first
	# style and the _br_-prefixed locals below.
	def _GenerateScript(i)
		cFile = ".stznode_" + @cName + "_" + @aSpecs[i][1] + "_gen.ring"
		cBasePath = This._BaseRing()
		cNlChar = char(10)
		cAddr = @aSpecs[i][1]
		if ring_len(@aSpecs[i][2]) > 0
			cAddr = cAddr + "@" + @aSpecs[i][2]
		ok
		cCode = 'load "' + cBasePath + '"' + cNlChar +
			'nPort = 0 + sysargv[len(sysargv)]' + cNlChar +
			'oNode = new stzNode("' + cAddr + '", nPort)' + cNlChar
		if @aSpecs[i][6] > 0
			cCode += 'oNode.SetInbox(' + @aSpecs[i][6] + ', "' +
				@aSpecs[i][7] + '")' + cNlChar
		ok
		aOn = @aSpecs[i][4]
		nOn = ring_len(aOn)
		for h = 1 to nOn
			cCode += 'oNode.On("' + aOn[h][1] + '", func aMsg {' + cNlChar +
				aOn[h][2] + cNlChar + '})' + cNlChar
		next
		if ring_len(@aSpecs[i][8]) > 0
			cCode += @aSpecs[i][8] + cNlChar
		ok
		cCode += 'oNode.Run(' + @nNodeTtlMs + ')' + cNlChar
		write(cFile, cCode)
		if StzFindFirst(cFile, @aScriptFiles) = 0
			@aScriptFiles + cFile
		ok
		return cFile

	def _BaseRing()
		_nBrSlash_ = 0
		_nBrLen_ = StzLen($cEngineDir)
		for _iBr_ = 1 to _nBrLen_
			if $cEngineDir[_iBr_] = "/"
				_nBrSlash_ = _iBr_
			ok
		next
		return StzLeft($cEngineDir, _nBrSlash_ - 1) + "/base/stzBase.ring"
