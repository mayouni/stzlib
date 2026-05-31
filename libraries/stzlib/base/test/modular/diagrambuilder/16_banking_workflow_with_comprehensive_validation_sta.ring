# Narrative
# --------
# Banking workflow with comprehensive validation stages
#
# Extracted from stzdiagrambuildertest.ring, block #16.

load "../../../stzBase.ring"


pr()

oLoanWorkflow = new stzDiagramMaker("Loan Application Workflow")
oLoanWorkflow {
	SetTheme(:Professional)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "apply", :Label = "Loan Application", :Type = :Start)
	WithColor(:success)

	AddNodeXT("doc_collect", "Collect Documents", :Process)
	WithColor(:primary)

	AddNodeXT("doc_verify", "Documents Complete?", :Decision)
	WithColor(:warning)

	AddNodeXT("credit_check", "Credit Check", :Process)
	WithColor(:info)

	AddNodeXT("credit_ok", "Good Credit?", :Decision)
	WithColor(:warning)

	AddNodeXT("income_verify", "Verify Income", :Process)
	WithColor(:info)

	AddNodeXT("income_ok", "Sufficient Income?", :Decision)
	WithColor(:warning)

	AddNodeXT("property_appraisal", "Property Appraisal", :Process)
	WithColor(:info)

	AddNodeXT("appraisal_ok", "Appraisal OK?", :Decision)
	WithColor(:warning)

	AddNodeXT("underwriting", "Underwriting Review", :Process)
	WithColor(:primary)

	AddNodeXT("underwrite_ok", "Approved?", :Decision)
	WithColor(:warning)

	AddNodeXT("legal_prep", "Legal Preparation", :Process)
	WithColor(:info)

	AddNodeXT("closing", "Loan Closing", :Process)
	WithColor(:success)

	AddNodeXT(:ID = "funded", :Label = "Loan Funded", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT(:ID = "denied", :Label = "Application Denied", :Type = :Endpoint)
	WithColor(:danger)

	AddNodeXT("request_more_docs", "Request More Documents", :Data)
	WithColor(:warning)

	ConnectXT("apply", :To = "doc_collect", :With = "")
	ConnectXT("doc_collect", :To = "doc_verify", :With = "")
	ConnectXT("doc_verify", :To = "credit_check", :With = "Yes")
	ConnectXT("doc_verify", :To = "request_more_docs", :With = "No")
	ConnectXT("request_more_docs", :To = "doc_collect", :With = "")

	ConnectXT("credit_check", :To = "credit_ok", :With = "")
	ConnectXT("credit_ok", :To = "income_verify", :With = "Yes")
	ConnectXT("credit_ok", :To = "denied", :With = "No")

	ConnectXT("income_verify", :To = "income_ok", :With = "")
	ConnectXT("income_ok", :To = "property_appraisal", :With = "Yes")
	ConnectXT("income_ok", :To = "denied", :With = "No")

	ConnectXT("property_appraisal", :To = "appraisal_ok", :With = "")
	ConnectXT("appraisal_ok", :To = "underwriting", :With = "Yes")
	ConnectXT("appraisal_ok", :To = "denied", :With = "No")

	ConnectXT("underwriting", :To = "underwrite_ok", :With = "")
	ConnectXT("underwrite_ok", :To = "legal_prep", :With = "Yes")
	ConnectXT("underwrite_ok", :To = "denied", :With = "No")

	ConnectXT("legal_prep", :To = "closing", :With = "")
	ConnectXT("closing", :To = "funded", :With = "")

	Render("example15_loan_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 16: INSURANCE CLAIMS WORKFLOW
#-----------------#
