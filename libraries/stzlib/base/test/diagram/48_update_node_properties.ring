# Narrative
# --------
# Update Node properties
#
# Extracted from stzdiagramtest.ring, block #48.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("task", "Task", [ :type = "process", :color = "blue" ])

oDiag.SetNodeProp(:task, :priority, "low")
oDiag.UpdateNodeProp(:task, :priority, "critical")
oDiag.UpdateNodeProp(:task, :status, "active")

aMeta = oDiag.NodePropsXT(:task)

? aMeta[:priority]
#--> critical
? aMeta[:status]
#--> active

pf()
#--> Executed in 0.02 second(s) in Ring 1.25
