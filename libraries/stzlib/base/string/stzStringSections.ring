#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGSECTIONS           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String sections -- Wraps stzString via      #
#                  composition. Extracting sections and ranges #
#                  from strings.                               #
#                  For aliases, use stzStringSectionsXT.       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringSections from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringSections! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   SECTION (SLICE)                                    #
	#======================================================#

	def SectionCS(_n1_, _n2_, pCaseSensitive)
		if CheckingParams()
			if isList(_n1_) and IsOneOfTheseNamedParamsList(_n1_, [:From, :FromPosition, :StartingAt])
				_n1_ = _n1_[2]
			ok
			if isList(_n2_) and IsOneOfTheseNamedParamsList(_n2_, [:To, :ToPosition, :Until])
				_n2_ = _n2_[2]
			ok
		ok
		return @oString.Section(_n1_, _n2_)

	def Section(_n1_, _n2_)
		return This.SectionCS(_n1_, _n2_, 1)

	  #======================================================#
	 #   RANGE                                              #
	#======================================================#

	def Range(pnStart, pnRange)
		return This.Section(pnStart, pnStart + pnRange - 1)

	  #======================================================#
	 #   MULTIPLE SECTIONS                                  #
	#======================================================#

	def Sections(paSections)
		_aResult_ = []
		_nLen_ = len(paSections)
		for i = 1 to _nLen_
			_aResult_ + This.Section(paSections[i][1], paSections[i][2])
		next
		return _aResult_

	  #======================================================#
	 #   ANTI-SECTIONS                                      #
	#======================================================#

	def AntiSections(paSections)
		_nLen_ = @oString.NumberOfChars()
		_aCovered_ = []
		_nSLen_ = len(paSections)
		for i = 1 to _nSLen_
			_n1_ = paSections[i][1]
			_n2_ = paSections[i][2]
			if _n1_ > _n2_
				_temp_ = _n1_
				_n1_ = _n2_
				_n2_ = _temp_
			ok
			for j = _n1_ to _n2_
				_aCovered_ + j
			next
		next

		_aResult_ = []
		_nStart_ = 0
		for i = 1 to _nLen_
			_bCovered_ = 0
			_nCoveredLen_ = len(_aCovered_)
			for k = 1 to _nCoveredLen_
				if _aCovered_[k] = i
					_bCovered_ = 1
					exit
				ok
			next
			if _bCovered_ = 0
				if _nStart_ = 0
					_nStart_ = i
				ok
			else
				if _nStart_ > 0
					_aResult_ + This.Section(_nStart_, i - 1)
					_nStart_ = 0
				ok
			ok
		next
		if _nStart_ > 0
			_aResult_ + This.Section(_nStart_, _nLen_)
		ok
		return _aResult_

	  #======================================================#
	 #   SECTION BETWEEN POSITIONS                          #
	#======================================================#

	def SectionBetween(_n1_, _n2_)
		return This.Section(_n1_ + 1, _n2_ - 1)

	  #======================================================#
	 #   REMOVE SECTION                                     #
	#======================================================#

	def RemoveSection(_n1_, _n2_)
		_nLen_ = @oString.NumberOfChars()
		if _n1_ < 1 _n1_ = 1 ok
		if _n2_ > _nLen_ _n2_ = _nLen_ ok
		if _n1_ > _n2_
			_temp_ = _n1_
			_n1_ = _n2_
			_n2_ = _temp_
		ok
		pH = @oString.Engine()
		pR = StzEngineStringRemoveRange(pH, _n1_, _n2_ - _n1_ + 1)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveSectionQ(_n1_, _n2_)
			This.RemoveSection(_n1_, _n2_)
			return This

	def SectionRemoved(_n1_, _n2_)
		_oCopy_ = new stzStringSections(@oString.Content())
		return _oCopy_.RemoveSectionQ(_n1_, _n2_).Content()

	  #======================================================#
	 #   REMOVE MANY SECTIONS                               #
	#======================================================#

	def RemoveSections(paSections)
		_nLen_ = len(paSections)
		for i = _nLen_ to 1 step -1
			This.RemoveSection(paSections[i][1], paSections[i][2])
		next

		def RemoveSectionsQ(paSections)
			This.RemoveSections(paSections)
			return This

	def SectionsRemoved(paSections)
		_oCopy_ = new stzStringSections(@oString.Content())
		return _oCopy_.RemoveSectionsQ(paSections).Content()

	  #======================================================#
	 #   REMOVE RANGE                                       #
	#======================================================#

	def RemoveRange(pnStart, pnRange)
		This.RemoveSection(pnStart, pnStart + pnRange - 1)

		def RemoveRangeQ(pnStart, pnRange)
			This.RemoveRange(pnStart, pnRange)
			return This

	def RangeRemoved(pnStart, pnRange)
		_oCopy_ = new stzStringSections(@oString.Content())
		return _oCopy_.RemoveRangeQ(pnStart, pnRange).Content()
