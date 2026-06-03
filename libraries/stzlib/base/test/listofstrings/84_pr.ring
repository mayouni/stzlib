# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #84.

load "../../stzBase.ring"


o1 = new stzListOfStrings([ "abc;123;tunis;rgs", "jhd;343;gafsa;ghj", "lki;112;beja;okp" ])

? o1.Split(";")
#--> [
# 	[ "abc", "123", "tunis", "rgs" ],
# 	[ "jhd", "343", "gafsa", "ghj" ],
# 	[ "lki", "112", "beja" , "okp" ]
# ]

? o1.Split(";")[1]
#--> [ "abc", "123", "tunis", "rgs" ]

? o1.Split(";")[2]
#--> [ "jhd", "343", "gafsa", "ghj" ]

? o1.Split(";")[3]
#--> [ "lki", "112", "beja" , "okp" ]

? o1.NthSubstringsAfterSplittingStringsUsing(3, ";")
#--> [ "tunis", "gafsa", "beja" ]

# The same function can be expressed like this
? o1.NthSubstrings(3, :AfterSplittingStringsUsing = ";")
#--> [ "tunis", "gafsa", "beja" ]

pf()
# Executed in 0.12 second(s)
