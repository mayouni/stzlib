load "softanzalib.ring"
//		     V         V         V
list1 = [ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K" ]
list2 = [          [ 3 ,  4],          [ 7 ,  8 ,  9 ]          ]

list3 = [ [ 1, 2], [ 3 ,  4], [5, 6 ], [ 7 ,  8 ,  9 ], [10, 11]]

o1 = new stzSplitter(list1)
? o1.SplitToPartsOf(3)

/*
o1 = new stzlist(list1)
aParts = o1.SplitAfterPositions([3, 5, 7])
for aPart in aParts
	? aPart
next

/*
PartsOnPositions([ 3, 5 ,7])
PartsIncluding([ 3:4, 7:9 ])

/*
cList = '[ 1, 2, "A", 3 ]'
cList = "amc am ttamc pcamc"
o1 = new stzString(cList)
? o1.ReplaceAll("amc","*")
//? o1.ReplaceSection(1,3,"*")

/*

o1 = new stzListProvidedAsString(cList)
? o1.Items()
