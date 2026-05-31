# Narrative
# --------
# Event emitter publishing to multiple subscribers
#
# Extracted from stzdiagrambuildertest.ring, block #6.

load "../../../stzBase.ring"

	with organic layout for non-hierarchical systems

pr()

oEventSystem = new stzDiagramMaker("Event-Driven System")
oEventSystem {
	SetTheme(:Vibrant)
	SetLayout(:Organic)

	AddNodeXT("event", "Event Emitter", :Event)
	WithColor(:primary)

	AddNodeXT("subscriber1", "Subscriber 1", :Process)
	WithColor(:success)

	AddNodeXT("subscriber2", "Subscriber 2", :Process)
	WithColor(:info)

	AddNodeXT("subscriber3", "Subscriber 3", :Process)
	WithColor(:warning)

	AddNodeXT("logger", "Logger", :Data)
	WithColor(:neutral)

	ConnectXT("event", :To = "subscriber1", :With = "on_update")
	ConnectXT("event", :To = "subscriber2", :With = "on_update")
	ConnectXT("event", :To = "subscriber3", :With = "on_update")
	ConnectXT("subscriber1", :To = "logger", :With = "log")
	ConnectXT("subscriber2", :To = "logger", :With = "log")
	ConnectXT("subscriber3", :To = "logger", :With = "log")

	Render("example5_events.svg")
}

pf()

#-----------------#
#  EXAMPLE 6: COMPLEX DECISION TREE
#-----------------#
