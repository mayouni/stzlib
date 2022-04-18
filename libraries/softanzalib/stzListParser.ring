
func StzListParserQ(paList)
	return new stzListParser(paList)

class stzListParser from stzParser
	@aList = []
	@anParsedPositions = []

	@nStart
	@nEnd
	@nStep

	@nCurrentPosition = 1

	@nDefaultStartPosition = 1
	@nDefaultEndPosition = :End
	@nDefaultNumberOfSteps = 1

	@nDefaultCurrentPosition = 1

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(paList)

		if NOT isList(paList)
			stzRaise("Can't create the stzListParser object! You should provide a list.")
		ok

		if len(paList) = 0
			stzRaise("Can't create the stzListParser object! The list you provided is empty.")
		ok

		@aList = paList
		This.Parse( @nDefaultStartPosition, @nDefaultEndPosition, @nDefaultNumberOfSteps )

	  #----------------------#
	 #     GENERAL INFO     #
	#----------------------#

	def List()
		return @aList

	def ParsedPositions()
		return @anParsedPositions

	def StartPosition()
		return @nStart

	def EndPosition()
		return @nEnd
	
	def NumberOfSteps()
		return @nStep

	  #-------------#
	 #   PARSING   #
	#-------------#

	def Parse(pnStart, pnEnd, pnStep)

		if isList(pnStart) and 
		   ( StzListQ(pnStart).IsStartingAtNamedParamList() or
		     StzListQ(pnStart).IsFromNamedParamList() )

			if pnStart[2] = :First
				pnStart[2] = 1

			else
				pnStart = pnStart[2]
			ok

			
		ok

		if isList(pnEnd) and StzListQ(pnEnd).IsToNamedParamList()

			if pnEnd[2] = :Last
				pnEnd = len(This.List())
			else
				pnEnd = pnEnd[2]
			ok

		ok

		if isList(pnStep) and StzListQ(pnStep).IsStepNamedParamList()
			pnStep = pnStep[2]
		ok

		if pnStart = :First
			pnStart = 1
		ok

		if pnEnd = :Last
			pnEnd = len(This.List())
		ok

		@nStart = pnStart
		@nEnd = pnEnd
		@nStep = pnStep

		@anParsedPositions = []

		for i = pnStart to pnEnd step pnStep
			@anParsedPositions + i
		next i

		@nCurrentPosition = @anParsedPositions[1]


	def SetStartPosition(pnStart)
		@nStart = pnStart
		This.Parse( pnStart, This.EndPosition(), This.NumberOfSteps() )

	def SetEndPosition(pnEnd)
		@nEnd = pnEnd
		This.Parse( This.StartPosition(), pnEnd, This.NumberOfSteps() )

	def SetNumberOfSteps(pnSteps)
		@nSteps = pnSteps
		This.Parse( This.StartPosition(), This.EndPosition(), pnSteps )

	  #----------------------#
	 #   CURRENT POSITION   #
	#----------------------#

	def SetCurrentPosition(n)
		if isNumber(n) and StzNumberQ(n).ExistsIn( This.ParsedPositions() )
			@nCurrentPosition = n

		but isString(n) and n = :Default
			@nCurrentPosition = @nDefaultCurrentPosition
		ok

	def CurrentPosition()
		return @nCurrentPosition

	def ResetCurrentPosition()
		@nCurrentPosition = 1

  	  #-----------------------#
	 #   NEXT NTH POSITION   #
	#-----------------------#

	def NextNthPosition(n)

		nPos = find( This.ParsedPositions(), This.CurrentPosition() )

		if nPos != 0
			nResult = This.ParsedPositions()[ nPos + n ]
			This.SetCurrentPosition( nResult )
			return nResult
		else
			return 0
		ok

		def NthNextPosition(n)
			return This.NextNthPosition(n)

	def NextPosition()
		return This.NextNthPosition(1)

  	  #---------------------------#
	 #   PREVIOUS NTH POSITION   #
	#---------------------------#

	def PreviousNthPosition(n)

		nPos = find( This.ParsedPositions(), This.CurrentPosition() )

		if nPos != 0
			nResult = This.ParsedPositions()[ nPos - n ]
			This.SetCurrentPosition( nResult )
			return nResult
		else
			return 0
		ok

		def NthPreviousPosition(n)
			return This.PreviousNthPosition(n)

	def PreviousPosition()
		return This.PreviousNthPosition(1)

	  #-------------------#
	 #   PARSING ITEMS   #
	#-------------------#

	def ParsedItems()

		aResult = []

		for nPosition in This.ParsedPositions()
			aResult + This.List()[ nPosition ]
		next

		return aResult

	def CurrentItem()
		return This.List()[ This.CurrentPosition() ]

	def NextNthItem(n)
		return This.List()[ This.NextNthPosition(n) ]

		def NthNextItem(n)
			return This.NextNthItem(n)

	def NextItem()
		return This.NextNthItem(1)

	def PreviousNthItem(n)
		return This.List()[ This.PreviousNthPosition(n) ]

		def NthPreviousItem(n)
			return This.PreviousNthItem(n)

	def PreviousItem()
		return This.PreviousNthItem(1)

	  #--------------------------#
	 #   RESETTING THE PARSER   #
	#--------------------------#

	def Reset()
		This.Parse( This.DefaultStartPosition(), This.DefaultEndPosition(), This.DefaultNumberOfSteps())
		This.ResetCurrentPosition()

	def SetDefaultStartPosition(pnStart)
		@nDefaultStartPosition = pnStart

	def DefaultStartPosition()
		return @nDefaultStartPosition

	def SetDefaultEndPosition(pnEnd)
		@nDefaultEndPosition = pnEnd

	def DefaultEndPosition()
		return @nDefaultEndPosition

	def SetDefaultNumberOfSteps(pnSteps)
		@nDefaultNumberOfSteps = pnSteps

	def DefaultNumberOfSteps()
		return @nDefaultNumberOfSteps

	def SetDefaultCurrentPosition(n)
		@nDefaultCurrentPosition = n

	def DefaultCurrentPosition()
		return @nDefaultCurrentPosition
