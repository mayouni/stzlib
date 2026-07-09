#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLISTSECTIONS            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : List sections subclass -- section/slice     #
#                  retrieval, anti-sections, ranges, and        #
#                  section-based operations.                    #
#                  For aliases, use stzListSectionsXT.          #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzListSections from stzObject

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
			StzRaise("Can't create stzListSections! Parameter must be a list or stzList object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oList.Content()

	def NumberOfItems()
		return @oList.NumberOfItems()

	def IsEmpty()
		return @oList.IsEmpty()

	  #================================================#
	 #    GETTING A SECTION (OR SLICE) OF THE LIST    #
	#================================================#

	def SectionCS(_n1_, _n2_, pCaseSensitive)

		_nScLen_ = This.NumberOfItems()

		if CheckingParams()

			if isList(_n1_) and
			   IsOneOfTheseNamedParamsList(_n1_, [
					:From, :FromPosition, :FromItemAt, :FromItemAtPosition,
					:StartingAt, :StartingAtPosition,
					:StartingAtItemAt, :StartingAtItemAtPosition,
					:Between, :BetweenPosition, :BetweenCharAt,
					:BetweenItemAtPosition,
					:BetweenPositions, :BetweenItemsAtPosition
					])

				_n1_ = _n1_[2]
			ok

			if isList(_n2_) and
			   IsOneOfTheseNamedParamsList(_n2_, [
					:To, :ToPosition, :ToItemAt, :ToItemAtPosition,
					:Until, :UntilPosition, :UntilItemAt, :UntilItemAtPosition,
					:UpTo, :UpToPosition, :UpToItemAt, :UpToItemAtPosition,
					:And,
					:StartingAt, :StartingAtPosition, :StartingAtItemAt, :StartingAtItemAtPosition
					])

				_n2_ = _n2_[2]
			ok

			if isString(_n1_) and (_n1_ = :First or _n1_ = :FirstItem or
			   _n1_ = :Start or _n1_ = :StartOfList)
				_n1_ = 1
			ok

			if isString(_n2_) and (_n2_ = :Last or _n2_ = :LastItem or
			   _n2_ = :End or _n2_ = :EndOfList)
				_n2_ = _nScLen_
			ok

			if NOT (isNumber(_n1_) and isNumber(_n2_))
				StzRaise("Incorrect param types! n1 and n2 must be numbers.")
			ok
		ok

		if _n1_ < 0
			_n1_ = _nScLen_ + _n1_ + 1
		ok

		if _n2_ < 0
			_n2_ = _nScLen_ + _n2_ + 1
		ok

		if _n1_ = 0
			_n1_ = 1
		ok

		if _n2_ = 0
			_n2_ = 1
		ok

		if _n1_ > _nScLen_
			_n1_ = _nScLen_
		ok

		if _n2_ > _nScLen_
			_n2_ = _nScLen_
		ok

		if _n1_ > _n2_
			_nScTemp_ = _n1_
			_n1_ = _n2_
			_n2_ = _nScTemp_
		ok

		_pScList_ = @oList._EngineListFromContent()
		_pScSection_ = StzEngineListSection(_pScList_, _n1_, _n2_)
		if _pScSection_ != NULL
			_aScResult_ = StzEngineListContentToRingList(_pScSection_)
			StzEngineListFree(_pScSection_)
		else
			_aScResult_ = []
		ok
		StzEngineListFree(_pScList_)
		return _aScResult_

		def SectionCSQ(_n1_, _n2_, pCaseSensitive)
			return new stzList( This.SectionCS(_n1_, _n2_, pCaseSensitive) )

		def SliceCS(_n1_, _n2_, pCaseSensitive)
			return This.SectionCS(_n1_, _n2_, pCaseSensitive)

			def SliceCSQ(_n1_, _n2_, pCaseSensitive)
				return This.SectionCSQ(_n1_, _n2_, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def Section(_n1_, _n2_)
		return This.SectionCS(_n1_, _n2_, 1)

		def SectionQ(_n1_, _n2_)
			return new stzList(This.Section(_n1_, _n2_))

		def Slice(_n1_, _n2_)
			return This.Section(_n1_, _n2_)

			def SliceQ(_n1_, _n2_)
				return new stzList(This.Slice(_n1_, _n2_))

	  #------------------------------------------------------------#
	 #   GETTING A SECTION (OR SLICE) OF THE LIST -- Z/EXTENDED   #
	#------------------------------------------------------------#

	def SectionCSZ(_n1_, _n2_, pCaseSensitive)
		if CheckingParams()
			if isString(_n1_) and (_n1_ = :Start or _n1_ = :StartOfList)
				_n1_ = 1
			ok

			if NOT isNumber(_n1_)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok
		ok

		_aSczResult_ = [ This.SectionCS(_n1_, _n2_, pCaseSensitive), _n1_ ]
		return _aSczResult_

		def SliceCSZ(_n1_, _n2_, pCaseSensitive)
			return This.SectionCSZ(_n1_, _n2_, pCaseSensitive)

	def SectionZ(_n1_, _n2_)
		return This.SectionCSZ(_n1_, _n2_, 1)

		def SliceZ(_n1_, _n2_)
			return SectionZ(_n1_, _n2_)

	  #------------------------------------------------------------#
	 #   GETTING A SECTION (OR SLICE) OF THE LIST -- ZZ/EXTENDED  #
	#------------------------------------------------------------#

	def SectionCSZZ(_n1_, _n2_, pCaseSensitive)
		if CheckingParams()
			if isString(_n1_) and (_n1_ = :Start or _n1_ = :StartOfList)
				_n1_ = 1
			ok

			if NOT isNumber(_n1_)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok
		ok

		_aSczzResult_ = [ This.SectionCS(_n1_, _n2_, pCaseSensitive), [_n1_, _n2_] ]
		return _aSczzResult_

		def SliceCSZZ(_n1_, _n2_, pCaseSensitive)
			return This.SectionCSZZ(_n1_, _n2_, pCaseSensitive)

	def SectionZZ(_n1_, _n2_)
		return This.SectionCSZZ(_n1_, _n2_, 1)

		def SliceZZ(_n1_, _n2_)
			return This.SectionZZ(_n1_, _n2_)

	  #======================================#
	 #   GETTING MANY SECTIONS (SLICES)     #
	#======================================#

	def Sections(paSections)
		_aSsResult_ = []
		_nSsLen_ = len(paSections)

		for _iSs_ = 1 to _nSsLen_
			@AddItem(_aSsResult_, This.Section(paSections[_iSs_][1], paSections[_iSs_][2]))
		next

		return _aSsResult_

		def SectionsQ(paSections)
			return new stzList( This.Sections(paSections) )

		def Slices(paSections)
			return This.Sections(paSections)

			def SlicesQ(paSections)
				return This.SectionsQ(paSections)

		def ManySections(paSections)
			return This.Sections(paSections)

	  #========================================================#
	 #   FINDING THE ANTI-SECTION(S) OF GIVEN SECTION(S)      #
	#========================================================#

	def FindAntiSection(_n1_, _n2_)
		if NOT ( isNumber(_n1_) and isNumber(_n2_) )
			StzRaise("Incorrect param types! n1 and n2 must be both Numbers.")
		ok

		return @oList.FindAntiSections([ [_n1_, _n2_ ] ])

		def FindAntiSectionZZ(_n1_, _n2_)
			return This.FindAntiSection(_n1_, _n2_)

		def AntiSectionZZ(_n1_, _n2_)
			return This.FindAntiSection(_n1_, _n2_)

	def AntiSection(_n1_, _n2_)
		_aAsResult_ = This.Section( This.FindAntiSection(_n1_, _n2_) )
		return _aAsResult_

		def AntiSectionQ(paSections)
			return new stzList( This.AntiSection(paSections) )

	  #------------------------------------------------------------#
	 #   FINDING THE ANTI-SECTIONS -- INCLUDING BOUNDS            #
	#------------------------------------------------------------#

	def FindAntiSectionIB(_n1_, _n2_)
		if NOT ( isNumber(_n1_) and isNumber(_n2_) )
			StzRaise("Incorrect param types! n1 and n2 must be both Numbers.")
		ok

		return @oList.FindAntiSectionsIB([ [_n1_, _n2_ ] ])

		def FindAntiSectionIBZZ(_n1_, _n2_)
			return This.FindAntiSectionIB(_n1_, _n2_)

		def AntiSectionIBZZ(_n1_, _n2_)
			return This.FindAntiSectionIB(_n1_, _n2_)

	def AntiSectionIB(_n1_, _n2_)
		_aAsiResult_ = This.Section( This.FindAntiSectionIB(_n1_, _n2_) )
		return _aAsiResult_

		def AntiSectionIBQ(paSections)
			return new stzList( This.AntiSectionIB(paSections) )

	  #===================================#
	 #    GETTING A RANGE OF THE LIST    #
	#===================================#

	def Range(pnStart, pnRange)

		if CheckingParams()
			if isString(pnStart)
				if pnStart = :First or pnStart = :FirstChar
					pnStart = 1
				but pnStart = :Last or pnStart = :LastChar
					pnStart = This.NumberOfItems()
				ok
			ok

			if NOT Q([pnStart, pnRange]).BothAreNumbers()
				StzRaise("Incorrect param type! pnStart and pnRange must be both numbers.")
			ok
		ok

		if pnStart < 0
			pnStart = This.NumberOfItems() + pnStart + 1
		ok

		if pnStart = 0 or pnRange = 0
			return ""
		ok

		_aRgResult_ = []

		if pnRange > 0
			@AddItem(_aRgResult_, This.Section( pnStart, pnStart + pnRange -1 ))
		else
			_nRgN1_ = pnStart + pnRange + 1
			if _nRgN1_ > 0
				@AddItem(_aRgResult_, This.Section( _nRgN1_, pnStart ))
			ok
		ok

		return _aRgResult_

		def RangeQ(pnStart, pnRange)
			return new stzList( This.Range(pnStart, pnRange) )

	  #--------------------------------------#
	 #  GETTING THE RANGE -- eXTended form  #
	#--------------------------------------#

	def RangeXT(pnStart, pnRange)
		if NOT (isNumber(pnStart) and isNumber(pnRange))
			StzRaise("Incorrect param types! pnStart and pnRange must be both numbers.")
		ok

		if NOT pnRange >= 0
			StzRaise("Incorrect param value! pnRange must be positive.")
		ok

		if pnStart < 0
			pnStart = @oList.NumberOfItems() + pnStart + 1
		ok

		_aRxSection_ = @RangeToSection(pnStart, pnRange)
		_aRxResult_ = @oList.SectionXT(_aRxSection_[1], _aRxSection_[2])

		return _aRxResult_

	  #------------------------------------#
	 #   GETTING MANY RANGES OF THE LIST  #
	#------------------------------------#

	def Ranges(paRanges)
		_aRgsResult_ = []

		_nRanges1Len_ = len(paRanges)
		for _iLoopRanges1_ = 1 to _nRanges1Len_
			_aRgsRange_ = paRanges[_iLoopRanges1_]
			@AddItem(_aRgsResult_, This.Range( _aRgsRange_[1], _aRgsRange_[2] ))
		next

		return _aRgsResult_

		def ManyRanges(paSections)
			return This.Ranges(paRanges)

	  #--------------------------------------------------------#
	 #   GETTING THE ANTI-RANGES OF A GIVEN SET OF SECTIONS   #
	#--------------------------------------------------------#

	def AntiRanges(paRanges)
		_aArSections_ = RangesToSections(paRanges)
		_aArResult_ = @oList.AntiSections(_aArSections_)

		return _aArResult_

		def RangesOtherThan(paRanges)
			return This.AntiRanges()

		def AntiRangesQ(paRanges)
			return new stzList( This.AntiRanges(paRanges) )

	def RangesAndAntiRanges(paRanges)
		_aRarSections_ = SectionsToRanges(paRanges)
		_aRarResult_ = @oList.SectionsAndAntiSections(_aRarSections_)
		return _aRarResult_

		def RangesAndAntiRangesQ(paRanges)
			return new stzList( This.RangesAndAntiRanges(paRanges) )

		def AllRangesIncluding(paRanges)
			return This.RangesAndAntiRanges(paRanges)

	  #---------------------------------------------------------------------------#
	 #   GETTING THE ANTI-RANGES -- INCLUDING BOUNDS                              #
	#---------------------------------------------------------------------------#

	def AntiRangesIB(paRanges)
		_aAribSections_ = RangesToSections(paRanges)
		_aAribResult_ = @oList.AntiSectionsIB(_aAribSections_)

		return _aAribResult_

		def RangesOtherThanIB(paRanges)
			return This.AntiRangesIB()

		def AntiRangesIBQ(paRanges)
			return new stzList( This.AntiRangesIB(paRanges) )

	def RangesAndAntiRangesIB(paRanges)
		_aRaribSections_ = SectionsToRanges(paRanges)
		_aRaribResult_ = @oList.SectionsAndAntiSectionsIB(_aRaribSections_)
		return _aRaribResult_

		def RangesAndAntiRangesIBQ(paRanges)
			return new stzList( This.RangesAndAntiRangesIB(paRanges) )

		def AllRangesIncludingIB(paRanges)
			return This.RangesAndAntiRangesIB(paRanges)
