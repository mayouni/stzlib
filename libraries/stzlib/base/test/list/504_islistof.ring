# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #504.
#ERR Error (R14) : Calling Method without definition: islistof

load "../../stzBase.ring"

pr()

# All these return TRUE

oNumber1 = StzNumberQ(7)
oNumber2 = StzNumberQ(12)
oNumber3 = StzNumberQ(24)

? Q([ oNumber1, oNumber2, oNumber3 ]).IsListOf(:StzNumbers)
#--> TRUE

? Q([ [oNumber1, oNumber2], [oNumber2, oNumber3] ]).IsListOf(:ListsOfStzNumbers)
#--> TRUE

oString1 = StzStringQ("Win")
oString2 = StzStringQ("Loose")
oString3 = StzStringQ("Don't care!")

? Q([ oString1, oString2, oString3 ]).IsListOf(:StzStrings)
#--> TRUE

? Q([ [oString1, oString2], [oString2, oString3] ]).IsListOf(:ListsOfStzStrings)
#--> TRUE

pf()
# Executed in 0.06 second(s).
