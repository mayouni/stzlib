# Narrative
# --------
# Editorial pipeline with review, fact-checking,
#
# Extracted from stzdiagrambuildertest.ring, block #19.

load "../../../stzBase.ring"

	SEO optimization, and publication scheduling
*/
pr()

oPublishWorkflow = new stzDiagramMaker("Editorial Publishing Pipeline")
oPublishWorkflow {
	SetTheme(:Professional)
	SetLayout(:TopDown)
	SetEdgeColor("gray")
	SetNodeStrokeColor("gray")

	AddNodeXT(:ID = "idea", :Label = "Content Idea", :Type = :Start)
	WithColor(:primary)

	AddNodeXT("research", "Research", :Process)
	WithColor(:primary)

	AddNodeXT("draft", "Write Draft", :Process)
	WithColor(:primary)

	AddNodeXT("editor_review", "Editor Review", :Process)
	WithColor(:info)

	AddNodeXT("editor_ok", "Editor Approves?", :Decision)
	WithColor(:warning)

	AddNodeXT("fact_check", "Fact Check", :Process)
	WithColor(:info)

	AddNodeXT("facts_ok", "Facts Verified?", :Decision)
	WithColor(:warning)

	AddNodeXT("design", "Design/Layout", :Process)
	WithColor(:neutral)

	AddNodeXT("seo_review", "SEO Review", :Process)
	WithColor(:info)

	AddNodeXT("seo_ok", "SEO Optimized?", :Decision)
	WithColor(:warning)

	AddNodeXT("schedule", "Schedule Publication", :Process)
	WithColor(:success)

	AddNodeXT("publish", "Publish", :Process)
	WithColor(:success)

	AddNodeXT("promote", "Promote on Social", :Data)
	WithColor(:neutral)

	AddNodeXT(:ID = "live", :Label = "Content Live", :Type = :Endpoint)
	WithColor(:success)

	AddNodeXT("revisions", "Request Revisions", :Data)
	WithColor(:warning)

	ConnectXT("idea", :To = "research", :With = "")
	ConnectXT("research", :To = "draft", :With = "")
	ConnectXT("draft", :To = "editor_review", :With = "")
	ConnectXT("editor_review", :To = "editor_ok", :With = "")
	ConnectXT("editor_ok", :To = "fact_check", :With = "Yes")
	ConnectXT("editor_ok", :To = "revisions", :With = "No")
	ConnectXT("revisions", :To = "draft", :With = "")

	ConnectXT("fact_check", :To = "facts_ok", :With = "")
	ConnectXT("facts_ok", :To = "design", :With = "Yes")
	ConnectXT("facts_ok", :To = "revisions", :With = "No")

	ConnectXT("design", :To = "seo_review", :With = "")
	ConnectXT("seo_review", :To = "seo_ok", :With = "")
	ConnectXT("seo_ok", :To = "schedule", :With = "Yes")
	ConnectXT("seo_ok", :To = "revisions", :With = "No")

	ConnectXT("schedule", :To = "publish", :With = "")
	ConnectXT("publish", :To = "promote", :With = "")
	ConnectXT("promote", :To = "live", :With = "")

	Render("example18_publishing_workflow.svg")
}

pf()

#-----------------#
#  EXAMPLE 19: RECRUITMENT & HIRING WORKFLOW
#-----------------#
