load "stzlib.ring"

o1 = new stzList([ "a", "_", "c", "_", "e", "_", "g" ])

// 2, 4, 6
// 3, 6, 9

aList = [2, 4, 6]
for i = 1 to len(aList)
	n = aList[i] + i - 1
	o1.InsertBefore(n, "*")
next
? o1.Content()
/*
aList = [2, 4, 6]
aResult = []
for i = 1 to len(aList)
	aResult + (aList[i] + i)
next
? aResult
*/

/*
// InsertAfterAtManyPositions([ 2, 4, 6 ])

o1 {
	InsertAfter(3, "*")
	? Content()

	
}
