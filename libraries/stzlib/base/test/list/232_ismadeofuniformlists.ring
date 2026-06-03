# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #232.
#ERR Error (R14) : Calling Method without definition: ismadeofuniformlists

load "../../stzBase.ring"

pr()

o1 = new stzList([
	[ "A", "B", "C" ],
	[ 1, 2, 3 ],
	[ NULL, NULL, [] ]
])

? o1.IsMadeOfUniformLists() # Or more precisely: IsMadeOfUnisizeLists()
#--> TRUE

pf()
# Executed in almost 0 second(s).
