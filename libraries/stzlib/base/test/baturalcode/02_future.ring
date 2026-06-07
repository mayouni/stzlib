# Narrative
# --------
# pr()
#
# Extracted from stzbaturalcodetest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

oStr = new stzString("ring")

AddFuture(:Uppercase) # or AddfutureAction()
AddFuture(:Replace = [ "I", "♥" ])

? @@(Future()) + NL # Or FutureActions()
#--> [
#	[ "uppercase", [ ] ],
#	[ "replace", [ "I", "♥" ] ]
# ]

ExecuteActions( Future(), :on = oStr )
? oStr.Content()
#--> R♥NG

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.02 second(s) in Ring 1.20
