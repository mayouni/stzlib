# Narrative
# --------
# Example 1: Simple balanced parentheses
#
# Extracted from stzregexmakertest.ring, block #17.

load "../../../stzBase.ring"


pr()

o1 = new stzRecursiveRegexMaker()
o1 {
	EnableNamedRecursion()
	
	AddLevel("expr", "\(")
	AddChildLevel("expr", "inner", "[^()]*")
	AddLevel("close", "\)")
	
	? Pattern()
	#--> (?P<expr>\()(?P<inner>[^()]*)\)
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
