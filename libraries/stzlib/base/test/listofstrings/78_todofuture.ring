# Narrative
# --------
# TODO/FUTURE
#
# Extracted from stzlistofstringstest.ring, block #78.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "aaa bbb ccc", "mm nnn oo", "vvv aaa", "yyy nn", "bb aa c" ])
? o1.WordsOfEachStringAreSortedInAscending() #--> FALSE

? o1.WordsOfEachStringSortedInAscending()
#--> [ "aaa bbb ccc", 
#	"mm nnn oo",
#	"aaa vvv",
#	"nn yyy",
	"aa bb c"
#     ]

? o1.WordsOfEachStringAreSortedInAscending() #--> FALSE

? o1.WordsOfEachStringSortedInDescending()
#--> [ "ccc bbb aaa", 
#	"oo nnn mm",
#	"vvv aaa",
#	"yyy nn",
	"c bb aa"
#     ]

? o1.WordsSortingOrders()
#--> [ :Ascending,
# 	:Ascending,
# 	:Descending,
# 	:Unsorted,
#	:Unsorted
#     ]

? o1.NumberOfStringsWhereWordsAreSortedInAscending() 	#--> 2
? o1.NumberOfStringsWhereWordsAreSortedInDescending()	#--> 2
? o1.NumberOfStringsWhereWordsAreUnsorted()		#--> 1

pf()
