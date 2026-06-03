# Narrative
# --------
# o1 = new stzListOfStrings([ "str1", '', "str2", "str3", '', '' ])
#
# Extracted from stzlistofstringstest.ring, block #48.

load "../../stzBase.ring"

pr()

o1.RemoveEmptyStrings()
? o1.Content() #--> [ "str1", "str2", "str3" ]

pf()
