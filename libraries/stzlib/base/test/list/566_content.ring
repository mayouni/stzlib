# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #566.
#ERR Error (R14) : Calling Method without definition: insertafterwxt

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "C", "D", "e" ])

o1.InsertAfterWXT( '{ Q(@item).IsLowercase() }', "*" )
? @@( o1.Content() )

#--> [ "a", "*", "b", "*", "C", "D", "e", "*" ]

pf()
# Executed in 0.14 second(s).
