# Narrative
# --------
# pr()
#
# Extracted from stzsubstringTest.ring, block #5.
#ERR Error (R14) : Calling Method without definition: substringisaword

load "../../stzBase.ring"

pr()

? Q("I love Ring").Words()
#--> [ "I", "love", "Ring" ]

? Q("I love Ring").SubStringIsAWord("Ring")
#--> TRUE

pf()
