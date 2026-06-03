# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #71.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "aaa", "bbb", "ccc" ])
o1.SortInDescending()
? o1.Content()	#--> [ "ccc", "bbb", "aaa" ]

pf()
# Executed in 0.05 second(s)
