# Narrative
# --------
# Same state machine with dark professional theme
#
# Extracted from stzdiagrambuildertest.ring, block #4.

load "../../../stzBase.ring"

	showing theme portability

pr()

oStateDark = new stzDiagramMaker("State Machine - Dark Theme")
oStateDark {
	SetTheme(:Dark)
	SetLayout(:TopDown)

	AddNodeXT("idle", "Idle", :State)
	WithColor(:neutral)

	AddNodeXT("running", "Running", :State)
	WithColor(:success)

	AddNodeXT("paused", "Paused", :State)
	WithColor(:warning)

	AddNodeXT("stopped", "Stopped", :State)
	WithColor(:danger)

	ConnectXT("idle", :To = "running", :With = "start()")
	ConnectXT("running", :To = "paused", :With = "pause()")
	ConnectXT("paused", :To = "running", :With = "resume()")
	ConnectXT("running", :To = "stopped", :With = "stop()")
	ConnectXT("paused", :To = "stopped", :With = "stop()")
	ConnectXT("stopped", :To = "idle", :With = "reset()")

	Render("example3_state_dark.svg")
}

pf()

#-----------------#
#  EXAMPLE 4: DATABASE ARCHITECTURE
#-----------------#
