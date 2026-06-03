# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #71.

load "../../../stzBase.ring"


o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
o1.SortInDescending()
? o1.Content()	#--> [ "ccc", "bbb", "aaa" ]

pf()
# Executed in 0.05 second(s)
