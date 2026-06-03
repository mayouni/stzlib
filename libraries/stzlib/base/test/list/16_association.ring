# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #16.

load "../../stzBase.ring"

pr()

? @@( Association([ "A":"C", 1:3, "a":"c" ]) )
#--> [ [ "A", 1, "a" ], [ "B", 2, "b" ], [ "C", 3, "c" ] ]

pf()
# Executed in 0.03 second(s)
