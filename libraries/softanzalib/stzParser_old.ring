/*
	Actually, this class parses only a 1D list, like this:
		1  2  3  4  5

	By default the direction of parsing is from left to right, starting at 1
	and ending at the last item of the list.

	IDEA :

	At the grid level, a GridParser class is to be made (todo):
	   1  2  3  4  5
	1  .  .  .  .  .
	2  .  .  .  .  .
	3  .  .  .  .  .
	4  .  .  .  .  .
	5  .  .  .  .  .

	In the future, 3D spaces must also have their Parser class (todo)

	For grids, the direction of parsing can be set by fellowing the order of numbers
	like this:

	1 2 3
	4 5 6
	7 8 9

	But can be anything like this:
	1 2 3
	6 5 4
	7 8 9

	or this:

	1 2 3
	8 9 4
	7 6 5

	or this:

	1 4 6
	7 2 5
	9 8 3

	or this:
	2 3 4
	9 1 5
	8 7 6

	or this
	9 2 3
	8 1 4
	7 6 5

	etc.
*/

class stzParser

	Content

	CurrentItem
	
	StartOfParsing
	EndOfParsing
	NumberOfSteps

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(n)

		Content = 1:n

		setStartOfParsing(1)
		setEndOfParsing(len(Content))
		setCurrentItem(1)
		setNumberOfSteps(1)

	  #-----------------#
	 #     GENERAL     #
	#-----------------#

	def Show()
		? Content()

	def Content()
		return Content

	  #------------------------#
	 #     PARSING PARAMS     #
	#------------------------#

	def SetNumberOfSteps(n)
		if n > 0 and n <= len( Content() )
			NumberOfSteps = n
		else
			raise("Number of steps out of range!")
		ok

	def NumberOfSteps()
		return NumberOfSteps

	def SetStartOfParsingAt(n)
		if n = :NumberOfItems
			n = len(Content)
		ok
		if n > 0 and n <= len(Content)
			StartOfParsing = n
		else
			raise("Start of parsing out of range!")
		ok

	def SetStartOfParsing(n)
		return SetStartOfParsingAt(n)

	def StartOfParsing()
		return StartOfParsing

	def SetEndOfParsingAt(n)
		if n = :NumberOfItems
			n = len(Content)
		ok
		if n > 0 and n <= len(Content)
			EndOfParsing = n
		else
			raise("End of parsing out of range!")
		ok

	def SetEndOfParsing(n)
		return SetEndOfParsingAt(n)

	def EndOfParsing()
		return EndOfParsing

	  #-----------------#
	 #     PARSING     #
	#-----------------#

	def Parse()
		return ParseOn( StartOfParsing(), EndOfParsing(), NumberOfSteps() )

	def ParseOn(pStartOfParsing, pEndOfParsing, pnSteps)
? pnsteps
dfdfdfdf
		aResult = []

		if pStartOfParsing = :NumberOfItems
			pStartOfParsing = This.NumberOfItems()

		but pStartOfParsing = :CurrentItem
			pStartOfParsing = This.CurrentItem()
		ok

		if pEndOfParsing = :NumberOfItems
			pEndOfParsing = This.NumberOfItems()

		but pEndOfParsing = :CurrentItem
			pEndOfParsing = This.CurrentItem
		ok

		if pnSteps = :CurrentNumberOfSteps
			pnsteps = This.NumberOfSteps()
		ok

		for i = pStartOfParsing to pEndOfParsing step pnSteps
			aResult + i
		next

		return aResult

	def ParseFromStartTo(n)

	def ParseFromStartToMiddle()

	def ParseFromEndToMiddle()

	def ParseFromEndTo(n)
	
	
	def ParseForward()

	def ParseBackward()

	def ParseInParallelOn( pa )

	def ParseRondomly()
	
	  #--------------------------------#
	 #     CURRENT AND NEXT ITEMS     #
	#--------------------------------#

	def SetCurrentItem(n)
		if n > 0 and n <= len(Parse())
			CurrentItem = Parse()[n]
			return CurrentItem
		else
			raise("Current item out of range!")
		ok

	def CurrentItem()
		return CurrentItem

	def NextItem()
		return NextNthItem(1)

	def NextNthItem(n)
		if n > 0 and n <= len(This.Parse())
			if n + CurrentItem() <= len(This.Parse())
				return CurrentItem() + n
			else
				raise("Out of range!")
			ok
		else
			raise("Number of steps out of range!")
		ok

	def PreviousItem()
		return PreviousNthItem(1)

	def PreviousNthItem(n)
		if n > 0 and n <= len(This.Parse())
			if CurrentItem() - n >= 1
				return CurrentItem() - n
			else
				raise("Out of range!")
			ok
		else
			raise("Number of steps out of range!")
		ok

	  #-----------------------------------#
	 #     MOVING IN THE PARSED LIST     #
	#-----------------------------------#

	def MoveToItem(n)
		This.SetCurrentItem(1)
		return CurrentItem()

	def MoveToFirstItem()
		return MoveToItem(1)

	def MoveToStart()
		return MoveToFirstItem()

	def MoveToLastItem()
		return MovetoItem( len(Content()) )

	def MoveToEnd()
		return MoveToLastItem()

	def MoveToMiddle()
		// TODO

	def MoveNStepsForeward(n)
		This.SetCurrentItem( CurrentItem() + n )
		return CurrentItem()

	def MoveNStepsBackward(n)
		This.SetCurrentItem( CurrentItem() - n )
		return CurrentItem()

	def MoveForeward()
		return MoveNStepsForeward(1)

	def MoveBackward()
		return MoveNstepsBacward(1)

	def MoveWhere( pItem, pCondition, pValue)
