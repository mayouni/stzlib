# Narrative
# --------
# Clear All Nodes
#
# Extracted from stzdiagramtest.ring, block #46.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n2", "Node 2", [ :type = "decision", :color = "green", :unit = "sales" ])

oDiag.Connect("n1", "n2")
oDiag.SetNodeProp("n1", :priority, "high")

? @@( oDiag.NodeProps("n1") ) + NL
#--> [ "type", "color", "priority" ]

? @@( oDiag.NodePropsXT("n1") ) + NL
#--> [ "type", "color", "priority" ]

? @@(oDiag.Props()) + NL
#--> [ "type", "color", "priority", "unit" ]

? @@NL(oDiag.PropsXT()) + NL
#-->
'
[
	[ "type", [ "process" ] ],
	[ "color", [ "blue" ] ],
	[ "priority", [ "high" ] ],
	[ "unit", [ "sales" ] ]
]
'

oDiag.RemoveAllNodes()

? oDiag.NodeCount()
#--> 0
? oDiag.EdgeCount()
#--> 0

pf()

#--> Executed in 0.02 second(s) in Ring 1.24

#====================================#
#  PROPERTIES OPERATIONS (METADATA)  #
#====================================#
