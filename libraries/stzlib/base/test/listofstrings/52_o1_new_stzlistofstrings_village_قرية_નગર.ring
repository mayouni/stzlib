# Narrative
# --------
# o1 = new stzListOfStrings([ "village", "قرية", "નગર" ])
#
# Extracted from stzlistofstringstest.ring, block #52.
#ERR Error (E9) : Can't open file 52_o1_new_stzlistofstrings_village_????_???.ring

load "../../stzBase.ring"

pr()

? o1.StringsW('T(@string).Script() = :Arabic') #--> [ "قرية" ]

? o1.StringsPositionsW('T(@string).Script() = :Arabic') #--> 2

pf()
