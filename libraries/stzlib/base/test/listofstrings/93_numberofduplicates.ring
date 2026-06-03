# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #93.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "regueb", "sfax", "regueb", "Tunis"
])

? o1.NumberOfDuplicates()
#--> 7
# Executed in 0.24 second(s)

? @@( o1.FindDuplicates() )
#--> [ 2, 3, 5, 6, 8, 9, 12 ]
# Executed in 0.37 second(s)

? @@( o1.DuplicatesZ() ) # Or DuplicatesAndTheirPositions()
#--> [
#	[ "tunis",  [ 2, 3, 5, 6, 8, 9 ] ],
#	[ "regueb", [ 12 ] ]
# ]
# Executed in 0.37 second(s)

#-- Same thing but with case sensitivity
? NL + "--" + NL


? o1.NumberOfDuplicatesCS(FALSE)
#--> 8
# Executed in 0.67 second(s)

? @@( o1.FindDuplicatesCS(FALSE) )
#--> [ 2, 3, 5, 6, 8, 9, 12, 13 ]
# Executed in 0.47 second(s)

? @@( o1.DuplicatesCSZ(FALSE) ) # Or DuplicatesAndTheirPositions()
#--> [
#	[ "tunis",  [ 2, 3, 5, 6, 8, 9, 13 ] ],
#	[ "regueb", [ 12 ] ]
# ]
# Executed in 0.47 second(s)

pf()
# Executed in 2.46 second(s)
