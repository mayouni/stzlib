# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #76.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "12", "12345", "123", "1" ])

? o1.SortedByInAscending('Q(@string).NumberOfChars()')
#--> [
#	"1",
#	"12",
#	"123",
#	"12345"
# ]

? o1.SortedByInDescending('Q(@string).NumberOfChars()')
#--> [
#	"12345",
#	"123",
#	"12",
#	"1"
# ]

pf()
# Executed in 0.05 second(s)
