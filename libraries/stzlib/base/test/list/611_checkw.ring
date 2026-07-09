# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #611.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", 5, "B", "C" ])

? o1.CheckW('{ isString(@item) and IsUppercase(@item) }')
#--> FALSE

pf()
# Executed in 0.10 second(s) in Ring 1.22
