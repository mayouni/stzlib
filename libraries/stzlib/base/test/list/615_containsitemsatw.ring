# Narrative
# --------
# *
#
# Extracted from stzlisttest.ring, block #615.
#ERR Error (R14) : Calling Method without definition: containsitemsatw

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", 1:3, "B", "C", 1:3, 1:3 ])

? o1.ContainsItemsAtW(	# Or ContainsAtW()
	[ 2, 5, 6 ],
	'isList(This[@i]) and len(This[@i]) = 3'
)
#--> TRUE

? o1.ContainsItemsAtW(
	[ 2, 3, 6 ],
	'isList(This[@i]) and len(This[@i]) = 3'
)
#--> FALSE

pf()
