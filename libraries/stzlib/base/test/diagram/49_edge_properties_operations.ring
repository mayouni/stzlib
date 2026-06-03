# Narrative
# --------
# Edge properties Operations
#
# Extracted from stzdiagramtest.ring, block #49.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("Test")

oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n2", "Node 2", [ :type = "process", :color = "blue" ])
oDiag.Connect("n1", "n2")

oDiag.SetEdgeProps("n1", "n2", [
    :type = "data_flow",
    :bandwidth = "high",
    :encrypted = TRUE
])

aMeta = oDiag.EdgePropsXT("n1", "n2")
? aMeta[:type]
#--> data_flow
? aMeta[:encrypted]
#--> TRUE

pf()
#--> Executed in 0.03 second(s) in Ring 1.24
