# R2 (slice 1) ACCEPTANCE -- meta/: structure as a graph + runnable rules
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md, roadmap R2)
#
# Scene 1: stzCodeGraph -- the library's own structure becomes queryable
#          (nodes/edges from SOURCE TRUTH, not flat records).
# Scene 2: impact + cascade -- "what you read instead of the diff".
# Scene 3: the MACHINE DOOR -- house rules as validators an agent RUNS.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

#== SCENE 1 -- the structure graph =======================================

? "-- Scene 1: the graph/ module, read as structure --"

oCG = new stzRingCodeGraph("D:/GitHub/stzlib/libraries/stzlib/base/graph")
aStats = oCG.Stats()
? "  classes: " + aStats[:classes] + "  methods: " + aStats[:methods] +
  "  inherits-edges: " + aStats[:inheritsEdges] + "  call-edges: " + aStats[:callEdges]

chk("the scanner finds a real population", aStats[:classes] >= 30)
chk("methods are attributed to their classes", aStats[:methods] >= 1000)
chk("stzKnowledgeGraph descends from stzGraph",
	ring_find(oCG.SubclassesOf("stzGraph"), "stzKnowledgeGraph") > 0)
chk("ancestry walks to the shared root",
	ring_find(oCG.AncestryOf("stzKnowledgeGraph"), "stzObject") > 0)
chk("ownership is structural, not prose",
	ring_find(oCG.OwnersOf("AddFact"), "stzKnowledgeGraph") > 0)

#== SCENE 2 -- impact and cascade ========================================

? ""
? "-- Scene 2: impact + cascade (the review artifacts) --"

aImp = oCG.ImpactOf("AddFact")
? "  ImpactOf(AddFact): owners " + @@(aImp[:owners]) +
  " / inherited by " + @@(aImp[:inheritedBy])
chk("impact names the owners", len(aImp[:owners]) >= 1)

aCas = oCG.Cascade("stzGraph")
? "  Cascade(stzGraph): " + aCas[:methodsTouched] + " methods, blast radius " +
  aCas[:blastRadius] + " (" + @@(aCas[:descendants]) + ")"
chk("cascade computes the blast radius BEFORE any change",
	aCas[:blastRadius] >= 3)

#-- CALL edges (name-based, from body parsing) --------------------------

? ""
? "-- Scene 2b: the CALL graph (who calls whom) --"

chk("call edges were extracted from method bodies", aStats[:callEdges] >= 200)

aCallers = oCG.CallersOf("AddFact")
? "  CallersOf(AddFact): " + @@(aCallers)
chk("CallersOf finds the real callers of a method", len(aCallers) >= 1)
chk("callers are STRUCTURED (class + method)",
	isList(aCallers[1]) and aCallers[1][:class] != "" and aCallers[1][:method] != "")

aDead = oCG.DeadCode()
? "  DeadCode (private helpers referenced by nothing): " + len(aDead)
chk("DeadCode() now ANSWERS (call edges landed -- no longer refuses)", isList(aDead))
chk("dead-code findings are structured (class/method/file/line)",
	len(aDead) = 0 or (aDead[1][:method] != "" and aDead[1][:line] > 0))
chk("DeadCode is scoped to PRIVATE helpers (name starts '_')",
	len(aDead) = 0 or StzLeft(aDead[1][:method], 1) = "_")

aCyc = oCG.CyclicCalls()
? "  CyclicCalls (intra-class mutual recursion): " + len(aCyc)
chk("CyclicCalls() now ANSWERS", isList(aCyc))
chk("each cycle is a 2-method pair in one class",
	len(aCyc) = 0 or (len(aCyc[1][:cycle]) = 2 and aCyc[1][:class] != ""))

#== SCENE 3 -- the machine door ==========================================

? ""
? "-- Scene 3: house rules an agent can RUN (LAW 6) --"

cBad = 'class Foo' + nl +
	'def Len()' + nl + '	return 5' + nl +
	'def BarQ()' + nl + '	return 42' + nl +
	'def KillProcess()' + nl + '	return' + nl

aF = StzCheckCode(cBad)
? "  planted-bad findings:"
n = len(aF)
for i = 1 to n
	? "    " + aF[i][:rule] + " @line " + aF[i][:line] + " [" + aF[i][:severity] + "]"
next

chk("no-len-method fires", _HasRule(aF, "no-len-method"))
chk("q-returns-object fires (Q must chain)", _HasRule(aF, "q-returns-object"))
chk("no-aggressive-verbs fires", _HasRule(aF, "no-aggressive-verbs"))
chk("the dirty source is refused", StzCodeIsClean(cBad) = FALSE)

cGood = 'class Foo' + nl + 'def BazQ()' + nl + '	return This' + nl
chk("clean source passes", StzCodeIsClean(cGood) = TRUE)
chk("findings are STRUCTURED (rule/line/severity/message)",
	aF[1][:message] != "" and aF[1][:line] > 0)

#== SCENE 4 -- governance invariants over a colored agent graph =========

? ""
? "-- Scene 4: the G2 seed -- graph predicates an agent RUNS --"

oAG = new stzGraph("agents")
oAG.AddNode("writer")
oAG.SetNodeProperty("writer", "kind", "llm_actor")
oAG.SetNodeProperty("writer", "capabilities", ["inference", "effectful"])
oAG.SetNodeProperty("writer", "taint", "open_llm_text")
oAG.AddNode("send_email")
oAG.SetNodeProperty("send_email", "kind", "effect")
oAG.AddEdgeXTT("writer", "send_email", "proposes", [])

aV = StzCheckAgentGraph(oAG)
? "  violations on the ungoverned graph: " + len(aV)
chk("all four invariants fire on the bad graph", len(aV) = 4)

oAG.SetNodeProperty("writer", "capabilities", ["inference"])
oAG.AddNode("gate")
oAG.SetNodeProperty("gate", "kind", "guardian")
oAG.AddNode("audit")
oAG.SetNodeProperty("audit", "kind", "trace_sink")
oAG.AddEdgeXTT("gate", "send_email", "guards", [])
oAG.AddEdgeXTT("send_email", "audit", "traces", [])
oAG.RemoveThisEdge("writer", "send_email")
oAG.AddEdgeXTT("writer", "gate", "proposes", [])

chk("governed composition is SOUND (proposes -> gate -> effect -> trace)",
	StzAgentGraphIsSound(oAG) = TRUE)

#== SCENE 5 -- the signable predicate set (the constitution mechanism) ==

? ""
? "-- Scene 5: G10 -- declared, diffable, SEALED predicate sets --"

oPS = new stzPredicateSet("house")
oPS.AddRule("no-len-method")
oPS.AddInvariant("no-llm-effectful")
cRulesFile = oPS.Save("t_house_accept")

oPS2 = StzLoadPredicateSet(cRulesFile)
chk("the loaded set verifies its seal", oPS2.Verify() = TRUE)
chk("the set enforces ONLY its own rules",
	len(oPS2.EnforceOnCode("class F" + nl + "def Len()" + nl + "return 1")) = 1)

cT = read(cRulesFile)
write(cRulesFile, StzReplace(cT, "no-len-method", "q-returns-object"))
oPS3 = StzLoadPredicateSet(cRulesFile)
chk("a tampered set BREAKS its seal", oPS3.Verify() = FALSE)
remove(cRulesFile)

#== SCENE 6 -- the promoted self-doc still answers, structured ==========

? ""
? "-- Scene 6: meta/ owns the self-doc (promoted from reflect/) --"

oDoc = StzLibDocQ([ "stzString" ])
aAns = oDoc.Ask("uppercase")
chk("Ask answers after the promotion", len(aAns) >= 1)
chk("and the answers are STRUCTURED records (the machine door reads them)",
	isList(aAns[1]) and len(aAns[1]) >= 3)

#== SUMMARY ==============================================================

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func _HasRule(paFindings, pcRule)
	_n_ = len(paFindings)
	for _i_ = 1 to _n_
		if paFindings[_i_][:rule] = pcRule
			return 1
		ok
	next
	return 0
