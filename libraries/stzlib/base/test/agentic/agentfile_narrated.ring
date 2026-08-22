# AGENTS AS FILES -- the .pia declaration, its court, and the folder
#
# The vision this answers: an agent is CREATED DECLARATIVELY, DROPPED IN A
# FOLDER, AND RUNS IN THE LOOP. Everything below is that sentence, taken
# apart and checked.
#
# WHAT IS NEW HERE AND WHAT IS NOT. New: a notation (.pia), a court that
# judges it, and a folder that mounts what passes. NOT new: stzPIAgent,
# stzAgentSkill, stzAgentMemory, stzGovernance, stzAgentHost. This is a
# front-end, and the proof of that is scene 4 -- a declared agent ticks on
# an ordinary host, through the ordinary Cycle(), with no new runtime.
#
# THE HABIT THIS INHERITS FROM prompt 37: THE DECLARATION IS JUDGED, AND
# IT IS JUDGED AT LOAD. Scene 3 is one refusal per gate, and every one of
# them happens before an agent exists -- never at the first tick, with the
# agent already supervised and something half-done.
#
# Scenes 1-3, 7 and 8 need no model and no files. Scenes 4-6 read the
# fixture folder beside this file; scene 6 writes one probe file into it
# and deletes it again, and asserts that it did.

load "../../stzBase.ring"

# A Ring-defined agent is loaded by THE PROGRAM, never by the folder --
# the folder discovers it, gates it and mounts it. stzAgentFolder says why
# at _ReadRingAgent, and it is a measurement rather than a preference.
load "agents/watcher.ring"

nPass = 0
nFail = 0

pr()

#=====================================================================#
? "-- Scene 1: a pi agent, declared and judged --"
#=====================================================================#

cPi = "pia: 1
name: kitchen-bot
kind: pi
coverage: watches stock levels and reorders when they run low
reversibility: compensable
schedule:
  timer: 20
memory:
  - stock level low
governance:
  authority: delegated
  risks:
    order-stock: 2
  grants:
    - order-stock
skills:
  - name: restock
    when: fact stock level low
    does: learn stock level ordered
    verify: fact stock level ordered
    effect: order-stock
"

oD = StzAgentDeclarationQ(cPi)
chk("the declaration is accepted", oD.IsValid() = 1)
chk("...with nothing to cite", oD.CiteFindings() = "")
chk("...and it knows its own name", oD.Name_() = "kitchen-bot")
chk("...its kind", oD.Kind() = "pi")
chk("...what it covers", len(StzFind("stock levels", oD.CoverageStatement())) > 0)
chk("...how reversible it is", oD.ReversibilityClass() = "compensable")
chk("...and when it ticks", oD.Schedule()[:mode] = "timer" and oD.Schedule()[:timer] = 20)

# the clause is PARSED, not kept as prose -- a verb and its words
chk("a clause is read as a verb and its arguments",
	oD.SkillAt(1)[:when][:verb] = "fact" and len(oD.SkillAt(1)[:when][:args]) = 3)
chk("...and the governed action is the skill's declared effect",
	oD.SkillAt(1)[:effect] = "order-stock")

? ""
#=====================================================================#
? "-- Scene 2: the declaration becomes an agent that runs --"
#=====================================================================#
# ToAgent() assembles the classes that already existed. Nothing below is
# new machinery: it is stzPIAgent.Cycle() over an stzAgentSkill, gated by
# stzGovernance, over an stzAgentMemory.

oAg = oD.ToAgent()
chk("the seeded fact is in the agent's memory",
	oAg.MemoryQ().Fact("stock", "level", "low") = 1)
chk("the declared risk tier reached governance",
	oAg.GovernanceQ().RiskOf("order-stock") = 2)
chk("...and the permission with it",
	oAg.GovernanceQ().HasPermission("kitchen-bot", "order-stock") = 1)
chk("...so the governed action MAY proceed",
	oAg.GovernanceQ().MayProceed("kitchen-bot", "order-stock") = 1)

chk("one cycle fires the skill and VERIFIES it", oAg.Cycle() = 1)
chk("...and the world changed the way the file said it would",
	oAg.MemoryQ().Fact("stock", "level", "ordered") = 1)

# the agent answers the two questions law 18 asks, straight from the file,
# so the engine loop needs no separate Declare()
chk("the agent carries its coverage statement",
	len(StzFind("stock levels", oAg.CoverageStatement())) > 0)
chk("...and its reversibility class", oAg.ReversibilityClass() = "compensable")

# the negative sibling: a precondition that does NOT hold does not fire
cIdle = "pia: 1
name: idle-bot
kind: pi
coverage: does nothing until the shelf is empty
reversibility: reversible
schedule:
  timer: 20
skills:
  - name: never
    when: fact shelf state empty
    does: learn shelf state restocked
"
oIdle = StzAgentDeclarationQ(cIdle).ToAgent()
chk("a precondition that does not hold fires nothing", oIdle.Cycle() = 0)
chk("...and leaves the world alone",
	oIdle.MemoryQ().Fact("shelf", "state", "restocked") = 0)

? ""
#=====================================================================#
? "-- Scene 3: one refusal per gate, every one of them AT LOAD --"
#=====================================================================#
# A file that cannot be honoured never becomes an agent. Each refusal
# names the rule that produced it.

chk("no version header", RefusedBy("name: a
kind: pi
coverage: c
reversibility: reversible
schedule:
  timer: 5
skills:
  - name: s
    does: learn a b c
", "pia-version"))

chk("a version this build does not know",
	RefusedBy(Edited(cPi, "pia: 1", "pia: 99"), "pia-version"))

chk("a key the format does not know",
	RefusedBy(Edited(cPi, "kind: pi", "kind: pi
mood: cheerful"), "pia-unknown-key"))

chk("no coverage statement -- law 18, refused here rather than at the tick",
	RefusedBy(Edited(cPi, "coverage: watches stock levels and reorders when they run low", "note: none"), "pia-coverage"))

chk("a reversibility class that is not one",
	RefusedBy(Edited(cPi, "reversibility: compensable", "reversibility: maybe"), "pia-reversibility"))

chk("no schedule -- an agent in a folder must say when it runs",
	RefusedBy(Edited(cPi, "schedule:
  timer: 20", "note: none"), "pia-schedule"))

chk("a verb outside the vocabulary",
	RefusedBy(Edited(cPi, "does: learn stock level ordered", "does: teleport stock level ordered"), "pia-clause"))

chk("a verb standing in the wrong slot -- an action where a test belongs",
	RefusedBy(Edited(cPi, "when: fact stock level low", "when: learn stock level low"), "pia-clause-slot"))

chk("a clause with the wrong number of words",
	RefusedBy(Edited(cPi, "does: learn stock level ordered", "does: learn stock level"), "pia-clause-arity"))

# THE ONE THE ASK NAMES BY ITSELF: an undeclared verify closure.
chk("a verify clause naming a Ring function that does not exist",
	RefusedBy(Edited(cPi, "verify: fact stock level ordered", "verify: ring:NoSuchCheckExists"), "pia-undeclared-closure"))
chk("...while the SAME clause naming a function that DOES exist is accepted",
	StzAgentDeclarationQ(Edited(cPi, "when: fact stock level low", "when: ring:StockIsCritical")).IsValid() = 1)

chk("a risk tier outside 1..4",
	RefusedBy(Edited(cPi, "order-stock: 2", "order-stock: 9"), "pia-governance"))

chk("a pi agent with no skills has nothing to do",
	RefusedBy("pia: 1
name: empty
kind: pi
coverage: covers nothing at all
reversibility: reversible
schedule:
  timer: 5
", "pia-skills"))

# THE RULE THAT IS NOT NEW HERE -- it is stzAgentGraph's, in stzAgentGraph's
# own sentence. One rule, two doors, same words.
cBadLlm = "pia: 1
name: rogue
kind: llm
coverage: proposes a summary
reversibility: reversible
schedule:
  timer: 20
proposes:
  prompt: Summarize {input}
  structure:
    - field: topic
      type: string
skills:
  - name: send
    when: always
    does: propose
    effect: send-email
"
oBad = StzAgentDeclarationQ(cBadLlm)
chk("an llm agent holding an EFFECT is refused", oBad.IsValid() = 0)
chk("...by the graph's own rule name",
	len(StzFind("no-llm-effectful", oBad.CiteFindings())) > 0)
chk("...in the graph's own words, quoted rather than paraphrased",
	len(StzFind("an LLM proposes, only a pi-gate commits", oBad.CiteFindings())) > 0)

chk("an llm agent whose skill WRITES the world is refused too",
	RefusedBy(Edited(cBadLlm, "    does: propose
    effect: send-email", "    does: learn mail state sent"), "no-llm-effectful"))

chk("an llm agent with no declared structure is refused",
	RefusedBy(Edited(cBadLlm, "  structure:
    - field: topic
      type: string
", ""), "pia-proposes"))

chk("a structure the schema court itself refuses is refused HERE, at load",
	RefusedBy(Edited(cBadLlm, "      type: string", "      type: telepathy"), "pia-proposes"))

chk("'proposes' on a PI agent is refused -- a pi agent acts",
	RefusedBy(Edited(cPi, "kind: pi", "kind: pi
proposes:
  prompt: x"), "pia-proposes"))

# and the negative sibling for the whole scene: the good file has none of it
chk("...and the accepted declaration carries no findings at all",
	len(StzAgentDeclarationQ(cPi).Findings()) = 0)

# AND THE REFUSAL IS THE FAMILY'S, NOT A PRIVATE ONE: it goes straight
# into an stzRuleReport with no adapter, so a bad agent file stands in the
# same CI gate as a bad graph, a bad schema or a bad code rule.
oRep = StzRuleReportQ("agent-declarations")
oRep.Ingest(StzAgentDeclarationQ(Edited(cPi, "reversibility: compensable", "reversibility: maybe")).Findings())
aIngested = oRep.FindingsOfSubject("pi-agent-declaration")
chk("a refusal is ingested by stzRuleReport with no adapter", len(aIngested) = 1)

# a refused declaration REFUSES TO BECOME AN AGENT rather than half-becoming one
bRaised = 0
try
	StzAgentDeclarationQ(Edited(cPi, "reversibility: compensable", "reversibility: maybe")).ToAgent()
catch
	bRaised = 1
done
chk("a refused declaration will not build an agent at all", bRaised = 1)

? ""
#=====================================================================#
? "-- Scene 4: the folder is the deployment --"
#=====================================================================#

oF = StzAgentFolderQ("agents")
nRead = oF.ReadAgents()

chk("the folder admitted the valid files", nRead = 3)
chk("...both notations came through the same door",
	oF.NotationOf("kitchen-bot") = "pia" and oF.NotationOf("watcher") = "ring")
chk("...the Ring agent kept the schedule it declared for itself",
	oF.ScheduleOf("watcher")[:timer] = 25)

# ONE BAD FILE DOES NOT STOP THE FOLDER, AND IT DOES NOT VANISH EITHER
chk("the one bad file was refused", oF.NumberOfRefusedFiles() = 1)
chk("...and the refusal names the file it came from",
	len(StzFind("badverb.pia", oF.CiteRefusals())) > 0)
chk("...and the rule that produced it",
	len(StzFind("pia-clause", oF.CiteRefusals())) > 0)
chk("...while the agents that were fine are loaded", oF.Has("kitchen-bot") = 1)
chk("...and the refused one is NOT", oF.Has("broken") = 0)

? ""
#=====================================================================#
? "-- Scene 5: dropped in a folder, and running in the loop --"
#=====================================================================#
# The whole sentence, end to end, on an ordinary stzAgentHost.

oHost = new stzAgentHost()
nUp = oHost.UseAgentsFrom("agents")
chk("the host mounted what the folder admitted", nUp = 3)
chk("...and supervises them by name", oHost.IsSupervising("kitchen-bot") = 1)

# the refusal is visible FROM THE HOST -- a host that mounted three files
# out of four and said nothing is the shape this exists to prevent
chk("the host carries the folder's refusals", len(oHost.AgentLoadRefusals()) > 0)
chk("...printable, from the host itself",
	len(StzFind("badverb.pia", oHost.CiteAgentLoadRefusals())) > 0)

oHost.RunFor(120)
chk("the declared agent really ticked on the host's loop",
	oHost.TicksOf("kitchen-bot") > 0)
chk("...and so did the Ring-defined one", oHost.TicksOf("watcher") > 0)
chk("...through the ordinary Cycle(), with the declared effect applied",
	oHost.AgentQ("kitchen-bot").MemoryQ().Fact("stock", "level", "ordered") = 1)

chk("nothing on disk changed while it ran",
	oHost.AgentFolderQ().HasChanged() = 0)
oHost.Shutdown()

# AND THE SAME FOLDER ON THE ZIG LOOP, which is the harder gate: the
# engine REFUSES to schedule an agent that declares neither a coverage
# statement nor a reversibility class (law 18). A declared agent answers
# both FROM ITS FILE, so it registers with nothing added by hand -- the
# file satisfying the law is the whole point of the file.
StzResetEngineAgentLoop()
oZig = new stzAgentHost()
oZig.UseAgentsFrom("agents")
oZig.UseEngineLoop()
chk("the folder's agents are accepted by the engine loop",
	oZig.IsUsingEngineLoop() = 1)
oZig.RunFor(120)
chk("...and Zig schedules them on the schedule the files declared",
	oZig.TicksOf("kitchen-bot") > 0)
oZig.Shutdown()
StzResetEngineAgentLoop()

? ""
#=====================================================================#
? "-- Scene 6: a file appears, a file changes, a file vanishes --"
#=====================================================================#
# The second half of "dropped in a folder": the folder is read again, and
# what moved is REPORTED rather than discovered by accident. Change is
# judged by the file's CONTENT (a SHA-256), not by its modification time
# -- StzFileModifTime answers 0 in this build, so a time-based watch would
# say "nothing changed" forever, which is the quietest way to be broken.

cTmp = "agents/_rescan-probe.pia"
if fexists(cTmp)
	remove(cTmp)
ok

oHost2 = new stzAgentHost()
oHost2.UseAgentsFrom("agents")
nBefore = oHost2.NumberOfAgents()
chk("nothing has moved yet", oHost2.AgentFolderQ().HasChanged() = 0)

write(cTmp, "pia: 1
name: probe
kind: pi
coverage: exists to be noticed appearing and vanishing
reversibility: reversible
schedule:
  timer: 20
skills:
  - name: mark
    when: no-fact probe state seen
    does: learn probe state seen
    verify: fact probe state seen
")

chk("a new file is noticed", oHost2.AgentFolderQ().HasChanged() = 1)
aMoved = oHost2.RescanAgents()
chk("...and reported as ADDED", len(aMoved[:added]) = 1)
chk("...and the host now supervises it", oHost2.IsSupervising("probe") = 1)
chk("...alongside the ones it already had",
	oHost2.NumberOfAgents() = nBefore + 1)

oHost2.RunFor(80)
chk("...and it really ticks", oHost2.TicksOf("probe") > 0)

# a CHANGED file: reported, and the running agent is deliberately NOT
# swapped -- it has a memory, a trace and possibly obligations
write(cTmp, "pia: 1
name: probe
kind: pi
coverage: exists to be noticed appearing and vanishing, now reworded
reversibility: reversible
schedule:
  timer: 20
skills:
  - name: mark
    when: no-fact probe state seen
    does: learn probe state seen
    verify: fact probe state seen
")
aMoved2 = oHost2.RescanAgents()
chk("a changed file is reported as CHANGED", len(aMoved2[:changed]) = 1)
chk("...and the agent already running is not silently replaced",
	oHost2.NumberOfAgents() = nBefore + 1)

# a VANISHED file: the agent stops ticking. CANCELLED, never retired --
# retirement is earned, and a deleted file earns nothing.
remove(cTmp)
aMoved3 = oHost2.RescanAgents()
chk("a deleted file is reported as REMOVED", len(aMoved3[:removed]) = 1)
chk("...and its agent was CANCELLED", oHost2.IsActive("probe") = 0)
chk("...but not retired -- retirement is earned",
	oHost2.IsRetired("probe") = 0)
nWas = oHost2.TicksOf("probe")
oHost2.RunFor(80)
chk("...so it ticks no more", oHost2.TicksOf("probe") = nWas)
oHost2.Shutdown()

chk("the fixture folder is as it was found", fexists(cTmp) = 0)

? ""
#=====================================================================#
? "-- Scene 7: a proposer, and what it may NOT do --"
#=====================================================================#
# An llm agent PROPOSES. It writes a candidate into its own memory and
# holds no effectful capability -- structurally, not by convention.

cLlm = "pia: 1
name: summarizer
kind: llm
coverage: proposes a topic and a mood for whatever the inbox holds
reversibility: reversible
schedule:
  timer: 20
memory:
  - inbox holds hello-world
proposes:
  prompt: Summarize this text: {input}
  input: recall inbox holds
  into: summary
  budget: 2
  structure:
    - field: topic
      type: string
    - field: mood
      type: oneof
      choices: positive, negative
"
oLD = StzAgentDeclarationQ(cLlm)
chk("the proposer declaration is accepted", oLD.IsValid() = 1)

oProp = oLD.ToAgent()
chk("it is an llm actor to the graph's vocabulary", oProp.Kind() = "llm_actor")
chk("...whose effectful capability is EMPTY, by construction",
	oProp.HoldsEffectful() = 0)

# MODEL-FREE, and deliberately: what is under test is the declaration and
# the tick, not a model. The seeded answer is VALIDATED against the
# declared structure exactly as a generated one would be.
oProp.SeedProposal("hello-world", "topic: greeting" + char(10) + "mood: positive")
chk("one tick makes a proposal", oProp.Cycle() = 1)
chk("...and says what it did", len(StzFind("candidate, never an effect", oProp.WhyLastTick())) > 0)
chk("...landing the declared fields in memory, under the declared subject",
	len(oProp.MemoryQ().Recall("summary", "topic")) = 1 and
	oProp.MemoryQ().Fact("summary", "mood", "positive") = 1)

# a proposal that does NOT satisfy the declared structure lands NOTHING
oProp2 = StzAgentDeclarationQ(cLlm).ToAgent()
bSeeded = 1
try
	oProp2.SeedProposal("hello-world", "topic: greeting" + char(10) + "mood: ecstatic")
catch
	bSeeded = 0
done
chk("a proposal outside the declared enumeration is refused at the door",
	bSeeded = 0)
chk("...so nothing of it reached memory",
	len(oProp2.MemoryQ().Recall("summary", "mood")) = 0)

# and with nothing to read, a tick is honest about doing nothing
cNoInput = Edited(cLlm, "memory:
  - inbox holds hello-world
", "")
oQuiet = StzAgentDeclarationQ(cNoInput).ToAgent()
chk("a tick with no input proposes nothing", oQuiet.Cycle() = 0)
chk("...and says so rather than passing for quiet",
	len(StzFind("nothing to propose", oQuiet.WhyLastTick())) > 0)

? ""
#=====================================================================#
? "-- Scene 8: what a declaration CANNOT do --"
#=====================================================================#
# The line that must travel with everything above. A file that passes
# every gate declares a WELL-FORMED agent. Whether it is the RIGHT agent
# is not a question any format can answer.

cWrong = "pia: 1
name: confused-bot
kind: pi
coverage: claims to watch the freezer
reversibility: reversible
schedule:
  timer: 20
memory:
  - freezer state warm
skills:
  - name: fix
    when: fact freezer state warm
    does: learn freezer state warm
    verify: fact freezer state warm
"
oW = StzAgentDeclarationQ(cWrong)
chk("a skill whose action changes NOTHING passes every gate", oW.IsValid() = 1)
oWA = oW.ToAgent()
chk("...runs", oWA.Cycle() = 1)
chk("...verifies", len(StzFind("VERIFIED", oWA.Trace()[1][:why])) > 0)
chk("...and the freezer is still warm. STRUCTURE IS NOT CORRECTNESS.",
	oWA.MemoryQ().Fact("freezer", "state", "warm") = 1)

# and the second limit, reported rather than hidden. v2 added the
# execution posture (ruling 3.2); v1 is still read -- the migration
# state stzAgentDeclaration's header records -- so every declaration in
# this suite loads unchanged, and safeworld_narrated.ring is where the
# v2 vocabulary earns its own scenes.
chk("the version is a gate: the build writes v2 and still reads v1",
	StzPiaVersion() = 2 and ring_find(StzPiaKnownVersions(), "1") > 0)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

# THE HELPERS LIVE AFTER pf(). Ring runs a file's top-level code until the
# first `func`, so a helper defined at the top silently kills every scene
# below it -- the file runs, prints nothing, and exits 0.

func chk(cWhat, bCond)
	if bCond = 1
		nPass++
		? "  [OK] " + cWhat
	else
		nFail++
		? "  [FAIL] " + cWhat
	ok

# TRUE when this text is refused AND the refusal is the named rule. Both
# halves matter: a declaration refused for the wrong reason would pass a
# test that only asked whether it was refused.
func RefusedBy(cText, cRule)
	_o_ = StzAgentDeclarationQ(cText)
	if _o_.IsValid() = 1
		return 0
	ok
	if len(StzFind(cRule, _o_.CiteFindings())) > 0
		return 1
	ok
	return 0

# NOT named Swap(): stzFuncs.ring already defines one, and a second is a
# C22 "Function redefinition" that stops the file before any scene runs.
func Edited(cText, cOld, cNew)
	return StzReplace(cText, cOld, cNew)

# The clause vocabulary has a door for anything it cannot say: `ring:` names
# a Ring function, and it must EXIST at load -- scene 3 checks both halves,
# by naming one that does not and this one that does. It sits down here
# with the other helpers for the same reason they do.
func StockIsCritical(oMem)
	return oMem.Fact("stock", "level", "critical")
