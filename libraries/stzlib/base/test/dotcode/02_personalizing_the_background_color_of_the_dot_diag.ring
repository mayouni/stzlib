# Narrative
# --------
# Personalizing the background color of the DOT diagram
#
# Extracted from stzdotcodetest.ring, block #2.

load "../../stzBase.ring"


pr()

oDot = new stzDotCode()
oDot.SetCode(`
	digraph G {
	    bgcolor="lightyellow";

	    a -> b [label="edge #1"];
	    a -> b [label="edge #2"];
	    a -> b [label="edge #3"];
	}
`)

oDot.View()
# Executed in 0.44 second(s) in Ring 1.25

pf()
