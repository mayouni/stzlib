# Narrative
# --------
# FindAll() locates every position where a given value occurs in a list.
#
# Here the list holds repeated pair values ([1,3], [4,6], etc.). Because
# Softanza treats each pair as a single comparable element, FindAll(1:3)
# scans for the element [1,3] and returns the list of all its 1-based
# positions -- here [ 1, 3, 4 ]. Contains(7:10) confirms the companion
# membership check: it reports TRUE because the pair [7,10] is present.
# Together they show that pair literals are first-class list elements that
# search and membership operations compare structurally, not by flattening.
#
# Extracted from stzlisttest.ring, block #380.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1:3, 4:6, 1:3, 1:3, 4:6, 7:10 ])

? o1.FindAll(1:3)
#--> [1, 3, 4]

? o1.Contains(7:10)
#--> TRUE	

pf()
# Executed in 0.02 second(s).
