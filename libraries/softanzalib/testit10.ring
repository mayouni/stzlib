load "stzlib.ring"

/*---------------

o1 = new stzString("bla bla <<word>> bla bla <<word>> bla <<word>>")

? o1.FindAll("word")
#--> [11, 28, 41]
	
? o1.FindSections("word")
#--> [ [11, 14], [28, 31], [41, 44] ]

	? o1.FindNthSection(2, "word")
	#--> [28, 31]
	
	? o1.FindLastSection("word")
#--> [41, 44]

? o1.NumberOfOccurrenceBetween("word", "<<", ">>")
#--> 3

? o1.FindBetween("word", "<<", ">>")
#--> [11, 28, 41]

	? o1.FindNthBetween(2, "word", "<<", ">>")
	#--> 28
	
	? o1.FindLastBetween("word", "<<", ">>")
	#--> 41

? o1.FindSectionsBetween("word", "<<", ">>")
#--> [ [11, 14], [28, 31], [41, 44] ]

	? o1.FindNthSectionBetween(2, "word", "<<", ">>")
	#--> [28, 31]
	
	? o1.FindLastSectionBetween("word", "<<", ">>")
	#--> [41, 44]

/*---------------

o1 = new stzString("bla bla <<word1>> bla bla <<word2>> bla <<word3>>")

//? o1.FindAnyBetween("<<", ">>")
#--> [11, 29, 43]

//? o1.FindAnyBetweenXT("<<", ">>")
#--> [ [11, "word1"], [29, "word2"], [43, "word2"] ]

? o1.FindAnySectionsBetween("<<", ">>")
#--> [ [11, 15], [29, 33], [43, 47] ]

? o1.FindAnySectionsBetweenXT("<<", ">>")
#--> [ [ "word1", [11, 15] ], [ "word2", [29, 33] ], [ "word3", [43, 47] ] ]

/*---------------

o1 = new stzString("bla bla <<word1>> bla bla <<word2>> bla <<word3>>")
aSectionsBetween = o1.FindAnySectionsBetween("<<", ">>")
? o1.NumberOfAntiSections( aSectionsBetween )
#--> 4

? o1.NthAntiSection(2, aSectionsBetween)
#--> ">> bla bla <<"

? o1.LastAntiSection(aSectionsBetween)
#--> ">>"

? o1.AntiSections( aSectionsBetween )
#--> [ "bla bla <<", ">> bla bla <<", ">> bla <<", ">>" ]

? o1.FindAntiSections( aSectionsBetween )
#--> [ [1, 10], [16, 28], [34, 42], [48, 49] ]

? o1.FindAntiSectionsXT( aSectionsBetween )
#--> [
#	[ [ 1, 10], "bla bla <<" ],
#	[ [16, 28], ">> bla bla <<" ],
#	[ [34, 42], ">> bla <<"],
#	[ [48, 49], ">>" ]
#    ]

/*---------------

o1 = new stzList([ 3, 7 ])
o1.MergeWith([ 1, 2, 4, 5, 6 ])
? o1.SortedInAscending()
#--> [ 1, 2, 3, 4, 5, 6, 7 ]

o1 = new stzListOfPairs([ [3, 5], [8, 10] ])
o1.MergeWith([ [1, 2], [6, 7] ])
? o1.SortedInAscending()
#--> [ [1, 2], [3, 5], [6, 7], [8, 10] ]

/*---------------

o1 = new stzString("bla bla <<word1>> bla bla <<word2>> bla <<word3>>")
? o1.SubstringsBetween("<<", ">>")
#--> [ "word1", "word2", "word3" ]

? o1.SubstringsBetweenXT("<<", ">>")
#--> [
#	[ "word1", [11, 15] ],
#	[ "word2", [29, 33] ],
#	[ "word3", [43, 47] ]
#    ]
