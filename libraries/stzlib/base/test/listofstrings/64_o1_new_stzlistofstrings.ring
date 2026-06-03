# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #64.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	"What's your name please",
	"Mabrooka",
	"Your name is a nice name",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? @@( o1.FindManySubstringsCSXT([ "name", "nice" ], TRUE) )
#--> [
#	[ "name" , [ [ 1, 13 ], [ 3, 6 ], [ 3, 21 ] ] ],
#	[ "nice" , [ [ 3, 16 ] ] ]
#     ]

pf()
