# Narrative
# --------
# o1 = new stzListOfStrings([ "village", "قرية", "નગર" ])
#
# Extracted from stzlistofstringstest.ring, block #52.

load "../../../stzBase.ring"

? o1.StringsW('T(@string).Script() = :Arabic') #--> [ "قرية" ]

? o1.StringsPositionsW('T(@string).Script() = :Arabic') #--> 2
