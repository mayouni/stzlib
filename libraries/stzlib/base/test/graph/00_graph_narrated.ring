load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzGraph -- engine-backed directed
# graph: nodes/edges, neighbors, shortest path, connectivity. Node ids are
# StzLower-normalised. Deterministic.
#
# Regression guard: Neighbors()'s pure-Ring fallback compared the raw arg
# against lowercased edge endpoints, so Neighbors("A") found nothing while
# Neighbors("a") worked; fixed to lowercase the query.

Scenario("The Zig graph engine is the active backend")
    Given("a stzGraph")
    g = Gr()
    Then("the engine backend is available + active", g._EnsureEngine(), TRUE)
EndScenario()

Scenario("Nodes and edges")
    Given("A->B, B->C, A->D over 4 nodes")
    g = Gr()
    Then("NumberOfNodes is 4", g.NumberOfNodes(), 4)
    Then("NumberOfEdges is 3", g.NumberOfEdges(), 3)
    Then("NodesIds are lowercased", ListEq(g.NodesIds(), [ "a", "b", "c", "d" ]), TRUE)
EndScenario()

Scenario("Neighbors (case-insensitive on the query)")
    Given("the same graph")
    g = Gr()
    Then("Neighbors('a') are b and d", ListEq(g.Neighbors("a"), [ "b", "d" ]), TRUE)
    Then("Neighbors('A') works too (case-insensitive)", ListEq(g.Neighbors("A"), [ "b", "d" ]), TRUE)
    Then("Neighbors('c') is empty (sink)", ListEq(g.Neighbors("c"), [ ]), TRUE)
EndScenario()

Scenario("Shortest path and connectivity")
    Given("the same graph")
    g = Gr()
    Then("ShortestPath A->C is a-b-c", ListEq(g.ShortestPath("A", "C"), [ "a", "b", "c" ]), TRUE)
    Then("the graph is connected", g.IsConnected(), TRUE)
    Then("there is a single connected component of all 4 nodes", ListEq(g.ConnectedComponents(), [ [ "a", "b", "c", "d" ] ]), TRUE)
EndScenario()

Scenario("Engine traversal orders")
    Given("A->B, A->C, B->D")
    g = new stzGraph("g")
    g.AddNode("A") g.AddNode("B") g.AddNode("C") g.AddNode("D")
    g.AddEdge("A", "B") g.AddEdge("A", "C") g.AddEdge("B", "D")
    Then("BFS visits level by level: a,b,c,d", ListEq(g.BFS("A"), [ "a", "b", "c", "d" ]), TRUE)
    Then("DFS goes deep first: a,b,d,c", ListEq(g.DFS("A"), [ "a", "b", "d", "c" ]), TRUE)
EndScenario()

Scenario("Bipartite detection")
    Given("a 3-node path vs a triangle")
    p = new stzGraph("p")
    p.AddNode("A") p.AddNode("B") p.AddNode("C")
    p.AddEdge("A", "B") p.AddEdge("B", "C")
    Then("a path is bipartite", p.IsBipartite(), TRUE)
    t = new stzGraph("t")
    t.AddNode("X") t.AddNode("Y") t.AddNode("Z")
    t.AddEdge("X", "Y") t.AddEdge("Y", "Z") t.AddEdge("Z", "X")
    Then("a triangle (odd cycle) is not bipartite", t.IsBipartite(), FALSE)
EndScenario()

Scenario("Weighted shortest path (Dijkstra)")
    Given("A-B(5)-D(5)=10 vs A-C(1)-D(20)=21")
    w = new stzGraph("w")
    w.AddNode("A") w.AddNode("B") w.AddNode("C") w.AddNode("D")
    w.AddEdgeXTT("A", "B", "", [ :weight = 5 ])
    w.AddEdgeXTT("B", "D", "", [ :weight = 5 ])
    w.AddEdgeXTT("A", "C", "", [ :weight = 1 ])
    w.AddEdgeXTT("C", "D", "", [ :weight = 20 ])
    Then("Dijkstra picks the cheaper route a-b-d", ListEq(w.WeightedShortestPath("A", "D"), [ "a", "b", "d" ]), TRUE)
    Then("its total weight is 10 (not the 2-edge 21)", w.WeightedShortestPathLength("A", "D"), 10)
EndScenario()

Summary()

func Gr()
    g = new stzGraph("g")
    g.AddNode("A")
    g.AddNode("B")
    g.AddNode("C")
    g.AddNode("D")
    g.AddEdge("A", "B")
    g.AddEdge("B", "C")
    g.AddEdge("A", "D")
    return g

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
