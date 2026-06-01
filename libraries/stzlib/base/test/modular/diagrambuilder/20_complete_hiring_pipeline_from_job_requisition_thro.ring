# Narrative
# --------
# Complete hiring pipeline from job requisition through onboarding
#
# Extracted from stzdiagrambuildertest.ring, block #20.

load "../../../stzBase.ring"

	with multiple screening stages and background checks
pr()

oRecruitmentWorkflow = new stzDiagramMaker("Recruitment Process")
oRecruitmentWorkflow {
	SetTheme(:Vibrant)
	SetLayout(:TopDown)

	AddNodeXT(:ID = "job_req", :Label = "Job Requisition", :Type = :Start)
	WithColor(:success)

	AddNodeXT("post_job", "Post Job Opening", :Process)
	WithColor(:primary)

	AddNodeXT("receive_apps", "Receive Applications", :Data)
	WithColor(:neutral)

	AddNodeXT("resume_screen", "Resume Screening", :Process)
	WithColor(:info)

	AddNodeXT("passes_screen", "Passes Initial Screen?", :Decision)
	WithColor(:warning)

	AddNodeXT("phone_interview", "Phone Interview", :Process)
	WithColor(:primary)

	AddNodeXT("phone_ok", "Advance to Technical?", :Decision)
	WithColor(:warning)

	AddNodeXT("technical_test", "Technical Assessment", :Process)
	WithColor(:info)

	AddNodeXT("technical_ok", "Passes Assessment?", :Decision)
	WithColor(:warning)

	AddNodeXT("on_site", "On-Site Interview", :Process)
	WithColor(:primary)

	AddNodeXT("team_feedback", "Team Feedback", :Data)
	WithColor(:neutral)

	AddNodeXT("on_site_ok", "Team Approves?", :Decision)
	WithColor(:warning)

	AddNodeXT("offer_prep", "Prepare Offer", :Process)
	WithColor(:success)

	AddNodeXT("offer_sent", "Send Offer", :Process)
	WithColor(:success)

	AddNodeXT("offer_accepted", "Offer Accepted?", :Decision)
	WithColor(:warning)

	AddNodeXT("background_check", "Background Check", :Process)
	WithColor(:info)

	AddNodeXT("check_ok", "Check Clear?", :Decision)
	WithColor(:warning)

	AddNodeXT("onboarding", "Onboarding", :Process)
	WithColor(:success)

	AddNodeXT(:ID = "hired", :Label = "Employee Onboarded", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT(:ID = "rejected", :Label = "Candidate Rejected", :Type = :Endpoint)
	WithColor(:danger)

	ConnectXT("job_req", :To = "post_job", :With = "")
	ConnectXT("post_job", :To = "receive_apps", :With = "")
	ConnectXT("receive_apps", :To = "resume_screen", :With = "")
	ConnectXT("resume_screen", :To = "passes_screen", :With = "")
	ConnectXT("passes_screen", :To = "phone_interview", :With = "Yes")
	ConnectXT("passes_screen", :To = "rejected", :With = "No")

	ConnectXT("phone_interview", :To = "phone_ok", :With = "")
	ConnectXT("phone_ok", :To = "technical_test", :With = "Yes")
	ConnectXT("phone_ok", :To = "rejected", :With = "No")

	ConnectXT("technical_test", :To = "technical_ok", :With = "")
	ConnectXT("technical_ok", :To = "on_site", :With = "Yes")
	ConnectXT("technical_ok", :To = "rejected", :With = "No")

	ConnectXT("on_site", :To = "team_feedback", :With = "")
	ConnectXT("team_feedback", :To = "on_site_ok", :With = "")
	ConnectXT("on_site_ok", :To = "offer_prep", :With = "Yes")
	ConnectXT("on_site_ok", :To = "rejected", :With = "No")

	ConnectXT("offer_prep", :To = "offer_sent", :With = "")
	ConnectXT("offer_sent", :To = "offer_accepted", :With = "")
	ConnectXT("offer_accepted", :To = "background_check", :With = "Yes")
	ConnectXT("offer_accepted", :To = "rejected", :With = "No")

	ConnectXT("background_check", :To = "check_ok", :With = "")
	ConnectXT("check_ok", :To = "onboarding", :With = "Yes")
	ConnectXT("check_ok", :To = "rejected", :With = "No")

	ConnectXT("onboarding", :To = "hired", :With = "")

	Render("example19_recruitment_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 20: CUSTOMER SUPPORT WORKFLOW
#-----------------#
