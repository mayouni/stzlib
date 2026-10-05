load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-PROVENANCE-SAVE-01 -- HaroBase rung 1: provenance survives a save.
#
# A knowledge graph records, per fact, WHERE it came from (:source) and
# HOW SURE its giver was (:confidence), and it records every contradiction
# it refused. ExportToKnow wrote only the bare triples, so all of that was
# lost the moment a graph was saved: knowledge read back from disk no
# longer said where it came from, a refused contradiction was forgotten,
# and a STRICT graph could not even re-load its own file. An agent's
# memory recorded no provenance at all.
#
# Now the .zknw file carries two more sections (provenance,
# contradictions) with every field escaped, the parser and the merge carry
# them back, and stzAgentMemory.Learn records which agent learned a fact
# and when.

$cFile = "_tmp_prov_kb"

# =====================================================================
#  SAVE, THEN READ BACK (the first three run against the old code too)
# =====================================================================

Scenario("a fact's source and confidence survive a save")
	oKB = new stzKnowledgeGraph("clinic")
	oKB.AddFactXT("aspirin", "treats", "headache", [ :source = "who-2024", :confidence = 0.9 ])
	oKB.WriteToKnowFile($cFile)
	oBack = new stzKnowledgeGraph("clinic")
	oBack.ImportKnow($cFile + ".zknw")
	aMeta = oBack.FactMeta()
	# before: the file held the bare triple -- FactMeta() came back empty
	Then("the fact came back", len(oBack.Facts()), 1)
	Then("its provenance came back with it", len(aMeta), 1)
	if len(aMeta) = 1
		Then("the source is the one recorded", aMeta[1][:meta][:source], "who-2024")
		Then("the confidence is a NUMBER, 0.9", aMeta[1][:meta][:confidence], 0.9)
	ok
EndScenario()

Scenario("a STRICT graph can load its own export")
	oS = new stzKnowledgeGraph("strict")
	oS.EnableStrictMode()
	oS.AddFactXT("paris", "capitalof", "france", [ :source = "atlas", :confidence = 1 ])
	oS.WriteToKnowFile($cFile)
	oS2 = new stzKnowledgeGraph("strict")
	oS2.EnableStrictMode()
	bRaised = 0
	try
		oS2.ImportKnow($cFile + ".zknw")
	catch
		bRaised = 1
	done
	# before: the merge re-added facts WITHOUT provenance, which strict
	# mode refuses by raising -- the graph could not read its own file
	Then("the import does not raise", bRaised, 0)
	Then("the fact is there", len(oS2.Facts()), 1)
EndScenario()

Scenario("a refused contradiction is remembered across a save")
	oS = new stzKnowledgeGraph("geo")
	oS.EnableStrictMode()
	oS.DefineProperty("capitalof", [ "unique" ])
	oS.AddFactXT("lyon", "capitalof", "france", [ :source = "atlas", :confidence = 1 ])
	oS.AddFactXT("lyon", "capitalof", "italy", [ :source = "rumour", :confidence = 0.1 ])
	Then("the second fact was refused and recorded", len(oS.Contradictions()), 1)
	oS.WriteToKnowFile($cFile)
	oBack = new stzKnowledgeGraph("geo")
	oBack.ImportKnow($cFile + ".zknw")
	# before: the contradiction lived in memory only
	Then("the contradiction came back", len(oBack.Contradictions()), 1)
	if len(oBack.Contradictions()) = 1
		Then("with who attempted what", oBack.Contradictions()[1][:attempted] + "/" +
			oBack.Contradictions()[1][:source], "italy/rumour")
	ok
EndScenario()

# =====================================================================
#  WHAT THE NEW FORMAT PROMISES
# =====================================================================

Scenario("a | and a line break inside a value are data, not separators")
	cSrc = "report | page 3" + char(10) + "second line"
	oKB = new stzKnowledgeGraph("tricky")
	oKB.AddFactXT("x", "means", "a|b", [ :source = cSrc, :confidence = 0.5 ])
	oKB.WriteToKnowFile($cFile)
	oBack = new stzKnowledgeGraph("tricky")
	oBack.ImportKnow($cFile + ".zknw")
	Then("the object with a | came back whole", oBack.Facts()[1][3], "a|b")
	Then("the source with | and a newline came back byte for byte",
		oBack.MetaOfFact("x", "means", "a|b")[:source] = cSrc, 1)
	Then("the escaping round-trips a backslash too",
		StzKnowUnescape(StzKnowEscape("C:" + char(92) + "p|" + char(92) + "n")), "C:" + char(92) + "p|" + char(92) + "n")
EndScenario()

Scenario("a strict graph REFUSES unproven facts on merge, and says which")
	cOld = 'knowledge "legacy"' + char(10) + char(10) + "facts" + char(10) +
		"    sun | is | star" + char(10)
	write($cFile + ".zknw", cOld)
	oS = new stzKnowledgeGraph("legacy")
	oS.EnableStrictMode()
	aR = oS.ImportKnow($cFile + ".zknw")
	Then("nothing unproven was admitted", len(oS.Facts()), 0)
	Then("the refusal is reported, not silent", len(aR[:refused]), 1)
	Then("and it says why", aR[:refused][1][4], "strict mode: no provenance")
EndScenario()

Scenario("an old file with no provenance still loads (negative sibling)")
	oN = new stzKnowledgeGraph("legacy")
	aR = oN.ImportKnow($cFile + ".zknw")
	Then("the fact loads into a non-strict graph", len(oN.Facts()), 1)
	Then("and the report counts it", aR[:merged], 1)
EndScenario()

# =====================================================================
#  AN AGENT'S MEMORY
# =====================================================================

Scenario("an agent's memory records who learned a fact, and when")
	nBefore = StzEngineTimeNowMs()
	oMem = new stzAgentMemory("waiter")
	oMem.Learn("table-4", "wants", "water")
	aP = oMem.ProvenanceOf("table-4", "wants", "water")
	Then("the source is the agent", aP[:source], "agent:waiter")
	Then("the time is recorded", aP[:learnedat] >= nBefore, 1)
	oMem.LearnXT("table-5", "wants", "wine", [ :source = "order-slip", :confidence = 0.7 ])
	Then("a caller's own source is kept", oMem.ProvenanceOf("table-5", "wants", "wine")[:source], "order-slip")
	When("the memory is saved and restored into a new agent")
	oMem.Save($cFile)
	oMem2 = new stzAgentMemory("waiter")
	oMem2.Restore($cFile + ".zknw")
	Then("the facts came back", oMem2.NumberOfFacts(), 2)
	Then("and still say who learned them",
		oMem2.ProvenanceOf("table-4", "wants", "water")[:source], "agent:waiter")
	Then("and how sure the slip was", oMem2.ProvenanceOf("table-5", "wants", "wine")[:confidence], 0.7)
EndScenario()

remove($cFile + ".zknw")

Summary()
