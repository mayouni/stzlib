# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #329.

load "../../stzBase.ring"


	o1 = new stzList([ "A", "B", "A", "C", "C", "D", "A", "E" ])
	
	? @@NL( o1.Index() ) # Or FindItems() or ItemsZ() or ItemsAndTheirPositions()
	#--> [
	# 	[ "A", [ 1, 3, 7 ] ],
	# 	[ "B", [ 2 ] ],
	# 	[ "C", [ 4, 5 ] ],
	# 	[ "D", [ 6 ] ],
	# 	[ "E", [ 8 ] ]
	# ]

StopProfiler()
#--> Executed in almost 0 second(s).
