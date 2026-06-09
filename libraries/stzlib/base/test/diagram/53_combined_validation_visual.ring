# Narrative
# --------
# COMBINED VALIDATION + VISUAL
#
# Extracted from stzdiagramtest.ring, block #53.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("SecurePayment")
oDiag {
	SetTheme("neutral")
	# Nodes with security metadata
	AddNodeXTT(:@input, "User Input", [
		:Type = "start",
		:SecurityLevel = 1,
		:Sensitive = FALSE
	])

	AddNodeXTT(:@valid, "Validate", [
		:Type = "decision",
		:SecurityLevel = 2,
		:RequiresApproval = TRUE,
		:Approver = "security_team"
	])

	AddNodeXTT(:@process, "Process Payment", [
		:Type = "process",
		:SecurityLevel = 3,
		:Amount = 5000
	])

	AddNodeXTT(:@audit, "Audit Log", [
		:Type = "data",
		:SecurityLevel = 3,
		:Sensitive = TRUE
	])

	AddNodeXTT(:@done, "Complete", [
		:Type = "endpoint",
		:SecurityLevel = 1
	])

	Connect(:@input, :@valid)
	Connect(:@valid, :@process)
	Connect(:@process, :@audit)
	Connect(:@audit, :@done)

	# Visual rule: Highlight high-security nodes
	RegisterVisualRule("security_visual", [
		:ConditionType = "property_range",
		:ConditionParams = [ "securitylevel", 3, 5 ],
		:Effects = [
			:Color = "red",
			:Penwidth = 3
		]
	])
	
	# Visual rule: Mark sensitive data
	RegisterVisualRule("sensitive_marker", [
		:ConditionType = "property_equals",
		:ConditionParams = [ "sensitive", TRUE ],
		:Effects = [
			:Color = "orange",
			:Style = "bold,dashed"
		]
	])
	
	ApplyVisualRules()
	
	? @@NL(NodesAffectedByVisualRules()) + NL
	#--> [ "@process", "@audit" ]

	? @@NL( ValidateXT(:SOX) )
	#--> [
	# 	[ "status", "pass" ],
	# 	[ "domain", "sox" ],
	# 	[ "issuecount", 0 ],
	# 	[ "issues", [  ] ],
	# 	[ "affectednodes", [  ] ]
	# ]

	View()
}

#NOTE What's happening:
# 
# 1. @process: Matches security_visual rule only
#  	- Red color, penwidth=3
#
# 2. @audit: Matches both rules
# 	- First rule: security_visual (red, penwidth=3)
# 	- Second rule: sensitive_marker (orange, bold+dashed style)
# 	- Final merge: Orange color (overrides red), penwidth=3, bold+dashed style
#
# Visual confirmation in diagram:
# 	- Process_Payment: Red rounded box, thick border
# 	- Audit_Log: Orange dashed box, thick border ✓
# 
# The rule merging logic is working as designed - later rules override earlier
# ones for the same property (color), while accumulating unique properties
# (penwidth from first rule, style from second rule).

pf()
# Executed in 0.66 second(s) in Ring 1.25
