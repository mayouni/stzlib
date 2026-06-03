# Narrative
# --------
# o1 = new stzListOfStrings([ "tom", "sam", "dan" ])
#
# Extracted from stzlistofstringstest.ring, block #81.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

? o1.Uppercased()	#--> [ "TOM", "SAM", "DAN" ]

o1 = new stzListOfStrings([ "TOM", "SAM", "DAN" ])
? o1.Lowercased()	#--> [ "tom", "sam", "dan" ]

pf()
