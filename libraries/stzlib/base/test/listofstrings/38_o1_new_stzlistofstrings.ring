# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #38.

load "../../stzBase.ring"

	"___ ring ___",
	"___ ring ___ ring",
	"___ ruby ___ ring",
	"___ ring ___ ruby ___ ring"
])

? o1.NumberOfOccurrenceOfManySubStrings([ "ring", "ruby", "python" ])
#--> [ 6, 2, 0 ]

? @@( o1.NumberOfOccurrenceOfManySubStringsXT([ "ring", "ruby", "python" ]) )
#--> [
#	[ [ 1, 1], [2, 2], [3, 1], [4, 2] ], 	#<<< Occurrence of "ring"
#	[ [ 3, 1 ], , [ 4, 1 ] ], 		#<<< Occurrences of "ruby"
#	[  ] 					#<<< No occurrences at all for "pyhthon"
#   ]
