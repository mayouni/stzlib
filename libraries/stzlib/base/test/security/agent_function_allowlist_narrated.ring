load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-AGENT-FN-01 -- threat-model risk R2: code, not an agent file,
# decides which Ring functions an agent may run.
#
# A .pia file's `ring:` clause was checked for EXISTENCE only, so a file --
# data, which may come from a folder, a colleague or a language model
# composing agents -- could name ANY function loaded in the process (a shell
# runner, a file remover) and declare itself "trusted". Now:
#
#   StzAllowAgentFunction(name, maxPosture)   -- in CODE
#
# names what agent files may call and the most trusted posture it may run
# under. At load, a clause naming anything else is refused, and so is a file
# claiming more trust than code allowed.

Scenario("a file naming a loaded but unallowed function is refused at load")
	# StzSystem runs a shell command: it exists, and no agent should name it
	oD = StzAgentDeclarationQ(Pia("StzSystem", "trusted"))
	# before: accepted -- existence was the whole check
	Then("the declaration is refused", oD.IsValid(), 0)
	Then("...naming the rule", HasRule(oD, "pia-function-not-allowed"), 1)
	Then("...and the one line that would allow it", StzFindFirst("StzAllowAgentFunction", Cite(oD)) > 0, 1)
EndScenario()

Scenario("a function code allowed loads, within its allowance")
	StzAllowAgentFunction("AllowlistProbeCheck", "external")
	Then("allowed at 'external', a file saying 'external' loads",
		StzAgentDeclarationQ(Pia("AllowlistProbeCheck", "external")).IsValid(), 1)
	Then("...and so does one asking for LESS trust ('sandboxed')",
		StzAgentDeclarationQ(Pia("AllowlistProbeCheck", "sandboxed")).IsValid(), 1)
	oD = StzAgentDeclarationQ(Pia("AllowlistProbeCheck", "trusted"))
	Then("a file claiming MORE trust ('trusted') is refused", oD.IsValid(), 0)
	Then("...as exceeding the allowance", HasRule(oD, "pia-posture-exceeds-allowance"), 1)
EndScenario()

Scenario("an allowance can be withdrawn")
	StzDisallowAgentFunction("AllowlistProbeCheck")
	Then("withdrawn, the same file is refused again",
		StzAgentDeclarationQ(Pia("AllowlistProbeCheck", "external")).IsValid(), 0)
EndScenario()

Scenario("a function that does not exist is still refused as before (negative sibling)")
	oD = StzAgentDeclarationQ(Pia("NoSuchFunctionAnywhere", "sandboxed"))
	Then("refused", oD.IsValid(), 0)
	Then("...for not existing", HasRule(oD, "pia-undeclared-closure"), 1)
EndScenario()

Scenario("the library's own roster functions are allowed by the library")
	Then("RollWritePointer needs no application allowance",
		StzAgentFunctionAllowance("RollWritePointer"), "trusted")
	bRaised = 0
	try  StzAllowAgentFunction("x", "godmode")  catch  bRaised = 1  done
	Then("an allowance must name a real posture", bRaised, 1)
EndScenario()

Summary()

# -- helpers (after the main code) ------------------------------------

func Pia cFn, cPosture
	# reversible work, so every posture is admissible on its own (the
	# posture x reversibility rule is not what this guard measures)
	nl = char(10)
	return "pia: 2" + nl + "name: probe" + nl + "kind: pi" + nl +
		"coverage: checks a stock level" + nl + "reversibility: reversible" + nl +
		"schedule:" + nl + "  timer: 20" + nl + "skills:" + nl +
		"  - name: check" + nl + "    when: always" + nl +
		"    does: ring:" + cFn + nl + "    verify: fact stock was checked" + nl +
		"    posture: " + cPosture + nl

func HasRule oD, cRule
	aF = oD.Findings()
	for i = 1 to len(aF)
		if aF[i][:rule] = cRule  return 1  ok
	next
	return 0

func Cite oD
	aF = oD.Findings()
	c = ""
	for i = 1 to len(aF)  c += aF[i][:message] + " "  next
	return c

func AllowlistProbeCheck oMem
	return 1
