

func StzSortedListQ(paList)
	return new stzSortedList(paList)

class stzOrderedList from stzSortedList

class stzSortedList from stzList
	@aContent

	def init(paList)
		@aContent = @SortList(paList)

	def Add(pItem)
		@aContent + pItem
		@aContent = @SortList(@aContent)

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
