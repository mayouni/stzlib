# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #564.
#ERR Error (R14) : Calling Method without definition: findallwxt

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "C", "D", "e" ])

? o1.FindAllW('{ Q(This[@i]).IsLowercase() }')
#--> [ 1, 2, 5 ]
# Executed in 0.08 second(s).

? o1.FindAllWXT('{ Q(@item).IsLowercase() }')
#--> [ 1, 2, 5 ]
# Executed in 0.14 second(s).

pf()
# Executed in 0.18 second(s).
