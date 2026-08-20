# A Ring-defined agent. Same folder, same gates, different notation.
#
# The PROGRAM loads this file (the folder does not evaluate source -- see
# stzAgentFolder._ReadRingAgent for the measured reason). The folder then
# finds watcherAgent(), holds it to the same four gates a .pia passes,
# and supervises it on the schedule it declares for itself.

func watcherAgent()
	return new watcherAgentClass("watcher")

class watcherAgentClass from stzPIAgent

	def init(pcName)
		super.init(pcName)

	def CoverageStatement()
		return "watches the queue and marks whatever it finds as seen"

	def ReversibilityClass()
		return "reversible"

	def Schedule()
		return [ :mode = "timer", :timer = 25, :channel = "" ]
