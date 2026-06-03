# Narrative
# --------
# o1 = new stzListOfStrings([ "tom", "sam", "dan" ])
#
# Extracted from stzlistofstringstest.ring, block #81.

load "../../stzBase.ring"

pr()

? o1.Uppercased()	#--> [ "TOM", "SAM", "DAN" ]

o1 = new stzListOfStrings([ "TOM", "SAM", "DAN" ])
? o1.Lowercased()	#--> [ "tom", "sam", "dan" ]

pf()
