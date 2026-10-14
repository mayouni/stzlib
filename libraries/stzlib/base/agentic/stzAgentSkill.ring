# R5 -- stzAgentSkill: A CAPABILITY = precondition + plan + verification
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md agentic/ map). PI skills are
# algorithmic, LLM skills are prompted -- SAME interface. A skill only
# RUNS when its precondition holds, and its result is VERIFIED before
# it counts (LAW 3: no unchecked effect).
#
#   oSk = new stzAgentSkill("restock")
#   oSk.SetWhen(func(oMem) { return oMem.Fact("stock", "level", "low") })
#   oSk.SetDoes(func(oMem) { oMem.Learn("stock", "level", "ordered")  return 1 })
#   oSk.SetVerifiedBy(func(oMem) { return oMem.Fact("stock", "level", "ordered") })

# Holds one capability of an agent: a precondition, an action and a check that the action worked.
#
# A skill runs only when its precondition holds, and its result counts only when the check confirms
# it, so no effect goes unchecked. Algorithmic (pi) and prompted (llm) skills share one interface.
# Apply never throws for the three ordinary outcomes: it answers ran and verified as 0 or 1 with a
# sentence saying why, so a caller can log all three the same way. The check runs after the action
# and cannot undo it.
#
#   receiver   o1 = new stzAgentSkill("restock") o2 = new stzAgentMemory("shop")
#   example    o2.Learn("stock", "level", "low")
#              o1.SetWhen(func oM { return oM.Fact("stock", "level", "low") })
#              o1.SetDoes(func oM { oM.Learn("stock", "level", "ordered") return 1 })
#              o1.SetVerifiedBy(func oM { return oM.Fact("stock", "level", "ordered") })
#              ? o1.Apply(o2)[:why]
#              #--> skill 'restock' ran and VERIFIED
#   see        stzAgentMemory, stzPIAgent
class stzAgentSkill from stzObject

	@cName = ""
	@fWhen = ""
	@fDoes = ""
	@fVerify = ""
	@cKind = "pi"       # pi | llm (posture, not machinery)

	# Builds a skill with a name and no precondition, action or check; its kind is pi.
	#
	#   pcName     the skill's name, quoted in the why of Apply
	#   returns    nothing; the object is built
	#   see        SetWhen, SetDoes, SetVerifiedBy
	def init(pcName)
		@cName = "" + pcName

	# Returns the name the skill was built with.
	#
	#   returns    a text
	#   see        init, Kind
	def Name_()
		return @cName

	# Sets the precondition: a function of the memory that must answer true before the skill may run.
	#
	#   fPrecondition   a function taking the memory and returning 1 or 0
	#   returns         the skill itself, so calls chain
	#   see             PreconditionHolds, Apply
	def SetWhen(fPrecondition)
		@fWhen = fPrecondition
		return This

	# Sets the action the skill performs on the memory when it runs.
	#
	#   fAction    a function taking the memory
	#   returns    the skill itself, so calls chain
	#   see        SetVerifiedBy, Apply
	def SetDoes(fAction)
		@fDoes = fAction
		return This

	# Sets the check run after the action to confirm that it had the intended effect.
	#
	#   fCheck     a function taking the memory and returning 1 when the effect is confirmed
	#   returns    the skill itself, so calls chain
	#   note       without a check the result counts as verified
	#   see        SetDoes, Apply
	def SetVerifiedBy(fCheck)
		@fVerify = fCheck
		return This

	# Marks the skill as prompted rather than algorithmic; the interface and the gates are the same.
	#
	#   returns    the skill itself, so calls chain
	#   note       it changes the posture reported by Kind, not the way Apply runs
	#   see        Kind
	def AsLLMSkill()
		@cKind = "llm"
		return This

	# Returns the skill's posture: pi for an algorithmic skill, llm after AsLLMSkill.
	#
	#   returns    the text pi or llm
	#   see        AsLLMSkill, Name_
	def Kind()
		return @cKind

	# Runs the precondition on a memory and returns its answer; a skill with no precondition always holds.
	#
	#   poMemory   the agent's memory (a stzAgentMemory)
	#   returns    what the precondition function returned, 1 when none is set
	#   note       Apply tests the answer against 0, so any other value, such as 2, counts as
	#              holding
	#   see        SetWhen, Apply
	def PreconditionHolds(poMemory)
		if @fWhen = ""
			return 1
		ok
		return call @fWhen(poMemory)

	# Runs the action only if the precondition holds, then checks the result, and reports what happened.
	#
	#   poMemory   the agent's memory, which the action may change
	#   returns    a hash list [ :ran, :verified, :why ]; why is a sentence naming the skill
	#   note       the action runs before the check, and a failed check does not undo it
	#   warning    a skill with no action reports ran 0 even when its precondition holds; a check
	#              must answer exactly 1 to verify
	#   see        SetDoes, SetVerifiedBy, PreconditionHolds
	#@ aka  run only when the precondition holds; VERIFY the result before reporting success. Returns [ :ran, :verified, :why ].
	def Apply(poMemory)
		if This.PreconditionHolds(poMemory) = 0
			return [ :ran = 0, :verified = 0,
				:why = "skill '" + @cName + "' skipped: precondition not met" ]
		ok
		if @fDoes = ""
			return [ :ran = 0, :verified = 0,
				:why = "skill '" + @cName + "' has no action" ]
		ok
		call @fDoes(poMemory)
		_bV_ = 1
		if @fVerify != ""
			_bV_ = call @fVerify(poMemory)
		ok
		if _bV_ = 1
			return [ :ran = 1, :verified = 1,
				:why = "skill '" + @cName + "' ran and VERIFIED" ]
		ok
		return [ :ran = 1, :verified = 0,
			:why = "skill '" + @cName + "' ran but FAILED verification" ]
