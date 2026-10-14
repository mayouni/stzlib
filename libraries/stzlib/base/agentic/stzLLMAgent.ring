# R5 -- stzLLMAgent: the LLM-backed agent, SAME shape, EMPTY capabilities
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.6.) Creativity PROPOSES;
# effects belong to a pi-gate. So an LLM agent's skills are marked llm,
# its Propose() returns a candidate, and it can NEVER commit an effect
# on its own -- only a hybrid composition under a pi-guardian may
# (stzAgentGraph enforces that structurally).
#
#   oLLM = new stzLLMAgent("summarizer")
#   oLLM.SetSkillFrom(oLLMFunction)      # an stzLLMFunction (R4 G3) is the body
#   ? oLLM.Propose("long text ...")   # a candidate -- NOT an effect
#   ? oLLM.HoldsEffectful()           # ALWAYS 0

# Holds a model-backed agent that proposes candidates and can never commit an effect on its own.
#
# It has the same shape as stzPIAgent but its body is a stzLLMFunction, and its capability set is
# inference only: HoldsEffectful answers 0 whatever is done to it, so the agent graph and the
# guardrails treat it as an llm_actor that a guarded pi-actor must admit before anything happens.
# Propose returns the model function's answer as a candidate. Documented and run here with a seeded
# answer, so no model is loaded and nothing is called over a network.
#
#   receiver   o1 = new stzLLMAgent("summarizer") o2 = new stzLLMFunction("sum")
#   example    o2.SetPrompt("summarize: {input}")
#              o2.Budget(2)
#              o2.SeedAnswer("hello world", "a greeting")
#              o1.SetSkillFrom(o2)
#              ? o1.Propose("hello world")
#              #--> a greeting
#              ? o1.HoldsEffectful()
#              #--> 0
#              ? o1.Kind()
#              #--> llm_actor
#   see        stzPIAgent, stzLLMFunction, stzAgentGraph
class stzLLMAgent from stzObject

	@cName = ""
	@oFn = ""
	@oMem = ""

	# Builds a model-backed agent with a name, an empty memory and no model body yet.
	#
	#   pcName     the agent's name, also the name of its memory
	#   returns    nothing; the object is built
	#   see        SetSkillFrom, Propose
	def init(pcName)
		@cName = "" + pcName
		@oMem = new stzAgentMemory(pcName)

	# Returns the name the agent was built with.
	#
	#   returns    a text
	#   see        init, Kind
	def Name_()
		return @cName

	# Returns the agent's memory, a stzAgentMemory built under the same name.
	#
	#   returns    a stzAgentMemory
	#   see        stzAgentMemory
	def MemoryQ()
		return @oMem

	# Gives the agent its body: a typed language-model function through which every proposal is made.
	#
	#   poLLMFunction   a stzLLMFunction, such as one with a seeded answer for offline use
	#   returns         the agent itself, so calls chain
	#   see             Propose, HoldsEffectful
	#@ aka  the LLM body is an stzLLMFunction (typed-or-refuse, budgeted, memoized -- R4 G3). The agent proposes through it.
	def SetSkillFrom(poLLMFunction)
		@oFn = poLLMFunction
		return This

	# Returns the candidate the model function gives for an input; it is a proposal and changes nothing.
	#
	#   pcInput    the text handed to the model function
	#   returns    what the model function answered, a candidate for a pi-gate to admit
	#   note       the agent only proposes, and only a guarded pi-actor may commit the effect
	#   warning    raises an error while no body is set, whose text names SkillFrom although the
	#              method is called SetSkillFrom; a model function with no Budget, or with no seeded
	#              or loaded answer, raises its own refusal
	#   see        SetSkillFrom, HoldsEffectful
	#@ aka  a PROPOSAL, never an effect -- the return value is a candidate a pi-gate must admit before anything happens
	def Propose(pcInput)
		if @oFn = ""
			stzraise("No LLM body -- SkillFrom(anStzLLMFunction) first.")
		ok
		return @oFn.Call_(pcInput)

	# Returns 0 always: a language-model agent never holds the right to commit an effect.
	#
	#   returns    the number 0
	#   note       the answer is fixed in the code, a structural guarantee and not a setting
	#   see        Capabilities, Kind
	#@ aka  the structural guarantee, stated in code: an LLM actor's capability set is EMPTY of 'effectful' -- forever
	def HoldsEffectful()
		return 0

	# Returns the capabilities the agent holds, which are inference only.
	#
	#   returns    a list holding the text inference
	#   see        HoldsEffectful, Kind
	def Capabilities()
		return [ "inference" ]

	# Returns the kind of actor the agent is, as the agent graph and its guardrails read it.
	#
	#   returns    the text llm_actor
	#   see        Capabilities, HoldsEffectful
	def Kind()
		return "llm_actor"
