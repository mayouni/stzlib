# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #334.
#ERR Error (R14) : Calling Method without definition: typesxt

load "../../stzBase.ring"

pr()

? @@( Q([ "AB", 12, ["A", "B"] ]).TypesXT() )
#--> [ [ "AB", "STRING" ], [ 12, "NUMBER" ], [ [ "A", "B" ], "LIST" ] ]

pf()
# Executed in almost 0 second(s).
