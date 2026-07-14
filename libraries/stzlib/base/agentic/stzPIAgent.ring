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
#   oAg.Governance().DeclareRisk("order-stock", 2)
#   oAg.Governance().GrantPermission("kitchen-bot", "order-stock")
#   oAg.Governance().SetAuthority("kitchen-bot", :Delegated)
#   oAg.AddSkill(oRestockSkill.NeedsAction("order-stock"))
#   oAg.Pursue()                # perceive -> decide -> (govern) -> act
#   ? oAg.Why()

class stzPIAgent from stzObject

	@cName = ""
	@oMem = NULL
	@oGov = NULL
	@aSkills = []       # [ skill, governedAction("" = ungoverned) ]
	@aTrace = []        # per-cycle [ skill, decision, verified, why ]
	@cWhy = ""

	def init(pcName)
		@cName = "" + pcName
		@oMem = new stzAgentMemory(pcName)
		@oGov = new stzGovernance(pcName)

	def Name_()
		return @cName

	def Memory()
		return @oMem

	def Governance()
		return @oGov

	def Trace()
		return @aTrace

	def Why()
		return @cWhy

	# a skill may declare the governed action it performs; if it does,
	# the agent asks stzGovernance.MayProceed BEFORE running it
	def AddSkill(poSkill)
		@aSkills + [ poSkill, "" ]
		return This

	def AddGovernedSkill(poSkill, pcAction)
		@aSkills + [ poSkill, StzLower("" + pcAction) ]
		return This

	def NumberOfSkills()
		return len(@aSkills)

	# ONE perceive-decide-act cycle over all skills. Each skill:
	#   perceive: PreconditionHolds over memory
	#   decide:   (if governed) MayProceed -- else skip, refusal traced
	#   act:      Apply, VERIFY, record
	# Returns the number of skills that ran AND verified.
	def Cycle()
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
		return _nActed_

	# run cycles until the world stops changing (fixpoint) or the cap
	# is hit -- the Softanzuter cascade at the agent level
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

	# the audit witness: every governed decision the agent took
	def DecisionLog()
		_aOut_ = []
		_n_ = len(@aTrace)
		for _i_ = 1 to _n_
			if @aTrace[_i_][:decision] = "ran" or @aTrace[_i_][:decision] = "refused"
				_aOut_ + @aTrace[_i_]
			ok
		next
		return _aOut_
