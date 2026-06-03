# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #65.
#ERR Error (R14) : Calling Method without definition: removeanyitemfromstart

load "../../stzBase.ring"

pr()

o1 = new stzList([ "🔻", "🔻", "1", "2", "3", "🔻", "🔻" ])
o1.RemoveAnyItemFromStart("🔻")
? @@( o1.Content() )
#--> [ "1", "2", "3", "🔻", "🔻" ]

o1.RemoveAnyItemFromEnd("🔻")
? @@( o1.Content() )
#--> [ "1", "2", "3" ]

pf()
# Executed in 0.01 second(s)
