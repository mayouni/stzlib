# Narrative
# --------
#
# Extracted from stzlistofhashliststest.ring, block #2.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

aList = [
	[ :name = "Avionav", 	:type = "Company", 	:domain = "Aeorospace" 	],
	[ :name = "Photoshop", 	:type = "software", 	:domain = "Graphics" 	],
	[ :name = "Ring", 	:type = "Language", 	:domain = "Programming" ]
]

o1 = new stzListOfHashLists(aList)

? o1.Show()

pf()
