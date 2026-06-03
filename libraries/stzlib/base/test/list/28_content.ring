# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #28.
#ERR Error (R14) : Calling Method without definition: replaceatbymanyxt

load "../../stzBase.ring"

pr()

o1 = new stzList([ "_", "_", "3", "4", "5", "6", "7", "_", "_" ])

o1.ReplaceAtByManyXT(3:5, [ "-3", "-4", "-5" ])
? @@( o1.Content() )
#--> [ "_", "_", "-3", "-4", "-5", "6", "7", "_", "_" ]

pf()
# Executed in 0.07 second(s)
