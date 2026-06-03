# Narrative
# --------
# o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
#
# Extracted from stzlistofstringstest.ring, block #74.

load "../../../stzBase.ring"

? o1.SortedInDescending() #--> [ "ccc", "bbb", "aaa" ]
? o1.Content()		  #--> [ "aaa", "bbb", "ccc" ]
