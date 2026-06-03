# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #63.
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

? @@( o1.FindSubstringCS("name", TRUE) ) + NL
#--> [
#	[ 1, [ 13    ] ],
#	[ 3, [ 6, 21 ] ]
#    ]

? @@( o1.FindNthSubstringCS(2, "name", TRUE) )
#--> [ 3, 6 ]
#--> The 2nd occurrenc of "name" in the list
# of strings is in position 6 of the 3rd string.

pf()
