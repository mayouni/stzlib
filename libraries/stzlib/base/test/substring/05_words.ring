# Narrative
# --------
# pr()
#
# Extracted from stzsubstringTest.ring, block #5.

load "../../stzBase.ring"

pr()

? Q("I love Ring").Words()
#--> [ "I", "love", "Ring" ]

? Q("I love Ring").SubStringIsAWord("Ring")
#--> TRUE

pf()
