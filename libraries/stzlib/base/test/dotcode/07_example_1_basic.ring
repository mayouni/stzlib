# Narrative
# --------
# #  Example 1: Basic  #
#
# Extracted from stzdotcodetest.ring, block #7.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#--------------------#

pr()

Dot = new stzDotCode()

Dot.SetCode('
	# This is my first Graphviz diagram
	digraph G {
	    a -> b;
	    b -> c;
	    a -> c;
	}
')

Dot.ExecuteAndView()

# Duration in seconds
? Dot.Duration()
#--> 0.30 second(s)

pf()
# Executed in 0.44 second(s) in Ring 1.24
