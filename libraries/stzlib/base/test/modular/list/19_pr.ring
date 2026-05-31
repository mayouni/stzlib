# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #19.

load "../../../stzBase.ring"


StzListQ([ "1":"3", "2":"7", "10":"12" ]) {
	Flatten()
	Sort()

	Show() + NL
	#--> [ "1", "10", "2", "2", "3", "3", "4", "5", "6", "7" ]

	? @@( FindItems() ) + NL # Or ItemsAndTheirPositions() or ItemsZ()
	#-->[
	# 	[ "1", [ 1 ] ], [ "10", [ 2 ] ], [ "2", [ 3, 4 ] ],
	# 	[ "3", [ 5, 6 ] ], [ "4", [ 7 ] ], [ "5", [ 8 ] ],
	# 	[ "6", [ 9 ] ], [ "7", [ 10 ] ]
	# ]

	? @@( NumberOfOccurrenceOfEachItem() ) # Or ItemsCount()
	#-->[
	# 	[ "1", 1 ], [ "10", 1 ], [ "2", 2 ],
	# 	[ "3", 2 ], [ "4", 1 ], [ "5", 1 ],
	# 	[ "6", 1 ], [ "7", 1 ]
	# ]
}

pf()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
