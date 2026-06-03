# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #207.
#ERR Error (R14) : Calling Method without definition: sortedby

load "../../stzBase.ring"

pr()

o1 = new stzList([ "programming", "is" ])
? o1.SortedBy('Q(@item).NumberOfChars()')
#--> [ "is", "programming" ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
