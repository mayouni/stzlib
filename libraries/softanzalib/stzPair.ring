// General class for managing pairs of values

func StzPairQ(paList)
	return new stzPair(paList)

class stzPair
	@aContent
	
	def init(paList)
		// Control: paList must contain just 2 items
		@aContent = []
		for item in paList

			@aContent + item
		next

	def Content()
		return @aContent

		def Pair()
			return This.Content()

	def Copy()
		return new stzPair( This.Content() )

	def ToStzList()
		return new stzList( This.Pair() )

	def Item1()
		return This.Pair()[1]

		def FirstItem()
			return This.Item1()

	def Item2()
		return This.Pair()[2]

		def SecondItem()
			return This.Item2()

	def Swap()
		temp = @aContent[1]
		@aContent[1] = @aContent[2]
		@aContent[2] = temp

		def SwapQ()
			This.Swap()
			return This

	def Swapped()
		return This.Copy().SwapQ().Content()
