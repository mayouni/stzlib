# R1 ACCEPTANCE -- the north star in miniature
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 0.1 + roadmap R1)
#
# A domain KNOWLEDGEBASE (.stzknow: facts + laws) loads, answers
# WhatIs/AreRelated, PROVES its answers with a structured trace, and --
# the decisive property -- a fact added through ANY door fires the
# derivation rules: intelligence augmented with ZERO code change.
#
# The domain: a small restaurant (the capstone's world, day one).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

#== SCENE 1 -- the world is authored through the natural sugar =========

? "-- Scene 1: authoring the restaurant's knowledge --"

StzKnow("margherita", "dish")
StzKnow("tomato", "ingredient")
StzKnow("mozzarella", "ingredient")
StzKnow("luigi", "chef")

StzConstrainRelation("contains", :Transitive)
StzConstrainRelation("pairs-with", :Symmetric)
StzConstrainRelation("run-by", :Unique)

StzKnowRelation("margherita", "contains", "tomato-sauce")
StzKnowRelation("tomato-sauce", "contains", "tomato")
StzKnowRelation("margherita", "pairs-with", "chianti")
StzKnowRelation("kitchen", "run-by", "luigi")

chk("the world answers WhatIs", WhatIs("margherita")[1] = "dish")
chk("the KG grew alongside (dual-write)",
	len(DefaultKnowledgeGraph().Facts()) >= 8)
chk("the law lives in the KG ontology",
	DefaultKnowledgeGraph().RelationHasLaw("contains", "transitive"))

#== SCENE 2 -- answers are PROVED, not asserted ==========================

? ""
? "-- Scene 2: Prove() -- the structured derivation trace --"

aProof = StzProve([ "margherita", "contains", "tomato" ])
? "  goal:      margherita contains tomato ?"
? "  verdict:   " + aProof[:verdict]
? "  narration: " + aProof[:narration]
nSteps = len(aProof[:steps])
for i = 1 to nSteps
	? "  step " + i + ":    " + aProof[:steps][i][:narration]
next

chk("the transitive goal is PROVED", aProof[:verdict] = TRUE)
chk("the proof narrates the law first",
	aProof[:steps][1][:kind] = "law")
chk("the proof chains the recorded facts",
	aProof[:steps][2][:kind] = "chain-link" and nSteps = 3)
chk("a certain verdict (deterministic)", aProof[:certainty] = 1)

aNo = StzProve([ "margherita", "contains", "luigi" ])
chk("an unprovable goal REFUSES with reasons",
	aNo[:verdict] = FALSE and aNo[:certainty] = 1)

#== SCENE 3 -- the knowledgebase persists and RELOADS whole =============

? ""
? "-- Scene 3: one file IS the brain (.stzknow round-trip) --"

StzSaveKnowledgeBase("restaurant_accept")
ForgetRelations()
chk("after forgetting, the relation is gone",
	AreRelated("margherita", "tomato") = "")

nAbsorbed = StzLoadKnowledgeBase("restaurant_accept.stzknow")
? "  facts absorbed from the file: " + nAbsorbed

chk("the file re-hydrated the facts", nAbsorbed >= 8)
chk("AreRelated answers again (direct)",
	AreRelated("margherita", "chianti") = "pairs-with")
chk("AreRelated walks the lawful chain again",
	AreRelated("margherita", "tomato") = "contains")
chk("the LAWS travelled inside the file",
	DefaultKnowledgeGraph().RelationHasLaw("pairs-with", "symmetric"))

#== SCENE 4 -- a fact through ANOTHER door augments the system ==========

? ""
? "-- Scene 4: derivation -- knowledge added by any door grows the brain --"

# an agent-door write: straight into the graph, bypassing the sugar
DefaultKnowledgeGraph().AddFact("tiramisu", "pairs-with", "espresso")
nDerived = StzApplyKnowledgeDerivations()
? "  derived edges after the agent's fact: " + nDerived

chk("the symmetric law DERIVED the reverse edge", nDerived >= 1)
chk("the derived fact is visible to the natural surface",
	AreRelated("espresso", "tiramisu") = "pairs-with")

#== SCENE 5 -- strict mode: expression free, admission governed =========

? ""
? "-- Scene 5: strict mode (G8 seed) --"

oKG = DefaultKnowledgeGraph()
oKG.EnableStrictMode()

bOk = oKG.AddFactXT("kitchen2", "run-by", "mario",
	[ :source = "owner-interview", :confidence = 0.95 ])
chk("a provenanced fact is admitted", bOk = 1)

bRefused = 0
try
	oKG.AddFact("naked", "fact", "here")
catch
	bRefused = 1
done
chk("a naked fact is refused in strict mode", bRefused = 1)

bContra = oKG.AddFactXT("kitchen2", "run-by", "giovanni",
	[ :source = "rumor", :confidence = 0.4 ])
chk("a :Unique contradiction is refused...", bContra = 0)
chk("...and RECORDED, never silently resolved",
	len(oKG.Contradictions()) = 1)

oKG.DisableStrictMode()

#== SUMMARY ==============================================================

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

remove("restaurant_accept.stzknow")

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
