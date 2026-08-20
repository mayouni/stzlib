# R5 (reactor-runtime slice) -- stzAgentHost: agents as SUPERVISED,
# CANCELLABLE, TRACED, DECOMMISSIONABLE reactor jobs.
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.10: "the agent host IS the
#  same host" -- an agent is a long-running service on the SAME libuv
#  loop the R7 delivery plane runs. R4b's DecommissionContract is
#  enforced here: retirement is EARNED.)
#
# The PI-agent's Cycle() is one perceive-decide-act pass; Pursue() runs
# it to fixpoint SYNCHRONOUSLY. The host adds the missing runtime: it
# ticks each supervised agent on its own interval driven by REAL libuv
# timers on the engine loop thread (never a Ring busy-loop), records a
# trace, lets a caller CANCEL an agent (stop ticking) and RETIRE it
# (governed teardown -- refused until its obligations are fulfilled).
#
#   oHost = new stzAgentHost()
#   oHost.Supervise(oKitchenBot, 50)         # TIMER-driven: tick every 50ms
#   oHost.SuperviseOnEvent(oOrderBot, "orders") # EVENT-driven: tick per event
#   oHost.SetRetirementGovernance(oGov)         # R4b decommission gate
#   oHost.RunFor(500)                        # perceive-act on the loop
#   ? oHost.TicksOf("kitchen-bot")
#   oHost.Retire("kitchen-bot")              # only if obligations met
#
# TWO SUPERVISION MODES: Supervise(agent, ms) ticks on a REAL libuv timer;
# SuperviseOnEvent(agent, channel) ticks ONCE PER EVENT emitted on the engine
# event bus (stzEventBus / reactive.zig) -- so the perceive-decide-act loop
# becomes a true EVENT LOOP: the agent reacts to what happens, when it
# happens. Both run on the same loop, traced + cancellable + decommissionable.
#
# RING-TRUE: a supervised agent is stored in a list; list append COPIES
# but a method-call THROUGH THE INDEX (@aAgents[i][2].Cycle()) reaches
# the live copy, whose memory shares the engine KG handle -- so ticks
# persist and reads see them. The caller therefore configures the agent
# FULLY before Supervise() and thereafter reaches it via the host's
# accessors, never the pre-handoff reference.

# ─── THE ENGINE LOOP (2026-08-20) ────────────────────────────────────
#
# UseEngineLoop() hands the SCHEDULING DECISION to Zig (agentloop.zig in
# stz_softanzuter.dll) while every act stays here: the engine decides who
# ticks, in what order, and why; this class pops that schedule and calls
# Cycle(). Zig owns time, Ring stays the scripting language of the loop.
#
# IT IS OPT-IN, and that is not timidity -- it is what makes the gate
# real. The engine REFUSES to schedule an agent that declares neither a
# coverage statement nor a reversibility class (law 18), so switching it
# on for everybody would break every host that has not declared them yet.
# A host that does not call UseEngineLoop() runs exactly the Ring pump it
# always ran, which is why the narrated tests under base/test/agentic
# needed no edit.
#
#   oHost.Declare("kitchen-bot", "covers order intake", :compensable)
#   oHost.SetPriority("kitchen-bot", 9)
#   oHost.UseEngineLoop()          # before or after Supervise, either way
#   oHost.RunFor(200)              # same call, Zig now picks the order
#
# An agent that answers CoverageStatement() and ReversibilityClass() for
# itself needs no Declare(); the host asks the agent first and falls back
# to what was declared here.

# The engine's agent table and loop registry are PROCESS-GLOBAL (64 slots,
# shared by every host in the process). Tests that build hosts repeatedly
# must reset between them, or slot names collide across cases.
func StzResetEngineAgentLoop()
	stzengineagentloopclear()
	stzenginezuterclear()

# What the loop says it schedules -- and what it says it cannot see. Read
# it from the engine rather than from a comment, which is the point.
#
# NOT named StzEngineAgentLoopCoverage(): Ring folds case, so that spelling
# IS the engine's own `stzengineagentloopcoverage` (the per-agent one), and
# defining it here silently stole every call to it -- R20, "extra number of
# parameters", pointing at the CALLER. A Ring wrapper must never spell an
# engine function's name in different case.
func StzAgentLoopCoverageStatement()
	return stzengineagentloopcoveragestatement()

# reversibility words -> the engine's classes. 0 is not a class, it is the
# ABSENCE of one, and registration refuses it.
func StzAgentReversibilityCode(pcClass)
	_c_ = StzLower(ring_trim("" + pcClass))
	if _c_ = "reversible"
		return 1
	but _c_ = "compensable"
		return 2
	but _c_ = "irreversible"
		return 3
	ok
	return 0

func StzAgentHostQ()
	return new stzAgentHost()

class stzAgentHost from stzObject

	@oReactor    = ""
	@bOwnsReactor = 0
	@oGov        = ""      # optional decommission-gate governance
	@aAgents     = []        # [ name, oAgent, tickMs, active, nextMs, ticks, retired ]
	@aTrace      = []        # [ atMs, name, acted, why ]
	@cWhy        = ""
	@bEngineLoop = 0         # Zig owns the tick when this is on
	@aDeclared   = []        # [ name, coverage, revClass, priority ]
	@cLoopWhy    = ""        # the engine's last refusal, verbatim
	@oFolder     = ""        # the agents/ folder, when one was mounted

	def init()
		@oReactor = new stzReactor()
		@bOwnsReactor = 1

	# Share another host's loop (e.g. an stzAppServer's) instead of
	# owning one -- "the agent host is the same host".
	def SetReactor(poReactor)
		if @bOwnsReactor and @oReactor != ""
			@oReactor.Destroy()
		ok
		@oReactor = poReactor
		@bOwnsReactor = 0
		return This

	def ReactorQ()
		return @oReactor

	def Why()
		return @cWhy

	# The governance whose decommission contract gates Retire(). NOTE:
	# the stored @oGov is a COPY (governance is pure Ring lists -- no
	# shared engine handle), so the decommission contract MUST be
	# declared and fulfilled THROUGH THE HOST (below), which mutates
	# this live copy. Fulfilling on the caller's original would leave
	# the host's copy stale (the Ring aliasing doctrine).
	def SetRetirementGovernance(poGov)
		@oGov = poGov
		return This

	def _EnsureGov()
		if @oGov = ""
			@oGov = new stzGovernance("agent-host")
		ok

	# Declare an agent's decommission obligations (retirement is earned
	# only once all are fulfilled).
	def DeclareDecommission(pcName, pacObligations)
		This._EnsureGov()
		@oGov.DeclareDecommission(pcName, pacObligations)
		return This

	# Fulfill one obligation (mutates the host's live governance copy).
	def FulfillObligation(pcName, pcObligation)
		This._EnsureGov()
		@oGov.FulfillObligation(pcName, pcObligation)
		return This

	def GovernanceQ()
		return @oGov

	#-- supervision -----------------------------------------------------

	# Register an agent to be ticked every nTickMs. The agent must be
	# fully configured (skills, governance) BEFORE this call.
	def Supervise(poAgent, nTickMs)
		if nTickMs < 1
			stzraise("stzAgentHost.Supervise: tick interval must be >= 1ms.")
		ok
		# row: name, agent, tickMs, active, nextDue, ticks, retired,
		#      channel(""=timer), lastEventCount, channelGeneration,
		#      engineSlot(-1 = not registered with the Zig loop)
		@aAgents + [ poAgent.Name_(), poAgent, nTickMs, 1,
		             StzEngineTimeNowMs(), 0, 0, "", 0, 0, -1 ]
		if @bEngineLoop = 1
			This._RegisterWithLoop(len(@aAgents))
		ok
		return This

	# EVENT-DRIVEN supervision (R5 reactor-runtime): tick the agent once per
	# EVENT emitted on pcChannel (the engine event bus, stzEventBus), not on a
	# timer. The perceive-decide-act loop becomes a true event loop -- the
	# agent reacts to what happens, when it happens. Past events are NOT
	# replayed (the baseline is the channel's current count at registration).
	def SuperviseOnEvent(poAgent, pcChannel)
		stzengine_reactive_create_channel("" + pcChannel)   # ensure it exists
		_nBase_ = stzengine_reactive_event_count("" + pcChannel)
		if _nBase_ < 0  _nBase_ = 0  ok
		@aAgents + [ poAgent.Name_(), poAgent, 0, 1,
		             0, 0, 0, "" + pcChannel, _nBase_,
		             stzengine_reactive_channel_generation("" + pcChannel), -1 ]
		if @bEngineLoop = 1
			This._RegisterWithLoop(len(@aAgents))
		ok
		return This

	# The channel an agent is event-supervised on ("" if timer-supervised).
	def ChannelOf(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return ""  ok
		return @aAgents[_n_][8]

	def NumberOfAgents()
		return len(@aAgents)

	# The nth supervised agent's NAME -- enumeration for an observer (the
	# appserver's /agents surface) that must not hold the agent itself.
	def NameAt(pnIndex)
		if pnIndex < 1 or pnIndex > len(@aAgents)
			return ""
		ok
		return @aAgents[pnIndex][1]

	def IsSupervising(pcName)
		return This._IndexOf(pcName) > 0

	def IsActive(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return 0  ok
		return @aAgents[_n_][4]

	def TicksOf(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return 0  ok
		return @aAgents[_n_][6]

	# The live supervised agent (reach it here, not via a stale ref).
	def AgentQ(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return ""  ok
		return @aAgents[_n_][2]

	def Trace()
		return @aTrace

	#-- agents as FILES (the agents/ folder) -----------------------------
	#
	# AT START: read the folder, mount everything valid on this host, each
	# on the schedule its own file declared.
	#
	#     oHost.UseAgentsFrom("agents")
	#     oHost.RunFor(500)
	#
	# ON CHANGE: RescanAgents() re-reads and reports what moved. It
	# supervises what ARRIVED and cancels what VANISHED -- and for a file
	# that CHANGED under a running agent it does neither, and says so.
	# Swapping a live agent is not a file operation: it has a memory, a
	# trace and possibly unfulfilled obligations, and replacing it quietly
	# would discard all three without anyone asking.
	#
	# AND THE REFUSALS ARE NOT SWALLOWED. AgentLoadRefusals() carries every
	# file the folder would not admit, in the unified finding shape, and
	# CiteAgentLoadRefusals() prints them. A host that mounted three agents
	# out of five and said nothing is the shape this exists to prevent.

	def UseAgentsFrom(pcPath)
		@oFolder = StzAgentFolderQ(pcPath)
		@oFolder.ReadAgents()
		_n_ = @oFolder.MountOn(This)
		@cWhy = "mounted " + _n_ + " agent(s) from '" + pcPath + "'; " +
			len(@oFolder.Refusals()) + " refusal(s)"
		return _n_

		def UseAgentsFromQ(pcPath)
			This.UseAgentsFrom(pcPath)
			return This

	def AgentFolderQ()
		return @oFolder

	def IsUsingAgentFolder()
		if @oFolder = ""
			return 0
		ok
		return 1

	def AgentLoadRefusals()
		if @oFolder = ""
			return []
		ok
		return @oFolder.Refusals()

	def CiteAgentLoadRefusals()
		if @oFolder = ""
			return ""
		ok
		return @oFolder.CiteRefusals()

	# Returns [ :added, :changed, :removed ] -- the file names that moved.
	def RescanAgents()
		if @oFolder = ""
			stzraise("stzAgentHost.RescanAgents: no agent folder -- call " +
				"UseAgentsFrom(path) first.")
		ok
		_a_ = @oFolder.Rescan()
		_ac_ = @oFolder.Names()
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			if This.IsSupervising(_ac_[_i_]) = 0
				_oAg_ = @oFolder.AgentQ(_ac_[_i_])
				_aS_ = @oFolder.ScheduleOf(_ac_[_i_])
				This.Declare(_ac_[_i_], "" + _oAg_.CoverageStatement(),
					"" + _oAg_.ReversibilityClass())
				if _aS_[:mode] = "event"
					This.SuperviseOnEvent(_oAg_, _aS_[:channel])
				else
					This.Supervise(_oAg_, _aS_[:timer])
				ok
			ok
		next
		# what vanished stops ticking; it is CANCELLED, not retired --
		# retirement is earned and a deleted file earns nothing
		_m_ = len(@aAgents)
		for _i_ = 1 to _m_
			_cN_ = @aAgents[_i_][1]
			if @aAgents[_i_][4] = 1 and @oFolder.Has(_cN_) = 0
				This.Cancel(_cN_)
			ok
		next
		@cWhy = "rescanned '" + @oFolder.Path() + "': " +
			len(_a_[:added]) + " added, " + len(_a_[:changed]) +
			" changed, " + len(_a_[:removed]) + " removed"
		return _a_

	#-- the engine loop (Zig owns the tick) -----------------------------

	# Declare an agent's COVERAGE STATEMENT and REVERSIBILITY CLASS -- what
	# law 18 obliges before anything schedules it. Needed only for agents
	# that do not answer CoverageStatement() / ReversibilityClass()
	# themselves; the host asks the agent first.
	def Declare(pcName, pcCoverage, pcReversibility)
		This.DeclareQ(pcName, pcCoverage, pcReversibility)

	def DeclareQ(pcName, pcCoverage, pcReversibility)
		_cN_ = "" + pcName
		_n_ = This._DeclIndex(_cN_)
		if _n_ = 0
			@aDeclared + [ _cN_, "" + pcCoverage, "" + pcReversibility, 0 ]
		else
			@aDeclared[_n_][2] = "" + pcCoverage
			@aDeclared[_n_][3] = "" + pcReversibility
		ok
		return This

	# Higher runs first in a pass. Ties break on registration order, so the
	# order is total and reproducible whether or not priorities are set.
	def SetPriority(pcName, pnPriority)
		This.SetPriorityQ(pcName, pnPriority)

	def SetPriorityQ(pcName, pnPriority)
		_cN_ = "" + pcName
		_n_ = This._DeclIndex(_cN_)
		if _n_ = 0
			@aDeclared + [ _cN_, "", "", pnPriority ]
		else
			@aDeclared[_n_][4] = pnPriority
		ok
		return This

	def PriorityOf(pcName)
		_n_ = This._DeclIndex("" + pcName)
		if _n_ = 0  return 0  ok
		return @aDeclared[_n_][4]

	# Adopt the Zig loop as this host's pump. Agents already supervised are
	# registered now, so the call order does not matter -- and a refusal
	# raises HERE, carrying the engine's own diagnostic.
	def UseEngineLoop()
		This.UseEngineLoopQ()

	def UseEngineLoopQ()
		@bEngineLoop = 1
		_nLen_ = len(@aAgents)
		for _i_ = 1 to _nLen_
			if @aAgents[_i_][11] < 0
				This._RegisterWithLoop(_i_)
			ok
		next
		return This

	def UseRingLoop()
		@bEngineLoop = 0
		return This

	def IsUsingEngineLoop()
		return @bEngineLoop

	# The engine's last refusal, verbatim. A refusal names its code, its
	# subject and what to do -- do not paraphrase it.
	def EngineLoopWhy()
		return @cLoopWhy

	# The engine slot an agent occupies (-1 when the Ring pump is driving).
	def EngineSlotOf(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return -1  ok
		return @aAgents[_n_][11]

	def _DeclIndex(pcName)
		_nLen_ = len(@aDeclared)
		for _i_ = 1 to _nLen_
			if @aDeclared[_i_][1] = pcName  return _i_  ok
		next
		return 0

	def _IndexOfSlot(pnSlot)
		_nLen_ = len(@aAgents)
		for _i_ = 1 to _nLen_
			if @aAgents[_i_][11] = pnSlot  return _i_  ok
		next
		return 0

	# Ask the AGENT first, fall back to what the host declared. An agent
	# that answers for itself needs no Declare() -- and one that answers
	# neither reaches the engine with an empty coverage statement and is
	# refused there, which is where the rule lives.
	def _CoverageFor(poAgent, pcName)
		if ismethod(poAgent, "CoverageStatement")
			_c_ = "" + poAgent.CoverageStatement()
			if ring_trim(_c_) != ""  return _c_  ok
		ok
		_n_ = This._DeclIndex(pcName)
		if _n_ = 0  return ""  ok
		return @aDeclared[_n_][2]

	def _ReversibilityFor(poAgent, pcName)
		if ismethod(poAgent, "ReversibilityClass")
			_n1_ = StzAgentReversibilityCode(poAgent.ReversibilityClass())
			if _n1_ > 0  return _n1_  ok
		ok
		_n_ = This._DeclIndex(pcName)
		if _n_ = 0  return 0  ok
		return StzAgentReversibilityCode(@aDeclared[_n_][3])

	# ONE RULE, TWO LAYERS, SAME WORDS. The graph rule `no-llm-effectful`
	# states it for a composed agent graph; the engine states it at
	# registration. This method only reports what the agent SAYS it is --
	# an stzLLMAgent answers Kind()="llm_actor" and HoldsEffectful()=0 by
	# construction, so it can never trip the rule, and an agent that claims
	# both is refused by the engine in the graph rule's own sentence.
	def _KindAndEffect(poAgent)
		_nKind_ = 0
		_nEff_  = 0
		if ismethod(poAgent, "Kind")
			if StzLower(ring_trim("" + poAgent.Kind())) = "llm_actor"
				_nKind_ = 1
			ok
		ok
		if ismethod(poAgent, "HoldsEffectful")
			if poAgent.HoldsEffectful()  _nEff_ = 1  ok
		ok
		if _nEff_ = 0 and ismethod(poAgent, "Capabilities")
			_ac_ = poAgent.Capabilities()
			if isList(_ac_)
				_nC_ = len(_ac_)
				for _i_ = 1 to _nC_
					if StzLower(ring_trim("" + _ac_[_i_])) = "effectful"
						_nEff_ = 1
						exit
					ok
				next
			ok
		ok
		return [ _nKind_, _nEff_ ]

	def _RegisterWithLoop(pnIndex)
		_cName_ = @aAgents[pnIndex][1]
		_oAgent_ = @aAgents[pnIndex][2]

		_nSlot_ = stzenginezuterfind(_cName_)
		if _nSlot_ < 0
			_nSlot_ = stzenginezutercreate(_cName_)
		ok
		if _nSlot_ < 0
			stzraise("stzAgentHost.UseEngineLoop: the engine holds 64 agent slots " +
				"and they are all taken -- '" + _cName_ + "' has nowhere to live.")
		ok

		_aKE_ = This._KindAndEffect(_oAgent_)
		_nTrig_ = 0
		if @aAgents[pnIndex][8] != ""  _nTrig_ = 1  ok
		_nInterval_ = @aAgents[pnIndex][3]
		if _nTrig_ = 1  _nInterval_ = 0  ok

		_rc_ = stzengineagentloopregister(_nSlot_, _aKE_[1],
			This._ReversibilityFor(_oAgent_, _cName_), _nTrig_, _aKE_[2],
			This.PriorityOf(_cName_), _nInterval_,
			This._CoverageFor(_oAgent_, _cName_))

		if _rc_ != 0
			@cLoopWhy = stzengineagentlooplastrefusal()
			stzraise("stzAgentHost: the engine loop REFUSED to schedule '" +
				_cName_ + "'. " + @cLoopWhy)
		ok
		@aAgents[pnIndex][11] = _nSlot_
		return This

	def _ReasonWord(pnReason)
		if pnReason = 1  return "tick"  ok
		if pnReason = 2  return "event" ok
		if pnReason = 3  return "mail"  ok
		return "nudge"

	# The engine pump: report what the loop cannot see, let Zig DECIDE,
	# then DO what it decided, in the order it decided.
	def _TickDueEngine()
		_nNow_ = StzEngineTimeNowMs()

		# 1. the bus lives in ANOTHER DLL, so the loop is told rather than
		#    looking (agentloop.zig's coverage statement says exactly this).
		_nLen_ = len(@aAgents)
		for _i_ = 1 to _nLen_
			if @aAgents[_i_][8] != "" and @aAgents[_i_][11] >= 0
				stzengineagentloopnoteevents(@aAgents[_i_][11],
					stzengine_reactive_event_count(@aAgents[_i_][8]),
					stzengine_reactive_channel_generation(@aAgents[_i_][8]))
			ok
		next

		# 2. Zig decides who runs, and in what order
		stzengineagentlooptick(_nNow_)

		# 3. Ring does it
		_nActed_ = 0
		while stzengineagentloopnext() = 1
			_nIdx_ = This._IndexOfSlot(stzengineagentloopcurrentslot())
			if _nIdx_ = 0  loop  ok
			if @aAgents[_nIdx_][7]      loop  ok
			if NOT @aAgents[_nIdx_][4]  loop  ok
			_nA_ = @aAgents[_nIdx_][2].Cycle()
			@aAgents[_nIdx_][6] = @aAgents[_nIdx_][6] + 1
			@aTrace + [ _nNow_, @aAgents[_nIdx_][1], _nA_,
			            This._ReasonWord(stzengineagentloopcurrentreason()) +
			            " " + @aAgents[_nIdx_][6] ]
			_nActed_ += _nA_
		end
		return _nActed_

	#-- the perceive-act runtime ---------------------------------------

	# Tick every ACTIVE, non-retired agent whose interval has elapsed:
	# run ONE Cycle() (perceive-decide-act) through the live index.
	# Returns the number of skill-firings verified this pass.
	def TickDue()
		# ONE CALL, TWO PUMPS. The Ring API does not change when the engine
		# loop is adopted -- RunFor / RunToQuiet / TickDue are the same
		# calls; only who decides the ORDER moves.
		if @bEngineLoop = 1
			return This._TickDueEngine()
		ok
		_nActed_ = 0
		_nNow_ = StzEngineTimeNowMs()
		_nLen_ = len(@aAgents)
		for _i_ = 1 to _nLen_
			if NOT @aAgents[_i_][4]  loop  ok         # inactive
			if @aAgents[_i_][7]      loop  ok         # retired
			if @aAgents[_i_][8] != ""
				# EVENT-DRIVEN: one Cycle per new event on the channel (catch
				# up if several arrived since the last pass).
				_nCur_ = stzengine_reactive_event_count(@aAgents[_i_][8])

				# A NEW GENERATION MEANS A NEW CHANNEL WEARING THE SAME NAME.
				#
				# The bus counter restarts at zero when a channel is destroyed
				# and remade -- and ClearAll(), which the bus offers for test
				# isolation, is PROCESS-GLOBAL, so it resets channels this host
				# is watching. The stored baseline was then higher than the live
				# count, the catch-up loop below never ran, and the agent went
				# deaf: silently, and for good if the old count was high.
				# Measured: after a reset and three fresh events, an agent
				# ticked once instead of three times.
				#
				# Watching for the COUNT to drop does not fix it -- by the time
				# anyone polls, the fresh channel may already have passed the
				# remembered value, and the dip is never seen. The generation is
				# unique for the life of the process, so this comparison is
				# exact rather than a race.
				_nGen_ = stzengine_reactive_channel_generation(@aAgents[_i_][8])
				if _nGen_ != @aAgents[_i_][10]
					@aAgents[_i_][10] = _nGen_
					@aAgents[_i_][9] = 0
					@aTrace + [ _nNow_, @aAgents[_i_][1], 0,
					            "channel remade -- baseline resynced" ]
				ok

				while @aAgents[_i_][9] < _nCur_
					@aAgents[_i_][9] = @aAgents[_i_][9] + 1
					_nE_ = @aAgents[_i_][2].Cycle()
					@aAgents[_i_][6] = @aAgents[_i_][6] + 1
					@aTrace + [ _nNow_, @aAgents[_i_][1], _nE_,
					            "event " + @aAgents[_i_][6] ]
					_nActed_ += _nE_
				end
			else
				# TIMER-DRIVEN: tick once when the interval has elapsed.
				if _nNow_ < @aAgents[_i_][5]  loop  ok
				# LIVE path: method-call through the index reaches the stored
				# agent, whose memory shares the engine KG handle.
				_nA_ = @aAgents[_i_][2].Cycle()
				@aAgents[_i_][6] = @aAgents[_i_][6] + 1
				@aAgents[_i_][5] = _nNow_ + @aAgents[_i_][3]
				@aTrace + [ _nNow_, @aAgents[_i_][1], _nA_,
				            "tick " + @aAgents[_i_][6] ]
				_nActed_ += _nA_
			ok
		next
		return _nActed_

	# Drive the loop for nMs, ticking due agents. The inter-tick wait is
	# a REAL libuv timer awaited on the engine loop thread (falls back
	# to a Ring sleep only when no reactor DLL is present -- LAW 2).
	def RunFor(nMs)
		_nDeadline_ = StzEngineTimeNowMs() + nMs
		while StzEngineTimeNowMs() < _nDeadline_
			This.TickDue()
			_nWait_ = This._NextWait(_nDeadline_)
			if _nWait_ <= 0  exit  ok
			This._Wait(_nWait_)
		end
		return This

	# Run until every supervised agent reaches fixpoint (a full pass with
	# zero firings) or the cap is hit -- the cascade at host level.
	def RunToQuiet()
		_nRound_ = 0
		while _nRound_ < 200
			_nRound_++
			if This.TickDue() = 0
				# a settling pass: confirm quiet once more after the
				# slowest interval, else we might miss a not-yet-due tick
				if This._AllQuiet()
					exit
				ok
			ok
			_nW_ = This._MinInterval()
			This._Wait(_nW_)
		end
		@cWhy = "ran " + _nRound_ + " round(s) to quiet"
		return This

	#-- cancellation + governed decommission ---------------------------

	# Stop ticking an agent WITHOUT retiring it (reversible pause).
	def Cancel(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0
			stzraise("stzAgentHost.Cancel: not supervising '" + pcName + "'.")
		ok
		@aAgents[_n_][4] = 0
		if @bEngineLoop = 1 and @aAgents[_n_][11] >= 0
			stzengineagentlooppause(@aAgents[_n_][11], 1)
		ok
		return This

	def Resume(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0
			stzraise("stzAgentHost.Resume: not supervising '" + pcName + "'.")
		ok
		@aAgents[_n_][4] = 1
		@aAgents[_n_][5] = StzEngineTimeNowMs()
		if @bEngineLoop = 1 and @aAgents[_n_][11] >= 0
			stzengineagentlooppause(@aAgents[_n_][11], 0)
		ok
		return This

	# DECOMMISSION (R4b): retirement is EARNED. When a governance is
	# wired, the agent may retire ONLY once every declared obligation is
	# fulfilled (MayRetire). A retired agent stops ticking permanently.
	# Returns TRUE on retirement, FALSE (with Why()) on refusal.
	def Retire(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0
			stzraise("stzAgentHost.Retire: not supervising '" + pcName + "'.")
		ok
		if @oGov != ""
			if @oGov.MayRetire(pcName) = 0
				@cWhy = @oGov.Why()
				return 0
			ok
		ok
		@aAgents[_n_][4] = 0
		@aAgents[_n_][7] = 1
		if @bEngineLoop = 1 and @aAgents[_n_][11] >= 0
			stzengineagentloopderegister(@aAgents[_n_][11])
			@aAgents[_n_][11] = -1
		ok
		@cWhy = "retired '" + pcName + "'"
		return 1

	def IsRetired(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return 0  ok
		return @aAgents[_n_][7]

	#-- teardown --------------------------------------------------------

	def Shutdown()
		if @bOwnsReactor and @oReactor != ""
			@oReactor.Destroy()
			@oReactor = ""
		ok
		return This

	#-- internals -------------------------------------------------------

	def _IndexOf(pcName)
		_cN_ = "" + pcName
		_nLen_ = len(@aAgents)
		for _i_ = 1 to _nLen_
			if @aAgents[_i_][1] = _cN_  return _i_  ok
		next
		return 0

	def _Wait(nMs)
		if nMs < 1  nMs = 1  ok
		if @oReactor != ""
			_nId_ = @oReactor.SubmitTimer(nMs)
			if _nId_ > 0
				@oReactor.AwaitTimer(_nId_, nMs + 1000)
				return
			ok
		ok
		sleep(nMs / 1000)

	# Ms until the earliest next due tick of an active agent, clamped to
	# the run deadline. Returns 0 when nothing more is due before then.
	def _NextWait(nDeadline)
		_nNow_ = StzEngineTimeNowMs()
		# On the engine path the due times live in Zig, so column 5 is not
		# the thing to read -- wait the shortest declared interval instead
		# and let the loop decide what that pass actually owes.
		if @bEngineLoop = 1
			_nW_ = This._MinInterval()
			if (_nNow_ + _nW_) > nDeadline  return nDeadline - _nNow_  ok
			return _nW_
		ok
		_nBest_ = nDeadline
		_bAny_ = 0
		_nLen_ = len(@aAgents)
		for _i_ = 1 to _nLen_
			if NOT @aAgents[_i_][4]  loop  ok
			if @aAgents[_i_][7]      loop  ok
			_bAny_ = 1
			if @aAgents[_i_][5] < _nBest_
				_nBest_ = @aAgents[_i_][5]
			ok
		next
		if NOT _bAny_  return 0  ok
		_nW_ = _nBest_ - _nNow_
		if _nW_ < 1  _nW_ = 1  ok
		if (_nNow_ + _nW_) > nDeadline  return nDeadline - _nNow_  ok
		return _nW_

	def _MinInterval()
		_nMin_ = 1000
		_nLen_ = len(@aAgents)
		for _i_ = 1 to _nLen_
			if @aAgents[_i_][4] and NOT @aAgents[_i_][7]
				if @aAgents[_i_][3] < _nMin_  _nMin_ = @aAgents[_i_][3]  ok
			ok
		next
		return _nMin_

	def _AllQuiet()
		# a pass ran with zero firings; treat as quiet (obligations, if
		# any, are the governed teardown gate -- not a liveness signal).
		return 1
