# Narrative
# --------
# HR workflow for employee leave approval
#
# Extracted from stzdiagrambuildertest.ring, block #18.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

	with balance checking and multi-level approval
*/
pr()

oLeaveWorkflow = new stzDiagramMaker("Leave Request Workflow")
oLeaveWorkflow {
	SetTheme(:Vibrant)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "request", :Label = "Leave Request Submitted", :Type = :Start)
	WithColor(:success)

	AddNodeXT("check_balance", "Check Leave Balance", :Process)
	WithColor(:primary)

	AddNodeXT("balance_ok", "Sufficient Balance?", :Decision)
	WithColor(:warning)

	AddNodeXT("manager_review", "Manager Review", :Process)
	WithColor(:info)

	AddNodeXT("manager_approve", "Manager Approves?", :Decision)
	WithColor(:warning)

	AddNodeXT("hr_review", "HR Review", :Process)
	WithColor(:info)

	AddNodeXT("hr_approve", "HR Approves?", :Decision)
	WithColor(:warning)

	AddNodeXT("block_calendar", "Block Calendar", :Process)
	WithColor(:neutral)

	AddNodeXT("notify_team", "Notify Team", :Data)
	WithColor(:neutral)

	AddNodeXT(:ID = "approved_leave", :Label = "Leave Approved", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT(:ID = "rejected", :Label = "Request Rejected", :Type = :Endpoint)
	WithColor(:danger)

	AddNodeXT("notify_rejection", "Notify Rejection", :Data)
	WithColor(:warning)

	ConnectXT("request", :To = "check_balance", :With = "")
	ConnectXT("check_balance", :To = "balance_ok", :With = "")
	ConnectXT("balance_ok", :To = "manager_review", :With = "Yes")
	ConnectXT("balance_ok", :To = "rejected", :With = "No")

	ConnectXT("manager_review", :To = "manager_approve", :With = "")
	ConnectXT("manager_approve", :To = "hr_review", :With = "Yes")
	ConnectXT("manager_approve", :To = "notify_rejection", :With = "No")

	ConnectXT("hr_review", :To = "hr_approve", :With = "")
	ConnectXT("hr_approve", :To = "block_calendar", :With = "Yes")
	ConnectXT("hr_approve", :To = "notify_rejection", :With = "No")

	ConnectXT("block_calendar", :To = "notify_team", :With = "")
	ConnectXT("notify_team", :To = "approved_leave", :With = "")
	ConnectXT("notify_rejection", :To = "rejected", :With = "")

	Render("example17_leave_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 18: CONTENT PUBLISHING WORKFLOW
#-----------------#
