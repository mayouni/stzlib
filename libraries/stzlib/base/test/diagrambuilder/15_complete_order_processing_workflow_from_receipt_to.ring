# Narrative
# --------
# Complete order processing workflow from receipt to completion
#
# Extracted from stzdiagrambuildertest.ring, block #15.

load "../../stzBase.ring"

	with inventory, payment, and shipping stages

pr()

oOrderWorkflow = new stzDiagramMaker("Order Processing Workflow")
oOrderWorkflow {
	SetTheme(:Professional)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "order_received", :Label = "Order Received", :Type = :Start)
	WithColor(:success)

	AddNodeXT("validate", "Validate Order", :Process)
	WithColor(:primary)

	AddNodeXT("valid", "Valid?", :Decision)
	WithColor(:warning)

	AddNodeXT("reserve_inventory", "Reserve Inventory", :Process)
	WithColor(:info)

	AddNodeXT("inventory_ok", "Stock Available?", :Decision)
	WithColor(:warning)

	AddNodeXT("process_payment", "Process Payment", :Process)
	WithColor(:primary)

	AddNodeXT("payment_ok", "Payment Success?", :Decision)
	WithColor(:warning)

	AddNodeXT("generate_label", "Generate Shipping Label", :Process)
	WithColor(:info)

	AddNodeXT("pack_item", "Pack Item", :Process)
	WithColor(:info)

	AddNodeXT("ship_item", "Ship Item", :Process)
	WithColor(:success)

	AddNodeXT("send_notification", "Send Notification", :Data)
	WithColor(:neutral)

	AddNodeXT(:ID = "completed", :Label = "Order Completed", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT("refund", "Process Refund", :Process)
	WithColor(:danger)

	AddNodeXT(:ID = "cancelled", :Label = "Order Cancelled", :Type = :Endpoint)
	WithColor(:danger)

	AddNodeXT("inventory_log", "Update Inventory Log", :Data)
	WithColor(:neutral)

	ConnectXT("order_received", :To = "validate", :With = "")
	ConnectXT("validate", :To = "valid", :With = "")
	ConnectXT("valid", :To = "reserve_inventory", :With = "Yes")
	ConnectXT("valid", :To = "cancelled", :With = "No")

	ConnectXT("reserve_inventory", :To = "inventory_ok", :With = "")
	ConnectXT("inventory_ok", :To = "process_payment", :With = "Yes")
	ConnectXT("inventory_ok", :To = "refund", :With = "No")

	ConnectXT("process_payment", :To = "payment_ok", :With = "")
	ConnectXT("payment_ok", :To = "generate_label", :With = "Yes")
	ConnectXT("payment_ok", :To = "refund", :With = "No")

	ConnectXT("generate_label", :To = "pack_item", :With = "")
	ConnectXT("pack_item", :To = "ship_item", :With = "")
	ConnectXT("ship_item", :To = "send_notification", :With = "")
	ConnectXT("send_notification", :To = "completed", :With = "")

	ConnectXT("refund", :To = "inventory_log", :With = "")
	ConnectXT("inventory_log", :To = "cancelled", :With = "")

	Render("example14_order_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 15: LOAN APPROVAL WORKFLOW
#-----------------#
