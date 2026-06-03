# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #140.
#ERR Error (R14) : Calling Method without definition: duporigins

load "../../stzBase.ring"

pr()

# DupOrigins = DuplicatesOrigins

o1 = new stzList([ "A", "B", "B", "B", "b", "C", "B", "C", "C", "c", "A" ])

? o1.DupOrigins() # Same As Duplicates()
#--> [ "A", "B", "C" ]

? o1.FindDupOrigins()
#--> [ 1, 2, 6 ]

o1.RemoveDupOrigins()
? @@( o1.Content() )
#--> [ "B", "B", "b", "B", "C", "C", "c", "A" ]

pf()
# Executed in almost 0 second(s).
