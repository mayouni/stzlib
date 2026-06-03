# Narrative
# --------
# Grouping nodes into logical domains
#
# Extracted from stzdiagramtest.ring, block #13.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("Clustered")

odiag.setTheme("light")
oDiag.AddNodeXTT("user_api", "User API", [ :type = "process", :color = "success" ])
oDiag.AddNodeXTT("user_db", "User DB", [ :type = "storage", :color = "success" ])
oDiag.AddNodeXTT("order_api", "Order API", [ :type = "process", :color = "info" ])
oDiag.AddNodeXTT("order_db", "Order DB", [ :tyoe = "storage", :color = "info" ])

oDiag.AddClusterXTT("users", "User Domain", ["user_api", "user_db"], :LightGreen)
oDiag.AddClusterXTT("orders", "Order Domain", ["order_api", "order_db"], :Lightblue)

oDiag.View()
? len(oDiag.Clusters()) #--> 2

pf()
# Executed in 0.54 second(s) in Ring 1.25
