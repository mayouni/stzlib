# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #98.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([
	"tunis", "tunis", "tunis", "gatfsa", "tunis", "tunis", "gabes",
	"tunis", "tunis", "Regueb", "sfax", "regueb", "Tunis"
])

? o1.ContainsNonDuplicatedStrings()
#--> TRUE
# Executed in 0.26 second(s)

? @@( o1.NumberOfNonDuplicatedStrings() )
#--> 6
# Executed in 0.34 second(s)

? @@( o1.FindNonDuplicatedStrings() )
#--> [ 4, 7, 10, 11, 12, 13 ]
#--> Executed in 0.34 second(s)

? @@( o1.NonDuplicatedStrings() )
#--> [ "gatfsa", "gabes", "Regueb", "sfax", "regueb", "Tunis" ]
# Executed in 0.34 second(s)

? @@( o1.NonDuplicatedStringsZ() ) # Or NonDuplicatedStringsAndTheirPositions()
#--> [
#	[ "gatfsa", 4  ],
#	[ "gabes",  7  ],
#	[ "Regueb", 10 ],
#	[ "sfax",   11 ],
#	[ "regueb", 12 ],
#	[ "Tunis",  13 ]
# ]
# Executed in 0.36 second(s)

pf()
# Executed in 1.59 second(s)
