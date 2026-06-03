# Narrative
# --------
# State machine demonstrating all state transitions
#
# Extracted from stzdiagrambuildertest.ring, block #3.

load "../../stzBase.ring"

	with light color palette

pr()

oStateLight = new stzDiagramMaker("State Machine - Light Theme")
oStateLight {
	SetTheme(:Light)
	SetLayout(:TopDown)
	SetFont(:default)

	AddNodeXT(:ID = "idle", :Label = "Idle", :Type = :State)
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

	Render("example2_state_light.svg")
}

pf()

#-----------------#
#  EXAMPLE 3: STATE MACHINE - DARK THEME
#-----------------#
