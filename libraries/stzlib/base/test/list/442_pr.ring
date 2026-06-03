# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #442.

load "../../stzBase.ring"


o1 = new stzList([ "1", "2", "*", "4", "5" ])

o1.ReplaceAt(3, :By = "3")
? @@( o1.Content() )
#--> [ "1", "2", "3", "4", "5" ]

o1 = new stzList([ "1", "_", "3", "_", "_" ])
o1.ReplaceNextNthOccurrenceST( 2, :Of = "_", :With = "5", :StartingAt = 3)
? @@( o1.Content() )
#--> [ "1", "_", "3", "_", "5" ]

pf()
# Executed in 0.03 second(s)  in Ring 1.21
