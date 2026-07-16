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
#   oHost.GovernRetirementWith(oGov)         # R4b decommission gate
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

func StzAgentHostQ()
	return new stzAgentHost()

class stzAgentHost from stzObject

	@oReactor    = NULL
	@bOwnsReactor = FALSE
	@oGov        = NULL      # optional decommission-gate governance
	@aAgents     = []        # [ name, oAgent, tickMs, active, nextMs, ticks, retired ]
	@aTrace      = []        # [ atMs, name, acted, why ]
	@cWhy        = ""

	def init()
		@oReactor = new stzReactor()
		@bOwnsReactor = TRUE

	# Share another host's loop (e.g. an stzAppServer's) instead of
	# owning one -- "the agent host is the same host".
	def UsingReactor(poReactor)
		if @bOwnsReactor and @oReactor != NULL
			@oReactor.Destroy()
		ok
		@oReactor = poReactor
		@bOwnsReactor = FALSE
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
	def GovernRetirementWith(poGov)
		@oGov = poGov
		return This

	def _EnsureGov()
		if @oGov = NULL
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
		#      channel(""=timer), lastEventCount
		@aAgents + [ poAgent.Name_(), poAgent, nTickMs, TRUE,
		             StzEngineTimeNowMs(), 0, FALSE, "", 0 ]
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
		@aAgents + [ poAgent.Name_(), poAgent, 0, TRUE,
		             0, 0, FALSE, "" + pcChannel, _nBase_ ]
		return This

	# The channel an agent is event-supervised on ("" if timer-supervised).
	def ChannelOf(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return ""  ok
		return @aAgents[_n_][8]

	def NumberOfAgents()
		return len(@aAgents)

	def IsSupervising(pcName)
		return This._IndexOf(pcName) > 0

	def IsActive(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return FALSE  ok
		return @aAgents[_n_][4]

	def TicksOf(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return 0  ok
		return @aAgents[_n_][6]

	# The live supervised agent (reach it here, not via a stale ref).
	def AgentQ(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return NULL  ok
		return @aAgents[_n_][2]

	def Trace()
		return @aTrace

	#-- the perceive-act runtime ---------------------------------------

	# Tick every ACTIVE, non-retired agent whose interval has elapsed:
	# run ONE Cycle() (perceive-decide-act) through the live index.
	# Returns the number of skill-firings verified this pass.
	def TickDue()
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
		@aAgents[_n_][4] = FALSE
		return This

	def Resume(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0
			stzraise("stzAgentHost.Resume: not supervising '" + pcName + "'.")
		ok
		@aAgents[_n_][4] = TRUE
		@aAgents[_n_][5] = StzEngineTimeNowMs()
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
		if @oGov != NULL
			if @oGov.MayRetire(pcName) = 0
				@cWhy = @oGov.Why()
				return FALSE
			ok
		ok
		@aAgents[_n_][4] = FALSE
		@aAgents[_n_][7] = TRUE
		@cWhy = "retired '" + pcName + "'"
		return TRUE

	def IsRetired(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0  return FALSE  ok
		return @aAgents[_n_][7]

	#-- teardown --------------------------------------------------------

	def Shutdown()
		if @bOwnsReactor and @oReactor != NULL
			@oReactor.Destroy()
			@oReactor = NULL
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
		if @oReactor != NULL
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
		_nBest_ = nDeadline
		_bAny_ = FALSE
		_nLen_ = len(@aAgents)
		for _i_ = 1 to _nLen_
			if NOT @aAgents[_i_][4]  loop  ok
			if @aAgents[_i_][7]      loop  ok
			_bAny_ = TRUE
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
		return TRUE
