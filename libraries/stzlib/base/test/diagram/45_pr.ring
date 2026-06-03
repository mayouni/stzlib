# Narrative
# --------
# pr()
#
# Extracted from stzdiagramtest.ring, block #45.

load "../../stzBase.ring"

pr()

? keys([ [ "color", "process" ], [ "color", "blue" ], [ "priority", "high" ] ])
#--> Incorrect param type! paList must be a hashlist.
#~> Because "color" is used twice as a key.

pf()
