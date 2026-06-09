# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #65.
#ERR Error (R14) : Calling Method without definition: findstringcs

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([

	"What's your name please",
	"Mabrooka",
	"Your name is a nice name",
	"I see",
	"Nice to meet you",
	"Mabrooka"
])

? o1.FindStringCS("i see", :CaseSensitive = FALSE) #--> [4]
? o1.FindStringCS("mabrooka", :CaseSensitive = FALSE) #--> [ 2, 6 ]

? o1.FindManyStringsCS( [ "i see", "mabrooka" ], :CS = FALSE ) # [ 2, 4, 6 ]

pf()
