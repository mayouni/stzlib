# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #543.

load "../../stzBase.ring"


o1 = new stzList([ "a", 1, "b", 2, "c", 3 ])
o1.RemoveWXT('Not isNumber(@item)')
? o1.Content()
#--> [ 1, 2, 3 ]

pf()
# Executed in 0.12 second(s).
