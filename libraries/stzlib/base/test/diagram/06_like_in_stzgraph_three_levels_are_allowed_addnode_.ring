# Narrative
# --------
# Like in stzGraph, three levels are allowed: AddNode(), AddNodeXT() and AddNodeXTT()
#
# Extracted from stzdiagramtest.ring, block #6.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzDiagram("")
o1 {
	SetTitle("HELLO TITLE")
	SetSubtitle("Curved Splines")

	SetSplines("curved") # or spline, ortho, polyline, line
	AddNode("a")
	AddNodeXT("b", "pass")
	AddNodeXTT("c", "end", [ :type = "endpoint", :color = "green" ]) 
	Connect("a", "b")
	ConnectXT("a", "c", "focus")
	View()
	? Code()
}
#-->
`
digraph "" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=curved, nodesep=0.60, ranksep=0.80, ordering=out]
    labelloc="t";
    label="
HELLO TITLE
Curved Splines


";
    fontsize=16;

    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#000000", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    a [label="a", shape=box, style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black"]
    b [label="pass", shape=box, style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black"]
    c [label="end", shape=doublecircle, style="solid,filled", fillcolor="#008000", fontcolor="white"]

    a -> b
    a -> c [label="focus"]

}
`

pf()
