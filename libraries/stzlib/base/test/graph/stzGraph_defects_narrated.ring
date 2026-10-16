load "../../stzBase.ring"
load "../_narrated.ring"

# stzGraph (base/graph/stzGraph.ring) -- the twelve register rows, run on small graphs whose answers were
# worked out by hand BEFORE the code was run:
#
#   chain       a -> b -> c -> d            3 hops, 4 nodes, no cycle
#   diamond     a -> b, a -> c, b -> d, c -> d        2 hops (3 nodes are reachable from a)
#   two arms    a -> b -> c and a -> d -> e           2 hops (4 nodes are reachable from a)
#   cycle+tail  a -> b -> c -> a, c -> d             a, b and c lie on the cycle; d only hangs off it
#   self-loop   x -> x, x -> y                       x lies on a cycle (its own); y does not
#
# What each row was: LongestPath counted the nodes reachable from one node; CyclicNodes tested a node among
# the nodes it reaches, and a start node is never listed there; the GraphML parser cut the text at fixed
# offsets; HasRule folded one side of the comparison; a failed validation was never recorded; the two
# multi-insert calls and ConnectEdgesXTT called a method with the wrong number of arguments.
#
# The GraphML file is written and read inside ONE fixture folder, <this folder>/_fixture (or the folder named
# by the environment variable STZ_FX_ROOT, which must itself end in /_fixture), created fresh at the start and
# removed at the end. FxGuard() refuses any path that is relative, has .., or is outside that folder, before
# every write and every delete. Run from inside this folder. ASCII only on the console.

$cFx = StzReplace(currentdir(), "\", "/") + "/_fixture"
if sysget("STZ_FX_ROOT") != ""
	$cFx = StzReplace(sysget("STZ_FX_ROOT"), "\", "/")
ok
if FxRootOk() = 0
	? "GUARD: the fixture root is not acceptable: " + $cFx
	shutdown(9)
ok
FxRemoveRoot()
StzDirCreatePath($cFx)

Scenario("Insert a chain of nodes behind an existing node (InsertNodesAfter)")
	Given("a -> b -> c, and the chain n1, n2 inserted after a")
	g = Mk([ "a", "b", "c" ], [ [ "a", "b" ], [ "b", "c" ] ])
	g.InsertNodesAfter("a", [ [ "n1", "N one" ], [ "n2", "N two" ] ])
	Then("the graph has five nodes now", g.NumberOfNodes(), 5)
	Then("a points to n1", g.EdgeExists("a", "n1"), 1)
	Then("n1 points to n2", g.EdgeExists("n1", "n2"), 1)
	Then("n2 points to b", g.EdgeExists("n2", "b"), 1)
	Then("b still points to c", g.EdgeExists("b", "c"), 1)
	Then("the old edge a -> b is gone", g.EdgeExists("a", "b"), 0)
	Then("the chain is not reversed: n2 does not point to n1", g.EdgeExists("n2", "n1"), 0)
	Then("the path from a to c runs through the whole chain",
		GxText(g.Path("a", "c")), GxText([ "a", "n1", "n2", "b", "c" ]))
	Then("the label of a new node is the one given", g.NodeLabel("n2"), "N two")
	Then("four edges before the insert became four edges after (one replaced by three, minus two)",
		g.NumberOfEdges(), 4)

	Given("the same graph, the target given in capitals and the new nodes as plain ids")
	g = Mk([ "a", "b", "c" ], [ [ "a", "b" ], [ "b", "c" ] ])
	g.InsertNodesAfter("A", [ "p", "q" ])
	Then("a capital target still finds the node", GxText(g.Path("a", "c")), GxText([ "a", "p", "q", "b", "c" ]))
	Then("a plain id is its own label", g.NodeLabel("q"), "q")

	Given("an empty list of nodes")
	g = Mk([ "a", "b" ], [ [ "a", "b" ] ])
	g.InsertNodesAfter("a", [])
	Then("nothing changes: two nodes", g.NumberOfNodes(), 2)
	Then("nothing changes: a -> b is kept", g.EdgeExists("a", "b"), 1)
EndScenario()

Scenario("Insert a chain of nodes in front of an existing node (InsertNodesBefore)")
	Given("a -> b -> c, and the chain n1, n2 inserted before b")
	g = Mk([ "a", "b", "c" ], [ [ "a", "b" ], [ "b", "c" ] ])
	g.InsertNodesBefore("b", [ [ "n1", "N one" ], [ "n2", "N two" ] ])
	Then("a points to n1", g.EdgeExists("a", "n1"), 1)
	Then("n1 points to n2", g.EdgeExists("n1", "n2"), 1)
	Then("n2 points to b: the list is in path order", g.EdgeExists("n2", "b"), 1)
	Then("b still points to c", g.EdgeExists("b", "c"), 1)
	Then("the old edge a -> b is gone", g.EdgeExists("a", "b"), 0)
	Then("the chain is not reversed: n2 does not point to n1", g.EdgeExists("n2", "n1"), 0)
	Then("the path from a to c runs through the whole chain",
		GxText(g.Path("a", "c")), GxText([ "a", "n1", "n2", "b", "c" ]))
	Then("the label of a new node is the one given", g.NodeLabel("n1"), "N one")

	Given("the same graph, the target given in capitals")
	g = Mk([ "a", "b", "c" ], [ [ "a", "b" ], [ "b", "c" ] ])
	g.InsertNodesBefore("B", [ "p", "q" ])
	Then("a capital target still finds the node", GxText(g.Path("a", "c")), GxText([ "a", "p", "q", "b", "c" ]))

	Given("an empty list of nodes")
	g = Mk([ "a", "b" ], [ [ "a", "b" ] ])
	g.InsertNodesBefore("b", [])
	Then("nothing changes: two nodes", g.NumberOfNodes(), 2)
	Then("nothing changes: a -> b is kept", g.EdgeExists("a", "b"), 1)
EndScenario()

Scenario("Add edges to several nodes, each with its own label and properties (ConnectEdgesXTT)")
	Given("four nodes and three edges out of a, with a label and a property on the first")
	g = Mk([ "a", "b", "c", "d" ], [])
	g.ConnectEdgesXTT("a", [ [ "b", "knows", [ [ "since", 2020 ] ] ], [ "c", "likes" ], "d" ])
	Then("three edges were added", g.NumberOfEdges(), 3)
	Then("a -> b exists", g.EdgeExists("a", "b"), 1)
	Then("a -> b carries its own label", g.Edge("a", "b")[:label], "knows")
	Then("a -> b carries its own property", g.EdgeProperty("a", "b", "since"), 2020)
	Then("a -> c carries its own label", g.Edge("a", "c")[:label], "likes")
	Then("a -> c has no property", len(g.Edge("a", "c")[:properties]), 0)
	Then("a plain id gives an unlabelled edge", g.Edge("a", "d")[:label], "")
	Then("the edges run one way: b -> a does not exist", g.EdgeExists("b", "a"), 0)
	Then("the spelling AddEdgesXTT does the same", AddedViaAddEdgesXTT(), 2)

	Given("an empty list")
	g = Mk([ "a", "b" ], [])
	g.ConnectEdgesXTT("a", [])
	Then("no edge is added", g.NumberOfEdges(), 0)
EndScenario()

Scenario("The longest path counts hops, not reachable nodes (LongestPath)")
	Given("the chain a -> b -> c -> d")
	g = Mk([ "a", "b", "c", "d" ], [ [ "a", "b" ], [ "b", "c" ], [ "c", "d" ] ])
	Then("it has four nodes", g.NumberOfNodes(), 4)
	Then("the longest path has three hops", g.LongestPath(), 3)
	Then("and not four, the number of nodes", g.LongestPath() = 4, 0)
	Then("nor three by coincidence of reach: a reaches three other nodes",
		len(g.ReachableFrom("a")), 3)

	Given("the diamond a -> b, a -> c, b -> d, c -> d")
	g = Mk([ "a", "b", "c", "d" ], [ [ "a", "b" ], [ "a", "c" ], [ "b", "d" ], [ "c", "d" ] ])
	Then("three nodes are reachable from a", len(g.ReachableFrom("a")), 3)
	Then("yet the longest path has two hops", g.LongestPath(), 2)

	Given("two arms a -> b -> c and a -> d -> e")
	g = Mk([ "a", "b", "c", "d", "e" ], [ [ "a", "b" ], [ "b", "c" ], [ "a", "d" ], [ "d", "e" ] ])
	Then("four nodes are reachable from a", len(g.ReachableFrom("a")), 4)
	Then("yet the longest path has two hops, which the old count answered as four", g.LongestPath(), 2)

	Given("a disconnected graph: a -> b and c -> d -> e")
	g = Mk([ "a", "b", "c", "d", "e" ], [ [ "a", "b" ], [ "c", "d" ], [ "d", "e" ] ])
	Then("the longest path is looked for in every part: two hops", g.LongestPath(), 2)

	Given("a single node, no edge")
	Then("no hop at all", Mk([ "x" ], []).LongestPath(), 0)
	Given("a graph with no node")
	Then("no hop either", Mk([], []).LongestPath(), 0)

	Given("the cycle a -> b -> c -> a")
	g = Mk([ "a", "b", "c" ], [ [ "a", "b" ], [ "b", "c" ], [ "c", "a" ] ])
	Then("the longest path that visits no node twice has two hops", g.LongestPath(), 2)
	Given("the cycle with a node d leading into it, d -> a")
	g = Mk([ "a", "b", "c", "d" ], [ [ "a", "b" ], [ "b", "c" ], [ "c", "a" ], [ "d", "a" ] ])
	Then("d, a, b, c is a path of three hops", g.LongestPath(), 3)
	Given("a node with an edge to itself")
	Then("the loop adds no hop", Mk([ "x" ], [ [ "x", "x" ] ]).LongestPath(), 0)

	Given("a chain of 400 nodes, to see that the walk is not recursive")
	acIds = []
	aEd = []
	for i = 1 to 400
		acIds + ("n" + i)
		if i > 1
			aEd + [ "n" + (i - 1), "n" + i ]
		ok
	next
	Then("it has 399 hops", Mk(acIds, aEd).LongestPath(), 399)
EndScenario()

Scenario("The nodes that lie on a cycle (CyclicNodes)")
	Given("a -> b -> c -> a with d hanging off c")
	g = Mk([ "a", "b", "c", "d" ], [ [ "a", "b" ], [ "b", "c" ], [ "c", "a" ], [ "c", "d" ] ])
	Then("a, b and c are on the cycle, in node order", GxText(g.CyclicNodes()), GxText([ "a", "b", "c" ]))
	Then("d is not: it can be left but never returned to", StzFindFirst("d", g.CyclicNodes()), 0)
	Then("and the graph agrees that it has a cycle", g.HasCyclicDependencies(), 1)

	Given("a node d that leads INTO the cycle, d -> a")
	g = Mk([ "a", "b", "c", "d" ], [ [ "a", "b" ], [ "b", "c" ], [ "c", "a" ], [ "d", "a" ] ])
	Then("d is not on the cycle either", GxText(g.CyclicNodes()), GxText([ "a", "b", "c" ]))

	Given("the diamond, which has no cycle")
	g = Mk([ "a", "b", "c", "d" ], [ [ "a", "b" ], [ "a", "c" ], [ "b", "d" ], [ "c", "d" ] ])
	Then("no node is on a cycle", GxText(g.CyclicNodes()), GxText([]))
	Then("and the graph agrees", g.HasCyclicDependencies(), 0)

	Given("a self-loop on x, and an edge x -> y")
	g = Mk([ "x", "y" ], [ [ "x", "x" ], [ "x", "y" ] ])
	Then("x is on a cycle of its own, y is not", GxText(g.CyclicNodes()), GxText([ "x" ]))
	Then("and the graph agrees", g.HasCyclicDependencies(), 1)

	Given("two cycles in two parts of the graph, a <-> b and c -> d -> e -> c, plus an isolated f")
	g = Mk([ "a", "b", "c", "d", "e", "f" ],
		[ [ "a", "b" ], [ "b", "a" ], [ "c", "d" ], [ "d", "e" ], [ "e", "c" ] ])
	Then("five nodes are on a cycle and the isolated one is not",
		GxText(g.CyclicNodes()), GxText([ "a", "b", "c", "d", "e" ]))

	Given("the explanation of the cycle a -> b -> c -> a with d hanging off c")
	g = Mk([ "a", "b", "c", "d" ], [ [ "a", "b" ], [ "b", "c" ], [ "c", "a" ], [ "c", "d" ] ])
	acCycles = g.Explain()[:cycles]
	Then("it names the nodes on the cycle", acCycles[1], "Cyclic nodes: a, b, c")
	Then("it does not name the node that only hangs off it", StzFindFirst("d can reach itself", GxText(acCycles)), 0)

	Given("the chain a -> b -> c -> d and a graph with no node")
	Then("the chain has none", GxText(Mk([ "a", "b", "c", "d" ], [ [ "a", "b" ], [ "b", "c" ], [ "c", "d" ] ]).CyclicNodes()), GxText([]))
	Then("the empty graph has none", GxText(Mk([], []).CyclicNodes()), GxText([]))
EndScenario()

Scenario("A GraphML file written by the graph is read back to the same graph")
	Given("a graph with labels and properties on nodes and edges, text that needs escaping, and a self-loop")
	g = new stzGraph("gml")
	g.AddNodeXTT("a", "Alpha & Co", [ [ "city", "Niamey" ], [ "size", 12 ] ])
	g.AddNodeXTT("b", "b < c > d", [])
	g.AddNodeXTT("c", 'say "hi"', [])
	g.AddNode("d")
	g.AddEdgeXTT("a", "b", "depends_on", [ [ "weight", 3 ] ])
	g.AddEdgeXTT("b", "c", "", [])
	g.AddEdgeXTT("c", "c", "loop", [])
	cFile = FxP("round.graphml")
	g.SaveToGraphML(cFile)
	Then("the file was written", fexists(cFile), 1)
	Then("it is GraphML", StzFindFirst("<graphml", FxRead("round.graphml")) > 0, 1)

	h = new stzGraph("other")
	h.LoadFromGraphML(cFile)
	Then("the node ids are the same, in order", GxText(h.NodesIds()), GxText(g.NodesIds()))
	Then("the edge count is the same", h.NumberOfEdges(), g.NumberOfEdges())
	Then("a -> b is there", h.EdgeExists("a", "b"), 1)
	Then("the self-loop is there", h.EdgeExists("c", "c"), 1)
	Then("b -> a was not invented", h.EdgeExists("b", "a"), 0)
	Then("a node label with an ampersand is read back", h.NodeLabel("a"), "Alpha & Co")
	Then("a node label with angle brackets is read back", h.NodeLabel("b"), "b < c > d")
	Then("a node label with quotes is read back", h.NodeLabel("c"), 'say "hi"')
	Then("a node property keeps its text", h.NodeProperty("a", "city"), "Niamey")
	Then("a node property keeps its number", h.NodeProperty("a", "size"), 12)
	Then("an edge label is read back", h.Edge("a", "b")[:label], "depends_on")
	Then("an edge property is read back", h.EdgeProperty("a", "b", "weight"), 3)
	Then("an edge with no label stays unlabelled", h.Edge("b", "c")[:label], "")
	Then("the graph written again is the same text: nothing was lost or garbled",
		h.ExportToGraphML(), g.ExportToGraphML())

	Given("the three other spellings of the load, each on a fresh graph")
	h2 = new stzGraph("x")
	h2.LoadGraphML(cFile)
	Then("LoadGraphML reads the same graph", h2.ExportToGraphML(), g.ExportToGraphML())
	h3 = new stzGraph("x")
	h3.ImportFromGraphML(cFile)
	Then("ImportFromGraphML reads the same graph", h3.ExportToGraphML(), g.ExportToGraphML())
	h4 = new stzGraph("x")
	h4.ImportGraphML(cFile)
	Then("ImportGraphML reads the same graph", h4.ExportToGraphML(), g.ExportToGraphML())

	Given("a graph that already holds nodes of its own when it loads")
	h5 = new stzGraph("x")
	h5.AddNode("zz")
	h5.LoadFromGraphML(cFile)
	Then("what it held before is replaced, not mixed in", h5.NodeExists("zz"), 0)
	Then("and it holds the file's four nodes", h5.NumberOfNodes(), 4)

	Given("a GraphML file in the plain dialect of other tools: empty node and edge tags, no label")
	FxWrite("plain.graphml", '<?xml version="1.0"?>' + char(10) +
		'<graphml xmlns="http://graphml.graphdrawing.org/xmlns">' + char(10) +
		'  <graph id="plain" edgedefault="directed">' + char(10) +
		'    <node id="x"/>' + char(10) +
		'    <node id="y"><data key="label">Why</data></node>' + char(10) +
		'    <edge id="e1" source="x" target="y"/>' + char(10) +
		'  </graph>' + char(10) +
		'</graphml>' + char(10))
	h6 = new stzGraph("x")
	h6.LoadFromGraphML(FxP("plain.graphml"))
	Then("both nodes are read", GxText(h6.NodesIds()), GxText([ "x", "y" ]))
	Then("a node with no label is labelled by its id", h6.NodeLabel("x"), "x")
	Then("a node with a label keeps it", h6.NodeLabel("y"), "Why")
	Then("the edge is read", h6.EdgeExists("x", "y"), 1)
	Then("the graph id is the file's", h6.Id(), "plain")
EndScenario()

Scenario("A rule is found by its name whatever the case (HasRule)")
	Given("a graph that loaded the dag rule group")
	g = Mk([ "a", "b" ], [ [ "a", "b" ] ])
	g.UseRulesFrom("dag")
	aRules = g.ActiveRules()
	Then("the group put at least one rule in", len(aRules) > 0, 1)
	cName = aRules[1][2]
	cKind = aRules[1][1]
	Then("it is found under the exact name", g.HasRule(cName), 1)
	Then("it is found under the name in capitals", g.HasRule(StzUpper(cName)), 1)
	Then("it is found under the name in small letters", g.HasRule(StzLower(cName)), 1)
	Then("a name that no rule has is not found", g.HasRule("no_such_rule_anywhere"), 0)
	Then("the other spelling agrees", g.ContainsRule(cName), 1)

	Given("every rule the graph holds")
	nFound = 0
	nAll = len(aRules)
	for i = 1 to nAll
		nFound += g.HasRule(StzLower(aRules[i][2]))
	next
	Then("each one is found by its lowercase name, whichever store holds it", nFound, nAll)

	Given("a graph that has not loaded any group")
	Then("nothing is found", Mk([ "a" ], []).HasRule(cName), 0)

	Given("the rule removed by its name in the other case")
	g.RemoveRule(StzLower(cName))
	Then("it is no longer found", g.HasRule(cName), 0)
EndScenario()

Scenario("The last validation is remembered whether it passed or failed (ValidationSummary, Anomalies)")
	Given("a graph that has not been validated")
	g = Mk([ "a", "b", "c" ], [ [ "a", "b" ], [ "b", "c" ], [ "c", "a" ] ])
	Then("the summary says no validation has run", g.ValidationSummary()[:status], "not_run")
	Then("there is no anomaly", GxText(g.Anomalies()), GxText([]))

	Given("the cycle a -> b -> c -> a, validated as a DAG")
	aV = g.ValidateDAG()
	Then("the validation itself failed", aV[:status], "fail")
	Then("the summary records the failure", g.ValidationSummary()[:status], "fail")
	Then("passed is false", g.ValidationSummary()[:passed], 0)
	Then("the summary counts the violations", g.ValidationSummary()[:violation_count] > 0, 1)
	Then("it lists the rules that were checked", len(g.ValidationSummary()[:rules_applied]) > 0, 1)
	aAn = g.Anomalies()
	Then("the anomalies list the violations", len(aAn), g.ValidationSummary()[:violation_count])
	Then("an anomaly names the rule that was broken", len(aAn[1][:rule]) > 0, 1)
	Then("an anomaly says what is wrong", len(aAn[1][:message]) > 0, 1)
	Then("the other spelling of the anomalies agrees", len(g.Violations()), len(aAn))

	Given("the cycle broken, validated again")
	g.RemoveThisEdge("c", "a")
	aV = g.ValidateDAG()
	Then("the validation passed", aV[:status], "pass")
	Then("the summary now records the pass, not the older failure", g.ValidationSummary()[:status], "pass")
	Then("passed is true", g.ValidationSummary()[:passed], 1)
	Then("no anomaly is left", GxText(g.Anomalies()), GxText([]))
EndScenario()

FxRemoveRoot()
Then("the fixture folder is gone", dirExists($cFx), 0)
Summary()

#------------------------------------------------------------------------------------------
# Graph builders.
#------------------------------------------------------------------------------------------

# lists are compared as their printed text: = does not compare lists
func GxText(x)
	return @@(x)

func Mk(acIds, aEdges)
	g = new stzGraph("g")
	nIds = len(acIds)
	for i = 1 to nIds
		g.AddNode(acIds[i])
	next
	nEdges = len(aEdges)
	for i = 1 to nEdges
		g.AddEdge(aEdges[i][1], aEdges[i][2])
	next
	return g

func AddedViaAddEdgesXTT()
	g = Mk([ "a", "b", "c" ], [])
	g.AddEdgesXTT("a", [ [ "b", "x", [] ], [ "c", "y", [] ] ])
	return g.NumberOfEdges()

#------------------------------------------------------------------------------------------
# Fixture helpers. Every path the library sees comes from FxP(); every destructive step is
# behind FxGuard().
#------------------------------------------------------------------------------------------

func FxRootOk()
	c = $cFx
	if NOT isString(c)
		return 0
	ok
	if len(c) < 20
		return 0
	ok
	if StzFindFirst("..", c) > 0
		return 0
	ok
	if StzRight(c, 9) != "/_fixture"
		return 0
	ok
	if c[2] != ":" or c[3] != "/"
		return 0
	ok
	return 1

# Refuses (and stops the process) any path that is not strictly inside the fixture root.
func FxGuard(cPath, bAllowRoot)
	if FxRootOk() = 0
		? "GUARD REFUSED: bad fixture root"
		shutdown(9)
	ok
	if NOT isString(cPath) or cPath = ""
		? "GUARD REFUSED: not a path"
		shutdown(9)
	ok
	p = StzReplace(cPath, "\", "/")
	if StzFindFirst("..", p) > 0
		? "GUARD REFUSED: contains .."
		shutdown(9)
	ok
	if p[2] != ":" or p[3] != "/"
		? "GUARD REFUSED: not absolute"
		shutdown(9)
	ok
	if bAllowRoot = 1 and p = $cFx
		return 1
	ok
	nRoot = len($cFx)
	if len(p) <= nRoot + 1 or left(p, nRoot + 1) != $cFx + "/"
		? "GUARD REFUSED: outside the fixture"
		shutdown(9)
	ok
	return 1

func FxP(cRel)
	p = $cFx + "/" + cRel
	FxGuard(p, 0)
	return p

func FxWrite(cRel, cContent)
	StzEngineFileWrite(FxP(cRel), cContent)

func FxRead(cRel)
	return StzEngineFileRead(FxP(cRel))

func FxRemoveRoot()
	if StzEngineDirExists($cFx) = 1
		FxGuard($cFx, 1)
		aFiles = StzEngineDirListFiles($cFx)
		nFiles = len(aFiles)
		for i = 1 to nFiles
			pf = $cFx + "/" + aFiles[i]
			FxGuard(pf, 0)
			StzEngineFileDelete(pf)
		next
		StzEngineDirDelete($cFx)
	ok
