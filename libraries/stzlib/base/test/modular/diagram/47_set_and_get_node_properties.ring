# Narrative
# --------
# Set and Get Node properties
#
# Extracted from stzdiagramtest.ring, block #47.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("task", "Task", [ :type = "process", :color = "blue" ])

oDiag.SetNodeProperties("task", [
    :priority = "high",
    :owner = "Alice",
    :duration = 120
])

? @@NL( oDiag.NodePropertiesXT("task") )
#--> [
# 	[ "type", "process" ],
# 	[ "color", "blue" ],
# 	[ "priority", "high" ],
# 	[ "owner", "Alice" ],
# 	[ "duration", 120 ]
# ]

pf()
#--> Executed in 0.02 second(s) in Ring 1.25
