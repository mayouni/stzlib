load "stzlib.ring"

aSet = [ "a", "b", "c", "d", "e" ]

for set in AllSetsOfNElements(aSet, 3)
	? set
next


func AllSetsOfNElements(paSet, n)

	aResult = []

	if n = 0
		aResult = NULL

	but n = 1
		aResult + []

		for elm in paSet
			aResult + [ elm ]
		next
		aResult + paSet

	but n = len(paSet)
		aResult + paSet
	
	else
	
		for i = 1 to len(paSet)

			# deleting the i th item
			aElems = paSet
			del(aElems,i)
			
			? "--- "+ paSet[i] ? aElems

			oList = new StzList( aElems)
			oList * paSet[i]
			? oList.Content()

		next i

	ok

	return aResult

func subsets(paSet)
	aResult = []

	for i = 1 to len(paSet)
		aResult + AllSetsOfNElements(paSet, i)
	next i

	return aResult
