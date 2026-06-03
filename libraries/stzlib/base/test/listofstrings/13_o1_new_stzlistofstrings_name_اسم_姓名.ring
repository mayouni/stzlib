# Narrative
# --------
# o1 = new stzListOfStrings([ "name", "اسم", "姓名" ])
#
# Extracted from stzlistofstringstest.ring, block #13.
#ERR Error (E9) : Can't open file 13_o1_new_stzlistofstrings_name_???_??.ring

load "../../stzBase.ring"

pr()

o1.RemoveAt(2)
? @@(o1.Content())
#--> [ "name", "姓名" ]

pf()
