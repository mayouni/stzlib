# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #207.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "programming", "is" ])
? o1.SortedBy('len(@item)')
#--> [ "is", "programming" ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
