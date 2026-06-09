# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #66.
#ERR Error (R21) : Using operator with values of incorrect type

load "../../stzBase.ring"

pr()

o1 = new stzString("---ring---ring--ring--")
? @@( o1.FindInSections("ring", [ [3, 8], [10, 15], [16, 21] ]) )
#--> [4, 11, 17 ]

? @@( o1.FindInSectionsAsSections("ring", [ [3, 8], [10, 15], [16, 21] ]) )
#--> [ [ 4, 7 ], [ 11, 14 ], [ 17, 20 ] ]

pf()
# Executed in 0.10 second(s)
