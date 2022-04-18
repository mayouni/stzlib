load "stzlib.ring"

/*------------ ERROR: function undefined --> ToSetOfHashLists
aList = [

	[ :number = 1, :name = "teeba", :age = 10 	],
	[ :number = 2, :name = "haneen", :age = 7 	],
	[ :number = 2, :name = "hussein", :age = 1 	]

]

o1 = new stzListOfHashLists( aList )
? o1.ToSetOfHashLists()
# -->
/*
	[ :number = 1, :name = "teeba", :age = 10 	],
	[ :number = 2, :name = [ "haneen", "hussein" ], :age = [ 7, 1]	],

*/

/*----------------
*/
aList = [
	[ :name = "Avionav", 	:type = "Company", 	:domain = "Aeorospace" 	],
	[ :name = "Photoshop", 	:type = "software", 	:domain = "Graphics" 	],
	[ :name = "Ring", 	:type = "Language", 	:domain = "Programming" ]
]

o1 = new stzListOfHashLists(aList)

? o1.Show()
