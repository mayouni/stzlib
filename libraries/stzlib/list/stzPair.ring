// General class for managing pairs of values

func StzPairQ(paList)
	return new stzPair(paList)

func IsPair(paList)
	if isList(paList) and len(paList) = 2
		return TRUE
	else
		return FALSE
	ok

	func @IsPair(paList)
		return IsPair(paList)

	func IsAPair(paList)
		return IsPair(paList)

	func @IsAPair(paList)
		return IsPair(paList)

class stzPair from stzList
	@aContent
	
	def init(paList)
		// Control: paList must contain just 2 items
		@aContent = []
		for item in paList
			@aContent + item
		next

		if KeepingHistory() = TRUE
			This.AddHistoricValue(This.Content())
		ok

	def Content()
		return @aContent

		def Pair()
			return This.Content()

		def Value()
			return Content()

	def Copy()
		return new stzPair( This.Content() )

	def Update(paPair)
		if CheckingParams()
			if NOT ( isList(paPair) and len(panPair) = 2 )
				StzRaise("Incorrect param type! paPair must be a list of 2 items.")
			ok
		ok

		@aContent = paPair

		if KeepingHisto() = TRUE
			This.AddHistoricValue(This.Content())  # From the parent stzObject
		ok

		def UpdateWith(paPair)
			This.Update(paPair)

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
		aContent = This.Content()

		temp = aContent[1]
		aContent[1] = aContent[2]
		aContent[2] = temp

		This.UpdateWith(aContent)

		def SwapQ()
			This.Swap()
			return This

	def Swapped()
		return This.Copy().SwapQ().Content()

	def BothAreNumbers()
		if isNumber(This.Item1()) and isNumber(This.Item2())
			return TRUE
		else
			return FALSE
		ok

	def BothAreStrings()
		if isString(This.Item1()) and isString(This.Item2())
			return TRUE
		else
			return FALSE
		ok

	def BothAreLists()
		if isList(This.Item1()) and isList(This.Item2())
			return TRUE
		else
			return FALSE
		ok

	def BothAreObjects()
		if isObject(This.Item1()) and isObject(This.Item2())
			return TRUE
		else
			return FALSE
		ok

	def IsStzPair()
		return TRUE
