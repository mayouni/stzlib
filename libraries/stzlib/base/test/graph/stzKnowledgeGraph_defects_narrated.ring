load "../../stzBase.ring"
load "../_narrated.ring"
decimals(4)

# stzKnowledgeGraph (base/graph/stzKnowledgeGraph.ring) -- the two register rows, run on invented graphs whose
# answers were worked out by hand BEFORE the code was changed. Run from inside this folder:
#     ring stzKnowledgeGraph_defects_narrated.ring
#
# The register said: ValidateOntology returned 1 whatever the ontology held (the body was only "return 1"), and
# Explain raised error R14 because it called ApplyInference, which exists nowhere.
#
# THE RULES the guard holds the code to (read from what the class already does with a law):
#     unique       a subject bears AT MOST ONE object for the relation (Admit refuses the second)
#     symmetric    a relation fact "a r b" implies "b r a" (the world layer derives it)
#     transitive   "a r b" and "b r c" imply "a r c" (Prove follows the chain; here the direct fact is asked for)
#     a law that is none of those three is a warning; a relation the ontology declares and no fact uses is a warning
# An issue is [ :rule, :subject, :where, :severity, :message ] with :subject always "knowledge". A violated law is
# severity "error"; the two advisory kinds are "warning". ValidateOntology() is 1 when no issue is an error, else 0.
# Names are shown in lowercase, as the graph keeps its ids.
#
# THE TRANSITIVE CHECK is the composition of two facts: a relation is transitive exactly when no pair of facts
# a r b, b r c lacks a r c. A return to the start (c is a) asks nothing, so a cycle terminates and a self-loop is fine.
#
# EXPLAIN SMALL GRAPH, worked by hand. Facts in this order: Dog is-a Animal, Cat is-a Animal, Dog eats Meat,
# Animal lives-in Zoo. Entities in creation order dog, animal, cat, meat, zoo. Links (in + out): animal 3, dog 2,
# cat 1, meat 1, zoo 1. Predicates: is-a 2, eats 1, lives-in 1. Density 4 / (5 * 4) = 20 percent.
#
# Every positive carries a negative sibling. ASCII only on the console.

# --- 1. ValidateOntology on nothing and on a sound ontology -------------------------------------------
Scenario("an empty ontology is valid, with or without facts")
	oE = new stzKnowledgeGraph("e")
	When("nothing is declared and nothing is known")
	Then("ValidateOntology answers 1", oE.ValidateOntology(), 1)
	Then("the issues list is empty", len(oE.ValidateOntologyIssues()), 0)
	oE.AddFact("Dog", "is-a", "Animal")
	When("facts exist and no law is declared")
	Then("ValidateOntology still answers 1", oE.ValidateOntology(), 1)
	Then("NEGATIVE: a relation with no declared law raises no issue", len(oE.ValidateOntologyIssues()), 0)
EndScenario()

Scenario("a sound ontology is valid: every law holds")
	oS = new stzKnowledgeGraph("s")
	oS.ConstrainRelation("born-in", "unique")
	oS.ConstrainRelation("friend-of", "symmetric")
	oS.ConstrainRelation("ancestor-of", "transitive")
	oS.AddFact("Ann", "born-in", "Paris")
	oS.AddFact("Bob", "born-in", "Paris")
	oS.AddFact("A", "friend-of", "B")
	oS.AddFact("B", "friend-of", "A")
	oS.AddFact("X", "ancestor-of", "Y")
	oS.AddFact("Y", "ancestor-of", "Z")
	oS.AddFact("X", "ancestor-of", "Z")
	When("three laws are declared and all three hold")
	Then("ValidateOntology answers 1", oS.ValidateOntology(), 1)
	Then("no issue", len(oS.ValidateOntologyIssues()), 0)
	Then("ValidateOntology answers a number, not a text", isNumber(oS.ValidateOntology()), 1)
EndScenario()

# --- 2. unique ---------------------------------------------------------------------------------------
Scenario("unique: a subject with two objects is one error, named by subject, relation and objects")
	oU = new stzKnowledgeGraph("u")
	oU.ConstrainRelation("Born-In", "UNIQUE")
	oU.AddFact("Ann", "born-in", "Paris")
	oU.AddFact("Ann", "born-in", "Rome")
	oU.AddFact("Bob", "born-in", "Oslo")
	aI = oU.ValidateOntologyIssues()
	When("Ann is born in two places and Bob in one, with the law written in capitals")
	Then("exactly one issue", len(aI), 1)
	Then("the rule, subject, where, severity and message are as worked out",
		KgIssueIs(KgNth(aI, 1), "relation_unique", "ann", "error",
		"'ann' bears 'born-in' to 2 objects (paris, rome), and the relation is unique."), 1)
	Then("ValidateOntology answers 0", oU.ValidateOntology(), 0)
	Then("the issue holds exactly the five keys", len(KgNth(aI, 1)), 5)
	oU.RemoveFact("Ann", "born-in", "Rome")
	When("the second birthplace is removed")
	Then("NEGATIVE: the ontology is valid again", oU.ValidateOntology(), 1)
	Then("NEGATIVE: and the list is empty", len(oU.ValidateOntologyIssues()), 0)
EndScenario()

Scenario("unique: facts typed in another case of the predicate still count, and 5 objects list 5, then the rest")
	oU2 = new stzKnowledgeGraph("u2")
	oU2.ConstrainRelation("owns", "unique")
	oU2.AddFact("Zoe", "OWNS", "a")
	oU2.AddFact("Zoe", "Owns", "b")
	oU2.AddFact("Zoe", "owns", "c")
	oU2.AddFact("Zoe", "owns", "d")
	oU2.AddFact("Zoe", "owns", "e")
	oU2.AddFact("Zoe", "owns", "f")
	aI = oU2.ValidateOntologyIssues()
	When("Zoe owns six things, the predicate spelt three ways")
	Then("one issue, not one per spelling", len(aI), 1)
	Then("it lists the first five and counts the rest",
		KgIssueIs(KgNth(aI, 1), "relation_unique", "zoe", "error",
		"'zoe' bears 'owns' to 6 objects (a, b, c, d, e, and 1 more), and the relation is unique."), 1)
EndScenario()

# --- 3. symmetric ------------------------------------------------------------------------------------
Scenario("symmetric: a one-way fact is an error naming the reverse that is missing")
	oY = new stzKnowledgeGraph("y")
	oY.ConstrainRelation("friend-of", "symmetric")
	oY.AddFact("A", "friend-of", "B")
	oY.AddFact("B", "friend-of", "A")
	oY.AddFact("C", "friend-of", "D")
	oY.AddFact("G", "friend-of", "G")
	aI = oY.ValidateOntologyIssues()
	When("A and B are friends both ways, C names D alone, and G is a self-loop")
	Then("exactly one issue", len(aI), 1)
	Then("it is C's fact",
		KgIssueIs(KgNth(aI, 1), "relation_symmetric", "c", "error",
		"'c' friend-of 'd' has no reverse: 'd' friend-of 'c' is missing."), 1)
	Then("ValidateOntology answers 0", oY.ValidateOntology(), 0)
	oY.AddFact("D", "friend-of", "C")
	When("the reverse is added")
	Then("NEGATIVE: the ontology is valid again", oY.ValidateOntology(), 1)
EndScenario()

Scenario("symmetric: when the pair already carries another predicate the message says the reverse cannot be added")
	oY2 = new stzKnowledgeGraph("y2")
	oY2.ConstrainRelation("friend-of", "symmetric")
	oY2.AddFact("E", "friend-of", "F")
	oY2.AddFact("F", "rival-of", "E")
	aI = oY2.ValidateOntologyIssues()
	When("F already links E with another predicate")
	Then("one issue", len(aI), 1)
	Then("it says so",
		KgIssueIs(KgNth(aI, 1), "relation_symmetric", "e", "error",
		"'e' friend-of 'f' has no reverse: 'f' friend-of 'e' is missing, and the pair already links 'f' to 'e' with 'rival-of'."), 1)
EndScenario()

# --- 4. transitive -----------------------------------------------------------------------------------
Scenario("transitive: a missing link is an error, and adding it clears the error")
	oT = new stzKnowledgeGraph("t")
	oT.ConstrainRelation("ancestor-of", "transitive")
	oT.AddFact("X", "ancestor-of", "Y")
	oT.AddFact("Y", "ancestor-of", "Z")
	aI = oT.ValidateOntologyIssues()
	When("X is the ancestor of Y and Y of Z, and nothing links X to Z")
	Then("one issue", len(aI), 1)
	Then("it names the missing fact",
		KgIssueIs(KgNth(aI, 1), "relation_transitive", "x", "error",
		"'x' ancestor-of 'y' and 'y' ancestor-of 'z', so 'x' ancestor-of 'z' is missing."), 1)
	Then("ValidateOntology answers 0", oT.ValidateOntology(), 0)
	oT.AddFact("X", "ancestor-of", "Z")
	When("the link X to Z is added")
	Then("NEGATIVE: no issue is left", len(oT.ValidateOntologyIssues()), 0)
	Then("NEGATIVE: and the ontology is valid", oT.ValidateOntology(), 1)
EndScenario()

Scenario("transitive: a chain of four asks for two links, in the order of the facts")
	oC = new stzKnowledgeGraph("c")
	oC.ConstrainRelation("below", "transitive")
	oC.AddFact("a", "below", "b")
	oC.AddFact("b", "below", "c")
	oC.AddFact("c", "below", "d")
	aI = oC.ValidateOntologyIssues()
	When("a chain a b c d is declared with no shortcut")
	Then("two issues", len(aI), 2)
	Then("the first is a to c",
		KgIssueIs(KgNth(aI, 1), "relation_transitive", "a", "error",
		"'a' below 'b' and 'b' below 'c', so 'a' below 'c' is missing."), 1)
	Then("the second is b to d",
		KgIssueIs(KgNth(aI, 2), "relation_transitive", "b", "error",
		"'b' below 'c' and 'c' below 'd', so 'b' below 'd' is missing."), 1)
EndScenario()

Scenario("transitive: a cycle terminates, a self-loop is fine, a tail on a cycle asks for one link")
	oK = new stzKnowledgeGraph("k")
	oK.ConstrainRelation("next", "transitive")
	oK.AddFact("p", "next", "q")
	oK.AddFact("q", "next", "p")
	oK.AddFact("s", "next", "s")
	When("two nodes follow each other and a third follows itself")
	Then("terminates and finds nothing missing", len(oK.ValidateOntologyIssues()), 0)
	oK.AddFact("q", "next", "r")
	aI = oK.ValidateOntologyIssues()
	When("a tail r hangs off q")
	Then("exactly one link is missing: p to r", len(aI), 1)
	Then("it names p to r",
		KgIssueIs(KgNth(aI, 1), "relation_transitive", "p", "error",
		"'p' next 'q' and 'q' next 'r', so 'p' next 'r' is missing."), 1)
EndScenario()

# --- 5. advisory issues, ontology shapes, order --------------------------------------------------------
Scenario("a law that is not known and a relation nobody uses are warnings, and do not make the ontology invalid")
	oW = new stzKnowledgeGraph("w")
	oW.ConstrainRelation("likes", "reflexive")
	oW.ConstrainRelation("never-used", "unique")
	oW.AddFact("Ann", "likes", "Bob")
	aI = oW.ValidateOntologyIssues()
	When("likes declares an unknown law and never-used is declared and never used")
	Then("two issues", len(aI), 2)
	Then("the unknown law comes first, as the ontology does",
		KgIssueIs(KgNth(aI, 1), "law_unknown", "likes", "warning",
		"'likes' declares the law 'reflexive', which is none of unique, symmetric or transitive."), 1)
	Then("the unused relation next",
		KgIssueIs(KgNth(aI, 2), "relation_unused", "never-used", "warning",
		"'never-used' is declared in the ontology, and no fact uses it."), 1)
	Then("ValidateOntology answers 1: warnings advise", oW.ValidateOntology(), 1)
	Then("NEGATIVE: a warning is not an error", KgField(aI, 1, "severity") != "error", 1)
EndScenario()

Scenario("a property declared with a schema is not a law; it is only checked for use")
	oP = new stzKnowledgeGraph("p")
	oP.DefineProperty(:Age, [ :type = "number", :min = 0, :max = 150 ])
	aI = oP.ValidateOntologyIssues()
	When("Age is declared with type, min and max and no fact uses age")
	Then("one warning, no error, no crash", len(aI), 1)
	Then("it is the unused property",
		KgIssueIs(KgNth(aI, 1), "relation_unused", "age", "warning",
		"'age' is declared in the ontology, and no fact uses it."), 1)
	Then("ValidateOntology answers 1", oP.ValidateOntology(), 1)
	oP.AddFact("Zed", "age", "30")
	When("a fact uses age")
	Then("NEGATIVE: the warning is gone", len(oP.ValidateOntologyIssues()), 0)
EndScenario()

Scenario("issues come in the order of the ontology, then unique, symmetric, transitive, then the facts")
	oO = new stzKnowledgeGraph("o")
	oO.ConstrainRelation("below", "transitive")
	oO.ConstrainRelation("owns", "unique")
	oO.ConstrainRelation("owns", "symmetric")
	oO.AddFact("a", "below", "b")
	oO.AddFact("b", "below", "c")
	oO.AddFact("m", "owns", "x")
	oO.AddFact("m", "owns", "y")
	aI = oO.ValidateOntologyIssues()
	When("below is declared first, then owns with symmetric declared after unique")
	Then("below's issue is first", GqExact(KgField(aI, 1, "rule"), "relation_transitive"), 1)
	Then("then owns: unique before symmetric", GqExact(KgField(aI, 2, "rule"), "relation_unique"), 1)
	Then("then the two missing reverses of owns, in fact order", GqExact(KgField(aI, 3, "rule"), "relation_symmetric"), 1)
	Then("and the second", GqExact(KgField(aI, 4, "rule"), "relation_symmetric"), 1)
	Then("four issues in all", len(aI), 4)
	Then("the first reverse is m to x", KgIssueIs(KgNth(aI, 3), "relation_symmetric", "m", "error",
		"'m' owns 'x' has no reverse: 'x' owns 'm' is missing."), 1)
	Then("the second reverse is m to y", KgIssueIs(KgNth(aI, 4), "relation_symmetric", "m", "error",
		"'m' owns 'y' has no reverse: 'y' owns 'm' is missing."), 1)
	Then("NEGATIVE: ValidateOntology answers 0", oO.ValidateOntology(), 0)
	aJ = oO.ValidateOntologyIssues()
	Then("the same call twice gives the same list", GqExact(@@(aI), @@(aJ)), 1)
EndScenario()

Scenario("Hebrew names work in a law check, and the check does not change the graph")
	oH = new stzKnowledgeGraph("h")
	oH.ConstrainRelation("נולד-ב", "unique")
	oH.AddFact("אבא", "נולד-ב", "חיפה")
	oH.AddFact("אבא", "נולד-ב", "עכו")
	cBefore = KgSnap(oH)
	aI = oH.ValidateOntologyIssues()
	When("a Hebrew subject has two birthplaces")
	Then("one issue", len(aI), 1)
	Then("it names the Hebrew subject", GqExact(KgField(aI, 1, "where"), "אבא"), 1)
	Then("the graph is byte-identical afterwards", GqExact(cBefore, KgSnap(oH)), 1)
EndScenario()

# --- 6. Explain ------------------------------------------------------------------------------------
Scenario("Explain on an empty graph answers the sections, not an error")
	oX = new stzKnowledgeGraph("empty")
	cErr = ""
	aX = []
	try
		aX = oX.Explain()
	catch
		cErr = cCatchError
	done
	When("Explain is asked of a graph with nothing in it")
	Then("it raises nothing", GqExact(cErr, ""), 1)
	Then("the keys are the eight sections, in order", GqExact(@@(KgKeys(aX)),
		@@([ "type", "structure", "facts", "entities", "predicates", "ontology", "patterns", "insights" ])), 1)
	Then("the type", GqExact(aX[:type], "Knowledge Graph"), 1)
	Then("the structure", GqExact(aX[:structure], 'Knowledge graph "empty" contains 0 entities and 0 facts.'), 1)
	Then("the facts", KgListEq(aX[:facts], [ "No facts defined yet" ]), 1)
	Then("the entities", KgListEq(aX[:entities], [ "No entities yet" ]), 1)
	Then("the predicates", KgListEq(aX[:predicates], [ "No predicates yet" ]), 1)
	Then("the ontology", KgListEq(aX[:ontology], [ "No formal ontology defined" ]), 1)
	Then("no pattern", len(aX[:patterns]), 0)
	Then("no insight", len(aX[:insights]), 0)
EndScenario()

Scenario("Explain on a small graph gives the counts, the entities by links, the predicates by use")
	oZ = KgZoo()
	aX = KgExplain(oZ)
	When("the zoo has 5 entities, 4 facts, 3 predicates and no ontology")
	Then("the structure", GqExact(aX[:structure], 'Knowledge graph "zoo" contains 5 entities and 4 facts.'), 1)
	Then("every fact, as written", KgListEq(aX[:facts],
		[ "Dog is-a Animal", "Cat is-a Animal", "Dog eats Meat", "Animal lives-in Zoo" ]), 1)
	Then("entities sorted by links, then by name", KgListEq(aX[:entities], [
		"Animal: 3 links (2 in, 1 out)", "Dog: 2 links (0 in, 2 out)", "Cat: 1 link (0 in, 1 out)",
		"Meat: 1 link (1 in, 0 out)", "Zoo: 1 link (1 in, 0 out)" ]), 1)
	Then("predicates sorted by use, then by name", KgListEq(aX[:predicates],
		[ "is-a: 2 facts", "eats: 1 fact", "lives-in: 1 fact" ]), 1)
	Then("no ontology", KgListEq(aX[:ontology], [ "No formal ontology defined" ]), 1)
	Then("the patterns: density and cycles", KgListEq(aX[:patterns],
		[ "Graph is sparse (20% density)", "Acyclic structure (no cycles)" ]), 1)
	Then("the insights: the most connected entity", KgListEq(aX[:insights],
		[ "Most connected entity: Animal (3 links)" ]), 1)
	Then("NEGATIVE: it never mentions an inference", StzFindFirst("nference", @@(aX)) = 0, 1)
EndScenario()

Scenario("Explain reports the ontology, its issues, the unused relations and the cycles")
	oZ2 = KgZoo()
	oZ2.ConstrainRelation("is-a", "transitive")
	oZ2.ConstrainRelation("eats", "unique")
	oZ2.ConstrainRelation("flies-over", "symmetric")
	oZ2.AddFact("Cat", "eats", "Fish")
	oZ2.AddFact("Zoo", "part-of", "Dog")
	aX = KgExplain(oZ2)
	When("Cat eats Fish too, Zoo is part of Dog, and three laws are declared")
	Then("the ontology lists each property with its laws", KgListEq(aX[:ontology], [
		"Ontology declares 3 properties.", "is-a: transitive", "eats: unique", "flies-over: symmetric" ]), 1)
	Then("the cycle Dog Animal Zoo Dog is seen", GqExact(KgNth(aX[:patterns], 2), "Circular relationships found (cycles)"), 1)
	Then("the insights name the issues and the unused relation", KgListEq(aX[:insights], [
		"Most connected entity: Animal (3 links)",
		"Ontology: 0 errors, 1 warning",
		"'flies-over' is declared in the ontology, and no fact uses it." ]), 1)
	Then("NEGATIVE: the unique law holds, so no violation is named", StzFindFirst("bears", @@(aX)) = 0, 1)
EndScenario()

Scenario("Explain names a violated law among its insights")
	oZ3 = KgZoo()
	oZ3.ConstrainRelation("eats", "unique")
	oZ3.AddFact("Dog", "eats", "Bone")
	aX = KgExplain(oZ3)
	When("Dog eats two things under a unique law")
	Then("the insights count the error and show its message", KgListEq(aX[:insights], [
		"Most connected entity: Animal (3 links)",
		"Ontology: 1 error, 0 warnings",
		"'dog' bears 'eats' to 2 objects (meat, bone), and the relation is unique." ]), 1)
EndScenario()

Scenario("Explain is read-only: the graph, its ontology and its counts are byte-identical after")
	oRo = KgZoo()
	oRo.ConstrainRelation("is-a", "transitive")
	oRo.ConstrainRelation("eats", "unique")
	oRo.AddFact("Dog", "eats", "Bone")
	nN = oRo.NodeCount()
	nE = oRo.EdgeCount()
	nF = len(oRo.Facts())
	nO = len(oRo.Ontology())
	cBefore = KgSnap(oRo)
	aA = KgExplain(oRo)
	aB = KgExplain(oRo)
	When("Explain is called twice on a graph that carries a violated law")
	Then("the nodes are the same", oRo.NodeCount(), nN)
	Then("the edges are the same", oRo.EdgeCount(), nE)
	Then("the facts are the same", len(oRo.Facts()), nF)
	Then("the ontology is the same", len(oRo.Ontology()), nO)
	Then("the whole state is the same, byte for byte", GqExact(cBefore, KgSnap(oRo)), 1)
	Then("two calls give the same answer", GqExact(@@(aA), @@(aB)), 1)
	Then("NEGATIVE: no inferred fact was added (still 5 plus 1 facts)", nF, 5)
EndScenario()

Scenario("Explain with Hebrew and accented names sorts by links, then by the bytes of the lowercase name")
	oV = new stzKnowledgeGraph("mix")
	oV.AddFact("Élan", "mange", "Café")
	oV.AddFact("כלב", "אוכל", "עצם")
	oV.AddFact("Zed", "mange", "Café")
	aX = KgExplain(oV)
	When("five entities in three scripts; Café has two links, the others one")
	Then("the structure", GqExact(aX[:structure], 'Knowledge graph "mix" contains 5 entities and 3 facts.'), 1)
	Then("Café first, then z, é, the Hebrew in letter order", KgListEq(aX[:entities], [
		"Café: 2 links (2 in, 0 out)", "Zed: 1 link (0 in, 1 out)", "Élan: 1 link (0 in, 1 out)",
		"כלב: 1 link (0 in, 1 out)", "עצם: 1 link (1 in, 0 out)" ]), 1)
	Then("predicates: the Latin one is used twice", KgListEq(aX[:predicates],
		[ "mange: 2 facts", "אוכל: 1 fact" ]), 1)
EndScenario()

Scenario("Explain lists five facts and ten entities, and counts the rest")
	oL = new stzKnowledgeGraph("long")
	for kgI = 1 to 12
		oL.AddFact("n" + kgI, "next", "n" + (kgI + 1))
	next
	aX = KgExplain(oL)
	When("a chain of 12 facts over 13 entities")
	Then("five facts shown, then the count of the rest", len(aX[:facts]), 6)
	Then("the sixth line", GqExact(KgNth(aX[:facts], 6), "... and 7 more facts"), 1)
	Then("ten entities shown, then the count of the rest", len(aX[:entities]), 11)
	Then("the last line", GqExact(KgNth(aX[:entities], 11), "... and 3 more entities"), 1)
	Then("NEGATIVE: the first fact is the first one added", GqExact(KgNth(aX[:facts], 1), "n1 next n2"), 1)
EndScenario()

# --- 7. scale ------------------------------------------------------------------------------------
Scenario("2,001 facts validate and explain in a band measured on this machine")
	oB = new stzKnowledgeGraph("big")
	oB.ConstrainRelation("r0", "symmetric")
	oB.ConstrainRelation("r1", "unique")
	oB.ConstrainRelation("r2", "transitive")
	oB.ConstrainRelation("r4", "unique")
	for kgK = 0 to 4
		for kgI = 0 to 399
			oB.AddFact("e" + kgI, "r" + kgK, "e" + ((kgI + 1 + 80 * kgK) % 400))
		next
	next
	oB.AddFact("e0", "r4", "e5")
	When("400 entities, five relations of 400 facts each by a fixed step, plus one second r4 object for e0")
	Then("2001 facts", len(oB.Facts()), 2001)
	nT0 = StzEngineWatchTimestampMs()
	aI = oB.ValidateOntologyIssues()
	nT1 = StzEngineWatchTimestampMs()
	? "    (timing) ValidateOntologyIssues over 2001 facts: " + (nT1 - nT0) + " ms"
	Then("400 one-way r0 facts + 400 missing r2 links + 1 double r4 object = 801 issues", len(aI), 801)
	Then("ValidateOntology answers 0", oB.ValidateOntology(), 0)
	Then("within the band set from measurement", (nT1 - nT0) < KgBandValidateMs(), 1)
	nT0 = StzEngineWatchTimestampMs()
	aX = KgExplain(oB)
	nT1 = StzEngineWatchTimestampMs()
	? "    (timing) Explain over 2001 facts: " + (nT1 - nT0) + " ms"
	Then("Explain answers its eight sections", len(aX), 8)
	Then("the structure", GqExact(aX[:structure], 'Knowledge graph "big" contains 400 entities and 2001 facts.'), 1)
	Then("Explain is within the band set from measurement", (nT1 - nT0) < KgBandExplainMs(), 1)
EndScenario()

Scenario("a chain of 2000 facts asks for 1999 shortcuts, and a hub of 22500 gaps stops at the cap with a notice")
	oCh = new stzKnowledgeGraph("chain")
	oCh.ConstrainRelation("next", "transitive")
	for kgI = 0 to 1999
		oCh.AddFact("n" + kgI, "next", "n" + (kgI + 1))
	next
	nT0 = StzEngineWatchTimestampMs()
	aI = oCh.ValidateOntologyIssues()
	nT1 = StzEngineWatchTimestampMs()
	? "    (timing) 2000-fact chain: " + (nT1 - nT0) + " ms"
	When("n0 -> n1 -> ... -> n2000 under a transitive law")
	Then("1999 issues: every two facts in a row lack their shortcut", len(aI), 1999)
	Then("the first is n0 to n2", GqExact(KgField(aI, 1, "message"), "'n0' next 'n1' and 'n1' next 'n2', so 'n0' next 'n2' is missing."), 1)
	Then("the last is n1998 to n2000", GqExact(KgField(aI, 1999, "where"), "n1998"), 1)
	Then("within the band", (nT1 - nT0) < KgBandValidateMs(), 1)
	oHub = new stzKnowledgeGraph("hub")
	oHub.ConstrainRelation("via", "transitive")
	for kgI = 1 to 150
		oHub.AddFact("a" + kgI, "via", "hub")
		oHub.AddFact("hub", "via", "c" + kgI)
	next
	nT0 = StzEngineWatchTimestampMs()
	aI = oHub.ValidateOntologyIssues()
	nT1 = StzEngineWatchTimestampMs()
	? "    (timing) hub, 22500 gaps, capped: " + (nT1 - nT0) + " ms"
	When("150 facts into a hub and 150 out of it: 22500 shortcuts are missing")
	Then("10000 issues and one notice", len(aI), 10001)
	Then("the notice is last and says so",
		KgIssueIs(KgNth(aI, 10001), "relation_transitive", "via", "error",
		"more than 10000 links of 'via' are missing; the rest are not listed."), 1)
	Then("NEGATIVE: the 10000th is an ordinary issue about an entity, not the notice", GqExact(KgField(aI, 10000, "where"), "via"), 0)
	Then("within the band", (nT1 - nT0) < KgBandValidateMs(), 1)
EndScenario()

Scenario("the issues feed the house rule report: errors make it unsound, warnings do not")
	oF = new stzKnowledgeGraph("f")
	oF.ConstrainRelation("never-used", "unique")
	oRep = new stzRuleReport("kg")
	oRep.Ingest(oF.ValidateOntologyIssues())
	When("only a warning is ingested")
	Then("one finding", oRep.NumberOfFindings(), 1)
	Then("the report is sound", oRep.IsSound(), 1)
	oF.ConstrainRelation("owns", "unique")
	oF.AddFact("m", "owns", "x")
	oF.AddFact("m", "owns", "y")
	oRep2 = new stzRuleReport("kg2")
	oRep2.Ingest(oF.ValidateOntologyIssues())
	When("a broken unique law is ingested too")
	Then("two findings", oRep2.NumberOfFindings(), 2)
	Then("NEGATIVE: the report is unsound", oRep2.IsSound(), 0)
EndScenario()

Summary()

#------------------------------ helpers ------------------------------------------------------------------

# the zoo: five entities, four facts, in this order
func KgZoo()
	kgZ = new stzKnowledgeGraph("zoo")
	kgZ.AddFact("Dog", "is-a", "Animal")
	kgZ.AddFact("Cat", "is-a", "Animal")
	kgZ.AddFact("Dog", "eats", "Meat")
	kgZ.AddFact("Animal", "lives-in", "Zoo")
	return kgZ

# the n-th item of a list, or an empty list when there is none (so a missing issue fails an assertion
# instead of ending the run)
func KgNth(a, n)
	if isList(a) and len(a) >= n
		return a[n]
	ok
	return []

# the value under cKey of the n-th hash list, or an empty list when there is none
func KgField(a, n, cKey)
	kgItem = KgNth(a, n)
	if isList(kgItem) and len(kgItem) > 0 and HasKey(kgItem, cKey)
		return kgItem[cKey]
	ok
	return []

# Explain, with a raised error turned into a one-line answer so the assertions can fail
func KgExplain(o)
	try
		return o.Explain()
	catch
		return [ :type = "RAISED", :structure = "RAISED " + cCatchError, :facts = [], :entities = [],
			:predicates = [], :ontology = [], :patterns = [], :insights = [] ]
	done

# 1 when the two texts are the same bytes (Ring's = folds case, strcmp stops at NUL)
func GqExact(a, b)
	if NOT (isString(a) and isString(b))
		return 0
	ok
	if len(a) != len(b)
		return 0
	ok
	return strcmp(a, b) = 0

# 1 when the issue has the subject knowledge and exactly this rule, where, severity and message
func KgIssueIs(aIssue, cRule, cWhere, cSev, cMsg)
	if NOT isList(aIssue)
		return 0
	ok
	if NOT (HasKey(aIssue, :rule) and HasKey(aIssue, :subject) and HasKey(aIssue, :where) and
	        HasKey(aIssue, :severity) and HasKey(aIssue, :message))
		return 0
	ok
	if GqExact(aIssue[:subject], "knowledge") = 0
		return 0
	ok
	if GqExact(aIssue[:rule], cRule) = 0
		return 0
	ok
	if GqExact(aIssue[:where], cWhere) = 0
		return 0
	ok
	if GqExact(aIssue[:severity], cSev) = 0
		return 0
	ok
	return GqExact(aIssue[:message], cMsg)

# 1 when two lists of texts are the same, element by element, byte for byte
func KgListEq(a, b)
	if NOT (isList(a) and isList(b))
		return 0
	ok
	if len(a) != len(b)
		return 0
	ok
	for kgJ = 1 to len(a)
		if GqExact(a[kgJ], b[kgJ]) = 0
			return 0
		ok
	next
	return 1

# the keys of a hash list, in order
func KgKeys(aH)
	kgR = []
	for kgJ = 1 to len(aH)
		kgR + aH[kgJ][1]
	next
	return kgR

# everything observable about a graph, as one text
func KgSnap(o)
	return o.ExportToKnow() + "#" + @@(o.Nodes()) + "#" + @@(o.Edges()) + "#" + @@(o.Ontology()) + "#" +
		@@(o.Contradictions()) + "#" + @@(o.FactMeta())

# bands, set from the measurement: ValidateOntologyIssues took 35 ms and Explain 108 ms over 2001 facts on the
# first run, so these allow 50 and 28 times that on a loaded machine
func KgBandValidateMs()
	return 2000

func KgBandExplainMs()
	return 3000
