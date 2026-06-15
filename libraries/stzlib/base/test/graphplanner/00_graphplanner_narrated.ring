load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzGraphPlanner -- A* shortest-path
# planning over a stzGraph (WalkFrom/Minimizing/Execute -> Cost/Route).
# Deterministic. Node ids are returned lowercased.

Scenario("Shortest path on a linear graph")
    Given("A --10-- B --10-- C")
    o = LinearPlan()
    Then("the total cost is 20", o.Cost(), 20)
    Then("the route is a -> b -> c", ListEq(o.Route(), [ "a", "b", "c" ]), TRUE)
EndScenario()

Scenario("A* picks the cheaper branch")
    Given("A->B->D costs 10 while A->C->D costs 21")
    o = DiamondPlan()
    Then("Cost is the cheaper 10 (not 21)", o.Cost(), 10)
    Then("Route goes through B, not C", ListEq(o.Route(), [ "a", "b", "d" ]), TRUE)
EndScenario()

Scenario("Engine A* still populates explainability data")
    Given("the diamond plan (A->B->D over A->C->D)")
    o = DiamondPlan()
    aWhy = o.Why("cost")
    Then("nodes_explored counts the engine's closed set (4: a,c,b,d)", aWhy[:nodes_explored], 4)
    Then("the explained route matches the optimal a-b-d", ListEq(aWhy[:route], [ "a", "b", "d" ]), TRUE)
    aEff = o.Efficiency()
    Then("efficiency path_length is 3", aEff[:path_length], 3)
EndScenario()

Summary()

func LinearPlan()
    g = new stzGraph("linear")
    g.AddNodeXTT("A", "Start", [ :x = 0,  :y = 0 ])
    g.AddNodeXTT("B", "Mid",   [ :x = 10, :y = 0 ])
    g.AddNodeXTT("C", "End",   [ :x = 20, :y = 0 ])
    g.AddEdgeXTT("A", "B", "road", [ :distance = 10 ])
    g.AddEdgeXTT("B", "C", "road", [ :distance = 10 ])
    p = new stzGraphPlanner(g)
    p.AddPlan("linear_path")
    p.WalkFrom("A", :To = "C")
    p.Minimizing("distance")
    p.Execute()
    return p

func DiamondPlan()
    g = new stzGraph("diamond")
    g.AddNodeXTT("A", "A", [ :x = 0,  :y = 0 ])
    g.AddNodeXTT("B", "B", [ :x = 5,  :y = 0 ])
    g.AddNodeXTT("C", "C", [ :x = 5,  :y = 5 ])
    g.AddNodeXTT("D", "D", [ :x = 10, :y = 0 ])
    g.AddEdgeXTT("A", "B", "r", [ :distance = 5 ])
    g.AddEdgeXTT("B", "D", "r", [ :distance = 5 ])
    g.AddEdgeXTT("A", "C", "r", [ :distance = 1 ])
    g.AddEdgeXTT("C", "D", "r", [ :distance = 20 ])
    p = new stzGraphPlanner(g)
    p.AddPlan("p1")
    p.WalkFrom("A", :To = "D")
    p.Minimizing("distance")
    p.Execute()
    return p

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
