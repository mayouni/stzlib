# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #114.

load "../../stzBase.ring"

pr()

	"What's your name please",
	"Mabrooka",
	"Your name and my name are not the same",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? @@( o1.FindSubStringsCS([ "name", "mabrooka" ], :CaseSensitive = FALSE) )
#-->
# [
#	[ [ 1, [ 13 ] ], [ 3, [ 6, 18 ] ] ],	#>>> "name" is found here
#	[ [ 2, [ 1 ] ], [ 6, [ 1 ] ] ]		#>>> "mabrooka" is found here
# ]

pf()
