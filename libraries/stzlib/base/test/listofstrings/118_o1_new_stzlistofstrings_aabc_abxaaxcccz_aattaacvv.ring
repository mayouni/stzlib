# Narrative
# --------
# o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
#
# Extracted from stzlistofstringstest.ring, block #118.
#ERR Error (R14) : Calling Method without definition: numberofoccurrenceofmanysubstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])

? @@( o1.NumberOfOccurrenceOfManySubstrings(["a","f","x"]) ) 
#--> [ 9, 0, 2 ]
? @@( o1.NumberOfOccurrenceOfManySubstringsXT(["a","f","x"]) ) 
#--> [
#	[ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ] ], #>>> There are 2"a"s in string 1, 3 in string 2, and 4 in string 
#	[ ],				  #>>> "f" does'nt exist!
#	[ [ 2, 2 ] ]			  #>>> There is 2 "x"s in string number 2
#    ]

pf()
