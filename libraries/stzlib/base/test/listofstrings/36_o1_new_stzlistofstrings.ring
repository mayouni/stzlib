# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #36.
#ERR Error (R14) : Calling Method without definition: findnthoccurrenceofsubstring

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

? o1.FindNthOccurrenceOfSubString(2, "name")
#--> [ 3, 6 ]

pf()
