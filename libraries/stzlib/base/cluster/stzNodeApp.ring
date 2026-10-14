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

# Declares a whole node topology as data, then runs it as real supervised processes on one machine or moves a node to another host.
#
# Node() makes a node current and the fluent calls On, Requires, Boot, AtHost, AtPort and InboxOf
# apply to it. A handler is a Ring code string, because code-as-data can cross an OS-process
# boundary where a closure cannot. Describe() returns the declaration as plain lists and
# StzNodeAppFromDescription rebuilds an identical app from it. RunLocal starts every node as a child
# process under a stzNodeSupervisor, all on loopback; Deploy moves a node by changing one host. The
# declaration methods are pure data and were run; RunLocal, StopAll and the running case of Deploy
# start processes and open ports, and were not run.
#
#   receiver   o1 = new stzNodeApp("shop") o1.Node("indexer") o1.On("embed", "return aMsg[2]")
#              o1.AtPort(47001)
#   example    ? o1.Name_()
#              #--> shop
#              ? @@( o1.Describe() )
#              #--> [ "app", "shop", [ [ "node", "indexer", "", 47001, [ [ "embed", "return aMsg[2]" ] ], [ ], 0, "none", "" ] ], [ ], [ 5, 30000 ] ]
#              ? o1.RestartsOf("indexer")
#              #--> -1
#   see        stzNode, stzNodeSupervisor, stzNodeRegistry
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

	# Creates an empty declaration of a node topology, under a name; nothing is started.
	#
	#   pcName     the application's name, stored in lower case
	#   returns    nothing; the object is built
	#   see        Node, Describe
	def init(pcName)
		@cName = StzLower("" + pcName)

	# Returns the application's name, in lower case.
	#
	#   returns    a text
	#   see        init
	def Name_()
		return @cName

	# Declares a node by name, or makes the existing one current, so that the next On, Requires, Boot, AtHost and AtPort calls apply to it.
	#
	#   pcName     the node's name, stored in lower case
	#   returns    the app itself, so calls chain
	#   warning    declarations are plain data; nothing starts until RunLocal
	#   see        On, Requires, AtHost
	#@ aka  -- declaration (fluent: Node() makes a node current) ------------------
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

	# Declares a handler on the current node: a message tag and the Ring code that computes the reply.
	#
	#   pcTag        the message tag, stored in lower case
	#   pcRingCode   Ring code as text, in which the message list aMsg is in scope and which returns
	#                the reply
	#   returns      the app itself, so calls chain
	#   warning      the handler is a code string, not a function, so that it can cross a process
	#                boundary; called before any Node it raises R2 Array Access (Index out of range)
	#   see          Node, Describe
	#@ aka  Handler = tag + RING CODE (a string; aMsg is in scope, return the reply value). Code-as-data is what crosses the process boundary.
	def On(pcTag, pcRingCode)
		@aSpecs[@nCurrent][4] + [ StzLower("" + pcTag), "" + pcRingCode ]
		return This

	# Declares the facets the current node needs.
	#
	#   paList     a list of facet names, or one name as text
	#   returns    the app itself, so calls chain
	#   warning    called before any Node it raises R2 Array Access (Index out of range)
	#   see        Node
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

	# Sets the code that runs at the top level of the node's process on every start and restart, before it serves.
	#
	#   pcRingCode   Ring code as text that builds the node's resident state
	#   returns      the app itself, so calls chain
	#   warning      a supervised restart gives a fresh process, so the boot code is what rebuilds
	#                its state
	#   see          On, RunLocal
	#@ aka  Node BOOT code (a Ring code string, top-level in the generated process, after handlers, before Run). This is where a node builds its RESIDENT state -- and because it runs on EVERY (re)start, a supervised restart rebuilds that state: a fresh process has no memory, so its boot must know how to make some.
	def Boot(pcRingCode)
		@aSpecs[@nCurrent][8] = "" + pcRingCode
		return This

	# Sets the host the current node binds, so that Deploy-style moves are one line.
	#
	#   pcHost     the host or interface address, stored in lower case
	#   returns    the app itself, so calls chain
	#   see        AtPort, Deploy
	def AtHost(pcHost)
		@aSpecs[@nCurrent][2] = StzLower("" + pcHost)
		return This

	# Sets the port the current node listens on.
	#
	#   pnPort     the port
	#   returns    the app itself, so calls chain
	#   see        AtHost
	def AtPort(pnPort)
		@aSpecs[@nCurrent][3] = 0 + pnPort
		return This

	# Declares the bounded inbox of a node: its capacity and what to do when it is full.
	#
	#   pcName     the node's name, made current
	#   nCap       the most messages the inbox holds
	#   cPolicy    the overflow policy, :DropOldest, :DropNewest or :Refuse
	#   returns    the app itself, so calls chain
	#   see        Node, On
	def InboxOf(pcName, nCap, cPolicy)
		This.Node(pcName)
		@aSpecs[@nCurrent][6] = 0 + nCap
		@aSpecs[@nCurrent][7] = StzLower("" + cPolicy)
		return This

	# Declares a group of nodes to supervise and the restart strategy that applies.
	#
	#   paNames      the node names in the group
	#   pcStrategy   the restart strategy, such as :OneForOne
	#   returns      the app itself, so calls chain
	#   warning      only the first group's strategy is used today, and every node is supervised
	#   see          RestartBudget, RunLocal
	def Supervise(paNames, pcStrategy)
		_a_ = []
		nLen = ring_len(paNames)
		for i = 1 to nLen
			_a_ + StzLower("" + paNames[i])
		next
		@aGroups + [ _a_, StzLower("" + pcStrategy) ]
		return This

	# Sets how many restarts the supervisor may do within a time window before it escalates.
	#
	#   nMax        the restarts allowed, 5 by default
	#   nWindowMs   the window length in milliseconds, 30000 by default
	#   returns     the app itself, so calls chain
	#   see         Supervise, Escalated
	def RestartBudget(nMax, nWindowMs)
		@nBudgetMax = 0 + nMax
		@nBudgetWindowMs = 0 + nWindowMs
		return This

	# Sets how long each node process serves before it ends by itself.
	#
	#   nMs        the time to live in milliseconds, 120000 by default
	#   returns    the app itself, so calls chain
	#   see        RunLocal
	def NodeTtl(nMs)
		@nNodeTtlMs = 0 + nMs
		return This

	# Returns the whole declaration as plain lists: [ app, name, nodes, groups, budget ].
	#
	#   returns    a list
	#   warning    a node row is [ node, name, host, port, handlers, requires, inbox capacity, inbox
	#              policy, boot code ]; StzNodeAppFromDescription rebuilds an identical app from it,
	#              which was checked by comparing both descriptions
	#   see        RunLocal
	#@ aka  The whole declaration as plain DATA -- inspectable, printable, sufficient to rebuild the app.
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

	# Starts every declared node as a real child process on this machine, on loopback, under a real supervisor.
	#
	#   returns    the app itself, so calls chain
	#   note       not run: it starts child processes and listens on ports
	#   warning    spawns processes, binds ports and writes generated scripts into the working
	#              folder; calling it a second time while running changes nothing
	#   see        Cycle, StopAll, Describe
	#@ aka  -- the running topology -----------------------------------------------
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

	# Lets the supervisor check its children and restart the dead ones; does nothing before RunLocal.
	#
	#   returns    the app itself, so calls chain
	#   note       run only before RunLocal, where it does nothing
	#   warning    the call that lets an agent host tick the app
	#   see        RunLocal, RestartsOf
	#@ aka  Drive supervision (the app keeps the house Name_()/Cycle() contract, so it is hostable like any periodic citizen).
	def Cycle()
		if NOT isNull(@oSup)
			@oSup.Cycle()
		ok
		return This

	# Returns how many times the supervisor restarted a node; -1 before RunLocal.
	#
	#   pcName     the node's name
	#   returns    a number
	#   warning    run only before RunLocal
	#   see        Escalated, Cycle
	def RestartsOf(pcName)
		if isNull(@oSup)
			return -1
		ok
		return @oSup.RestartsOf(pcName)

	# Returns how many times the supervisor gave up on a restart budget and escalated; 0 before RunLocal.
	#
	#   returns    a number
	#   warning    run only before RunLocal
	#   see        RestartBudget, RestartsOf
	def Escalated()
		if isNull(@oSup)
			return 0
		ok
		return @oSup.Escalated()

	# Kills a node's process, for chaos tests; supervision restarts it on its next Cycle.
	#
	#   pcName     the node's name
	#   returns    the app itself, so calls chain
	#   note       run only before RunLocal, where it does nothing
	#   warning    does nothing before RunLocal
	#   see        Cycle, RestartsOf
	#@ aka  Kill a node's OS process (chaos/testing); supervision observes the death on its next Cycle and heals it like any other.
	def KillNode(pcName)
		if NOT isNull(@oSup)
			@oSup.KillChild(pcName)
		ok
		return This

	# Moves a node to another host with one line; while running, it also restarts the node there and re-points the registry.
	#
	#   pcName     the node's name
	#   pcHost     the host to move it to
	#   returns    the app itself, so calls chain
	#   note       run only before RunLocal, where it only changes the declaration; the running case
	#              is read from the code and not run
	#   warning    before RunLocal it only records the new host
	#   see        AtHost, RunLocal
	#@ aka  ONE line moves a node; nothing else changes for any caller.
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

	# Sends stz.stop to every node, destroys the supervisor, deletes the generated scripts and marks the app stopped.
	#
	#   returns    the app itself, so calls chain
	#   note       not run: it talks to nodes
	#   warning    sends messages over the node plane
	#   see        RunLocal
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
