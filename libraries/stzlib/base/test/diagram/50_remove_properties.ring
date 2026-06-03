# Narrative
# --------
# Remove properties
#
# Extracted from stzdiagramtest.ring, block #50.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.SetNodeProps("n1", [:key = "value"])

? @@(oDiag.NodeProps("n1"))
#--> [ "type", "color", "key" ]

oDiag.RemoveNodeProps("n1")

? @@(oDiag.NodeProps("n1"))
#--> []

pf()
#--> Executed in 0.02 second(s) in Ring 1.24

#=======================#
#  COMBINED OPERATIONS  #
#=======================#
