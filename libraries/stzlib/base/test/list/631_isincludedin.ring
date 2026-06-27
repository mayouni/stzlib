# Narrative
# --------
# Extracted from stzlisttest.ring, block #631.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "green", "red" ])

? o1.IsIncludedIn([ "green", "red", "blue" ])
#--> FALSE

? o1.AreIncludedIn([ "green", "red", "blue" ])
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.02 second(s) before
