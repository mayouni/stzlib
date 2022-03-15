
func ListThatHasMoreNumberOfItems(paList1, paList2)
	oList1 = nex stzList(aList1)
	if oList1.HasMoreNumberOfItemsThen(paList2)
		return paList1
	else
		return paList2
	ok

func ListThatHasLessNumberOfItems(paList1, paList2)
	oList1 = new stzList(paList1)
	if oList1.HasLessNumberOfItemsThen(paList2)
		return paList1
	else
		return paList2
	ok

class stzListOfPairs from stzObject
	@aContent = []

	@oList1
	@oList2

	def init(paList1, paList2)
		@oList1 = new stzList(paList1)
		@oList2 = new stzList(paList2)

		for i = 1 to len(ListThatHasLessNumberOfItems(paList1, paList2))
			@aContent + [ paList1[i], paList2[i] ]
		next


	def Content()
		return @aContent

	def NumberOfPairs()
		return len(@aContent)

	def Pair(n)
		return Content()[n]

	def FindPair(aPair)

	def PairsAreMadeOfEqualItems()
		bResult = TRUE
		for aPair in Content()
			if aPair[1] != aPair[2]	// Does not work if items are lists or objects
				bResult = FALSE
			ok
		next
		return bResult

