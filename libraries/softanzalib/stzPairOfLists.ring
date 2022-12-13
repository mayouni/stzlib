
// TODO: Generalise this class in stzListOfLists
// --> See work done in stzListOfNumbersList and complete it

func StzPairOfListsQ(paList1, paList2)
	return new stzPairOfLists(paList1, paList2)

class stzPairOfLists from stzPair

	@aList1
	@aList2

	def init(paList1, paList2)
		if NOT BothAreLists(paList1, paList2)
			StzRaise("Can not create object!")
		ok

		@aList1 = paList1
		@aList2 = paList2

	def Content()
		return [ @aList1, @aList2 ]

		def PairOfLists()
			return This.Content()

	def FirstList()
		return @aList1

	def SecondList()
		return @aList2

	def Alternate()
		aResult = []

		nLen1 = len( This.FirstList() )
		nlen2 = len( This.SecondList() )

		nMax = Max(nLen1, nLen2)

		cBiggerList = ""
		cOtherList = ""

		if nLen1 = nMax
			cBiggerList = :FirstList
			cOtherList = :SecondList

		else
			cBiggerList = :SecondList
			cOtherList = :FirstList
		ok

		cBiggerList += "()"
		cOtherList += "()"

		cCode =
			"for i = 1 to len(This." + cBiggerList + ")" + NL +
			"	aResult + This." + cBiggerList + "[i]" + NL +
			"	if i <= len(This." + cOtherList + ")" + NL +
			"		aResult + " + cOtherList + "[i]" + NL +
			"	ok" + NL +
			"next"
		
		eval(cCode)

		return aResult

		def AlternateQ()
			return new stzList( This.Alternate() )

	def Associate()
		aResult = []
		nLen1 = len( This.FirstList() )
		nLen2 = len( This.SecondList() )

		for i = 1 to nLen1
			if i <= nLen2
				aResult + [ This.FirstList()[i], This.SecondList()[i] ]
			ok
		next

		return aResult

		def AssociateQ()
			return This.AssociateQR(:stzList)

		def AssociateQR(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Associate() )

			on :stzHashList
				return new stzHashList( This.Associate() )

			other
				StzRaise("Unsupported return type!")
			off
