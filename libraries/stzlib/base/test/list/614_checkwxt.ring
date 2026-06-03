# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #614.

load "../../stzBase.ring"

pr()

# All items are lLists having same number of items

o1 = new stzList([ 1:3, 1:3, 1:3 ])
? o1.CheckWXT('isList(@item) and len(@item) = len(o1[1])')
#--> TRUE

pf()
# Executed in 0.10 second(s) in Ring 1.22
