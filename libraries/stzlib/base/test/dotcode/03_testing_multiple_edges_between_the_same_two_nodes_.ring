# Narrative
# --------
# Testing multiple edges between the same two nodes (multigraph)
#
# Extracted from stzdotcodetest.ring, block #3.

load "../../stzBase.ring"


pr()

oDot = new stzDotCode()
oDot.SetCode(`
	digraph G {
	    // 'strict' is omitted, so multiple edges are allowed
	    a -> b [label="edge #1"];
	    a -> b [label="edge #2"];
	    a -> b [label="edge #3"];
	}
`)

oDot.View()

pf()
# Executed in 0.44 second(s) in Ring 1.25
