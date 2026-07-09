
// TODO: Generalise this class in stzListOfLists
// --> See work done in stzListOfListsOfNumbers and complete it

func StzPairOfListsQ(paList1, paList2)
	return new stzPairOfLists(paList1, paList2)

class stzPairOfLists from stzListOfLists

	@aList1
	@aList2

	def init(paList1, paList2)
		if NOT @BothAreLists(paList1, paList2)
			StzRaise("Can not create object!")
		ok

		@aList1 = paList1
		@aList2 = paList2

		if KeepingHistory() = 1
			This.AddHistoricValue(This.Content())
		ok

	def Content()
		return [ @aList1, @aList2 ]

		def PairOfLists()
			return This.Content()

		def Value()
			return Content()

	def FirstList()
		return @aList1

	def SecondList()
		return @aList2

	def Alternate()
		_aResult_ = []

		_nLen1_ = len( This.FirstList() )
		_nlen2_ = len( This.SecondList() )

		_nMax_ = @Max([ _nLen1_, _nlen2_ ])

		_cBiggerList_ = ""
		_cOtherList_ = ""

		if _nLen1_ = _nMax_
			_cBiggerList_ = :FirstList
			_cOtherList_ = :SecondList

		else
			_cBiggerList_ = :SecondList
			_cOtherList_ = :FirstList
		ok

		_cBiggerList_ += "()"
		_cOtherList_ += "()"

		cCode =
			"for i = 1 to len(This." + _cBiggerList_ + ")" + NL +
			"	aResult + This." + _cBiggerList_ + "[i]" + NL +
			"	if i <= len(This." + _cOtherList_ + ")" + NL +
			"		aResult + " + _cOtherList_ + "[i]" + NL +
			"	ok" + NL +
			"next"
		
		eval(cCode)

		return _aResult_

		def AlternateQ()
			return new stzList( This.Alternate() )

	def Associate()
		_aResult_ = []
		_nLen1_ = len( This.FirstList() )
		_nlen2_ = len( This.SecondList() )

		for i = 1 to _nLen1_
			if i <= _nlen2_
				_aResult_ + [ This.FirstList()[i], This.SecondList()[i] ]
			ok
		next

		return _aResult_

		def AssociateQ()
			return This.AssociateQRT(:stzList)

		def AssociateQRT(pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.Associate() )

			on :stzHashList
				return new stzHashList( This.Associate() )

			other
				StzRaise("Unsupported return type!")
			off
