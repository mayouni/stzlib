# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #76.
#ERR Error (R14) : Calling Method without definition: replaceoccurrencesbymany

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "*", "D", "*",  "=" ])

o1.ReplaceOccurrencesByMany([ 3, 5, 6 ], ["C", "E", "F"])

? @@( o1.Content() )
#--> [ "A", "B", "C", "D", "E", "F" ]

pf()
# Executed in 0.06 second(s)
