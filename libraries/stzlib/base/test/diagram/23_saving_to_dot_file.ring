# Narrative
# --------
# Saving to DOT file
#
# Extracted from stzdiagramtest.ring, block #23.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("simple")
oDiag.AddNodeXTT("a", "Node A", [ :type = "procesd", :Color = "white" ])
oDiag.AddNodeXTT("b", "Node B", [ :type = "process", :Color = "white" ])
oDiag.Connect("a", "b")

if  oDiag.SaveDotInFolder("txtfiles")
	? read("../_data/simple.dot")
ok
#-->
'
digraph "simple" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=0.60, ranksep=0.80, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#000000", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    a [label="Node_A", shape=box, style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black"]
    b [label="Node_B", shape=box, style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black"]

    a -> b

}
'

pf()
# Executed in 0.06 second(s) in Ring 1.25
