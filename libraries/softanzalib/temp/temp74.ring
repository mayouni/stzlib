load "stzlib.ring"

o1 = new stzString("🐨")
? o1.NumberOfChars()
? o1.NumberOfBytes()
? o1.Content()

/*
? CharIsLetter("ف")
? unicodetochar(1617)
/*
for nUnicode in ListsMerge([ 1611:1631, 1643:1644, 1748:1773 ])
	? ""+ nUnicode + ": " + UnicodeToChar(nUnicode)
next

/*
aListOfLists = [ 1:3, 4:7, 8:9, [10, 11,13] ]
aListOfLists = [ [1,2,3], [4,5,6], [ 7,[9,10,11] ] ]

aMerged = []

for aList in aListOfLists
	for item in aList
? item
? type(item)
? "----"
		aMerged + item
	next
next

