# Narrative
# --------
# Extracted from stzlisttest.ring, block #565.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "C", "D", "e" ])

o1.InsertAfterW( '{ Q(This[@i]).IsLowercase() }', "*" )
? @@( o1.Content() )
#--> [ "a", "*", "b", "*", "C", "D", "e", "*" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.07 second(s) before
