# Narrative
# --------
# Same process flow using LeftRight layout
#
# Extracted from stzdiagrambuildertest.ring, block #11.

load "../../../stzBase.ring"

	better for wide screen presentation

pr()

oLayoutLeftRight = new stzDiagramMaker("Process Flow - Left Right")
oLayoutLeftRight {
	SetTheme(:Vibrant)
	SetLayout(:LeftRight)

	AddNodeXT(:ID = "s1", :Label = "Start", :Type = :Start)
	WithColor(:success)

	AddNodeXT("a1", "Step A", :Process)
	WithColor(:primary)

	AddNodeXT("a2", "Step B", :Process)
	WithColor(:primary)

	AddNodeXT("a3", "Step C", :Process)
	WithColor(:primary)

	AddNodeXT(:ID = "e1", :Label = "End", :Type = :Endpoint)
	WithColor(:success)

	ConnectXT("s1", :To = "a1", :With = "")
	ConnectXT("a1", :To = "a2", :With = "")
	ConnectXT("a2", :To = "a3", :With = "")
	ConnectXT("a3", :To = "e1", :With = "")

	Render("example10_layout_leftright.svg")
}

pf()

#-----------------#
#  EXAMPLE 11: TRADITIONAL ORGANIZATION CHART
#-----------------#
