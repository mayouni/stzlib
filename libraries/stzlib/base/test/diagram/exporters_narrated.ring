# The diagram EXPORTERS -- four ways out, and one way back.
#
# stzDiagram ships four exporters that no test had ever run: stzDiagramToDot
# (Graphviz), stzDiagramToMermaid, stzDiagramToJSON, and stzDiagramToStzDiag
# (Softanza's own .stzdiag). All four WROTE correctly -- exporters usually do,
# because the writer is the half you look at.
#
# The reader is the half that rots. ImportDiag() read .stzdiag back and
# dropped EVERY EDGE LABEL: an edge is two lines in that format --
#
#     a -> b
#         label: "next"
#
# -- and the parser's edges branch only ever matched the arrow line, so the
# label line matched nothing and was silently discarded, then the edge was
# added with Connect(), which takes no label. Same disease as .stzflow and
# .stzstyl: the writer says something the reader never listens for.
#
# Each exporter is judged by its TARGET, not by its own say-so: the JSON is
# handed to the engine's JSON validator, the DOT/Mermaid are checked for the
# syntax their tools require, and .stzdiag is asked to come back whole.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

oD = new stzDiagram("flow")
oD.AddNodeXTT("a", "Start", [ ["type", "start"] ])
oD.AddNodeXT("b", "Middle")
oD.AddNodeXT("c", "End")
oD.AddEdgeXT("a", "b", "next")
oD.AddEdge("b", "c")
oD.SetTheme("dark")

? "-- Scene 1: Graphviz DOT --"

cDot = oD.Dot()
chk("it writes something", len(cDot) > 0)
chk("a real digraph, named", StzFindFirst('digraph "flow" {', cDot) > 0)
chk("every node is declared", StzFindFirst('a [label="Start"', cDot) > 0 and
	StzFindFirst('b [label="Middle"', cDot) > 0)
chk("the edge carries its label", StzFindFirst("a -> b [label=", cDot) > 0)
chk("... and the plain edge has none", StzFindFirst("b -> c", cDot) > 0)
chk("it closes its brace", StzRight(StzTrim(cDot), 1) = "}")

? ""
? "-- Scene 2: Mermaid --"

cMer = oD.Mermaid()
chk("it declares a graph + direction", StzLeft(cMer, 8) = "graph TD")
chk("the start node takes the stadium shape", StzFindFirst('a(["Start"])', cMer) > 0)
chk("a plain node is a box", StzFindFirst('b["Middle"]', cMer) > 0)
chk("the labelled edge uses the pipe form", StzFindFirst("a -->|next| b", cMer) > 0)
chk("the plain edge is a bare arrow", StzFindFirst("b --> c", cMer) > 0)

? ""
? "-- Scene 3: JSON -- judged by the engine, not by itself --"

cJson = oD.Json()
chk("the ENGINE's JSON parser accepts it", StzJsonIsValid(cJson) = TRUE)
chk("... and reads the id back out of it", StzJsonGet(cJson, "id") = "flow")
chk("it carries nodes and edges", StzFindFirst('"nodes"', cJson) > 0 and
	StzFindFirst('"edges"', cJson) > 0)

? ""
? "-- Scene 4: .stzdiag -- the one that must come BACK --"

cDiag = oD.stzdiag()
chk("it writes its sections", StzFindFirst("nodes", cDiag) > 0 and
	StzFindFirst("edges", cDiag) > 0 and StzFindFirst("properties", cDiag) > 0)
chk("... including the edge label the reader used to drop",
	StzFindFirst('label: "next"', cDiag) > 0)

oBack = new stzDiagram("blank")
oBack.ImportDiag(cDiag)

chk("every node came back", oBack.NodeCount() = oD.NodeCount())
chk("every edge came back", oBack.EdgeCount() = oD.EdgeCount())
chk("a node's label came back", oBack.Node("a")[:label] = "Start")
chk("a node's property came back", oBack.NodeProperty("a", "type") = "start")
chk("the theme came back", oBack.Theme() = oD.Theme())

# THE defect this pins
chk("THE EDGE LABEL came back", oBack.Edge("a", "b")[:label] = "next")
chk("... and an unlabelled edge stays unlabelled", oBack.Edge("b", "c")[:label] = "")

? ""
? "-- Scene 5: importing into a diagram that already has nodes --"

# ImportDiag refuses unless the incoming first node anchors somewhere
bRefused = 0
try
	oOther = new stzDiagram("other")
	oOther.AddNodeXT("zzz", "Unrelated")
	oOther.ImportDiag(cDiag)
catch
	bRefused = 1
done
chk("an import that anchors nowhere REFUSES (never a silent merge)", bRefused = 1)

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
