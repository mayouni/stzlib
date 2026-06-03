# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #398.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "A":"B", 2, 3, "X", "Y", "Z" ])

? o1 - "A":"B"
#--> [ 1, 2, 3, "X", "Y", "Z" ]

? @@( o1 - These([ "X", "Y", "Z" ]) )
#--> [ 1, [ "A", "B" ], 2, 3 ]

pf()
# Executed in almost 0 second(s).
