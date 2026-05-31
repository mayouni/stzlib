# Narrative
# --------
# Multi-level decision logic for user authentication
#
# Extracted from stzdiagrambuildertest.ring, block #7.

load "../../../stzBase.ring"

	demonstrating diamond nodes and conditional flow

pr()

oDecisionTree = new stzDiagramMaker("User Authentication Flow")
oDecisionTree {
	SetTheme(:Vibrant)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "start", :Label = "", :Type = :Start)
	WithColor(:success)

	AddNodeXT("input", "Enter Credentials", :Process)
	WithColor(:primary)

	AddNodeXT("check_user", "User Exists?", :Decision)
	WithColor(:warning)

	AddNodeXT("check_pass", "Password Valid?", :Decision)
	WithColor(:warning)

	AddNodeXT("check_2fa", "2FA Enabled?", :Decision)
	WithColor(:warning)

	AddNodeXT("send_2fa", "Send 2FA Code", :Process)
	WithColor(:info)

	AddNodeXT("verify_2fa", "Code Valid?", :Decision)
	WithColor(:warning)

	AddNodeXT("success", "Login Success", :Endpoint)
	WithColor(:success)

	AddNodeXT("error", "Login Failed", :Endpoint)
	WithColor(:danger)

	ConnectXT("start", :To = "input", :With = "")
	ConnectXT("input", :To = "check_user", :With = "")
	ConnectXT("check_user", :To = "check_pass", :With = "Yes")
	ConnectXT("check_user", :To = "error", :With = "No")
	ConnectXT("check_pass", :To = "check_2fa", :With = "Yes")
	ConnectXT("check_pass", :To = "error", :With = "No")
	ConnectXT("check_2fa", :To = "send_2fa", :With = "Yes")
	ConnectXT("check_2fa", :To = "success", :With = "No")
	ConnectXT("send_2fa", :To = "verify_2fa", :With = "")
	ConnectXT("verify_2fa", :To = "success", :With = "Yes")
	ConnectXT("verify_2fa", :To = "error", :With = "No")

	Render("example6_decision_tree.svg")
}

pf()

#-----------------#
#  EXAMPLE 7: MICROSERVICES WITH CLUSTERS
#-----------------#
