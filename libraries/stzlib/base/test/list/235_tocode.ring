# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #235.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "b", "C", "B", '"B",', "D", "E" ])
? o1.ToCode()
#-->  [ "A", "b", "C", "B", '"B",', "D", "E" ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in ring 1.17
