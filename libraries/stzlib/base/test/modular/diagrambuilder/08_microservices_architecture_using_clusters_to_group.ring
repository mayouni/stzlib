# Narrative
# --------
# Microservices architecture using clusters to group
#
# Extracted from stzdiagrambuildertest.ring, block #8.

load "../../../stzBase.ring"

	related services by domain

pr()

oMicroservices = new stzDiagramMaker("Microservices Architecture")
oMicroservices {
	SetTheme(:Dark)
	SetLayout(:LeftRight)
	SetBackgroundColor("#1e1e1e")

	AddNodeXT("gateway", "API Gateway", :Process)
	WithColor(:primary)

	AddNodeXT("user_svc", "User Service", :Process)
	WithColor(:success)

	AddNodeXT("user_db", "User DB", :Storage)
	WithColor(:success)

	AddNodeXT("order_svc", "Order Service", :Process)
	WithColor(:info)

	AddNodeXT("order_db", "Order DB", :Storage)
	WithColor(:info)

	AddNodeXT("pay_svc", "Payment Service", :Process)
	WithColor(:warning)

	AddNodeXT("pay_db", "Payment DB", :Storage)
	WithColor(:warning)

	AddNodeXT("queue", "Message Queue", :Data)
	WithColor(:danger)

	ConnectXT("gateway", :To = "user_svc", :With = "route")
	ConnectXT("gateway", :To = "order_svc", :With = "route")
	ConnectXT("gateway", :To = "pay_svc", :With = "route")

	ConnectXT("user_svc", :To = "user_db", :With = "")
	ConnectXT("order_svc", :To = "order_db", :With = "")
	ConnectXT("pay_svc", :To = "pay_db", :With = "")

	ConnectXT("order_svc", :To = "queue", :With = "publish")
	ConnectXT("pay_svc", :To = "queue", :With = "publish")
	ConnectXT("queue", :To = "user_svc", :With = "subscribe")

	AddClusterXT(:ID = "users", :Label = "User Domain", :Nodes = ["user_svc", "user_db"], :Color = "lightgreen")
	AddClusterXT(:ID = "orders", :Label = "Order Domain", :Nodes = ["order_svc", "order_db"], :Color = "lightblue")
	AddClusterXT(:ID = "payments", :Label = "Payment Domain", :Nodes = ["pay_svc", "pay_db"], :Color = "lightyellow")

	Render("example7_microservices.svg")
}

pf()

#-----------------#
#  EXAMPLE 8: DATA PIPELINE
#-----------------#
