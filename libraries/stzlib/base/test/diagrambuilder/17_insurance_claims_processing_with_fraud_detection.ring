# Narrative
# --------
# Insurance claims processing with fraud detection,
#
# Extracted from stzdiagrambuildertest.ring, block #17.

load "../../stzBase.ring"

	damage estimation, and payment authorization
*/
pr()

oClaimsWorkflow = new stzDiagramMaker("Insurance Claims Workflow")
oClaimsWorkflow {
	SetTheme(:Dark)
	SetLayout(:TopDown)
	SetNodeStrokeColor(:Gray)
	SetEdgeColor(:Gray)

	AddNodeXT(:ID = "claim_filed", :Label = "Claim Filed", :Type = :Start)
	WithColor(:primary)

	AddNodeXT("claim_intake", "Claim Intake", :Process)
	WithColor(:primary)

	AddNodeXT("assign_adjuster", "Assign Adjuster", :Process)
	WithColor(:info)

	AddNodeXT("field_inspection", "Field Inspection", :Process)
	WithColor(:info)

	AddNodeXT("documentation", "Gather Documentation", :Process)
	WithColor(:info)

	AddNodeXT("fraud_check", "Fraud Review", :Process)
	WithColor(:warning)

	AddNodeXT("fraud_flag", "Fraud Detected?", :Decision)
	WithColor(:warning)

	AddNodeXT("estimate_damage", "Estimate Damage", :Process)
	WithColor(:info)

	AddNodeXT("estimate_ok", "Estimate Approved?", :Decision)
	WithColor(:warning)

	AddNodeXT("reserve_funds", "Reserve Funds", :Data)
	WithColor(:neutral)

	AddNodeXT("authorize_repair", "Authorize Repair/Payout", :Process)
	WithColor(:success)

	AddNodeXT("payment_processed", "Process Payment", :Process)
	WithColor(:success)

	AddNodeXT(:ID = "claim_closed", :Label = "Claim Closed", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT(:ID = "claim_denied", :Label = "Claim Denied", :Type = :Endpoint)
	WithColor(:danger)

	AddNodeXT("investigation", "Fraud Investigation", :Data)
	WithColor(:danger)

	ConnectXT("claim_filed", :To = "claim_intake", :With = "")
	ConnectXT("claim_intake", :To = "assign_adjuster", :With = "")
	ConnectXT("assign_adjuster", :To = "field_inspection", :With = "")
	ConnectXT("field_inspection", :To = "documentation", :With = "")
	ConnectXT("documentation", :To = "fraud_check", :With = "")
	ConnectXT("fraud_check", :To = "fraud_flag", :With = "")

	ConnectXT("fraud_flag", :To = "estimate_damage", :With = "No")
	ConnectXT("fraud_flag", :To = "investigation", :With = "Yes")
	ConnectXT("investigation", :To = "claim_denied", :With = "")

	ConnectXT("estimate_damage", :To = "estimate_ok", :With = "")
	ConnectXT("estimate_ok", :To = "reserve_funds", :With = "Yes")
	ConnectXT("estimate_ok", :To = "claim_denied", :With = "No")

	ConnectXT("reserve_funds", :To = "authorize_repair", :With = "")
	ConnectXT("authorize_repair", :To = "payment_processed", :With = "")
	ConnectXT("payment_processed", :To = "claim_closed", :With = "")

	Render("example16_claims_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 17: EMPLOYEE LEAVE REQUEST WORKFLOW
#-----------------#
