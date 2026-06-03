# Narrative
# --------
# Example 4: Empty Pattern
#
# Extracted from stzregexmakertest.ring, block #20.

load "../../../stzBase.ring"


pr()

o1 = new stzRecursiveRegexMaker()
o1 {
	? @@(Pattern())
	#--> ""
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
