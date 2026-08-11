
func StzListParserQ(paList)
	return new stzListParser(paList)

# Minimal parent class -- the full stzParser lives in max/ and isn't
# loaded by base/. stzListParser uses this lightweight base-only
# stzParser stub so it can be loaded directly from stzBase.
# Both classes are declared together so Ring's "subsequent funcs
# get swallowed by the most-recent class" rule doesn't bite us.
class stzParser from stzObject
	@xSource = ""

	def init(pSource)
		@xSource = pSource

	def Source()
		return @xSource

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
			StzRaise("Can't create the stzListParser object! You should provide a list.")
		ok

		if len(paList) = 0
			StzRaise("Can't create the stzListParser object! The list you provided is empty.")
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
		   ( IsStartingAtNamedParamList(pnStart) or
		     IsFromNamedParamList(pnStart) )

			if pnStart[2] = :First or pnStart[2] = :Start
				pnStart[2] = 1

			else
				pnStart = pnStart[2]
			ok

			
		ok

		if isList(pnEnd) and IsToNamedParamList(pnEnd)

			if pnEnd[2] = :Last or pnEnd[2] = :End
				pnEnd = len(This.List())
			else
				pnEnd = pnEnd[2]
			ok

		ok

		if isList(pnStep) and IsStepNamedParamList(pnStep)
			pnStep = pnStep[2]
		ok

		if pnStart = :First or pnStart = :Start
			pnStart = 1
		ok

		if pnEnd = :Last or pnEnd = :End
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
		# @nSteps used to be written here and read by nothing: the live attribute
		# is @nStep, which Parse() below sets and NumberOfSteps() returns. It was
		# not even declared -- the assignment created it -- so the class carried a
		# dead twin one letter away from the real one.
		This.Parse( This.StartPosition(), This.EndPosition(), pnSteps )

	  #----------------------#
	 #   CURRENT POSITION   #
	#----------------------#

	def SetCurrentPosition(n)
		if isNumber(n) and StzNumberQ(n).ExistsIn( This.ParsedPositions() )
			@nCurrentPosition = n

		but isString(n) and n = :Default
			@nCurrentPosition = This._DefaultOrFirstParsed()
		ok

	def CurrentPosition()
		return @nCurrentPosition

	# BACK TO WHERE A FRESH PARSE STARTS.
	#
	# This hardcoded 1, which ignored SetDefaultCurrentPosition() outright and --
	# worse -- could leave the parser on a position that is not in the parse at
	# all: parse 3..8 by 2, reset, and it sat on position 1, which its own
	# SetCurrentPosition() REFUSES, while CurrentItem() went on reading outside
	# the parsed range. Reset() calls this, so Reset() inherited both.
	#
	# SetCurrentPosition(:Default) meant the same thing and did something else,
	# so the two now share one rule.
	def ResetCurrentPosition()
		@nCurrentPosition = This._DefaultOrFirstParsed()

	# The declared default when it is actually in the parse; otherwise the first
	# parsed position -- which is exactly where Parse() itself leaves the cursor.
	def _DefaultOrFirstParsed()
		if StzFindFirst(@nDefaultCurrentPosition, @anParsedPositions) > 0
			return @nDefaultCurrentPosition
		ok
		if len(@anParsedPositions) > 0
			return @anParsedPositions[1]
		ok
		return @nDefaultCurrentPosition

  	  #-----------------------#
	 #   NEXT NTH POSITION   #
	#-----------------------#

	def NextNthPosition(n)

		_nPos_ = StzFindFirst(This.CurrentPosition(), This.ParsedPositions())

		if _nPos_ != 0
			_nResult_ = This.ParsedPositions()[ _nPos_ + n ]
			This.SetCurrentPosition( _nResult_ )
			return _nResult_
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

		_nPos_ = StzFindFirst(This.CurrentPosition(), This.ParsedPositions())

		if _nPos_ != 0
			_nResult_ = This.ParsedPositions()[ _nPos_ - n ]
			This.SetCurrentPosition( _nResult_ )
			return _nResult_
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

		_aResult_ = []

		_aThisParsedPositions1_ = This.ParsedPositions()
		_nThisParsedPositions1Len_ = len(_aThisParsedPositions1_)
		for _iLoopThisParsedPositions1_ = 1 to _nThisParsedPositions1Len_
			_nPosition_ = _aThisParsedPositions1_[_iLoopThisParsedPositions1_]
			_aResult_ + This.List()[ _nPosition_ ]
		next

		return _aResult_

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
