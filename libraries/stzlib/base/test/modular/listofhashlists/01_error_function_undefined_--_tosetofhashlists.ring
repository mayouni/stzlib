# Narrative
# --------
# ERROR: function undefined --> ToSetOfHashLists
#
# Extracted from stzlistofhashliststest.ring, block #1.

load "../../../stzBase.ring"

aList = [

	[ :number = 1, :name = "teeba", :age = 10 	],
	[ :number = 2, :name = "haneen", :age = 7 	],
	[ :number = 2, :name = "hussein", :age = 1 	]

]

o1 = new stzListOfHashLists( aList )
? o1.ToSetOfHashLists()
#-->
/*
	[ :number = 1, :name = "teeba", :age = 10 	],
	[ :number = 2, :name = [ "haneen", "hussein" ], :age = [ 7, 1]	],

*/
