# Narrative
# --------
# FLUENT VISUAL RULES (WITH CLASS)
#
# Extracted from stzdiagramtest.ring, block #54.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("TaskPriorities")
oDiag {
	AddNodeXTT("low", "Low Priority", [:priority = 1])
	AddNodeXTT("med", "Medium Priority", [:priority = 5])
	AddNodeXTT("high", "High Priority", [:priority = 10])
	AddNodeXTT("critical", "CRITICAL", [:priority = 15])
	
	Connect("low", "med")
	Connect("med", "high")
	Connect("high", "critical")
	
	# Option 1: Pure data (as before)
	RegisterVisualRule("LOW_PRIORITY", [
		:conditionType = "property_range",
		:conditionParams = ["priority", 1, 3],
		:effects = [["color", "green"]]
	])
	
	RegisterVisualRule("CRITICAL_PRIORITY", [
		:conditionType = "property_range",
		:conditionParams = ["priority", 10, 99],
		:effects = [["color", "red"], [	"penwidth", 3 ]]
	])
	
	ApplyVisualRules()

	? @@NL(VisualRulesApplied())
	
	View()
}

pf()
# Executed in 0.58 second(s) in Ring 1.25
