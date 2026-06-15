load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzGraphQuery -- a fluent MATCH/Select
# query over a stzGraph. Deterministic. The graph is built outside any
# brace-block so the query stays in file scope.

Scenario("Match all nodes")
    Given("a social graph with 3 people and 1 company")
    g = BuildGraph()
    r = StzGraphQueryQ(g).MatchQ(:nodes).Select("*")
    Then("all 4 nodes are returned", len(r), 4)
    Then("the first node's id is alice", r[1]["node"][:id], "alice")
EndScenario()

Scenario("Match nodes by label")
    Given("the same graph")
    g = BuildGraph()
    Then("3 nodes are labeled Person", len( StzGraphQueryQ(g).MatchQ([ :nodes, :labeled = "Person" ]).Select("*") ), 3)
    Then("1 node is labeled Company", len( StzGraphQueryQ(g).MatchQ([ :nodes, :labeled = "Company" ]).Select("*") ), 1)
EndScenario()

Scenario("Match nodes by property")
    Given("the same graph")
    g = BuildGraph()
    Then("2 people are age 30", len( StzGraphQueryQ(g).MatchQ([ :nodes, :where = [ :age, "=", 30 ] ]).Select("*") ), 2)
    Then("1 person is age 25", len( StzGraphQueryQ(g).MatchQ([ :nodes, :where = [ :age, "=", 25 ] ]).Select("*") ), 1)
EndScenario()

Summary()

func BuildGraph()
    g = new stzGraph("social")
    g.AddNodeXTT("alice", "Person", [ :age = 30, :city = "Paris" ])
    g.AddNodeXTT("bob",   "Person", [ :age = 25, :city = "London" ])
    g.AddNodeXTT("carol", "Person", [ :age = 30, :city = "Paris" ])
    g.AddNodeXT("company_x", "Company")
    return g
