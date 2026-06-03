# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #92.

load "../../stzBase.ring"


o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

? @@( o1.FindDuplicatesOfString("tunis") )
#--> [ 2, 3, 5, 6, 8, 9 ]
# Executed in 0.11 second(s)

? @@( o1.FindDuplicatesOfStringCS("tunis", :CS = FALSE) )
#--> [ 2, 3, 5, 6, 8, 9, 13 ]
# Executed in 0.12 second(s)

pf()
# Executed in 0.20 second(s)
