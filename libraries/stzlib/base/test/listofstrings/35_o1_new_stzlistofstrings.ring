# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #35.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([

	"what's your name please",
	"mabrooka",
	"your name and my name are not the same",
	"i see",
	"nice to meet you",
	"mabrooka"
])

? @@( o1.FindSubStrings([ "name", "mabrooka"]) ) + NL
#-->
#  [
#	# "name" is found here
#	[
#		[ 1, [ 13 ] ], [ 3, [ 6, 18 ] ]
#	],
#
#	# and "mabrooka" is found here
#	[
#		[ 2, [ 1 ] ], [ 6, [ 1 ] ]
#	]
#  ]

? @@( o1.FindSubStringsXT([ "name", "mabrooka"]) )
#-->
#  [
#	# "name" is found here
#	[
#		[ 1, 13 ], [ 3, 6 ], [ 3, 18 ]
#	],
#
#	# and "mabrooka" is found here
#	[
#		[ 2, 1 ], [ 6, 1 ]
#	]
#  ]

pf()
