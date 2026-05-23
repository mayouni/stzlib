

func StzSortedListQ(paList)
	return new stzSortedList(paList)

class stzOrderedList from stzSortedList

class stzSortedList from stzList
	@aContent

	def init(paList)
		@aContent = paList
		_pSlInit = This._EngineListFromContent()
		if _pSlInit != NULL
			StzEngineListSort(_pSlInit)
			@aContent = This._ContentFromEngineList(_pSlInit)
			StzEngineListFree(_pSlInit)
		else
			@aContent = @SortList(paList)
		ok

	def Add(pItem)
		_pSlAdd = This._EngineListFromContent()
		if _pSlAdd != NULL
			if isNumber(pItem)
				if floor(pItem) = pItem
					_pSlVal2 = StzEngineValueNewInt(pItem)
				else
					_pSlVal2 = StzEngineValueNewFloat(pItem)
				ok
			else
				_pSlVal2 = StzEngineValueNewString("" + pItem)
			ok
			if _pSlVal2 != NULL
				StzEngineListSortedInsert(_pSlAdd, _pSlVal2)
				@aContent = This._ContentFromEngineList(_pSlAdd)
				StzEngineValueFree(_pSlVal2)
			else
				@aContent + pItem
				StzEngineListSort(_pSlAdd)
				@aContent = This._ContentFromEngineList(_pSlAdd)
			ok
			StzEngineListFree(_pSlAdd)
		else
			@aContent + pItem
			@aContent = @SortList(@aContent)
		ok

		def AddQ(pItem)
			return this

	def Append(pItem)
		This.Add(pItem)

		def AppendQ(pItem)
			return This

	def operator(pcOp, item)

		if pcOp = "+"
			This.Add(item)
		ok
