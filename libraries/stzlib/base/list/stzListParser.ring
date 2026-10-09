
func StzListParserQ(paList)
	return new stzListParser(paList)

# Keeps a value as the source to parse; the minimal base class that stzListParser is built on.
#
# In base/ this class is a stub: it stores whatever value it is built with and gives it back with
# Source. The full parser family lives elsewhere and is not loaded by the base library. Nothing else
# is defined here. stzListParser inherits from it but has its own init that does not call this one,
# so Source of a stzListParser answers an empty text; build a stzParser directly, or read the list
# of a stzListParser with List.
#
#   receiver   o1 = new stzParser("some source")
#   example    ? o1.Source()
#              #--> some source
#              o2 = new stzParser([ 1, 2 ])
#              ? @@( o2.Source() )
#              #--> [ 1, 2 ]
#   see        stzListParser
class stzParser from stzObject
	@xSource = ""

	# Builds the minimal base parser around any value and keeps it as its source.
	#
	#   pSource    the value to keep as the source, of any type
	#   returns    nothing; the object is built
	#   note       stzListParser inherits from it but does not call it: its own init takes a list
	#              and leaves Source empty
	#   see        Source
	def init(pSource)
		@xSource = pSource

	# Returns the value the parser was built around.
	#
	#   returns    the value given to init, of its own type
	#   note       on a stzListParser it answers an empty text, because that class stores its list
	#              elsewhere (see List)
	#   see        init
	def Source()
		return @xSource

# Walks through a list with a cursor, visiting the positions you choose: from a start to an end by a step, forward or backwards.
#
# A parser is built over a non-empty list with new stzListParser(aList) or StzListParserQ(aList); no
# stzList method builds one. Parse chooses the positions to visit (ParsedPositions) and ParsedItems
# answers the items there; the cursor, read with CurrentPosition and CurrentItem, moves with
# NextPosition, PreviousPosition and the Nth forms, which count visited positions, not list
# positions, so with a step of 2 NextNthPosition(2) advances four list positions. NextItem and
# PreviousItem move the cursor and answer the item, so two calls give two different items. Reset
# parses again with the default start, end and step (1, the last position, 1 until a SetDefault...
# call changes them), not with the last Parse. Positions count from 1. Moving past the last visited
# position, or before the first, raises a Ring error (R2, array access out of range) and leaves the
# cursor in place; Parse does not check the positions against the list, and ParsedItems raises when
# one is outside it. The base class stzParser only keeps a source value; a stzListParser does not
# fill it, so read the list with List.
#
#   receiver   o1 = new stzListParser([ "a", "b", "c", "d", "e", "f", "g", "h" ])
#   example    o1.Parse(3, 8, 2)
#              ? @@( o1.ParsedPositions() )
#              #--> [ 3, 5, 7 ]
#              ? @@( o1.ParsedItems() )
#              #--> [ "c", "e", "g" ]
#              ? o1.NextItem()
#              #--> e
#              ? o1.CurrentPosition()
#              #--> 5
#              o1.Reset()
#              ? o1.CurrentPosition()
#              #--> 1
#              o2 = new stzListParser([ "שלום", "مرحبا", "😀", "ok" ])
#              ? o2.NextItem()
#              #--> مرحبا
#   see        stzList, stzListSorter, stzListFlattener
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

	# Builds a parser over a non-empty list and parses it from the first position to the last, one step at a time.
	#
	#   paList     the list to walk through, which must not be empty, a text or an empty list raises
	#              an error
	#   returns    nothing; the object is built, with the cursor on position 1
	#   note       the parser keeps the list as given; stzParser.Source of a stzListParser answers
	#              an empty text, so read the list with List
	#   see        List, Parse
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

	# Returns the list being parsed.
	#
	#   returns    a list
	#   see        ParsedItems, ParsedPositions
	def List()
		return @aList

	# Returns the positions the current parse visits, in order.
	#
	#   returns    a list of numbers, positions in the list counted from 1
	#   note       after Parse(3, 8, 2) on a list of 8 it is [ 3, 5, 7 ]
	#   see        ParsedItems, Parse
	def ParsedPositions()
		return @anParsedPositions

	# Returns the position the current parse starts at.
	#
	#   returns    a number
	#   see        EndPosition, Parse
	def StartPosition()
		return @nStart

	# Returns the position the current parse was asked to stop at.
	#
	#   returns    a number
	#   note       after Parse(3, 8, 2) it is 8, though the last position visited is 7
	#   see        StartPosition, Parse
	def EndPosition()
		return @nEnd
	
	# Returns the step of the current parse: the distance between two visited positions.
	#
	#   returns    a number
	#   note       it is a step length, not a count of positions; use len(ParsedPositions()) for the
	#              count
	#   see        Parse, SetNumberOfSteps
	def NumberOfSteps()
		return @nStep

	  #-------------#
	 #   PARSING   #
	#-------------#

	# Chooses which positions to visit, from a start to an end by a step, and puts the cursor on the first one.
	#
	#   pnStart    the first position, a number or :First, also accepted as :From = n
	#   pnEnd      the last position, a number or :Last, also accepted as :To = n
	#   pnStep     the distance between two positions, a negative number walks backwards, also
	#              accepted as :Step = n
	#   returns    nothing; the parser is re-parsed
	#   note       Parse(5, 2, -1) on abcde visits 5, 4, 3, 2; no check is made against the list, so
	#              Parse(1, 20, 1) on a list of 5 gives 20 positions and ParsedItems then raises an
	#              error
	#   see        ParsedPositions, Reset, SetStartPosition
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


	# Changes the position the parse starts at and parses again, keeping the end and the step.
	#
	#   pnStart    the new first position
	#   returns    nothing; the parser is re-parsed and the cursor goes to the first position
	#   see        SetEndPosition, SetNumberOfSteps, Parse
	def SetStartPosition(pnStart)
		@nStart = pnStart
		This.Parse( pnStart, This.EndPosition(), This.NumberOfSteps() )

	# Changes the position the parse stops at and parses again, keeping the start and the step.
	#
	#   pnEnd      the new last position
	#   returns    nothing; the parser is re-parsed and the cursor goes to the first position
	#   see        SetStartPosition, SetNumberOfSteps, Parse
	def SetEndPosition(pnEnd)
		@nEnd = pnEnd
		This.Parse( This.StartPosition(), pnEnd, This.NumberOfSteps() )

	# Changes the step of the parse and parses again, keeping the start and the end.
	#
	#   pnSteps    the new distance between two positions
	#   returns    nothing; the parser is re-parsed and the cursor goes to the first position
	#   see        SetStartPosition, SetEndPosition, Parse
	def SetNumberOfSteps(pnSteps)
		# @nSteps used to be written here and read by nothing: the live attribute
		# is @nStep, which Parse() below sets and NumberOfSteps() returns. It was
		# not even declared -- the assignment created it -- so the class carried a
		# dead twin one letter away from the real one.
		This.Parse( This.StartPosition(), This.EndPosition(), pnSteps )

	  #----------------------#
	 #   CURRENT POSITION   #
	#----------------------#

	# Moves the cursor to a position that belongs to the parse, or back to the default one with :Default.
	#
	#   n          the position to move to, a number in ParsedPositions, or :Default for the default
	#              current position
	#   returns    nothing; a position outside the parse, or any other value, is ignored without an
	#              error
	#   note       SetCurrentPosition(5) on a parse of 4, 6 leaves the cursor where it was
	#   see        CurrentPosition, ResetCurrentPosition
	def SetCurrentPosition(n)
		if isNumber(n) and StzNumberQ(n).ExistsIn( This.ParsedPositions() )
			@nCurrentPosition = n

		but isString(n) and n = :Default
			@nCurrentPosition = This._DefaultOrFirstParsed()
		ok

	# Returns the position the cursor is on.
	#
	#   returns    a number
	#   see        CurrentItem, SetCurrentPosition
	def CurrentPosition()
		return @nCurrentPosition

	# Puts the cursor back on the default current position when the parse contains it, otherwise on the first parsed position.
	#
	#   returns    nothing; the cursor moves
	#   see        SetCurrentPosition, Reset
	#@ aka  BACK TO WHERE A FRESH PARSE STARTS.
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

	# Moves the cursor forward by n visited positions and returns the position it lands on.
	#
	#   n          how many visited positions to advance, counted in the parse, not in the list
	#   returns    a number, the new cursor position
	#   note       with a step of 2, NextNthPosition(2) advances four list positions;
	#              NthNextPosition is the same call
	#   warning    moving past the last visited position raises an error (R2, array access out of
	#              range) instead of answering 0, and the cursor stays where it was;
	#              NextNthPosition(9) on 5 positions and NextPosition on the last one both raise
	#   see        NextPosition, PreviousNthPosition, NextNthItem
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

	# Moves the cursor to the next visited position and returns it.
	#
	#   returns    a number, the new cursor position
	#   warning    moving past the last visited position raises an error (R2, array access out of
	#              range) and leaves the cursor in place
	#   see        NextNthPosition, PreviousPosition, NextItem
	def NextPosition()
		return This.NextNthPosition(1)

  	  #---------------------------#
	 #   PREVIOUS NTH POSITION   #
	#---------------------------#

	# Moves the cursor back by n visited positions and returns the position it lands on.
	#
	#   n          how many visited positions to go back, counted in the parse, not in the list
	#   returns    a number, the new cursor position
	#   note       NthPreviousPosition is the same call
	#   warning    moving before the first visited position raises an error (R2, array access out of
	#              range) instead of answering 0, and the cursor stays where it was
	#   see        PreviousPosition, NextNthPosition, PreviousNthItem
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

	# Moves the cursor to the previous visited position and returns it.
	#
	#   returns    a number, the new cursor position
	#   warning    moving before the first visited position raises an error (R2, array access out of
	#              range) and leaves the cursor in place
	#   see        PreviousNthPosition, NextPosition, PreviousItem
	def PreviousPosition()
		return This.PreviousNthPosition(1)

	  #-------------------#
	 #   PARSING ITEMS   #
	#-------------------#

	# Returns the items at the visited positions, in the order visited.
	#
	#   returns    a list of items
	#   note       with positions beyond the list it raises an error (R2, array access out of range)
	#   see        ParsedPositions, List
	def ParsedItems()

		_aResult_ = []

		_aThisParsedPositions1_ = This.ParsedPositions()
		_nThisParsedPositions1Len_ = len(_aThisParsedPositions1_)
		for _iLoopThisParsedPositions1_ = 1 to _nThisParsedPositions1Len_
			_nPosition_ = _aThisParsedPositions1_[_iLoopThisParsedPositions1_]
			_aResult_ + This.List()[ _nPosition_ ]
		next

		return _aResult_

	# Returns the item under the cursor, without moving it.
	#
	#   returns    the item at CurrentPosition
	#   see        CurrentPosition, NextItem
	def CurrentItem()
		return This.List()[ This.CurrentPosition() ]

	# Moves the cursor forward by n visited positions and returns the item it lands on.
	#
	#   n          how many visited positions to advance
	#   returns    the item at the new position
	#   note       NthNextItem is the same call
	#   warning    moving past the last visited position raises an error, as NextNthPosition does
	#   see        NextNthPosition, NextItem
	def NextNthItem(n)
		return This.List()[ This.NextNthPosition(n) ]

		def NthNextItem(n)
			return This.NextNthItem(n)

	# Moves the cursor to the next visited position and returns the item there.
	#
	#   returns    the item at the new position
	#   note       the cursor moves, so two calls give two different items
	#   warning    moving past the last visited position raises an error (R2, array access out of
	#              range)
	#   see        NextNthItem, PreviousItem, CurrentItem
	def NextItem()
		return This.NextNthItem(1)

	# Moves the cursor back by n visited positions and returns the item it lands on.
	#
	#   n          how many visited positions to go back
	#   returns    the item at the new position
	#   note       NthPreviousItem is the same call
	#   warning    moving before the first visited position raises an error, as PreviousNthPosition
	#              does
	#   see        PreviousNthPosition, PreviousItem
	def PreviousNthItem(n)
		return This.List()[ This.PreviousNthPosition(n) ]

		def NthPreviousItem(n)
			return This.PreviousNthItem(n)

	# Moves the cursor to the previous visited position and returns the item there.
	#
	#   returns    the item at the new position
	#   warning    moving before the first visited position raises an error (R2, array access out of
	#              range)
	#   see        PreviousNthItem, NextItem, CurrentItem
	def PreviousItem()
		return This.PreviousNthItem(1)

	  #--------------------------#
	 #   RESETTING THE PARSER   #
	#--------------------------#

	# Parses again with the default start, end and step, and puts the cursor back to its default.
	#
	#   returns    nothing; the parser is re-parsed
	#   note       it returns to the defaults (1, :End, 1), not to the last Parse
	#   see        Parse, ResetCurrentPosition, SetDefaultStartPosition
	def Reset()
		This.Parse( This.DefaultStartPosition(), This.DefaultEndPosition(), This.DefaultNumberOfSteps())
		This.ResetCurrentPosition()

	# Sets the start position Reset will use.
	#
	#   pnStart    the default first position
	#   returns    nothing; takes effect at the next Reset
	#   see        DefaultStartPosition, Reset
	def SetDefaultStartPosition(pnStart)
		@nDefaultStartPosition = pnStart

	# Returns the start position Reset uses.
	#
	#   returns    a number; 1 until changed
	#   see        SetDefaultStartPosition, Reset
	def DefaultStartPosition()
		return @nDefaultStartPosition

	# Sets the end position Reset will use.
	#
	#   pnEnd      the default last position, a number or :End
	#   returns    nothing; takes effect at the next Reset
	#   see        DefaultEndPosition, Reset
	def SetDefaultEndPosition(pnEnd)
		@nDefaultEndPosition = pnEnd

	# Returns the end position Reset uses.
	#
	#   returns    a number, or the word end until changed
	#   see        SetDefaultEndPosition, Reset
	def DefaultEndPosition()
		return @nDefaultEndPosition

	# Sets the step Reset will use.
	#
	#   pnSteps    the default distance between two positions
	#   returns    nothing; takes effect at the next Reset
	#   see        DefaultNumberOfSteps, Reset
	def SetDefaultNumberOfSteps(pnSteps)
		@nDefaultNumberOfSteps = pnSteps

	# Returns the step Reset uses.
	#
	#   returns    a number; 1 until changed
	#   see        SetDefaultNumberOfSteps, Reset
	def DefaultNumberOfSteps()
		return @nDefaultNumberOfSteps

	# Sets the position the cursor returns to on Reset and ResetCurrentPosition, when the parse contains it.
	#
	#   n          the default cursor position
	#   returns    nothing; takes effect at the next reset
	#   see        DefaultCurrentPosition, ResetCurrentPosition
	def SetDefaultCurrentPosition(n)
		@nDefaultCurrentPosition = n

	# Returns the position the cursor returns to on Reset.
	#
	#   returns    a number; 1 until changed
	#   see        SetDefaultCurrentPosition, ResetCurrentPosition
	def DefaultCurrentPosition()
		return @nDefaultCurrentPosition
