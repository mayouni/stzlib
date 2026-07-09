# Narrative
# ---------
#
# Extracted from stzlisttest.ring, block #480.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "Word1", "كلمة 2", "Word3", "كلمة 4", "Word5", "كلمة 6" ])
? o1.CheckOnWF([1, 3, 5], func x { return Q(x).IsLeftToRight() } )
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.03 second(s) before
