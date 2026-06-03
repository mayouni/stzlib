# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #97.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "Regueb", "sfax", "regueb", "Tunis"
])

? @@( o1.DuplicatedStringsCS(FALSE) )
#--> [ "tunis", "regueb" ]
# Executed in 0.36 second(s)

o1.RemoveDuplicatedStringsCS(FALSE)
? @@( o1.Content() )
#--> [ "gatfsa", "gabes", "sfax" ]

pf()
# Executed in 0.87 second(s)
