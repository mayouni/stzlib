# R5 -- stzAgentSkill: A CAPABILITY = precondition + plan + verification
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md agentic/ map). PI skills are
# algorithmic, LLM skills are prompted -- SAME interface. A skill only
# RUNS when its precondition holds, and its result is VERIFIED before
# it counts (LAW 3: no unchecked effect).
#
#   oSk = new stzAgentSkill("restock")
#   oSk.When(func(oMem) { return oMem.Fact("stock", "level", "low") })
#   oSk.Does(func(oMem) { oMem.Learn("stock", "level", "ordered")  return 1 })
#   oSk.VerifiedBy(func(oMem) { return oMem.Fact("stock", "level", "ordered") })

class stzAgentSkill from stzObject

	@cName = ""
	@fWhen = NULL
	@fDoes = NULL
	@fVerify = NULL
	@cKind = "pi"       # pi | llm (posture, not machinery)

	def init(pcName)
		@cName = "" + pcName

	def Name_()
		return @cName

	def When(fPrecondition)
		@fWhen = fPrecondition
		return This

	def Does(fAction)
		@fDoes = fAction
		return This

	def VerifiedBy(fCheck)
		@fVerify = fCheck
		return This

	def AsLLMSkill()
		@cKind = "llm"
		return This

	def Kind()
		return @cKind

	def PreconditionHolds(poMemory)
		if @fWhen = NULL
			return 1
		ok
		return call @fWhen(poMemory)

	# run only when the precondition holds; VERIFY the result before
	# reporting success. Returns [ :ran, :verified, :why ].
	def Apply(poMemory)
		if This.PreconditionHolds(poMemory) = 0
			return [ :ran = 0, :verified = 0,
				:why = "skill '" + @cName + "' skipped: precondition not met" ]
		ok
		if @fDoes = NULL
			return [ :ran = 0, :verified = 0,
				:why = "skill '" + @cName + "' has no action" ]
		ok
		call @fDoes(poMemory)
		_bV_ = 1
		if @fVerify != NULL
			_bV_ = call @fVerify(poMemory)
		ok
		if _bV_ = 1
			return [ :ran = 1, :verified = 1,
				:why = "skill '" + @cName + "' ran and VERIFIED" ]
		ok
		return [ :ran = 1, :verified = 0,
			:why = "skill '" + @cName + "' ran but FAILED verification" ]
