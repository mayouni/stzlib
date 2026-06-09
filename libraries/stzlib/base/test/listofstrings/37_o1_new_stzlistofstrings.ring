# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #37.
#ERR Error (R14) : Calling Method without definition: findsubstring

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([

	"What's your name please?",
	"Mabrooka!",
	"Your name and my name are not the same...",
	"I see.",
	"Nice to meet you,",
	"Mabrooka!"
])
	
? @@( o1.FindSubstring("name") ) + NL
#--> [ [ 1, [ 13 ] ], [ 3, [6, 18 ] ] ]

# For your convinience, you can get the result in an exmpanded form:
? @@( o1.FindSubStringXT("name") )
#--> [ [ 1, 13 ], [ 3, 6 ], [ 3, 18 ] ]

pf()
