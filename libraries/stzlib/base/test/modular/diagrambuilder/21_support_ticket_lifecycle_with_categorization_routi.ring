# Narrative
# --------
# Support ticket lifecycle with categorization, routing,
#
# Extracted from stzdiagrambuildertest.ring, block #21.

load "../../../stzBase.ring"

	investigation, escalation, and satisfaction tracking
*/
pr()

oSupportWorkflow = new stzDiagramMaker("Customer Support Workflow")
oSupportWorkflow {
	SetTheme(:Professional)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "ticket_opened", :Label = "Ticket Opened", :Type = :Start)
	WithColor(:success)

	AddNodeXT("categorize", "Categorize Issue", :Process)
	WithColor(:primary)

	AddNodeXT("priority", "Assess Priority", :Decision)
	WithColor(:warning)

	AddNodeXT("assign_agent", "Assign to Agent", :Process)
	WithColor(:info)

	AddNodeXT("agent_investigate", "Agent Investigates", :Process)
	WithColor(:primary)

	AddNodeXT("troubleshoot_ok", "Issue Resolved?", :Decision)
	WithColor(:warning)

	AddNodeXT("escalate", "Escalate to Specialist", :Process)
	WithColor(:info)

	AddNodeXT("send_solution", "Send Solution", :Process)
	WithColor(:success)

	AddNodeXT("customer_confirm", "Customer Confirms Fix?", :Decision)
	WithColor(:warning)

	AddNodeXT("satisfaction", "Satisfaction Survey", :Data)
	WithColor(:neutral)

	AddNodeXT(:ID = "closed", :Label = "Ticket Closed", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT("reopen", "Reopen Ticket", :Data)
	WithColor(:warning)

	ConnectXT("ticket_opened", :To = "categorize", :With = "")
	ConnectXT("categorize", :To = "priority", :With = "")
	ConnectXT("priority", :To = "assign_agent", :With = "")
	ConnectXT("assign_agent", :To = "agent_investigate", :With = "")
	ConnectXT("agent_investigate", :To = "troubleshoot_ok", :With = "")
	ConnectXT("troubleshoot_ok", :To = "send_solution", :With = "Yes")
	ConnectXT("troubleshoot_ok", :To = "escalate", :With = "No")
	ConnectXT("escalate", :To = "send_solution", :With = "")
	ConnectXT("send_solution", :To = "customer_confirm", :With = "")
	ConnectXT("customer_confirm", :To = "satisfaction", :With = "Yes")
	ConnectXT("customer_confirm", :To = "reopen", :With = "No")
	ConnectXT("reopen", :To = "agent_investigate", :With = "")
	ConnectXT("satisfaction", :To = "closed", :With = "")

	Render("example20_support_workflow.svg")
}

pf()

#-----------------#
#  SUMMARY
#-----------------#
