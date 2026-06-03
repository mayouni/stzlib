# Narrative
# --------
# Verifying Mermaid node type shapes
#
# Extracted from stzdiagramtest.ring, block #27.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("MermaidShapesTest")
oDiag.AddNodeXTT("s", "Node S", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("d", "Node D", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("e", "Node E", [ :type = "endpoint", :color = "success" ])

? oDiag.Mermaid()
#-->
'
graph TD
    s(["Node_S"])
    d{{"Node_D"}}
    e(["Node_E"])
'

pf()
