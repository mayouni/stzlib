# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #567.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "C", "D", "e" ])
o1.InsertBeforeW( '{ Q(This[@i]).IsLowercase() }', "*" )
? o1.Content()
#--> [ "*", "a", "*", "b", "C", "D", "*", "e" ]

pf()
# Executed in 0.07 second(s).
