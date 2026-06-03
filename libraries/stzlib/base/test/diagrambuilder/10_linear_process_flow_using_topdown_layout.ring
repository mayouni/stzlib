# Narrative
# --------
# Linear process flow using TopDown layout
#
# Extracted from stzdiagrambuildertest.ring, block #10.

load "../../stzBase.ring"

	ideal for sequential step-by-step processes

pr()

oLayoutTopDown = new stzDiagramMaker("Process Flow - Top Down")
oLayoutTopDown {
	SetTheme(:Vibrant)
	SetLayout(:TopDown)

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

	Render("example9_layout_topdown.svg")
}

pf()

#-----------------#
#  EXAMPLE 10: LAYOUT COMPARISON - LEFTRIGHT
#-----------------#
