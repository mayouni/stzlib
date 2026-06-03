# Narrative
# --------
# Verifying DOT node type shapes
#
# Extracted from stzdiagramtest.ring, block #24.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("DotShapesTest")
oDiag.SetTheme("vibrant")
oDiag.AddNodeXTT("s", "Node S", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("d", "Node D", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("p", "Node P", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("e", "Node E", [ :type = "endpoint", :color = "success" ])

? oDiag.Dot()
#-->
'
digraph "dotshapestest" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=0.60, ranksep=0.80, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#000000", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    s [label="Node_S", shape=ellipse, style="solid,filled", fillcolor="#008000", fontcolor="white"]
    d [label="Node_D", shape=diamond, style="solid,filled", fillcolor="#FFA500", fontcolor="black"]
    p [label="Node_P", shape=box, style="rounded,solid,filled", fillcolor="#0000FF", fontcolor="white"]
    e [label="Node_E", shape=doublecircle, style="solid,filled", fillcolor="#008000", fontcolor="white"]

    s -> d [style=invis]
    d -> p [style=invis]
    p -> e [style=invis]

}
'

pf()
# Executed in 0.04 second(s) in Ring 1.25
