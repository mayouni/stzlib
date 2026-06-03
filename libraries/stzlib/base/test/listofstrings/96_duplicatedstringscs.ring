# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #96.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "Regueb", "sfax", "regueb", "Tunis"
])

? @@( o1.DuplicatedStringsCS(FALSE) )
#--> [ "tunis", "regueb" ]
# Executed in 0.38 second(s)

? @@( o1.FindDuplicatedStringsCS(FALSE) )
#--> [ 1, 2, 3, 5, 6, 8, 9, 13, 10, 12 ]
# Executed in 0.50 second(s)

? @@( o1.DuplicatedStringsCSZ(FALSE) )
#--> [
#	[ "tunis",  [ 1, 2, 3, 5, 6, 8, 9, 13 ] ],
#	[ "regueb", [ 10, 12 ] ]
# ]
# Executed in 0.52 second(s)

#--
? NL + "--" + NL

? @@( o1.DuplicatedStringsCS(TRUE) )
#--> [ "tunis" ]
# Executed in 0.27 second(s)

? @@( o1.FindDuplicatedStringsCS(TRUE) )
#--> [ 1, 2, 3, 5, 6, 8, 9 ]
# Executed in 0.35 second(s)

? @@( o1.DuplicatedStringsCSZ(TRUE) )
#--> [ [ "tunis", [ 1, 2, 3, 5, 6, 8, 9 ] ] ]
# Executed in 0.35 second(s)

pf()
# Executed in 2.22 second(s)
