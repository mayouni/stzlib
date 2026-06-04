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

class stzListSections

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

	def SectionCS(n1, n2, pCaseSensitive)

		_nScLen_ = This.NumberOfItems()

		if CheckingParams()

			if isList(n1) and
			   IsOneOfTheseNamedParamsList(n1, [
					:From, :FromPosition, :FromItemAt, :FromItemAtPosition,
					:StartingAt, :StartingAtPosition,
					:StartingAtItemAt, :StartingAtItemAtPosition,
					:Between, :BetweenPosition, :BetweenCharAt,
					:BetweenItemAtPosition,
					:BetweenPositions, :BetweenItemsAtPosition
					])

				n1 = n1[2]
			ok

			if isList(n2) and
			   IsOneOfTheseNamedParamsList(n2, [
					:To, :ToPosition, :ToItemAt, :ToItemAtPosition,
					:Until, :UntilPosition, :UntilItemAt, :UntilItemAtPosition,
					:UpTo, :UpToPosition, :UpToItemAt, :UpToItemAtPosition,
					:And,
					:StartingAt, :StartingAtPosition, :StartingAtItemAt, :StartingAtItemAtPosition
					])

				n2 = n2[2]
			ok

			if isString(n1) and (n1 = :First or n1 = :FirstItem or
			   n1 = :Start or n1 = :StartOfList)
				n1 = 1
			ok

			if isString(n2) and (n2 = :Last or n2 = :LastItem or
			   n2 = :End or n2 = :EndOfList)
				n2 = _nScLen_
			ok

			if NOT (isNumber(n1) and isNumber(n2))
				StzRaise("Incorrect param types! n1 and n2 must be numbers.")
			ok
		ok

		if n1 < 0
			n1 = _nScLen_ + n1 + 1
		ok

		if n2 < 0
			n2 = _nScLen_ + n2 + 1
		ok

		if n1 = 0
			n1 = 1
		ok

		if n2 = 0
			n2 = 1
		ok

		if n1 > _nScLen_
			n1 = _nScLen_
		ok

		if n2 > _nScLen_
			n2 = _nScLen_
		ok

		if n1 > n2
			_nScTemp_ = n1
			n1 = n2
			n2 = _nScTemp_
		ok

		_pScList_ = @oList._EngineListFromContent()
		_pScSection_ = StzEngineListSection(_pScList_, n1, n2)
		if _pScSection_ != NULL
			_aScResult_ = StzEngineContentFromList(_pScSection_)
			StzEngineListFree(_pScSection_)
		else
			_aScResult_ = []
		ok
		StzEngineListFree(_pScList_)
		return _aScResult_

		def SectionCSQ(n1, n2, pCaseSensitive)
			return new stzList( This.SectionCS(n1, n2, pCaseSensitive) )

		def SliceCS(n1, n2, pCaseSensitive)
			return This.SectionCS(n1, n2, pCaseSensitive)

			def SliceCSQ(n1, n2, pCaseSensitive)
				return This.SectionCSQ(n1, n2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def Section(n1, n2)
		return This.SectionCS(n1, n2, 1)

		def SectionQ(n1, n2)
			return new stzList(This.Section(n1, n2))

		def Slice(n1, n2)
			return This.Section(n1, n2)

			def SliceQ(n1, n2)
				return new stzList(This.Slice(n1, n2))

	  #------------------------------------------------------------#
	 #   GETTING A SECTION (OR SLICE) OF THE LIST -- Z/EXTENDED   #
	#------------------------------------------------------------#

	def SectionCSZ(n1, n2, pCaseSensitive)
		if CheckingParams()
			if isString(n1) and (n1 = :Start or n1 = :StartOfList)
				n1 = 1
			ok

			if NOT isNumber(n1)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok
		ok

		_aSczResult_ = [ This.SectionCS(n1, n2, pCaseSensitive), n1 ]
		return _aSczResult_

		def SliceCSZ(n1, n2, pCaseSensitive)
			return This.SectionCSZ(n1, n2, pCaseSensitive)

	def SectionZ(n1, n2)
		return This.SectionCSZ(n1, n2, 1)

		def SliceZ(n1, n2)
			return SectionZ(n1, n2)

	  #------------------------------------------------------------#
	 #   GETTING A SECTION (OR SLICE) OF THE LIST -- ZZ/EXTENDED  #
	#------------------------------------------------------------#

	def SectionCSZZ(n1, n2, pCaseSensitive)
		if CheckingParams()
			if isString(n1) and (n1 = :Start or n1 = :StartOfList)
				n1 = 1
			ok

			if NOT isNumber(n1)
				StzRaise("Incorrect param type! n1 must be a number.")
			ok
		ok

		_aSczzResult_ = [ This.SectionCS(n1, n2, pCaseSensitive), [n1, n2] ]
		return _aSczzResult_

		def SliceCSZZ(n1, n2, pCaseSensitive)
			return This.SectionCSZZ(n1, n2, pCaseSensitive)

	def SectionZZ(n1, n2)
		return This.SectionCSZZ(n1, n2, 1)

		def SliceZZ(n1, n2)
			return This.SectionZZ(n1, n2)

	  #======================================#
	 #   GETTING MANY SECTIONS (SLICES)     #
	#======================================#

	def Sections(paSections)
		_aSsResult_ = []
		_nSsLen_ = ring_len(paSections)

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

	def FindAntiSection(n1, n2)
		if NOT ( isNumber(n1) and isNumber(n2) )
			StzRaise("Incorrect param types! n1 and n2 must be both Numbers.")
		ok

		return @oList.FindAntiSections([ [n1, n2 ] ])

		def FindAntiSectionZZ(n1, n2)
			return This.FindAntiSection(n1, n2)

		def AntiSectionZZ(n1, n2)
			return This.FindAntiSection(n1, n2)

	def AntiSection(n1, n2)
		_aAsResult_ = This.Section( This.FindAntiSection(n1, n2) )
		return _aAsResult_

		def AntiSectionQ(paSections)
			return new stzList( This.AntiSection(paSections) )

	  #------------------------------------------------------------#
	 #   FINDING THE ANTI-SECTIONS -- INCLUDING BOUNDS            #
	#------------------------------------------------------------#

	def FindAntiSectionIB(n1, n2)
		if NOT ( isNumber(n1) and isNumber(n2) )
			StzRaise("Incorrect param types! n1 and n2 must be both Numbers.")
		ok

		return @oList.FindAntiSectionsIB([ [n1, n2 ] ])

		def FindAntiSectionIBZZ(n1, n2)
			return This.FindAntiSectionIB(n1, n2)

		def AntiSectionIBZZ(n1, n2)
			return This.FindAntiSectionIB(n1, n2)

	def AntiSectionIB(n1, n2)
		_aAsiResult_ = This.Section( This.FindAntiSectionIB(n1, n2) )
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

		_nRanges1Len_ = ring_len(paRanges)
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
