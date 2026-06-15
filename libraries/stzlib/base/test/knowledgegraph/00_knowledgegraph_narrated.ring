load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzKnowledgeGraph -- a triple store
# (subject, predicate, object) with a pattern-query interface. Predicates
# are normalised to lowercase. Deterministic.

Scenario("Add and remove facts")
    Given("three animal facts")
    o = new stzKnowledgeGraph("Animals")
    o.AddFact("Dogs", :IsA, "Animals")
    o.AddFact("Dogs", :Eats, "Food")
    o.AddFact("Cats", :IsA, "Animals")
    Then("there are 3 facts", len(o.Facts()), 3)
    Then("facts store predicates lowercased", ListEq(o.Facts(), [ [ "Dogs", "isa", "Animals" ], [ "Dogs", "eats", "Food" ], [ "Cats", "isa", "Animals" ] ]), TRUE)
    When("one fact is removed")
    o.RemoveFact("Dogs", :Eats, "Food")
    Then("two facts remain", len(o.Facts()), 2)
EndScenario()

Scenario("Node existence")
    Given("a small graph")
    o = new stzKnowledgeGraph("G")
    o.AddFact("Dogs", :IsA, "Mammals")
    Then("a known subject exists", o.NodeExists("Dogs"), TRUE)
    Then("a known object exists", o.NodeExists("Mammals"), TRUE)
    Then("an unknown node does not", o.NodeExists("Fish"), FALSE)
EndScenario()

Scenario("Pattern queries")
    Given("two mammals and a diet fact")
    o = new stzKnowledgeGraph("G")
    o.AddFact("Dogs", :IsA, "Mammals")
    o.AddFact("Cats", :IsA, "Mammals")
    o.AddFact("Dogs", :Eats, "Food")
    Then("variable subject yields all mammals", ListEq(o.Query(["?x", :IsA, "Mammals"]), [ "Dogs", "Cats" ]), TRUE)
    Then("variable object yields the diet", ListEq(o.Query(["Dogs", :Eats, "?what"]), [ "Food" ]), TRUE)
    Then("a fully-bound query is an existence check (TRUE)", o.Query(["Dogs", :IsA, "Mammals"]), TRUE)
EndScenario()

Scenario("Predicates and relations of an entity")
    Given("facts about Dogs")
    o = new stzKnowledgeGraph("G")
    o.AddFact("Dogs", :IsA, "Mammals")
    o.AddFact("Dogs", :Eats, "Food")
    Then("Predicates lists Dogs' relations", ListEq(o.Predicates("Dogs"), [ "isa", "eats" ]), TRUE)
    Then("Relations pairs predicate with object", ListEq(o.Relations("Dogs"), [ [ "isa", "Mammals" ], [ "eats", "Food" ] ]), TRUE)
EndScenario()

Scenario("Entity lookup folds multibyte case")
    Given("a fact whose subject is an UPPERCASE accented entity")
    k = new stzKnowledgeGraph("K")
    k.AddFact("Caf" + KgUpE(), :Serves, "coffee")
    Then("Predicates of the lowercase accented form still match", ListEq(k.Predicates("caf" + KgLowE()), [ "serves" ]), TRUE)
EndScenario()

Summary()

func KgLowE
    return char(195) + char(169)

func KgUpE
    return char(195) + char(137)

func ListEq aA, aE
    if len(aA) != len(aE) return FALSE ok
    nLen = len(aA)
    for i = 1 to nLen
        if isList(aA[i]) and isList(aE[i])
            if NOT ListEq(aA[i], aE[i]) return FALSE ok
        else
            if aA[i] != aE[i] return FALSE ok
        ok
    next
    return TRUE
