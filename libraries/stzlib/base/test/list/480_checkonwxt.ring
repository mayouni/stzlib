# Narrative
# --------
# #TODO
#
# Extracted from stzlisttest.ring, block #480.

load "../../stzBase.ring"

pr()

StartProfiler()

o1 = new stzList([ "Word1", "كلمة 2", "Word3", "كلمة 4", "Word5", "كلمة 6" ])
? o1.CheckOnWF([1, 3, 5], func x { return Q(x).IsLeftToRight() } )
#--> TRUE

StopProfiler()
#--> Executed in 0.03 second.

pf()
