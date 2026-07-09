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

class stzListRandom from stzObject

	@oList

	  #===================#
	 #   INITIALIZATION  #
	#===================#

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

	def Content()
		return @oList.Content()

	def List()
		return @oList.List()

	def NumberOfItems()
		return @oList.NumberOfItems()

	def IsEmpty()
		return @oList.IsEmpty()

	  #===========================================#
	 #   GETTING A RANDOM POSITION IN THE LIST   #
	#===========================================#

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
		while StzFindFirst(panPos, _nRpepResult_) > 0
			_nRpepResult_ = ARandomNumberBetween(1, _nRpepLen_)
		end

		return _nRpepResult_

	  #==========================================#
	 #   GETTING N RANDOM POSITIONS IN THE LIST #
	#==========================================#

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

	def NRandomItems(_n_)
		_pNriList_ = @oList._EngineListFromContent()
		_pNriPicked_ = StzEngineListRandomItems(_pNriList_, _n_)
		if _pNriPicked_ != NULL
			_aNriResult_ = StzEngineListContentToRingList(_pNriPicked_)
			StzEngineListFree(_pNriPicked_)
		else
			_aNriResult_ = []
		ok
		StzEngineListFree(_pNriList_)
		return _aNriResult_

		def SomeItems()
			_nSiN_ = ARandomNumberBetween(1, This.NumberOfItems())
			return This.NRandomItems(_nSiN_)

	  #================================================#
	 #   RANDOMIZING THE ITEMS POSITIONS IN THE LIST   #
	#================================================#

	def Randomize()
		_pRzList_ = @oList._EngineListFromContent()
		StzEngineListShuffle(_pRzList_)
		@oList.UpdateWith( StzEngineListContentToRingList(_pRzList_) )
		StzEngineListFree(_pRzList_)

		def RandomizeQ()
			This.Randomize()
			return This

		def Randomise()
			This.Randomize()

			def RandomiseQ()
				This.Randomise()
				return This

		def Shuffle()
			This.Randomize()

			def ShuffleQ()
				This.Shuffle()
				return This

		def RandomizePositions()
			This.Randomize()

			def RandomizePositionsQ()
				This.RandomizePositions()
				return This

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

		def RandomiseSection(n1, n2)
			This.RandomizeSection(n1, n2)

		def ShuffleSection(n1, n2)
			This.RandomizeSection(n1, n2)

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

		def RandomiseSections(panSections)
			This.RandomizeSections(panSections)

		def ShuffleSections(panSections)
			This.RandomizeSections(panSections)

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

	def RandomizeNumbers()
		_aRnSections_ = @oList.FindNumbersAsSections()
		This.RandomizeSections(_aRnSections_)

		def RandomizeNumbersQ()
			This.RandomizeNumbers()
			return This

		def RandomiseNumbers()
			This.RandomizeNumbers()

		def ShuffleNumbers()
			This.RandomizeNumbers()

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

	def RandomizeStrings()
		_aRstSections_ = @oList.FindStringsAsSections()
		This.RandomizeSections(_aRstSections_)

		def RandomizeStringsQ()
			This.RandomizeStrings()
			return This

		def RandomiseStrings()
			This.RandomizeStrings()

		def ShuffleStrings()
			This.RandomizeStrings()

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

	def RandomizeLists()
		_aRlSections_ = @oList.FindListsAsSections()
		This.RandomizeSections(_aRlSections_)

		def RandomizeListsQ()
			This.RandomizeLists()
			return This

		def RandomiseLists()
			This.RandomizeLists()

		def ShuffleLists()
			This.RandomizeLists()

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

	def RandomizeObjects()
		_aRoSections_ = @oList.FindObjectsAsSections()
		This.RandomizeSections(_aRoSections_)

		def RandomizeObjectsQ()
			This.RandomizeObjects()
			return This

		def RandomiseObjects()
			This.RandomizeObjects()

		def ShuffleObjects()
			This.RandomizeObjects()

	def ObjectsRandomized()
		_oOrdCopy_ = new stzListRandom(This.Content())
		_oOrdCopy_.RandomizeObjects()
		_aOrdResult_ = _oOrdCopy_.Content()
		return _aOrdResult_

		def ObjectsRandomised()
			return This.ObjectsRandomized()

		def ObjectsShuffled()
			return This.ObjectsRandomized()
