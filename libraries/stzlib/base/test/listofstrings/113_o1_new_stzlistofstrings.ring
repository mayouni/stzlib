# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #113.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([

	"What's your name please",
	"Mabrooka",
	"Your name and my name are not the same",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? @@( o1.FindSubString("name") )
#--> [
#	[ 1, [ 13 ]    ],
#	[ 3, [ 6, 18 ] ]
#    ]

? @@( o1.FindNthOccurrenceOfSubString(3, "name") )
#--> [ 2, 18 ]

pf()
