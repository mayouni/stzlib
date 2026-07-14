# R5 -- stzLLMAgent: the LLM-backed agent, SAME shape, EMPTY capabilities
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.6.) Creativity PROPOSES;
# effects belong to a pi-gate. So an LLM agent's skills are marked llm,
# its Propose() returns a candidate, and it can NEVER commit an effect
# on its own -- only a hybrid composition under a pi-guardian may
# (stzAgentGraph enforces that structurally).
#
#   oLLM = new stzLLMAgent("summarizer")
#   oLLM.SkillFrom(oLLMFunction)      # an stzLLMFunction (R4 G3) is the body
#   ? oLLM.Propose("long text ...")   # a candidate -- NOT an effect
#   ? oLLM.HoldsEffectful()           # ALWAYS 0

class stzLLMAgent from stzObject

	@cName = ""
	@oFn = NULL
	@oMem = NULL

	def init(pcName)
		@cName = "" + pcName
		@oMem = new stzAgentMemory(pcName)

	def Name_()
		return @cName

	def MemoryQ()
		return @oMem

	# the LLM body is an stzLLMFunction (typed-or-refuse, budgeted,
	# memoized -- R4 G3). The agent proposes through it.
	def SkillFrom(poLLMFunction)
		@oFn = poLLMFunction
		return This

	# a PROPOSAL, never an effect -- the return value is a candidate a
	# pi-gate must admit before anything happens
	def Propose(pcInput)
		if @oFn = NULL
			stzraise("No LLM body -- SkillFrom(anStzLLMFunction) first.")
		ok
		return @oFn.Call_(pcInput)

	# the structural guarantee, stated in code: an LLM actor's
	# capability set is EMPTY of 'effectful' -- forever
	def HoldsEffectful()
		return 0

	def Capabilities()
		return [ "inference" ]

	def Kind()
		return "llm_actor"
