# R5 -- stzPIAgent: THE PROGRAMMATIC-INTELLIGENCE AGENT (the convergence)
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.6 rung 3 + agentic/ map.)
#
# The PI-agent is ASSEMBLED from what the roadmap already built, NOT
# invented:
#   MIND      = the Softanzuter ladder -- skills fire on the perceived
#               state (reaction), a goal directs the sequence (planning)
#   MEMORY    = stzAgentMemory over a stzKnowledgeGraph (R1)
#   SKILLS    = stzAgentSkill (precondition + plan + verification)
#   GOVERNANCE= stzGovernance (R4b): every act passes MayProceed BEFORE
#               it runs; decisions leave a lineage
#   ACCOUNTABILITY = Why() on every cycle; deterministic, zero-cost,
#               offline (LAW 2/3). stzLLMAgent is the SAME shape with
#               model-backed skills (a later slice).
#
#   oAg = new stzPIAgent("kitchen-bot")
#   oAg.GovernanceQ().DeclareRisk("order-stock", 2)
#   oAg.GovernanceQ().GrantPermission("kitchen-bot", "order-stock")
#   oAg.GovernanceQ().SetAuthority("kitchen-bot", :Delegated)
#   oAg.AddSkill(oRestockSkill.NeedsAction("order-stock"))
#   oAg.Pursue()                # perceive -> decide -> (govern) -> act
#   ? oAg.Why()

# Holds an agent that perceives its memory, decides under governance, acts through verified skills and can say why.
#
# A stzPIAgent is assembled from parts that already exist: a stzAgentMemory over a knowledge graph,
# stzAgentSkill objects (precondition, action, check) and a stzGovernance record. Cycle runs one
# pass over the skills: a skill whose precondition does not hold is skipped, a governed skill asks
# MayProceed first and is refused if it does not pass, and an admitted skill is applied and
# verified. Pursue repeats Cycle to a fixpoint, bounded at 20 rounds. It is deterministic and
# offline. GiveWorkbench binds the safe world: the agent's ring functions then rehearse file writes
# in memory, and GenerateUpdatePlan is the one export toward reality.
#
#   receiver   o1 = new stzPIAgent("kitchen-bot") o2 = new stzAgentSkill("restock")
#   example    o2.SetWhen(func m { return m.Fact("stock", "level", "low") })
#              o2.SetDoes(func m { m.Learn("stock", "level", "ordered") return 1 })
#              o1.AddSkill(o2)
#              o1.MemoryQ().Learn("stock", "level", "low")
#              ? o1.Cycle()
#              #--> 1
#              ? o1.MemoryQ().Fact("stock", "level", "ordered")
#              #--> 1
#              ? o1.Trace()[1][:decision]
#              #--> ran
#   see        stzAgentSkill, stzAgentMemory, stzGovernance, stzAgentHost
class stzPIAgent from stzObject

	@cName = ""
	@oMem = ""
	@oGov = ""
	@aSkills = []       # [ skill, governedAction("" = ungoverned) ]
	@aTrace = []        # per-cycle [ skill, decision, verified, why ]
	@cWhy = ""
	@nWorkbench = 0     # the safe-world twin's ID -- an id, never the
	# Builds an agent with a name, an empty memory, a governance record and no skills.
	#
	#   pcName     the agent's name, also the actor named in governance decisions
	#   returns    nothing; the object is built
	#   see        AddSkill, Cycle
	#@ aka  object: an id survives Ring's copy-on-assign (the engine-wrapper copy law, in pure Ring)
	def init(pcName)
		@cName = "" + pcName
		@oMem = new stzAgentMemory(pcName)
		@oGov = new stzGovernance(pcName)

	# Returns the name the agent was built with.
	#
	#   returns    a text
	#   see        init
	def Name_()
		return @cName

	# Returns the agent's memory, where the skills perceive and learn.
	#
	#   returns    a stzAgentMemory
	#   see        stzAgentMemory
	#@ aka  Q-convention: these return chainable OBJECTS -> Q suffix
	def MemoryQ()
		return @oMem

	# Returns the agent's governance record: risks, permissions, authority and decisions.
	#
	#   returns    a stzGovernance
	#   see        AddGovernedSkill, DecisionLog
	def GovernanceQ()
		return @oGov

	# Returns what happened to each skill on every cycle so far, in order.
	#
	#   returns    a list of hash lists [ :skill, :decision, :verified, :why ]; decision is skipped,
	#              refused or ran
	#   note       the trace grows with every cycle and is never cleared
	#   see        DecisionLog, Cycle
	def Trace()
		return @aTrace

	# Returns the sentence that sums up the last Pursue.
	#
	#   returns    a text; empty before the first Pursue
	def Why()
		return @cWhy

	# Opens a rehearsal workbench for the agent, if it has none, so that its file writes land in memory.
	#
	#   returns    nothing; use GiveWorkbenchQ to chain
	#   note       during Cycle the workbench is the ambient one, reached by a ring function through
	#              StzActiveWorkbenchQ; calling it again keeps the same workbench
	#   see        WorkbenchQ, GenerateUpdatePlan
	#@ aka  THE BINDING OF THE SAFE WORLD (ruling 3.2). A workbench-holding agent's ring: functions rehearse their file writes into an stzVirtualFileSystem instead of touching disk; the tick's ONLY export toward reality is GenerateUpdatePlan(), which a COMMITTING ACTOR executes under stzUpdatePlan's three gates (scope, capability, governance). `Agents That Cannot Hurt You`, made a method call.
	def GiveWorkbench()
		if @nWorkbench = 0
			@nWorkbench = StzOpenAgentWorkbench()
			StzAgentWorkbenchQ(@nWorkbench).SetActor(@cName)
		ok

		def GiveWorkbenchQ()
			This.GiveWorkbench()
			return This

	# TRUE if the agent was given a workbench.
	#
	#   returns    TRUE or FALSE
	#   see        GiveWorkbench, WorkbenchQ
	def HasWorkbench()
		if @nWorkbench > 0
			return 1
		ok
		return 0

	# Returns a face onto the agent's workbench.
	#
	#   returns    a stzAgentWorkbench
	#   note       the face reaches the one live workbench, so changes through it are the agent's
	#              own
	#   warning    raises an error naming the agent when it holds no workbench
	#   see        GiveWorkbench, HasWorkbench
	def WorkbenchQ()
		if @nWorkbench = 0
			stzraise("stzPIAgent.WorkbenchQ: '" + @cName + "' holds no " +
				"workbench -- GiveWorkbench() first.")
		ok
		return StzAgentWorkbenchQ(@nWorkbench)

	# Returns the agent's rehearsed file changes as an update plan, its only export toward reality.
	#
	#   returns    a stzUpdatePlan
	#   note       the plan is executed by a committing actor, never by the agent
	#   warning    raises the no-workbench error when the agent holds none
	#   see        WorkbenchQ, GiveWorkbench
	#@ aka  the tick's only export toward reality
	def GenerateUpdatePlan()
		return This.WorkbenchQ().GenerateUpdatePlan()

	# Adds a skill that runs whenever its precondition holds, without asking governance.
	#
	#   poSkill    a stzAgentSkill
	#   returns    nothing; use AddSkillQ to chain
	#   see        AddGovernedSkill, Cycle
	#@ aka  a skill may declare the governed action it performs; if it does, the agent asks stzGovernance.MayProceed BEFORE running it
	def AddSkill(poSkill)
		@aSkills + [ poSkill, "" ]

		def AddSkillQ(poSkill)
			This.AddSkill(poSkill)
			return This

	# Adds a skill whose action must first pass the governance gate, which asks about the action by its lower-case name.
	#
	#   poSkill    a stzAgentSkill
	#   pcAction   the governed action the skill performs
	#   returns    nothing; use AddGovernedSkillQ to chain
	#   note       the gate refuses an action with no declared risk tier, and each refusal is traced
	#   see        AddSkill, GovernanceQ
	def AddGovernedSkill(poSkill, pcAction)
		@aSkills + [ poSkill, StzLower("" + pcAction) ]

		def AddGovernedSkillQ(poSkill, pcAction)
			This.AddGovernedSkill(poSkill, pcAction)
			return This

	# Returns how many skills the agent holds.
	#
	#   returns    a number
	#   see        AddSkill, AddGovernedSkill
	def NumberOfSkills()
		return len(@aSkills)

	# Runs one pass over all skills: tests each precondition, asks governance for governed ones, then applies and verifies.
	#
	#   returns    a number, how many skills ran and were verified
	#   note       a skill whose precondition stays true fires again on every cycle
	#   see        Pursue, Trace
	#@ aka  ONE perceive-decide-act cycle over all skills. Each skill: perceive: PreconditionHolds over memory decide: (if governed) MayProceed -- else skip, refusal traced act: Apply, VERIFY, record Returns the number of skills that ran AND verified.
	def Cycle()
		# The AMBIENT workbench: while THIS agent's skills fire, a ring:
		# function's file writes land in this agent's twin. The previous
		# ambient is restored on the way out, so cycles nested across
		# agents stay correct -- and an agent WITHOUT a workbench leaves
		# the ambient untouched rather than clearing someone else's.
		_nPrevWb_ = $nStzActiveAgentWorkbench
		if @nWorkbench > 0
			$nStzActiveAgentWorkbench = @nWorkbench
		ok
		_nActed_ = 0
		_nS_ = len(@aSkills)
		for _i_ = 1 to _nS_
			_oSk_ = @aSkills[_i_][1]
			_cAction_ = @aSkills[_i_][2]
			if _oSk_.PreconditionHolds(@oMem) = 0
				@aTrace + [ :skill = _oSk_.Name_(), :decision = "skipped",
					:verified = 0, :why = "precondition not met" ]
				loop
			ok
			# GOVERNANCE GATE: a governed skill needs MayProceed
			if _cAction_ != ""
				if @oGov.MayProceed(@cName, _cAction_) = 0
					@aTrace + [ :skill = _oSk_.Name_(), :decision = "refused",
						:verified = 0, :why = @oGov.Why() ]
					loop
				ok
				@oGov.RecordDecision(@cName + "-" + _oSk_.Name_(),
					"skill fired on met precondition", @cName, _cAction_)
			ok
			_aR_ = _oSk_.Apply(@oMem)
			@aTrace + [ :skill = _oSk_.Name_(),
				:decision = "ran", :verified = _aR_[:verified],
				:why = _aR_[:why] ]
			if _aR_[:verified] = 1
				_nActed_++
			ok
		next
		$nStzActiveAgentWorkbench = _nPrevWb_
		return _nActed_

	# Repeats Cycle until a cycle verifies nothing or 20 rounds are done.
	#
	#   returns    a number, the total of skill-firings that were verified
	#   note       a skill that leaves its own precondition true runs to the 20-round limit; the
	#              sentence for it is kept for Why
	#   see        Cycle, Why
	#@ aka  run cycles until the world stops changing (fixpoint) or the cap is hit -- the Softanzuter cascade at the agent level
	def Pursue()
		_nTotal_ = 0
		_nRound_ = 0
		while _nRound_ < 20
			_nRound_++
			_nActed_ = This.Cycle()
			_nTotal_ += _nActed_
			if _nActed_ = 0
				exit
			ok
		end
		@cWhy = "pursued " + _nRound_ + " round(s); " + _nTotal_ +
			" skill-firing(s) verified"
		$cStzLastWhyB = @cWhy
		return _nTotal_

	# Returns the governed decisions taken so far: every trace row that ran or was refused.
	#
	#   returns    a list of hash lists [ :skill, :decision, :verified, :why ]
	#   note       skipped rows, where a precondition did not hold, are left out
	#   see        Trace, GovernanceQ
	#@ aka  the audit witness: every governed decision the agent took
	def DecisionLog()
		_aOut_ = []
		_n_ = len(@aTrace)
		for _i_ = 1 to _n_
			if @aTrace[_i_][:decision] = "ran" or @aTrace[_i_][:decision] = "refused"
				_aOut_ + @aTrace[_i_]
			ok
		next
		return _aOut_
