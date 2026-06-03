# Narrative
# --------
# o1 = new stzListOfStrings([ "*", "A*B*C", "*" ])
#
# Extracted from stzlistofstringstest.ring, block #28.

load "../../stzBase.ring"

pr()

? @@( o1.Find( :String = "*" ) ) + NL
#--> [1, 3]

? @@( o1.Find( :SubString = "*" ) )
#--> [ [1, [1]], [2, [2, 4]], [3, [1]] ]

pf()
