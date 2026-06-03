# Narrative
# --------
# Flat organizational structure for startups
#
# Extracted from stzdiagrambuildertest.ring, block #14.
#ERR Error (R24) : Using uninitialized variable: showing

load "../../stzBase.ring"

	showing organic collaboration patterns

pr()

oStartupOrg = new stzDiagramMaker("Lean Startup - Flat Structure")
oStartupOrg {
	SetTheme(:Vibrant)
	SetLayout(:Organic)

	AddNodeXT("founder", "Founder/CEO", :Event)
	WithColor(:primary)

	AddNodeXT("dev1", "Full-Stack Dev", :Process)
	WithColor(:success)

	AddNodeXT("dev2", "Full-Stack Dev", :Process)
	WithColor(:success)

	AddNodeXT("design", "Designer/UX", :Process)
	WithColor(:info)

	AddNodeXT("marketing", "Marketing", :Process)
	WithColor(:warning)

	AddNodeXT("sales", "Sales", :Process)
	WithColor(:warning)

	AddNodeXT("ops", "Operations", :Process)
	WithColor(:neutral)

	ConnectXT("founder", :To = "dev1", :With = "")
	ConnectXT("founder", :To = "dev2", :With = "")
	ConnectXT("founder", :To = "design", :With = "")
	ConnectXT("founder", :To = "marketing", :With = "")
	ConnectXT("founder", :To = "sales", :With = "")
	ConnectXT("founder", :To = "ops", :With = "")

	ConnectXT("dev1", :To = "design", :With = "")
	ConnectXT("dev1", :To = "marketing", :With = "")
	ConnectXT("design", :To = "marketing", :With = "")
	ConnectXT("marketing", :To = "sales", :With = "")

	Render("example13_startup_org.svg")
}

pf()

#-----------------#
#  EXAMPLE 14: E-COMMERCE ORDER WORKFLOW
#-----------------#
