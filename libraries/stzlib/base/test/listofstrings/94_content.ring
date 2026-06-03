# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #94.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

o1.RemoveDuplicates()
? @@( o1.Content() )
#--> [ "tunis", "gatfsa", "gabes", "regueb", "sfax", "Tunis" ]

pf()
# Executed in 0.03 second(s): so fast because it uses Qt
