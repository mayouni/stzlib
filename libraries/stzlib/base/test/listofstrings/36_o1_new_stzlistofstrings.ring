# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #36.

load "../../stzBase.ring"

	"What's your name please",
	"Mabrooka",
	"Your name and my name are not the same",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? o1.FindNthOccurrenceOfSubString(2, "name")
#--> [ 3, 6 ]
