# Narrative
# --------
# TODO/FUTURE
#
# Extracted from stzlistofstringstest.ring, block #77.
#ERR Error (R14) : Calling Method without definition: wordsofeachstringaresortedinascending

load "../../stzBase.ring"


pr()

o1 = new stzListOfStrings([ "aaa bbb ccc", "mm nnn oo", "aaa vvv", "nn yyy", "aa bb c" ])
? o1.WordsOfEachStringAreSortedInAscending()	#--> TRUE

o1 = new stzListOfStrings([ "ccc bbb aaa", "oo nnn mm", "vvv aaa", "yyy nn", "c bb aa" ])
? o1.WordsOfEachStringAreSortedInDescending()	#--> TRUE

pf()
