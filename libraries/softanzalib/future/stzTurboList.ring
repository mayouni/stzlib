


class stzTurboList
	@aItems     = []
	@aPositions = []
	@nNumberOfItems

	@aNumberOfOccurrence = []

	def init(paList)
		if NOT isList(paList)
			StzRaise("Incorrect param type! paList must be a list.")
		ok
	
		if Q(paList).IsAPairOfLists()

			if NOT len(paList[1]) = len(paList[2])
				StzRaise("Incorrect format! The two lists must have same size.")
			ok

			nLen2 = len(paList[2])
			for i = 1 to nLen2
				if NOT (isList(paList[2][i]) and Q(paList[2][i]).IsListOfNumbers())
					StzRaise("Incorrect format! The second list must be a list of litts of numbers.")
				ok
			next

			oFlattened = Q(paList[2]).FlattenQ()
			if NOT oFlattened.SortInAscendingQ().IsContiguous()
				StzRaise("Incorrect format! The numbers in paList[2] must form a contiguous list.")
			ok

			@aItems = paList[1]
			@aPositions = paList[2]
			@nNumberOfItems = oFlattened.NumberOfItems()

		else
			StzRaise("Incorrect param type! paList must be a pair of lists.")
		ok

	def Content()
/*
	[  "1",   "2",      "*",      "4",   "6",   "7",   "9"   ],
	[ [ 1 ], [ 2 ], [ 3, 5, 8 ], [ 4 ], [ 6 ], [ 7 ], [ 9 ]  ]
*/

		aResult = 1 : This.NumberOfItems()
		nLen = len(@aItems)

		for i = 1 to nLen
			item = @aItems[i]
			nLen2 = len(@aPositions[i])

			for j = 1 to nLen2
				nPos = @aPositions[i][j]
				aResult[nPos] = item
			next

		next

		return aResult

		def Value()
			return This.Content()

	def @Items()
		return @aItems

	def @Positions()
		return @aPositions

	def NumberOfItems()
		return @nNumberOfItems

		def HowManyItems()
			return @nNumberOfItems

		def HowManyItem()
			return @nNumberOfItems

	def Item(n)
		return @aItems[n]

	def FindAll(pItem)
		n = Q(@aItems).FindFirst(pItem)
		return @aPositions[n]

	def NumberOfOccurrence(pItem)
		n = Q(@aItems).FindFirst(pItem)
		return @aNumberOfOccurrence[n]

		def NumberOfOccurrences(pItem)
			return This.NumberOfOccurrence(pItem)

		def HowManyOccurrence(pItem)
			return This.NumberOfOccurrence(pItem)

		def HowManyOccurrences(pItem)
			return This.NumberOfOccurrence(pItem)

	def FindNth(n, pItem)
		nPos = Q(@aItems).FindFirst(pItem)
		return @aPositions[nPos][n]

	def FindFirst(pItem)
		nPos = Q(@aItems).FindFirst(pItem)
		return @aPositions[nPos][1]

	def FindLast(pItem)
		nPos = Q(@aItems).FindFirst(pItem)
		return @aPositions[nPos][len(@aPositions[nPos])]

	def FindNext(pItem, pnStartingAt)
		if isList(pnStartingAt) and Q(pnStartingAt).IsStartingAtNamedParam()
			pnStartingAt = pnStartingAt[2]
		ok

		nPos = Q(@aItems).FindFirst(pItem)
		anPos = @aPositions[nPos]

		if pnStartingAt >= anPos[len(anPos)]
			return 0

		but pnStartingAt < anPos[1]
			return anPos[1]

		else
			n = Q(anPos).FindFirst(pnStartingAt)
			return n + pnStartingAt + 1
		ok

	def FindNextNth(n, pItem, pnStartingAt)
		if isList(pnStartingAt) and Q(pnStartingAt).IsStartingAtNamedParam()
			pnStartingAt = pnStartingAt[2]
		ok

		if n <= 0
			return 0
		ok

		nPos = Q(@aItems).FindFirst(pItem)
		anPos = @aPositions[nPos]
		nLen = len(anPos)

		if n > len(anPos)
			return 0
		ok 

		if pnStartingAt >= anPos[len(anPos)]
			return 0

		but pnStartingAt < anPos[1]
			return anPos[n]

		else
			nPos = Q(anPos).FindFirst(pnStartingAt)

			if nPos + n > nLen
				return 0
			else
				return anPos[nPos + n]
			ok
		ok
