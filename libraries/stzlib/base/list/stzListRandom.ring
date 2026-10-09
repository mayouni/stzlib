#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTRANDOM              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List random subclass -- random position     #
#                  selection, random item retrieval, shuffle,   #
#                  and randomization of list content.           #
#                  For aliases, use stzListRandomXT.            #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

# Draws positions and items at random from a list, and shuffles the whole list, a section of it or the runs of one kind of item.
#
# Built around a list or a stzList. The drawing methods (RandomPosition, RandomItem, NRandomItems
# and their Except forms) leave the list as it is. Randomize, Shuffle and the section and typed
# variants change it in place and answer nothing, while Randomized and the other names ending in
# Randomized answer a shuffled copy. The typed shuffles (numbers, strings, lists, objects) only
# reorder items of that kind that sit next to each other: [ 1, 2, 3, "a", 4, 5 ] can swap 1, 2 and 3
# and swap 4 and 5, but a number never crosses the text. Two cautions: NRandomPositions(0) never
# returns, and RandomItemExceptPosition on a list of one item raises R2. The draws are random, so
# promises can only be made about shape and ranges.
#
#   receiver   o1 = new stzListRandom([ 10, 20, 30, 40, 50 ])
#   example    ? o1.NumberOfItems()
#              #--> 5
#              ? o1.RandomPositionGreaterThan(5)
#              #--> 0
#              ? len(o1.NRandomItems(3))
#              #--> 3
#              ? sum(o1.Randomized())
#              #--> 150
#              ? o1.Content()[1]
#              #--> 10
#   see        stzList, stzRandom
class stzListRandom from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	# Wraps a list, or a stzList object, so that its items and their order can be drawn and shuffled at random.
	#
	#   pListOrObj   a list, or a stzList object to share
	#   returns      nothing; the object is built
	#   note         given a list, the object works on its own copy
	#   warning      any other value, such as a text, raises an error saying the parameter must be a
	#                list or stzList object
	#   see          Content, Randomize, RandomItem
	def init(pListOrObj)
		if isList(pListOrObj)
			@oList = new stzList(pListOrObj)
		but isObject(pListOrObj)
			@oList = pListOrObj
		else
			StzRaise("Can't create stzListRandom! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	# Returns the list as it stands now, after any shuffle done in place.
	#
	#   returns    a list
	#   see        List, Randomized
	def Content()
		return @oList.Content()

	# Returns the list held by the object, the same items as the content accessor gives.
	#
	#   returns    a list
	#   see        Content
	def List()
		return @oList.List()

	# Returns how many items the list holds.
	#
	#   returns    a number
	#   see        IsEmpty, RandomPosition
	def NumberOfItems()
		return @oList.NumberOfItems()

	# TRUE if the list holds no item.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfItems
	def IsEmpty()
		return @oList.IsEmpty()

	  #===========================================#
	 #   GETTING A RANDOM POSITION IN THE LIST   #
	#===========================================#

	# Returns a position drawn at random, each position of the list equally likely.
	#
	#   returns    a number from 1 to the number of items; 0 for an empty list
	#   see        RandomItem, RandomPositionGreaterThan, RandomPositionLessThan
	def RandomPosition()
		_nRpResult_ = ARandomNumberBetween(1, This.NumberOfItems())
		return _nRpResult_

		def ARandomPosition()
			return This.RandomPosition()

		def APosition()
			return This.RandomPosition()

		def AnyPosition()
			return This.RandomPosition()

		def AnyRandomPosition()
			return This.RandomPosition()

	  #------------------------------------------------------------------------#
	 #   GETTING A RANDOM POSITION GREATER THAN / LESS THAN THE ONE PROVIDED  #
	#------------------------------------------------------------------------#

	# Returns a position drawn at random among those after the given one.
	#
	#   _n_        the position to stay after
	#   returns    a number from _n_ + 1 to the number of items; 0 when _n_ is already the last
	#              position or beyond
	#   warning    a value that is not a number raises an error
	#   see        RandomPositionLessThan, RandomPosition
	def RandomPositionGreaterThan(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_nRpgtLen_ = This.NumberOfItems()

		if _n_ >= _nRpgtLen_
			return 0
		ok

		_nRpgtResult_ = ARandomNumberBetween(_n_ + 1, _nRpgtLen_)
		return _nRpgtResult_

	# Returns a position drawn at random among those before the given one.
	#
	#   _n_        the position to stay before
	#   returns    a number from 1 to _n_ - 1; 0 when _n_ is 1 or less
	#   warning    a value that is not a number raises an error
	#   see        RandomPositionGreaterThan, RandomPosition
	def RandomPositionLessThan(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		if _n_ <= 1
			return 0
		ok

		_nRpltResult_ = ARandomNumberBetween(1, _n_ - 1)
		return _nRpltResult_

	  #------------------------------------------------#
	 #   GETTING A RANDOM POSITION EXCEPT ONE / MANY  #
	#------------------------------------------------#

	def RandomPositionExcept(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		_nRpeLen_ = This.NumberOfItems()

		if _nRpeLen_ <= 1
			return 0
		ok

		_nRpeResult_ = _n_
		while _nRpeResult_ = _n_
			_nRpeResult_ = ARandomNumberBetween(1, _nRpeLen_)
		end

		return _nRpeResult_

	# Returns a position drawn at random that is not in the list given.
	#
	#   panPos     the positions to avoid
	#   returns    a position that is free; 0 when every position is excluded
	#   note       with five items and 1, 2, 3 excluded it answers 4 or 5
	#   warning    a value that is not a list of numbers raises an error
	#   see        RandomPosition, RandomItemExceptPosition
	def RandomPositionExceptPositions(panPos)
		if CheckingParams()
			if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
				StzRaise("Incorrect param type! panPos must be a list of numbers.")
			ok
		ok

		_nRpepLen_ = This.NumberOfItems()
		_nRpepLenPos_ = len(panPos)

		if _nRpepLen_ - _nRpepLenPos_ <= 0
			return 0
		ok

		_nRpepResult_ = panPos[1]
		while StzFindFirst(_nRpepResult_, panPos) > 0
			_nRpepResult_ = ARandomNumberBetween(1, _nRpepLen_)
		end

		return _nRpepResult_

	  #==========================================#
	 #   GETTING N RANDOM POSITIONS IN THE LIST #
	#==========================================#

	# Returns several different positions in random order.
	#
	#   _n_        how many positions to draw
	#   returns    a list of different positions; every position, shuffled, when _n_ exceeds the
	#              number of items
	#   note       NRandomPositions(8) on eight items always gave a permutation of 1 to 8
	#   warning    it never returns when _n_ is 0 (tried on lists of 5 and of 3 items), so do not
	#              pass 0
	#   see        RandomPosition, NRandomItems
	def NRandomPositions(_n_)
		_nNrpLen_ = This.NumberOfItems()
		if _n_ >= _nNrpLen_
			_n_ = _nNrpLen_
		ok

		_anNrpResult_ = NUniqueRandomNumbersIn(_n_, 1:_nNrpLen_)
		return _anNrpResult_

		def NRandomPositionsU(_n_)
			return This.NRandomPositions(_n_)

	  #=================================#
	 #   GETTING A RANDOM ITEM         #
	#=================================#

	# Returns an item drawn at random, each item equally likely.
	#
	#   returns    one item of the list
	#   warning    an empty list raises an error, index outside the list
	#   see        RandomPosition, RandomItemExceptPosition, NRandomItems
	def RandomItem()
		return @oList.ItemAt( This.RandomPosition() )

		def ARandomItem()
			return This.RandomItem()

		def AnItem()
			return This.RandomItem()

		def AnyItem()
			return This.RandomItem()

		def AnyRandomItem()
			return This.RandomItem()

	  #-----------------------------------------------------#
	 #   GETTING A RANDOM ITEM EXCEPT THE ONE PROVIDED      #
	#-----------------------------------------------------#

	def RandomItemExceptCS(pItem, pCaseSensitive)
		_nRieLen_ = This.NumberOfItems()

		if _nRieLen_ <= 1
			StzRaise("Can't get a random item! The list has only one item.")
		ok

		_nRieTries_ = 0
		_rieResult_ = This.RandomItem()

		while BothAreEqualCS(_rieResult_, pItem, pCaseSensitive)
			_rieResult_ = This.RandomItem()
			_nRieTries_++
			if _nRieTries_ > 100
				exit
			ok
		end

		return _rieResult_

	def RandomItemExcept(pItem)
		return This.RandomItemExceptCS(pItem, 1)

		def AnItemOtherThan(pItem)
			return This.RandomItemExcept(pItem)

		def AnItemExcept(pItem)
			return This.RandomItemExcept(pItem)

		def AnyItemOtherThan(pItem)
			return This.RandomItemExcept(pItem)

		def AnyItemExcept(pItem)
			return This.RandomItemExcept(pItem)

	  #-----------------------------------------------------#
	 #   GETTING A RANDOM ITEM EXCEPT AT THE GIVEN POSITION #
	#-----------------------------------------------------#

	# Returns an item drawn at random from the positions other than the one given.
	#
	#   _n_        the position to leave out
	#   returns    one item of the list
	#   note       with 10, 20, 30, 40, 50 and position 1 it never answered 10
	#   warning    a list of one item raises R2 Array Access (Index out of range), because no other
	#              position exists
	#   see        RandomItem, RandomPositionExceptPositions
	def RandomItemExceptPosition(_n_)
		_riepResult_ = @oList.ItemAt( This.RandomPositionExcept(_n_) )
		return _riepResult_

		def ARandomItemExceptPosition(_n_)
			return This.RandomItemExceptPosition(_n_)

		def AnItemExceptPosition(_n_)
			return This.RandomItemExceptPosition(_n_)

		def AnItemExceptAt(_n_)
			return This.RandomItemExceptPosition(_n_)

	  #=================================#
	 #   GETTING N RANDOM ITEMS        #
	#=================================#

	# Returns several different items in random order.
	#
	#   _n_        how many items to draw
	#   returns    a list of _n_ items; the whole list, shuffled, when _n_ exceeds its length; [ ]
	#              for 0
	#   note       the list itself is not changed
	#   see        SomeItems, NRandomPositions, RandomItem
	def NRandomItems(_n_)
		_pNriList_ = @oList._EngineListFromContent()
		_pNriPicked_ = StzEngineListRandomItems(_pNriList_, _n_)
		if _pNriPicked_ != ""
			_aNriResult_ = StzEngineListContentToRingList(_pNriPicked_)
			StzEngineListFree(_pNriPicked_)
		else
			_aNriResult_ = []
		ok
		StzEngineListFree(_pNriList_)
		return _aNriResult_

		# Returns a random number of items, from 1 to all of them, drawn at random without repeats.
		#
		#   returns    a list of items
		#   see        NRandomItems, RandomItem
		def SomeItems()
			_nSiN_ = ARandomNumberBetween(1, This.NumberOfItems())
			return This.NRandomItems(_nSiN_)

	  #================================================#
	 #   RANDOMIZING THE ITEMS POSITIONS IN THE LIST   #
	#================================================#

	# Reorders all the items of the list at random, in place.
	#
	#   returns    nothing; the list is changed (use RandomizeQ to chain)
	#   note       the items stay the same, only their order changes: the sum of a numeric list is
	#              unchanged
	#   see        Randomized, RandomizeSection
	def Randomize()
		_pRzList_ = @oList._EngineListFromContent()
		StzEngineListShuffle(_pRzList_)
		@oList.UpdateWith( StzEngineListContentToRingList(_pRzList_) )
		StzEngineListFree(_pRzList_)

		def RandomizeQ()
			This.Randomize()
			return This

		# Reorders all the items at random, in place; the British spelling of the same call.
		#
		#   returns    nothing; the list is changed
		#   see        Randomize, Shuffle
		def Randomise()
			This.Randomize()

			def RandomiseQ()
				This.Randomise()
				return This

		# Reorders all the items at random, in place; the card-game name of the same call.
		#
		#   returns    nothing; the list is changed
		#   see        Randomize, Randomise
		def Shuffle()
			This.Randomize()

			def ShuffleQ()
				This.Shuffle()
				return This

		# Reorders all the items at random, in place; the same call spelt with the word positions.
		#
		#   returns    nothing; the list is changed
		#   see        Randomize, Shuffle
		def RandomizePositions()
			This.Randomize()

			def RandomizePositionsQ()
				This.RandomizePositions()
				return This

	# Returns a copy of the list with its items in random order, leaving the object as it was.
	#
	#   returns    a list
	#   note       the original keeps its order
	#   see        Randomize, SectionRandomized
	def Randomized()
		_oRzdCopy_ = new stzListRandom(This.Content())
		_oRzdCopy_.Randomize()
		return _oRzdCopy_.Content()

		def Randomised()
			return This.Randomized()

		def Shuffeled()
			return This.Randomized()

	  #---------------------------------------------------------------------#
	 #  RANDOMIZING THE ITEMS POSITIONS IN THE GIVEN SECTION OF THE LIST   #
	#---------------------------------------------------------------------#

	# Reorders at random the items from one position to another, in place, and leaves the rest where it is.
	#
	#   n1         the first position of the section
	#   n2         the last position of the section
	#   returns    nothing; the list is changed
	#   note       on 1 to 8, section 3 to 6 only permutes the items 3, 4, 5 and 6
	#   warning    positions that are not numbers raise an error
	#   see        SectionRandomized, RandomizeSections, Randomize
	def RandomizeSection(n1, n2)
		if CheckingParams()
			if NOT @BothAreNumbers(n1, n2)
				StzRaise("Incorrect param types! n1 and n2 must be both numbers.")
			ok
		ok

		_aRsContent_ = This.Content()

		_nRsLen_ = n2 - n1 + 1
		_anRsPos_ = NRandomNumbersBetweenU(_nRsLen_, n1, n2)
		_aRsItems_ = @oList.ItemsAtPositions(_anRsPos_)

		_jRs_ = 0
		for _iRs_ = n1 to n2
			_jRs_++
			_aRsContent_[_iRs_] = _aRsItems_[_jRs_]
		next

		@oList.UpdateWith(_aRsContent_)

		def RandomizeSectionQ(n1, n2)
			This.RandomizeSection(n1, n2)
			return This

		# Reorders at random the items from one position to another, in place; the British spelling of the same call.
		#
		#   n1         the first position of the section
		#   n2         the last position of the section
		#   returns    nothing; the list is changed
		#   see        RandomizeSection, ShuffleSection
		def RandomiseSection(n1, n2)
			This.RandomizeSection(n1, n2)

		# Reorders at random the items from one position to another, in place; the card-game name of the same call.
		#
		#   n1         the first position of the section
		#   n2         the last position of the section
		#   returns    nothing; the list is changed
		#   see        RandomizeSection, RandomiseSection
		def ShuffleSection(n1, n2)
			This.RandomizeSection(n1, n2)

	# Returns a copy of the list in which one section is in random order, leaving the object as it was.
	#
	#   n1         the first position of the section
	#   n2         the last position of the section
	#   returns    a list
	#   see        RandomizeSection, Randomized
	def SectionRandomized(n1, n2)
		_oSrdCopy_ = new stzListRandom(This.Content())
		_oSrdCopy_.RandomizeSection(n1, n2)
		_aSrdResult_ = _oSrdCopy_.Content()
		return _aSrdResult_

		def SectionRandomised(n1, n2)
			return This.SectionRandomized(n1, n2)

	  #----------------------------------------------------------------------#
	 #  RANDOMIZING THE ITEMS POSITIONS IN THE GIVEN SECTIONS OF THE LIST   #
	#----------------------------------------------------------------------#

	# Reorders at random each of several sections of the list, in place, one after the other.
	#
	#   panSections   a list of [ first, last ] pairs of positions
	#   returns       nothing; the list is changed
	#   note          the sections [ 1, 3 ] and [ 6, 8 ] of eight items permute inside themselves
	#                 only
	#   warning       a value that is not a list of pairs of numbers raises an error
	#   see           RandomizeSection, SectionsRandomized
	def RandomizeSections(panSections)
		if CheckingParams()
			if NOT ( isList(panSections) and @IsListOfPairsOfNumbers(panSections) )
				StzRaise("Incorrect param type! panSections must be a list of pairs of numbers.")
			ok
		ok

		_nRssLen_ = len(panSections)
		for _iRss_ = 1 to _nRssLen_
			This.RandomizeSection(panSections[_iRss_][1], panSections[_iRss_][2])
		next

		def RandomizeSectionsQ(panSections)
			This.RandomizeSections(panSections)
			return This

		# Reorders at random each of several sections, in place; the British spelling of the same call.
		#
		#   panSections   a list of [ first, last ] pairs of positions
		#   returns       nothing; the list is changed
		#   see           RandomizeSections, ShuffleSections
		def RandomiseSections(panSections)
			This.RandomizeSections(panSections)

		# Reorders at random each of several sections, in place; the card-game name of the same call.
		#
		#   panSections   a list of [ first, last ] pairs of positions
		#   returns       nothing; the list is changed
		#   see           RandomizeSections, RandomiseSections
		def ShuffleSections(panSections)
			This.RandomizeSections(panSections)

	# Returns a copy of the list in which several sections are in random order, leaving the object as it was.
	#
	#   panSections   a list of [ first, last ] pairs of positions
	#   returns       a list
	#   see           RandomizeSections, SectionRandomized
	def SectionsRandomized(panSections)
		_oSsrdCopy_ = new stzListRandom(This.Content())
		_oSsrdCopy_.RandomizeSections(panSections)
		_aSsrdResult_ = _oSsrdCopy_.Content()
		return _aSsrdResult_

		def SectionsRandomised(panSections)
			return This.SectionsRandomized(panSections)

	  #-------------------------------------------------#
	 #  RANDOMIZING THE NUMBERS EXISTING IN THE LIST    #
	#=================================================#

	# Reorders at random the numbers that sit next to each other in the list, in place, each such run on its own.
	#
	#   returns    nothing; the list is changed
	#   warning    a number never moves across a text or any other item, and a lone number between
	#              two other items stays where it is: [ 1, 2, 3, "a", 4, 5 ] only permutes 1, 2, 3
	#              and 4, 5, and [ 1, "a", 2, "b" ] never changes
	#   see        NumbersRandomized, RandomizeStrings
	def RandomizeNumbers()
		_aRnSections_ = @oList.FindNumbersAsSections()
		This.RandomizeSections(_aRnSections_)

		def RandomizeNumbersQ()
			This.RandomizeNumbers()
			return This

		# Reorders at random the runs of adjacent numbers, in place; the British spelling of the same call.
		#
		#   returns    nothing; the list is changed
		#   see        RandomizeNumbers, ShuffleNumbers
		def RandomiseNumbers()
			This.RandomizeNumbers()

		# Reorders at random the runs of adjacent numbers, in place; the card-game name of the same call.
		#
		#   returns    nothing; the list is changed
		#   see        RandomizeNumbers, RandomiseNumbers
		def ShuffleNumbers()
			This.RandomizeNumbers()

	# Returns a copy in which each run of adjacent numbers is in random order, leaving the object as it was.
	#
	#   returns    a list
	#   note       over 60 draws no number left its run
	#   see        RandomizeNumbers, StringsRandomized
	def NumbersRandomized()
		_oNrdCopy_ = new stzListRandom(This.Content())
		_oNrdCopy_.RandomizeNumbers()
		_aNrdResult_ = _oNrdCopy_.Content()
		return _aNrdResult_

		def NumbersRandomised()
			return This.NumbersRandomized()

		def NumbersShuffled()
			return This.NumbersRandomized()

	  #-------------------------------------------------#
	 #  RANDOMIZING THE STRINGS EXISTING IN THE LIST    #
	#=================================================#

	# Reorders at random the texts that sit next to each other in the list, in place, each such run on its own.
	#
	#   returns    nothing; the list is changed
	#   warning    a text never moves across a number or any other item, and a lone text between
	#              other items stays put
	#   see        StringsRandomized, RandomizeNumbers
	def RandomizeStrings()
		_aRstSections_ = @oList.FindStringsAsSections()
		This.RandomizeSections(_aRstSections_)

		def RandomizeStringsQ()
			This.RandomizeStrings()
			return This

		# Reorders at random the runs of adjacent texts, in place; the British spelling of the same call.
		#
		#   returns    nothing; the list is changed
		#   see        RandomizeStrings, ShuffleStrings
		def RandomiseStrings()
			This.RandomizeStrings()

		# Reorders at random the runs of adjacent texts, in place; the card-game name of the same call.
		#
		#   returns    nothing; the list is changed
		#   see        RandomizeStrings, RandomiseStrings
		def ShuffleStrings()
			This.RandomizeStrings()

	# Returns a copy in which each run of adjacent texts is in random order, leaving the object as it was.
	#
	#   returns    a list
	#   see        RandomizeStrings, NumbersRandomized
	def StringsRandomized()
		_oSrtdCopy_ = new stzListRandom(This.Content())
		_oSrtdCopy_.RandomizeStrings()
		_aSrtdResult_ = _oSrtdCopy_.Content()
		return _aSrtdResult_

		def StringsRandomised()
			return This.StringsRandomized()

		def StringsShuffled()
			return This.StringsRandomized()

	  #-------------------------------------------------#
	 #  RANDOMIZING THE LISTS EXISTING IN THE LIST      #
	#=================================================#

	# Reorders at random the lists that sit next to each other in the list, in place, each such run on its own.
	#
	#   returns    nothing; the list is changed
	#   warning    a list never moves across another kind of item, and a lone list between other
	#              items stays put
	#   see        ListsRandomized, RandomizeNumbers
	def RandomizeLists()
		_aRlSections_ = @oList.FindListsAsSections()
		This.RandomizeSections(_aRlSections_)

		def RandomizeListsQ()
			This.RandomizeLists()
			return This

		# Reorders at random the runs of adjacent lists, in place; the British spelling of the same call.
		#
		#   returns    nothing; the list is changed
		#   see        RandomizeLists, ShuffleLists
		def RandomiseLists()
			This.RandomizeLists()

		# Reorders at random the runs of adjacent lists, in place; the card-game name of the same call.
		#
		#   returns    nothing; the list is changed
		#   see        RandomizeLists, RandomiseLists
		def ShuffleLists()
			This.RandomizeLists()

	# Returns a copy in which each run of adjacent lists is in random order, leaving the object as it was.
	#
	#   returns    a list
	#   see        RandomizeLists, StringsRandomized
	def ListsRandomized()
		_oLrdCopy_ = new stzListRandom(This.Content())
		_oLrdCopy_.RandomizeLists()
		_aLrdResult_ = _oLrdCopy_.Content()
		return _aLrdResult_

		def ListsRandomised()
			return This.ListsRandomized()

		def ListsShuffled()
			return This.ListsRandomized()

	  #-------------------------------------------------#
	 #  RANDOMIZING THE OBJECTS EXISTING IN THE LIST    #
	#=================================================#

	# Reorders at random the objects that sit next to each other in the list, in place, each such run on its own.
	#
	#   returns    nothing; the list is changed
	#   warning    an object never moves across another kind of item
	#   see        ObjectsRandomized, RandomizeLists
	def RandomizeObjects()
		_aRoSections_ = @oList.FindObjectsAsSections()
		This.RandomizeSections(_aRoSections_)

		def RandomizeObjectsQ()
			This.RandomizeObjects()
			return This

		# Reorders at random the runs of adjacent objects, in place; the British spelling of the same call.
		#
		#   returns    nothing; the list is changed
		#   see        RandomizeObjects, ShuffleObjects
		def RandomiseObjects()
			This.RandomizeObjects()

		# Reorders at random the runs of adjacent objects, in place; the card-game name of the same call.
		#
		#   returns    nothing; the list is changed
		#   see        RandomizeObjects, RandomiseObjects
		def ShuffleObjects()
			This.RandomizeObjects()

	# Returns a copy in which each run of adjacent objects is in random order, leaving the object as it was.
	#
	#   returns    a list
	#   see        RandomizeObjects, ListsRandomized
	def ObjectsRandomized()
		_oOrdCopy_ = new stzListRandom(This.Content())
		_oOrdCopy_.RandomizeObjects()
		_aOrdResult_ = _oOrdCopy_.Content()
		return _aOrdResult_

		def ObjectsRandomised()
			return This.ObjectsRandomized()

		def ObjectsShuffled()
			return This.ObjectsRandomized()
