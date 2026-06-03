# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #101.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "Regueb", "sfax", "regueb", "Tunis"
])

//? @@( o1.DuplicatedStringsCS(TRUE) )
#--> [ "tunis" ]
# Executed in 0.26 second(s)

o1.RemoveDuplicatedStringsCS(TRUE)
? @@( o1.Content() )
#--> [ "gatfsa", "gabes", "Regueb", "sfax", "regueb", "Tunis" ]
# Executed in 0.35 second(s)

pf()
# Executed in 0.58 second(s)
