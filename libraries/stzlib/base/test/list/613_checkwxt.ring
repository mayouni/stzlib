# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #613.

load "../../stzBase.ring"

pr()

# All items are lists with 3 items

o1 = new stzList([ 1:3, 1:3, 1:3, 5 ])
? o1.CheckWF( func x { return isList(x) and len(x) = 3 } )
#--> FALSE

pf()
# Executed in 0.10 second(s) in Ring 1.22
