
#NOTE: Reflect on the difference between stzWalker and stzParser
#~> May be taht stzParser maintains the state of the current position

func StzParserQ(paList)
	return new StzParser(paList)

class stzParser from stzList
	@nStart
	@nEnd
	@nSteps
	
	@aContent = []
	@nCurrentPosition = 1

	@aList
	
	  #--------------#
	 #     INIT     #
	#--------------#

	def init(aList)
		@aList = aList
		This.Parse(1, len(aList), 1)

	def List()
		return @aList

	def Content()
		return @aContent

		def Value()
			return Content()

		def ParsedPositions()
			return This.Content()

	def NumberOfParsedPositions()
		return len(This.Content())

		def NumberOfParsedItems()
			return This.NumberOfParsedPositions()

	  #----------------#
	 #     PARSER     #
	#----------------#

	def SetStartOfParsing(n)
		@nStart = n
		This.Parse( n, This.EndOfParsing(), This.NumberOfSteps() )

	def SetNumberOfSteps(n)
		@nSteps = n
		This.Parse( This.StartOfParsing(), This.EndOfParsing(), n )

	def SetEndOfParsing(n)
		@nEnd = n
		This.Parse( This.StartOfParsing(), n, This.NumberOfSteps() )

	def Parse(pnStart, pnEnd, pnSteps)
		if isList(pnStart) and StzListQ(pnStart).IsStartingAtNamedParam()
			pnStart = pnStart[2]
		ok

		if isList(pnEnd) and StzListQ(pnEnd).IsToNamedParam()
			pnEnd = pnEnd[2]
		ok
		
		if isList(pnSteps) and StzListQ(pnSteps).IsStepNamedParam()
			pnSteps = pnSteps[2]
		ok

		@nStart = pnStart
		@nEnd = pnEnd
		@nSteps = pnSteps

		aResult = []
		for i=pnStart to pnEnd step pnSteps
			aResult + i
		next i

		@aContent = aResult
		
	  #--------------#
	 #     INFO     #
	#--------------#

	def StartOfParsing()
		return @nStart

	def EndOfParsing()
		return @nEnd

	def NumberOfSteps()
		return @nSteps

	  #---------------------------------------#
	 #     MOVING IN THE LIST BY POSITION    #
	#---------------------------------------#

	def CurrentPosition()
		return @nCurrentPosition

	def SetCurrentPosition(n)
		if isNumber(n) and StzNumberQ(n).ExistsIn( This.ParsedPositions() )
			@nCurrentPosition = n
		ok

	def MoveToCurrentPosition()
		return This.ParsedPositions()[ This.CurrentPosition() ]

	def MoveToPosition(n)
		This.SetCurrentPosition(n)
		
	def NextPosition()
		if @nCurrentPosition = This.NumberOfPositions()
			return @nCurrentPosition
		else
			return @nCurrentPosition + 1
		ok

	def MoveToNextPosition()
		This.MoveToNextNthPosition(1)

	def MoveToNextNthPosition(n)
		if n + This.CurrentPosition() <= This.NumberOfParsedItems()
			// Important: Don't swap the 2 following lines!
			nNthPosition = This.ParsedPositions()[ This.CurrentPosition() + n ]
			This.MoveToPosition( This.CurrentPosition() + n)
		ok

	def PreviousPosition()
		if @nCurrentPosition = 1
			return @nCurrentPosition
		else
			return @nCurrentPosition - 1
		ok

	def SetPreviousPosition(n)
		if isNumber(n) and StzNumberQ(n).ExistsIn( This.ParsedPositions() )
			@nPreviousPosition = n
		ok

	def MoveToPreviousPosition()
		This.MoveToPreviousNthPosition(1)

	def MoveToPreviousNthPosition(n)
		if This.CurrentPosition() - n >= 1
			// Important: Don't swap the 2 following lines!
			nNthPosition = This.ParsedPositions()[ This.CurrentPosition() - n ]
			This.MoveToPosition( This.CurrentPosition() - n)

		ok

	def MoveToFirstPosition()
		This.MoveToPosition(1)
		
	def MoveToLastPosition()
		This.MoveToPosition( This.NumberOfParsedPositions() )

	  #-----------------------------------#
	 #     MOVING IN THE LIST BY ITEM    #
	#-----------------------------------#

	def FirstItem()
		return This.NthItem(1)

	def LastItem()
		This.SetCurrentPosition( This.NumberOfParsedItems() )
		return This.List()[ This.ParsedPositions()[ This.NumberOfParsedPositions() ] ]

	def NthItem(n)
		This.SetCurrentPosition(n)
		return This.List()[ This.ParsedItems()[ n ] ]

	def PreviousNthItem(n)
		return This.List()[ This.PreviousNthPosition(n) ]

		def NthPreviousItem(n)
			return This.PreviousNthItem(n)

	def PreviousItem()
		return This.List()[ This.PreviousPosition() ]

	def NextNthItem(n)
		if n + This.CurrentPosition() <= len(This.List())
			return This.List()[ This.NextNthPosition(n) ]

		ok

		def NthNextItem(n)
			return This.NextNtthItem()

	def NextItem()
		return This.NextNthItem(1)

	def CurrentItem()
		return This.List()[ This.CurrentPosition() ]

	def NextNthPosition(n)
		return StzListQ(This.ParsedPositions()).NextNthItemST(n, This.CurrentPosition())

		def NthNextPosition(n)
			return This.NextNthPosition(n)

	def PreviousNthPosition(n)
		return StzListQ(This.ParsedPositions()).PreviousNthItemST(n, This.CurrentPosition())

		def NthPreviousPosition(n)
			return This.PreviousNthPosition(n)
