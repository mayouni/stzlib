# Narrative
# --------
# Extracted from stzlisttest.ring, block #567.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "C", "D", "e" ])
# Migrated to WF: the W condition called a Ring method (Q(..).IsLowercase()),
# which the engine DSL has no dispatch for by design -> anonymous-function form.
o1.InsertBeforeWF( func x { return Q(x).IsLowercase() }, "*" )
? o1.Content()
#--> [ "*", "a", "*", "b", "C", "D", "*", "e" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.07 second(s) before
