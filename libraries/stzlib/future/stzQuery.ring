
class stzQuery from stzObject
	aData

	def init(paData)
		aData = paData

	def Content()
		return aData

		def Value()
			return This.Content()

	def NumberOfItems()
		return len(aData)

	def FindWhere( pItem, pCondition, pValue )
		/*
		o1 = new stzList([1,8,16,1,4,8,1])
		? o1.FindtWhere( :CurrentItem, :IsDoubleOf, :NextItem )
		*/

		// Initializing variables
		aResult = []
		nValue = 0
		aValue = []
		nStart = 1
		nEnd = This.NumberOfItems()
		n = 0

		aSyntaxNext = [ :NextItem, :NextstItem, :NextndItem, :NextrdItem, :NextthItem ]
		aSyntaxPrecedent = [ :PrecedentItem, :PrecedentstItem, :PrecedentndItem, :PrecedentrdItem, :PrecedentthItem ]
		oTempNext = new stzList(aSyntaxNext)
		oTempPrecedent = new stzList(aSyntaxPrecedent)

		// Analyzing the first param, by detecting the
		// number of steps in :NextItem, Next2ndItem, ...
		oTempItem = new stzString(pItem)
		if isString(pItem)
			nSteps = StringToNumber( oTempItem.OnlyNumbers() )
		ok

		if pItem = :CurrentItem
			n = 0
			nStart = 1
			nEnd = This.NumberOfItems()

		else

			if oTempNext.Contains( oTempItem.OnlyLetters() )
			// Case of Next3rdItem, or Precedent21stItem for example...
				n = nSteps
				nStart = 1
				nEnd = This.NumberOfItems() - n

			but oTempPrecedent.Contains( oTempItem.OnlyLetters() )
				n = -nSteps
				nStart = nSteps+1
				nEnd = This.NumberOfItems()
			else
				StzRaise("Unsupported syntax of pItem!")
			ok
		ok

		// Analyzing the third param, by detecting if the
		// pValue contains :NextItem, :Next2ndItem, ...
		oTempValue = new stzString(pValue)
		if isString(pValue)
			if pValue = :CurrentItem
				// Do nothing
			else
				if oTempNext.Contains( oTempValue.OnlyLetters() )
					nEnd -= nSteps

				but oTempPrecedent.Contains( oTempValue.OnlyLetters() )
					nStart += nSteps
				else
					StzRaise("Unsupported syntax of pValue!")
				ok
			ok
		ok

		// Iterating over the list and finding the requested items
		for i = nStart to nEnd

			// Defining the value depending of its type
			if isString(pValue)
				if pValue = :CurrentItem
					nValue = This[i]
				else
					if oTempNext.Contains( oTempValue.OnlyLetters() )
						nValue = This[i+nSteps]

					but oTempPrecedent.Contains( oTempValue.OnlyLetters() )
						nValue = This[i-nSteps]
					else
						StzRaise("Unsupported syntax of pValue!")
					ok
				ok

			but isNumber(pValue)
				nValue = pValue

			but isList(pValue)
				aValue = pValue

			else
				StzRaise("Unsupported value!")
			ok

			// Adding the request result dependening on the condition
			switch pCondition
			on :IsEqualTo
				if This[i+n] = nValue
					aResult + i
				ok

			on :IsSmallerThan
				if This[i+n] < nValue
					aResult + i
				ok

			on :IsBiggerThan
				if This[i+n] > nValue
					aResult + i
				ok

			on :IsSmallerOrEqualTo
				if This[i+n] <= nValue
					aResult + i
				ok

			on :IsEqualOrBiggerThan
				if This[i+n] >= nValue
					aResult + i
				ok

			on :IsDoubleOf
				if This[i+n] = DoubleOf(nValue)
					aResult + i
				ok

			on :IsTripleOf
				if This[i+n] = TripleOf(nValue)
					aResult + i
				ok

			on :IsQuadrupleOf
				if This[i+n] = QuadrupleOf(nValue)
					aResult + i
				ok

			on :IsQuintupleOf
				if This[i+n] = QuintupleOf(nValue)
					aResult + i
				ok

			on :IsSextupleOf
				if This[i+n] = SextupleOf(nValue)
					aResult + i
				ok

			on :IsOctupleOf
				if This[i+n] = OctupleOf(nValue)
					aResult + i
				ok

			on :IsNonupleOf
				if This[i+n] = NonupleOf(nValue)
					aResult + i
				ok

			on :IsDecupleOf
				if This[i+n] = DecupleOf(nValue)
					aResult + i
				ok
			
			on :ExistsIn
				oTempList = new stzList(aValue)
				if oTempList.Contains(This[i+n])
					aResult + i
				ok
			off
		next i

		return aResult

	def SelectWhere( pItem, pCondition, pValue )
		aResult = []

		aPositions = This.FindWhere( pItem, pCondition, pValue )

		for i in aPositions
			aResult + This.Content()[ i ]
		next

		return aResult

	def FindAndSelectWhere( pItem, pCondition, pValue )
		aResult = []

		aPositions = This.FindWhere( pItem, pCondition, pValue )
		aSelected = This.SelectWhere( pItem, pCondition, pValue )

		for i=1 to len(aPositions)
			aResult + [ aPositions[i], aSelected[i] ]
		next

		return aResult

	def SelectWhereItemIsEqualto(pValue)
		return SelectWhere(:CurrentItem, :IsEqualTo, pValue)


	def UpdateWhere( pItem, pCondition, pValue )
		// TODO

	def RemoveWhere( pItem, pCondition, pValue )
		// TODO

	def DoWhere( pFunc, pItem, pCondition, pValue )
		// TODO
