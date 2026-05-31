# Narrative
# --------
# Converting to Graphviz DOT language
#
# Extracted from stzdiagramtest.ring, block #22.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("DotTest")
? oDiag.theme()

oDiag.AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("end", "End", [ :type = "endpoint", :color = "success" ])
oDiag.Connect("start", "end")

? @@NL( oDiag.ToHashList() ) + NL

//oDiag.View()
#-->
'
diagram "DotTest"

properties
    theme: light
    layout: topdown

nodes
    start
        label: "Start"
        type: start
        color: success

    end
        label: "End"
        type: endpoint
        color: success

edges
    start -> end
'

pf()
