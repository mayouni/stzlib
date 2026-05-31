# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #232.

load "../../../stzBase.ring"


o1 = new stzList([
	[ "A", "B", "C" ],
	[ 1, 2, 3 ],
	[ NULL, NULL, [] ]
])

? o1.IsMadeOfUniformLists() # Or more precisely: IsMadeOfUnisizeLists()
#--> TRUE

pf()
# Executed in almost 0 second(s).
