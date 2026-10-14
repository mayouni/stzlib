#=====================================================================#
#  STZAGENTFOLDER -- THE FOLDER IS THE DEPLOYMENT                     #
#  drop a file in agents/, and it runs                                 #
#=====================================================================#
/*
	THE CONVENTION, whole:

	    <host root>/
	      agents/
	        kitchen-bot.pia      a declaration (stzAgentDeclaration)
	        summarizer.pia       a proposer
	        watcher.ring         a Ring-defined agent

	    oFolder = StzAgentFolderQ("agents")
	    oFolder.ReadAgents()
	    oFolder.MountOn(oHost)        # supervised on its declared schedule
	    oHost.RunFor(200)

	TWO NOTATIONS, ONE SET OF GATES. A `.pia` file is judged by
	stzAgentDeclaration. A `.ring` file must define a function named after
	itself -- `watcher.ring` defines `func watcherAgent()` -- returning an
	agent object, and it passes THE SAME gates: it is refused unless it
	answers Name_(), Cycle(), CoverageStatement() and ReversibilityClass().
	"Ring for the rest" does not mean "Ring escapes the rules"; it means
	the rest is written in Ring and judged identically.

	AND ONE ASYMMETRY, STATED RATHER THAN GLOSSED: a .pia file is DATA, so
	the folder reads it. A .ring file is a PROGRAM, and the folder does
	NOT execute it -- the app carries `load "agents/watcher.ring"` and the
	folder discovers, gates, mounts and supervises what that defines. The
	reason is measured and written at _ReadRingAgent below; it is not
	timidity about running code.

	A REFUSAL IS NOT A CRASH, AND IT IS NOT A SILENCE EITHER. One bad file
	does not stop the folder: it is refused, the refusal is kept with the
	file that caused it, and ReadAgents() returns how many were accepted.
	Refusals() carries every one of them in the family's unified finding
	shape, CiteRefusals() prints them, and a host that mounted this folder
	answers AgentLoadRefusals() with the same list -- so a green run that
	silently loaded three agents out of five is not a shape this can take.

	ON FILE CHANGE, AND WHY BY CONTENT RATHER THAN BY TIME. Rescan()
	re-reads the folder and reports what appeared, changed or vanished.
	It compares a SHA-256 of each file's bytes, not a modification time:
	StzFileModifTime answers 0 on every platform in this build, so a
	time-based watch would report "nothing changed" forever -- which is
	the quietest possible way for a reload to be broken. A hash cannot lie
	about that, and it is also right about a file rewritten within the
	same clock tick.

	WHAT THIS DOES NOT DO: it does not watch the filesystem. Rescan() is
	called by whoever owns the cadence -- a host tick, a supervisor, a
	developer at a prompt -- because a watcher thread here would be a
	second runtime, and this file is a front-end.
*/

# NOT named Load()/Reload(): `load` is a Ring KEYWORD, so `def Load()`
# is a C6 "Error in function name" that takes the whole library down at
# parse time. ReadAgents() and Rescan() say the same thing and survive.
func StzAgentFolderQ(pcPath)
	return new stzAgentFolder(pcPath)

# The function a Ring-defined agent file must export: <basename>Agent().
func _StzAgentFolderEntryName(pcBase)
	return "" + pcBase + "Agent"

# Reads a folder of agent files, gates each one, and mounts the accepted agents on a host so that dropping a file in the folder deploys it.
#
# A .pia file is data: it is judged by stzAgentDeclaration and turned into an agent. A .ring file is
# a program: the folder does not execute it, the application loads it, and the folder finds its
# <name>Agent() function and holds the object to the same four gates (it must answer Name_, Cycle,
# CoverageStatement and ReversibilityClass). A bad file does not stop the others: it is refused,
# kept in Refusals with the file that caused it, and ReadAgents counts only the accepted. Rescan
# compares a SHA-256 of each file, since a modification time is not available in this build. The
# folder does not watch the disk; whoever owns the cadence calls Rescan.
#
#   receiver   o1 = new stzAgentFolder("../agentic/agents")
#   example    ? o1.ReadAgents()
#              #--> 2
#              ? @@( o1.Names() )
#              #--> [ "kitchen-bot", "summarizer" ]
#              ? o1.NotationOf("kitchen-bot")
#              #--> pia
#              ? o1.NumberOfRefusedFiles()
#              #--> 2
#   see        stzAgentDeclaration, stzAgentHost, stzPIAgent
class stzAgentFolder from stzObject

	@cPath = ""
	@aLoaded = []        # [ :file, :name, :agent, :schedule, :kind, :hash, :notation ]
	@aRefusals = []      # unified findings, one or more per refused file
	@aRefusedFiles = []  # [ file, count ]
	@cWhy = ""

	# Builds a folder reader on a path; nothing is read until ReadAgents is called.
	#
	#   pcPath     the folder that holds the agent files (.pia declarations and .ring agents)
	#   returns    nothing; the object is built
	#   see        ReadAgents, Path
	def init(pcPath)
		@cPath = "" + pcPath

	# Returns the folder path given at construction, unchanged.
	#
	#   returns    a text
	#   see        init, ReadAgents
	def Path()
		return @cPath

	# Returns a one-line account of the last read or mount: how many agents were loaded or mounted, or why nothing was.
	#
	#   returns    a text; empty before the first ReadAgents
	#   see        ReadAgents, MountOn, Describe
	def Why()
		return @cWhy

	# Reads and gates every .pia and .ring file of the folder, and returns how many were accepted; the rest go to Refusals.
	#
	#   returns    a number, the agents accepted; 0 when the folder does not exist, with the cause
	#              in Why
	#   note       every call starts from empty, so it is also the way to reload
	#   warning    a .ring file is not executed: the program must already have loaded it, or the
	#              file is refused with rule ring-agent-entry; a second file claiming a loaded name
	#              is refused as pia-duplicate-name
	#   see        Refusals, Rescan, MountOn
	#@ aka  -- loading --------------------------------------------------------
	def ReadAgents()
		@aLoaded = []
		@aRefusals = []
		@aRefusedFiles = []
		if NOT direxists(@cPath)
			@cWhy = "no folder at '" + @cPath + "' -- nothing was loaded"
			return 0
		ok
		_ac_ = This._AgentFiles()
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			This._ReadOne(_ac_[_i_])
		next
		@cWhy = "loaded " + len(@aLoaded) + " agent(s) from '" + @cPath +
			"', refused " + len(@aRefusedFiles) + " file(s)"
		return len(@aLoaded)

	# Returns how many agents the last read accepted.
	#
	#   returns    a number
	#   see        ReadAgents, Names
	def NumberOfAgents()
		return len(@aLoaded)

	# Returns how many files the last read refused.
	#
	#   returns    a number
	#   see        RefusedFiles, Refusals
	def NumberOfRefusedFiles()
		return len(@aRefusedFiles)

	# Returns the names of the accepted agents, in lower case, in file-name order.
	#
	#   returns    a list of text
	#   see        Has, AgentQ
	def Names()
		_ac_ = []
		_n_ = len(@aLoaded)
		for _i_ = 1 to _n_
			_ac_ + @aLoaded[_i_][:name]
		next
		return _ac_

	# TRUE if an agent of that name was loaded; the match ignores case and surrounding blanks.
	#
	#   pcName     the agent's name
	#   returns    TRUE or FALSE
	#   see        Names, AgentQ
	def Has(pcName)
		if This._IndexOf(pcName) = 0
			return 0
		ok
		return 1

	# Returns the live agent object loaded under that name, so it can be configured before it is mounted.
	#
	#   pcName     the agent's name, matched without regard to case
	#   returns    an agent object
	#   note       after MountOn the host ticks its own copy, so configure through this face before
	#              mounting
	#   warning    raises an error naming the folder for a name that was not loaded
	#   see        MountOn, Has
	#@ aka  The live agent object. Configure it through this face BEFORE MountOn() -- afterwards the host's copy is the one that ticks.
	def AgentQ(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0
			stzraise("stzAgentFolder: no agent named '" + pcName +
				"' was loaded from '" + @cPath + "'.")
		ok
		return @aLoaded[_n_][:agent]

	# Returns when the agent runs, as declared in its file.
	#
	#   pcName     the agent's name
	#   returns    a list [ :mode, :timer, :channel ]; mode, timer and channel are empty or 0 for an
	#              unknown name
	#   note       a Ring agent without a Schedule method gets mode timer, 50
	#   see        NotationOf, MountOn
	def ScheduleOf(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0
			return [ :mode = "", :timer = 0, :channel = "" ]
		ok
		return @aLoaded[_n_][:schedule]

	# Returns which notation the agent was written in.
	#
	#   pcName     the agent's name
	#   returns    the text pia or ring; an empty text for an unknown name
	#   see        ScheduleOf, Names
	def NotationOf(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0
			return ""
		ok
		return @aLoaded[_n_][:notation]

	# Returns every reason a file was refused, in the library's finding shape.
	#
	#   returns    a list of [ :rule, :subject, :where, :severity, :message ] rows; where names the
	#              file
	#   note       a rescan adds a ring-agent-restart row for a changed .ring file
	#   see        CiteRefusals, RefusedFiles
	def Refusals()
		return @aRefusals

	# Returns the refused files with how many findings each one carries.
	#
	#   returns    a list of [ file, number ] pairs
	#   see        Refusals, NumberOfRefusedFiles
	def RefusedFiles()
		return @aRefusedFiles

	# Returns the refusals as printable lines, one per finding, as [rule @ where] message.
	#
	#   returns    a text; empty when the folder loaded whole
	#   note       printing it after every read keeps a partly loaded folder from passing for a
	#              healthy one
	#   see        Refusals, Describe
	#@ aka  The refusals, printable. Empty when the folder loaded whole -- and a caller that prints this after every ReadAgents() cannot mistake a partially-loaded folder for a healthy one.
	def CiteRefusals()
		if len(@aRefusals) = 0
			return ""
		ok
		_c_ = ""
		_n_ = len(@aRefusals)
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += char(10)
			ok
			_c_ += "[" + @aRefusals[_i_][:rule] + " @ " +
				@aRefusals[_i_][:where] + "] " + @aRefusals[_i_][:message]
		next
		return _c_

	# Returns a multi-line summary: the folder, the counts, each agent with its notation and kind, then the refusals.
	#
	#   returns    a text
	#   see        CiteRefusals, Why
	def Describe()
		_c_ = "folder '" + @cPath + "' -- " + len(@aLoaded) + " agent(s), " +
			len(@aRefusedFiles) + " refused file(s)" + char(10)
		_n_ = len(@aLoaded)
		for _i_ = 1 to _n_
			_c_ += "  " + @aLoaded[_i_][:name] + "  (" +
				@aLoaded[_i_][:notation] + ", " + @aLoaded[_i_][:kind] + ")" + char(10)
		next
		if len(@aRefusals) > 0
			_c_ += "REFUSED:" + char(10) + This.CiteRefusals() + char(10)
		ok
		return _c_

	# Returns what differs on disk since the last read, without loading it; files are compared by the SHA-256 of their bytes, not by time.
	#
	#   returns    a list [ :added, :changed, :removed ], each a list of file names
	#   note       a file that was refused and has not changed is not reported as added again; a
	#              missing folder reports every loaded file as removed
	#   see        HasChanged, Rescan
	#@ aka  -- change -----------------------------------------------------------
	def Changes()
		_aAdd_ = []
		_aChg_ = []
		_aRem_ = []
		if NOT direxists(@cPath)
			_n_ = len(@aLoaded)
			for _i_ = 1 to _n_
				_aRem_ + @aLoaded[_i_][:file]
			next
			return [ :added = _aAdd_, :changed = _aChg_, :removed = _aRem_ ]
		ok
		_ac_ = This._AgentFiles()
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_nAt_ = This._IndexOfFile(_ac_[_i_])
			if _nAt_ = 0
				if This._IndexOfRefusedFile(_ac_[_i_]) = 0
					_aAdd_ + _ac_[_i_]
				ok
				loop
			ok
			if This._HashOf(_ac_[_i_]) != @aLoaded[_nAt_][:hash]
				_aChg_ + _ac_[_i_]
			ok
		next
		_m_ = len(@aLoaded)
		for _i_ = 1 to _m_
			if ring_find(_ac_, @aLoaded[_i_][:file]) = 0
				_aRem_ + @aLoaded[_i_][:file]
			ok
		next
		return [ :added = _aAdd_, :changed = _aChg_, :removed = _aRem_ ]

	# TRUE if any file was added, changed or removed since the last read.
	#
	#   returns    TRUE or FALSE
	#   see        Changes, Rescan
	def HasChanged()
		_a_ = This.Changes()
		if len(_a_[:added]) + len(_a_[:changed]) + len(_a_[:removed]) > 0
			return 1
		ok
		return 0

	# Reads the folder again whole and returns what moved since the previous read, so a host can mount what arrived and retire what left.
	#
	#   returns    a list [ :added, :changed, :removed ], as Changes answered before the read
	#   note       a changed .pia file is re-read
	#   warning    a changed .ring file is not re-evaluated, because Ring cannot unload a function:
	#              the old code keeps running and a ring-agent-restart refusal names the file
	#   see        Changes, MountOn
	#@ aka  Re-read the folder whole. Returns what moved, so a host can mount what arrived and retire what left rather than guessing.
	def Rescan()
		_a_ = This.Changes()
		_acStale_ = []
		_n_ = len(_a_[:changed])
		for _i_ = 1 to _n_
			if StzLower(This._ExtensionOf(_a_[:changed][_i_])) = "ring"
				_acStale_ + _a_[:changed][_i_]
			ok
		next
		This.ReadAgents()
		_m_ = len(_acStale_)
		for _i_ = 1 to _m_
			@aRefusals + [ :rule = "ring-agent-restart",
				:subject = "ring-agent", :where = _acStale_[_i_],
				:severity = :error,
				:message = "this Ring agent file changed on disk and the " +
					"RUNNING CODE IS STILL THE OLD ONE. Ring cannot unload a " +
					"function, so a rescan cannot pick the change up -- " +
					"restart the process. A .pia declaration would have been " +
					"re-read here." ]
		next
		return _a_

	# Supervises every loaded agent on a host, each on the schedule its own file declared, and returns how many were mounted.
	#
	#   poHost     an agent host
	#   returns    a number
	#   note       the agents' own coverage statement and reversibility class are declared on the
	#              host first
	#   see        ReadAgents, AgentQ
	#@ aka  -- mounting ---------------------------------------------------------
	def MountOn(poHost)
		_nUp_ = 0
		_n_ = len(@aLoaded)
		for _i_ = 1 to _n_
			_cN_ = @aLoaded[_i_][:name]
			_oAg_ = @aLoaded[_i_][:agent]
			_aS_ = @aLoaded[_i_][:schedule]
			poHost.Declare(_cN_, This._CoverageOf(_oAg_), This._RevOf(_oAg_))
			if _aS_[:mode] = "event"
				poHost.SuperviseOnEvent(_oAg_, _aS_[:channel])
			else
				poHost.Supervise(_oAg_, _aS_[:timer])
			ok
			_nUp_++
		next
		@cWhy = "mounted " + _nUp_ + " agent(s) from '" + @cPath + "'"
		return _nUp_

	#-- the private half -------------------------------------------------

	def _AgentFiles()
		_ac_ = StzListFiles(@cPath)
		_aOut_ = []
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_f_ = "" + _ac_[_i_]
			_cE_ = StzLower(This._ExtensionOf(_f_))
			if _cE_ = "pia" or _cE_ = "ring"
				_aOut_ + _f_
			ok
		next
		return ring_sort(_aOut_)

	def _ExtensionOf(pcFile)
		_a_ = StzFind(".", pcFile)
		if len(_a_) = 0
			return ""
		ok
		_nAt_ = _a_[len(_a_)]
		return StzMid(pcFile, _nAt_ + 1, StzLen(pcFile) - _nAt_)

	def _BaseOf(pcFile)
		_a_ = StzFind(".", pcFile)
		if len(_a_) = 0
			return pcFile
		ok
		_nAt_ = _a_[len(_a_)]
		return StzMid(pcFile, 1, _nAt_ - 1)

	def _FullPath(pcFile)
		return @cPath + "/" + pcFile

	def _HashOf(pcFile)
		return StzEngineCryptoSha256(StzFileRead(This._FullPath(pcFile)))

	def _ReadOne(pcFile)
		if StzLower(This._ExtensionOf(pcFile)) = "ring"
			This._ReadRingAgent(pcFile)
			return
		ok
		_oD_ = StzAgentDeclarationFromFileQ(This._FullPath(pcFile))
		if _oD_.IsValid() = 0
			This._Refuse(pcFile, _oD_.Findings())
			return
		ok
		if This._IndexOf(_oD_.Name_()) > 0
			This._Refuse(pcFile, [ [ :rule = "pia-duplicate-name",
				:subject = "pi-agent-declaration", :where = pcFile,
				:severity = :error,
				:message = "an agent named '" + _oD_.Name_() + "' was already " +
					"loaded from this folder; a host supervises BY NAME, so " +
					"two files claiming one name is a question this loader " +
					"will not answer for you." ] ])
			return
		ok
		@aLoaded + [ :file = pcFile, :name = _oD_.Name_(),
			     :agent = _oD_.ToAgent(), :schedule = _oD_.Schedule(),
			     :kind = _oD_.Kind(), :hash = This._HashOf(pcFile),
			     :notation = "pia" ]

	# A RING-DEFINED AGENT, THROUGH THE SAME DOOR. The file is loaded, its
	# <basename>Agent() function is called, and the object it returns is
	# held to the gates a declaration is held to.
	def _ReadRingAgent(pcFile)
		_cBase_ = This._BaseOf(pcFile)
		_cFn_ = _StzAgentFolderEntryName(_cBase_)

		# THIS LOADER DOES NOT EVALUATE SOURCE, AND THE REASON IS MEASURED
		# RATHER THAN CHOSEN ON TASTE. The obvious implementation is
		# `eval("load '" + path + "'")`, and it half-works: the file loads
		# and its entry function becomes callable. But a class defined in
		# an eval-loaded file DOES NOT GET ITS PARENT -- `class X from
		# stzPIAgent` produces an object on which ismethod("Cycle") answers
		# 0 and oX.Name_() raises R14, "Calling Method without definition".
		# Only the methods written in that file itself survive. An agent
		# that cannot inherit stzPIAgent is not an agent, so the folder
		# refuses to pretend, and the app loads its own Ring agents:
		#
		#     load "agents/watcher.ring"     # once, in the program
		#     oFolder = StzAgentFolderQ("agents")
		#     oFolder.ReadAgents()           # finds it, gates it, mounts it
		#
		# The .pia notation is the drop-in one, because it is DATA. A .ring
		# agent is discovered, judged and supervised by the same folder
		# under the same gates -- it just is not executed by it. That also
		# means reading a folder never runs anything, which is a better
		# property than the one that was lost.
		_oAg_ = ""
		try
			_oAg_ = call _cFn_()
		catch
			This._Refuse(pcFile, [ [ :rule = "ring-agent-entry",
				:subject = "ring-agent", :where = pcFile, :severity = :error,
				:message = "'" + _cFn_ + "()' raised rather than returning an " +
					"agent: " + StzLeft(cCatchError, 200) ] ])
			return
		done
		if NOT isObject(_oAg_)
			This._Refuse(pcFile, [ [ :rule = "ring-agent-entry",
				:subject = "ring-agent", :where = pcFile, :severity = :error,
				:message = "'" + _cFn_ + "()' returned something that is not an " +
					"object." ] ])
			return
		ok

		_aBad_ = []
		if NOT ismethod(_oAg_, "Name_")
			_aBad_ + "Name_()"
		ok
		if NOT ismethod(_oAg_, "Cycle")
			_aBad_ + "Cycle()"
		ok
		if NOT ismethod(_oAg_, "CoverageStatement")
			_aBad_ + "CoverageStatement()"
		ok
		if NOT ismethod(_oAg_, "ReversibilityClass")
			_aBad_ + "ReversibilityClass()"
		ok
		if len(_aBad_) > 0
			This._Refuse(pcFile, [ [ :rule = "ring-agent-gates",
				:subject = "ring-agent", :where = pcFile, :severity = :error,
				:message = "this agent does not answer " +
					StzJoinWith(_aBad_, ", ") + ". A Ring-defined agent passes " +
					"the SAME gates a .pia declaration passes -- writing it in " +
					"Ring is a change of notation, not an exemption." ] ])
			return
		ok

		_cCov_ = ring_trim("" + _oAg_.CoverageStatement())
		if _cCov_ = ""
			This._Refuse(pcFile, [ [ :rule = "ring-agent-gates",
				:subject = "ring-agent", :where = pcFile, :severity = :error,
				:message = "CoverageStatement() is empty. The engine loop " +
					"refuses to schedule an agent that does not say what it " +
					"covers (law 18), so this is refused at load rather than " +
					"at the first tick." ] ])
			return
		ok
		if StzAgentReversibilityCode(_oAg_.ReversibilityClass()) = 0
			This._Refuse(pcFile, [ [ :rule = "ring-agent-gates",
				:subject = "ring-agent", :where = pcFile, :severity = :error,
				:message = "ReversibilityClass() answers '" +
					_oAg_.ReversibilityClass() + "', which is not one of " +
					StzJoinWith(StzPiaReversibilityClasses(), ", ") +
					". The absence of a class is not a class." ] ])
			return
		ok

		_cName_ = StzLower(ring_trim("" + _oAg_.Name_()))
		if This._IndexOf(_cName_) > 0
			This._Refuse(pcFile, [ [ :rule = "pia-duplicate-name",
				:subject = "ring-agent", :where = pcFile, :severity = :error,
				:message = "an agent named '" + _cName_ + "' was already loaded " +
					"from this folder." ] ])
			return
		ok

		_aS_ = [ :mode = "timer", :timer = 50, :channel = "" ]
		if ismethod(_oAg_, "Schedule")
			_aS_ = _oAg_.Schedule()
		ok
		@aLoaded + [ :file = pcFile, :name = _cName_, :agent = _oAg_,
			     :schedule = _aS_, :kind = "pi", :hash = This._HashOf(pcFile),
			     :notation = "ring" ]

	def _Refuse(pcFile, paFindings)
		_n_ = len(paFindings)
		for _i_ = 1 to _n_
			_f_ = paFindings[_i_]
			_f_[:where] = pcFile + " :: " + _f_[:where]
			@aRefusals + _f_
		next
		@aRefusedFiles + [ pcFile, _n_ ]

	def _CoverageOf(poAgent)
		if ismethod(poAgent, "CoverageStatement")
			return "" + poAgent.CoverageStatement()
		ok
		return ""

	def _RevOf(poAgent)
		if ismethod(poAgent, "ReversibilityClass")
			return "" + poAgent.ReversibilityClass()
		ok
		return ""

	def _IndexOf(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aLoaded)
		for _i_ = 1 to _n_
			if @aLoaded[_i_][:name] = _c_
				return _i_
			ok
		next
		return 0

	def _IndexOfFile(pcFile)
		_n_ = len(@aLoaded)
		for _i_ = 1 to _n_
			if @aLoaded[_i_][:file] = pcFile
				return _i_
			ok
		next
		return 0

	def _IndexOfRefusedFile(pcFile)
		_n_ = len(@aRefusedFiles)
		for _i_ = 1 to _n_
			if @aRefusedFiles[_i_][1] = pcFile
				return _i_
			ok
		next
		return 0
