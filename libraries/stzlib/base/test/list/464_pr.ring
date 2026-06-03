# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #464.

load "../../stzBase.ring"


? @@( StzListQ([ "a", [ "b", [ "c",  "d" ], "e" ], "f" ]).Flattened() )
#--> [ "a","b","c","d","e","f" ]

pf()
# Executed in almost 0 second(s).
