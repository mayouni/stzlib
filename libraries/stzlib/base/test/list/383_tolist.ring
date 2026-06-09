# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #383.
#ERR exit 1: "

load "../../stzBase.ring"

pr()

? Q(' "A" : "C" ').ToList()
#--> [ "A", "B", "C" ]

? Q(' "ا" : "ج" ').ToList()
#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

pf()
# Executed in 0.09 second(s).
