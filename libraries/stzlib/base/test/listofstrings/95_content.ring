# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #95.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

o1.RemoveDuplicatesCS(FALSE)
? @@(o1.Content())
#--> [ "tunis", "gatfsa", "gabes", "regueb", "sfax" ]

pf()
# Executed in 0.49 second(s): takes a while because it's not based on Qt
