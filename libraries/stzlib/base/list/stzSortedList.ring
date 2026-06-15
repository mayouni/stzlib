

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
			# Type-specific sorted insert -- builds the value inside the list
			# DLL. (A StzValue handle minted by the value DLL does NOT resolve
			# in the list DLL's handle table, so the old handle-based
			# StzEngineListSortedInsert read garbage and was a silent no-op.)
			if isNumber(pItem)
				if floor(pItem) = pItem
					StzEngineListSortedInsertInt(_pSlAdd, pItem)
				else
					StzEngineListSortedInsertFloat(_pSlAdd, pItem)
				ok
			else
				StzEngineListSortedInsertString(_pSlAdd, "" + pItem)
			ok
			@aContent = This._ContentFromEngineList(_pSlAdd)
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
