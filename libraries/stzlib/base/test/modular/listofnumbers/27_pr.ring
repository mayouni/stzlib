# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #27.

load "../../../stzBase.ring"


? Q([1, 2, "*", 3 ]) + "*"
#--> [ 1, 2, 3 ]

? Q([1, 2, "*", 3 ]) + Q("*")
#--> A stzList object containg [ 1, 2, 3 ]

pf()
# Executed in 0.03 second(s)
