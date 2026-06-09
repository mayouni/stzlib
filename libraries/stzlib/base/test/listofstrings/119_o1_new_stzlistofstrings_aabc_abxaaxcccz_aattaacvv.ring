# Narrative
# --------
# o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
#
# Extracted from stzlistofstringstest.ring, block #119.
#ERR Error (R14) : Calling Method without definition: containssubstringineachstring

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])

? o1.ContainsSubStringInEachString("aa") #--> TRUE

? @@( o1.UniqueChars() )	#TODO // fix performance lag!
#--> [ "a", "b", "c", "x", "z", "t", "v" ]


? @@( o1.CommonChars() )
#--> ["a", "c"]

pf()
