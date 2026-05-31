# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #399.

load "../../../stzBase.ring"


? Q([ "A", 1:3, "B", 1:3, "C" ]).ItemRemoved(1:3)
#--> [ "A", "B", "C" ]

? Q([ "A", 1:3, "B", 1:3, "C" ]).ItemRemovedW('isList(This[@i])')
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.04 second(s).
