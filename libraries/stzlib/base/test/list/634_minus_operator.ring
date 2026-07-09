# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #634.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "b", "b", "c" ])
? o1 - "b"
#--> [ "a", "c" ]

? o1 - These([ "b", "c", "b" ])
#--> [ "a" ]

pf()
# Executed in almost 0 second(s).
