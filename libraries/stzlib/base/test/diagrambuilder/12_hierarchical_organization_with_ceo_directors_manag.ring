# Narrative
# --------
# Hierarchical organization with CEO, directors, managers,
#
# Extracted from stzdiagrambuildertest.ring, block #12.

load "../../stzBase.ring"

	and individual contributors showing reporting structure

pr()

oOrgChart = new stzDiagramMaker("Company Organization Chart")
oOrgChart {
	SetTheme(:Professional)
	SetLayout(:TopDown)
	SetBackgroundColor("white")

	AddNodeXT(:ID = "ceo", :Label = "CEO\nJohn Smith", :Type = :Process)
	WithColor(:primary)

	AddNodeXT("cto", "CTO\nAlice Johnson", :Process)
	WithColor(:info)

	AddNodeXT("cfo", "CFO\nBob Williams", :Process)
	WithColor(:warning)

	AddNodeXT("coo", "COO\nCarol Davis", :Process)
	WithColor(:success)

	AddNodeXT("dev_lead", "Dev Lead\nEric Brown", :Process)
	WithColor(:primary)

	AddNodeXT("devops_lead", "DevOps Lead\nFiona Green", :Process)
	WithColor(:primary)

	AddNodeXT("finance_lead", "Finance Lead\nGeorge White", :Process)
	WithColor(:warning)

	AddNodeXT("senior_dev1", "Senior Dev\nHenry Black", :Process)
	WithColor(:neutral)

	AddNodeXT("senior_dev2", "Senior Dev\nIsabel Lopez", :Process)
	WithColor(:neutral)

	AddNodeXT("junior_dev1", "Junior Dev\nJack Miller", :Process)
	WithColor(:neutral)

	AddNodeXT("junior_dev2", "Junior Dev\nKate Taylor", :Process)
	WithColor(:neutral)

	ConnectXT("ceo", :To = "cto", :With = "Reports")
	ConnectXT("ceo", :To = "cfo", :With = "Reports")
	ConnectXT("ceo", :To = "coo", :With = "Reports")

	ConnectXT("cto", :To = "dev_lead", :With = "")
	ConnectXT("cto", :To = "devops_lead", :With = "")

	ConnectXT("cfo", :To = "finance_lead", :With = "")

	ConnectXT("dev_lead", :To = "senior_dev1", :With = "")
	ConnectXT("dev_lead", :To = "senior_dev2", :With = "")

	ConnectXT("senior_dev1", :To = "junior_dev1", :With = "Mentors")
	ConnectXT("senior_dev2", :To = "junior_dev2", :With = "Mentors")

	Render("example11_orgchart_traditional.svg")
}

pf()

#-----------------#
#  EXAMPLE 12: MATRIX ORGANIZATION
#-----------------#
