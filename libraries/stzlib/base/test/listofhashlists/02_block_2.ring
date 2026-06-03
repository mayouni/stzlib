# Narrative
# --------
#
# Extracted from stzlistofhashliststest.ring, block #2.

load "../../stzBase.ring"

aList = [
	[ :name = "Avionav", 	:type = "Company", 	:domain = "Aeorospace" 	],
	[ :name = "Photoshop", 	:type = "software", 	:domain = "Graphics" 	],
	[ :name = "Ring", 	:type = "Language", 	:domain = "Programming" ]
]

o1 = new stzListOfHashLists(aList)

? o1.Show()
