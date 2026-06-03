# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #79.

load "../../stzBase.ring"


o1 = new stzListOfStrings([ "abcde", "bdace", "ebadc", "debac", "edcba" ])
? o1.AreAnagrams()
#--> TRUE

? o1.IsListOfAnagrams()
#--> TRUE

pf()
# Executed in 1.49 second(s)
