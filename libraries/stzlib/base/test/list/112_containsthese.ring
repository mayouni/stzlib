# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #112.
#ERR Error (R14) : Calling Method without definition: eachcontainsthese

load "../../stzBase.ring"

pr()

? Q([ "a", "♥", "*" ]).ContainsThese([ "♥", "*"])
#--> TRUE

o1 = new stzList([ [ "a", "♥", "*" ], [ "♥", "*"], [ "a", "b", "♥", "*" ] ])
? o1.EachContainsThese([ "♥", "*" ])
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.21
