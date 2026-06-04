# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #70.
#ERR Error (R14) : Calling Method without definition: sortbyindescending

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "i", "ring", "language" ])
o1.SortByInDescending('Q(@string).NumberOfChars()')

? @@( o1.Content() )
#--> [ "language", "ring", "i" ]

pf()
# Executed in 0.06 second(s)
