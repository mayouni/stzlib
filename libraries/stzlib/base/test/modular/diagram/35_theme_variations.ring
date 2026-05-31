# Narrative
# --------
# Theme variations
#
# Extracted from stzdiagramtest.ring, block #35.

load "../../../stzBase.ring"


pr()

# Supported thems: light, dark, vibrant, pro, access,
# print, gray, lightgray, darkgray

o1 = new stzDiagram("ThemeTest")
o1 {
	SetTheme(:light)
	SetLayout(:RightLeft)
	SetNodeStrokeColor("navy")
	
	AddNodeXTT("x", "Alpha", [ :type = "start", :color = "success" ])
	AddNodeXTT("y", "Beta", [ :type = "process", :color = "primary" ])
	AddNodeXTT("z", "Gamma", [ :type = "endpoint", :color = "primary" ])
	
	Connect("x", "y")
	Connect("y", "z")
	
	? Dot()
	View()
}
#-->
`
digraph "themetest" {
    graph [rankdir=RL, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=0.60, ranksep=0.80, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#000000", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    x [label="Alpha", shape=ellipse, style="solid,filled", fillcolor="#4D654D", fontcolor="white", color="#008000"]
    y [label="Beta", shape=box, style="rounded,solid,filled", fillcolor="#4D4DC9", fontcolor="white", color="#008000"]
    z [label="Gamma", shape=doublecircle, style="solid,filled", fillcolor="#4D4DC9", fontcolor="white", color="#008000"]

    x -> y
    y -> z

}
`

pf()
# Executed in 0.61 second(s) in Ring 1.25
