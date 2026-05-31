# Narrative
# --------
# Simple process flow with theme and layout
#
# Extracted from stzdiagrambuildertest.ring, block #2.

load "../../../stzBase.ring"

pr()

oDiagMaker = new stzDiagramMaker("Order Processing")
oDiagMaker {

	# Configuring Theme, layout and colors

	SetTheme(:Vibrant)
	SetLayout(:LeftRight)
	SetEdgeColor(:Gray)
	SetNodeStrokeColor(:Gray)

	# Desiging the nodes

	AddNodeXT(:ID = "start", :Label = "Start Order", :Type = :Start)
	WithColor(:Success)

	AddNodeXT("verify", "Verify Payment", :Process)
	WithColor(:Primary)

	AddNodeXT("decision", "Payment OK?", :Decision)
	WithColor(:Warning)

	AddNodeXT("ship", "Ship Order", :Process)
	WithColor(:Primary)

	AddNodeXT("end", "Order Complete", :Endpoint)
	WithColor(:Success)

	# Connecting the nodes

	ConnectXT("start", :To = "verify", :With = "Step 1")
	ConnectXT("verify", :To = "decision", :With = "Check")
	ConnectXT("decision", :To = "ship", :With = "Yes")
	ConnectXT("ship", :To = "end", :With = "Complete")

	# Rendering and display the diagram
	Show()
}

pf()

#-----------------#
#  EXAMPLE 2: STATE MACHINE - LIGHT THEME
#-----------------#
