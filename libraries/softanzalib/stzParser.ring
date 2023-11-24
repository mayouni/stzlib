

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
		
	def MoveToNextPosition()
		This.MoveToNextNthPosition(1)

	def MoveToNextNthPosition(n)
		if n + This.CurrentPosition() <= This.NumberOfParsedItems()
			// Important: Don't swap the 2 following lines!
			nNthPosition = This.ParsedPositions()[ This.CurrentPosition() + n ]
			This.MoveToPosition( This.CurrentPosition() + n)
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
		return This.List()[ This.ParsedItems()[ This.NumberOfParsedItems() ] ]

	def NthItem(n)
		This.SetCurrentPosition(n)
		return This.List()[ This.ParsedItems()[ n ] ]

	def PreviousNthItem(n)
		return This.List()[ This.PreviousNthPosition(n) ]

	def PreviousItem()
		return This.List()[ This.PreviousPosition() ]

	def NextNthItem(n)
		if n + This.CurrentPosition() <= len(This.List())
			return This.List()[ This.NextNthPosition(n) ]

		ok

	def NextItem()
		return This.NextNthItem(1)

	def CurrentItem()
		return This.List()[ This.CurrentPosition() ]
