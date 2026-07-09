#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGBOUNDER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String bounder -- sections, ranges,         #
#                  between, bounding, and bounds checking.     #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringBounderXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringBounder from stzObject

	@oString

	  #===================#
	 #   INITIALIZATION  #
	#===================#

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringBounder! Parameter must be a string or stzString object.")
		ok

	  #===============================#
	 #     CONTENT ACCESS            #
	#===============================#

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     SECTION (SLICE)           #
	#===============================#

	def SectionCS(_n1_, _n2_, pCaseSensitive)

		_nLen_ = @oString.NumberOfChars()

		if CheckingParams()

			if isList(_n1_)
				_oN1_ = Q(_n1_)
				if IsOneOfTheseNamedParamsList(_n1_, [
					:From, :FromPosition, :Start, :FromStart,
					:StartingAt, :StartingAtPosition,
					:Between, :BetweenPosition ])
					_n1_ = _n1_[2]
				ok
			ok

			if isList(_n2_)
				_oN2_ = Q(_n2_)
				if IsOneOfTheseNamedParamsList(_n2_, [
					:To, :ToPosition, :End, :ToEnd,
					:Until, :UntilPosition, :UpTo, :UpToPosition, :And ])
					_n2_ = _n2_[2]
				ok
			ok

			if isString(_n1_)
				if _n1_ = :First or _n1_ = :FirstChar
					_n1_ = 1
				but _n1_ = :Last or _n1_ = :LastChar
					_n1_ = _nLen_
				else
					_oFinder_ = new stzStringFinder(@oString)
					_n1_ = _oFinder_.FindFirstCS(_n1_, pCaseSensitive)
				ok
			ok

			if isString(_n2_)
				if _n2_ = :End or _n2_ = :Last or _n2_ = :LastChar
					_n2_ = _nLen_
				but _n2_ = :First or _n2_ = :FirstChar
					_n2_ = 1
				else
					_nLen2_ = StzLen(_n2_)
					_oFinder_ = new stzStringFinder(@oString)
					_n2_ = _oFinder_.FindLastCS(_n2_, pCaseSensitive) + _nLen2_ - 1
				ok
			ok

			if NOT @BothAreNumbers(_n1_, _n2_)
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if _n1_ > _n2_
			_nSwap_ = _n1_
			_n1_ = _n2_
			_n2_ = _nSwap_
		ok

		if NOT ( _n1_ >= 1 and _n1_ <= _nLen_ and _n2_ >= 1 and _n2_ <= _nLen_ )
			StzRaise("Indexes out of range! n1 and n2 must be inside the string.")
		ok

		return @oString.Section(_n1_, _n2_)

		def SectionCSQ(_n1_, _n2_, pCaseSensitive)
			return new stzStringBounder( This.SectionCS(_n1_, _n2_, pCaseSensitive) )

	def Section(_n1_, _n2_)
		return This.SectionCS(_n1_, _n2_, 1)

		def SectionQ(_n1_, _n2_)
			return new stzStringBounder(This.Section(_n1_, _n2_))

	  #===============================#
	 #     MULTIPLE SECTIONS         #
	#===============================#

	def Sections(_aSections_)
		return @oString.Sections(_aSections_)

	  #===============================#
	 #     ANTI-SECTION              #
	#===============================#

	def AntiSection(_n1_, _n2_)
		_nLen_ = @oString.NumberOfChars()
		_acResult_ = []

		if _n1_ > 1
			_acResult_ + @oString.Section(1, _n1_ - 1)
		ok
		if _n2_ < _nLen_
			_acResult_ + @oString.Section(_n2_ + 1, _nLen_)
		ok

		return _acResult_

	  #===============================#
	 #     RANGE                     #
	#===============================#

	def RangeCS(_nStartPos_, nRange, pCaseSensitive)

		if CheckingParams()
			if NOT isNumber(nRange)
				StzRaise("Incorrect param type! nRange must be a number.")
			ok

			if isNumber(_nStartPos_)
				if _nStartPos_ < 0
					_nStartPos_ = @oString.NumberOfChars() + _nStartPos_ + 1
				ok
				if _nStartPos_ = 0 or nRange = 0
					return ""
				ok
			ok
		ok

		_cResult_ = ""

		if nRange > 0
			if CheckingParams() and isString(_nStartPos_)
				_oFinder_ = new stzStringFinder(@oString)
				_nStartPos_ = _oFinder_.FindFirstCS(_nStartPos_, pCaseSensitive)
			ok
			_cResult_ = This.SectionCS(_nStartPos_, _nStartPos_ + nRange - 1, pCaseSensitive)
		else
			_n1_ = _nStartPos_ + nRange + 1
			if _n1_ > 0
				_cResult_ = This.SectionCS(_n1_, _nStartPos_, pCaseSensitive)
			ok
		ok

		return _cResult_

		def RangeCSQ(_nStartPos_, nRange, pCaseSensitive)
			return new stzStringBounder( This.RangeCS(_nStartPos_, nRange, pCaseSensitive) )

	def Range(_nStartPos_, nRange)
		return This.RangeCS(_nStartPos_, nRange, 1)

		def RangeQ(_nStartPos_, nRange)
			return new stzStringBounder( This.Range(_nStartPos_, nRange) )

	  #===============================#
	 #     BETWEEN                   #
	#===============================#

	def BetweenCS(pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)
		# Softanza semantics: Between() returns ALL matches (list)

		if CheckingParams()
			if isList(pSubStrOrPos2) and IsAndNamedParamList(pSubStrOrPos2)
				pSubStrOrPos2 = pSubStrOrPos2[2]
			ok
		ok

		if NOT ( @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2) or @BothAreNumbers(pSubStrOrPos1, pSubStrOrPos2) )
			StzRaise("Incorrect params types! pSubStrOrPos1 and pSubStrOrPos2 must be both strings or numbers.")
		ok

		if @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2)
			# Engine-backed: returns ALL substrings as null-delimited buffer
			_bBtwnCase_ = @CaseSensitive(pCaseSensitive)
			pH = @oString.Engine()
			pR = StzEngineStringBetweenAllCS(pH, pSubStrOrPos1, pSubStrOrPos2, _bBtwnCase_)
			if pR = NULL return [] ok
			_cBtwnJoined_ = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			if _cBtwnJoined_ = ""
				return []
			ok
			return _SplitNullDelimited(_cBtwnJoined_)
		else
			# Positional: single section between two positions
			_n1_ = pSubStrOrPos1 + 1
			_n2_ = pSubStrOrPos2 - 1
			_cBtwnResult_ = @oString.Section(_n1_, _n2_)
			return [ _cBtwnResult_ ]
		ok

	def Between(pSubStrOrPos1, pSubStrOrPos2)
		return This.BetweenCS(pSubStrOrPos1, pSubStrOrPos2, 1)

	  #=======================================#
	 #     FIRST BETWEEN (single result)     #
	#=======================================#

	def FirstBetweenCS(pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)

		if CheckingParams()
			if isList(pSubStrOrPos2) and IsAndNamedParamList(pSubStrOrPos2)
				pSubStrOrPos2 = pSubStrOrPos2[2]
			ok
		ok

		if NOT ( @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2) or @BothAreNumbers(pSubStrOrPos1, pSubStrOrPos2) )
			StzRaise("Incorrect params types! pSubStrOrPos1 and pSubStrOrPos2 must be both strings or numbers.")
		ok

		if @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2)
			# Engine-backed: returns FIRST match only
			_bFbCase_ = @CaseSensitive(pCaseSensitive)
			pH = @oString.Engine()
			pR = StzEngineStringBetweenFirstCS(pH, pSubStrOrPos1, pSubStrOrPos2, _bFbCase_)
			if pR = NULL return "" ok
			_cFbResult_ = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			return _cFbResult_
		else
			_n1_ = pSubStrOrPos1 + 1
			_n2_ = pSubStrOrPos2 - 1
			return @oString.Section(_n1_, _n2_)
		ok

	def FirstBetween(pSubStrOrPos1, pSubStrOrPos2)
		return This.FirstBetweenCS(pSubStrOrPos1, pSubStrOrPos2, 1)

	  #=======================================#
	 #     LAST BETWEEN (single result)      #
	#=======================================#

	def LastBetweenCS(pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)

		if CheckingParams()
			if isList(pSubStrOrPos2) and IsAndNamedParamList(pSubStrOrPos2)
				pSubStrOrPos2 = pSubStrOrPos2[2]
			ok
		ok

		if NOT ( @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2) or @BothAreNumbers(pSubStrOrPos1, pSubStrOrPos2) )
			StzRaise("Incorrect params types! pSubStrOrPos1 and pSubStrOrPos2 must be both strings or numbers.")
		ok

		if @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2)
			# Engine-backed: returns LAST match only
			pH = @oString.Engine()
			pR = StzEngineStringBetweenLast(pH, pSubStrOrPos1, pSubStrOrPos2)
			if pR = NULL return "" ok
			_cLbResult_ = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			return _cLbResult_
		else
			_n1_ = pSubStrOrPos1 + 1
			_n2_ = pSubStrOrPos2 - 1
			return @oString.Section(_n1_, _n2_)
		ok

	def LastBetween(pSubStrOrPos1, pSubStrOrPos2)
		return This.LastBetweenCS(pSubStrOrPos1, pSubStrOrPos2, 1)

	  #=======================================#
	 #     NTH BETWEEN (single result)       #
	#=======================================#

	def NthBetweenCS(n, pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)

		if CheckingParams()
			if isList(pSubStrOrPos2) and IsAndNamedParamList(pSubStrOrPos2)
				pSubStrOrPos2 = pSubStrOrPos2[2]
			ok
		ok

		if NOT ( @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2) or @BothAreNumbers(pSubStrOrPos1, pSubStrOrPos2) )
			StzRaise("Incorrect params types! pSubStrOrPos1 and pSubStrOrPos2 must be both strings or numbers.")
		ok

		if @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2)
			# Engine-backed: returns NTH match only
			# Engine is 0-based for nth, Softanza is 1-based
			pH = @oString.Engine()
			pR = StzEngineStringBetweenNth(pH, pSubStrOrPos1, pSubStrOrPos2, n - 1)
			if pR = NULL return "" ok
			_cNbResult_ = StzEngineStringData(pR)
			StzEngineStringFree(pR)
			return _cNbResult_
		else
			_n1_ = pSubStrOrPos1 + 1
			_n2_ = pSubStrOrPos2 - 1
			return @oString.Section(_n1_, _n2_)
		ok

	def NthBetween(n, pSubStrOrPos1, pSubStrOrPos2)
		return This.NthBetweenCS(n, pSubStrOrPos1, pSubStrOrPos2, 1)

	  #=============================================#
	 #     REPLACE BETWEEN (bounds preserved)      #
	#=============================================#

	# Default: bounds are NOT included (Softanza convention)
	# ReplaceBetween("[", "]", "X") on "[hello]" => "[X]"
	# Engine replaces including bounds, so we wrap replacement

	def ReplaceBetween(pcOpen, pcClose, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceBetween(pH, pcOpen, pcClose, pcOpen + pcReplacement + pcClose)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def ReplaceFirstBetween(pcOpen, pcClose, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceFirstBetween(pH, pcOpen, pcClose, pcOpen + pcReplacement + pcClose)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def ReplaceLastBetween(pcOpen, pcClose, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceLastBetween(pH, pcOpen, pcClose, pcOpen + pcReplacement + pcClose)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def ReplaceNthBetween(n, pcOpen, pcClose, pcReplacement)
		pH = @oString.Engine()
		# Engine is 0-based for nth
		pR = StzEngineStringReplaceNthBetween(pH, pcOpen, pcClose, pcOpen + pcReplacement + pcClose, n - 1)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	  #=================================================#
	 #     REPLACE BETWEEN IB (bounds included)         #
	#=================================================#

	# IB: bounds ARE included in replacement
	# ReplaceBetweenIB("[", "]", "X") on "[hello]" => "X"

	def ReplaceBetweenIB(pcOpen, pcClose, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceBetween(pH, pcOpen, pcClose, pcReplacement)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def ReplaceFirstBetweenIB(pcOpen, pcClose, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceFirstBetween(pH, pcOpen, pcClose, pcReplacement)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def ReplaceLastBetweenIB(pcOpen, pcClose, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceLastBetween(pH, pcOpen, pcClose, pcReplacement)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def ReplaceNthBetweenIB(n, pcOpen, pcClose, pcReplacement)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceNthBetween(pH, pcOpen, pcClose, pcReplacement, n - 1)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	  #=============================================#
	 #     REMOVE BETWEEN (bounds preserved)       #
	#=============================================#

	# Default: bounds are NOT included
	# RemoveBetween("[", "]") on "[hello]" => "[]"

	def RemoveBetween(pcOpen, pcClose)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceBetween(pH, pcOpen, pcClose, pcOpen + pcClose)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def RemoveFirstBetween(pcOpen, pcClose)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceFirstBetween(pH, pcOpen, pcClose, pcOpen + pcClose)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def RemoveLastBetween(pcOpen, pcClose)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceLastBetween(pH, pcOpen, pcClose, pcOpen + pcClose)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def RemoveNthBetween(n, pcOpen, pcClose)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceNthBetween(pH, pcOpen, pcClose, pcOpen + pcClose, n - 1)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	  #=================================================#
	 #     REMOVE BETWEEN IB (bounds included)          #
	#=================================================#

	# IB: bounds ARE removed too
	# RemoveBetweenIB("[", "]") on "[hello]" => ""

	def RemoveBetweenIB(pcOpen, pcClose)
		pH = @oString.Engine()
		pR = StzEngineStringReplaceBetween(pH, pcOpen, pcClose, "")
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def RemoveFirstBetweenIB(pcOpen, pcClose)
		pH = @oString.Engine()
		pR = StzEngineStringRemoveFirstBetween(pH, pcOpen, pcClose)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def RemoveLastBetweenIB(pcOpen, pcClose)
		pH = @oString.Engine()
		pR = StzEngineStringRemoveLastBetween(pH, pcOpen, pcClose)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	def RemoveNthBetweenIB(n, pcOpen, pcClose)
		pH = @oString.Engine()
		pR = StzEngineStringRemoveNthBetween(pH, pcOpen, pcClose, n - 1)
		if pR != NULL
			@oString.Update(StzEngineStringData(pR))
			StzEngineStringFree(pR)
		ok

	  #=======================================#
	 #     BETWEEN -- INCLUDING BOUNDS       #
	#=======================================#

	def BetweenCSIB(pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)
		if isNumber(pSubStrOrPos1) and isNumber(pSubStrOrPos2)
			return @oString.Section(pSubStrOrPos1, pSubStrOrPos2)
		ok

		_oFinder_ = new stzStringFinder(@oString)
		_n1_ = _oFinder_.FindFirstCS(pSubStrOrPos1, pCaseSensitive)
		_n2_ = _oFinder_.FindLastCS(pSubStrOrPos2, pCaseSensitive) + StzLen(pSubStrOrPos2) - 1
		return @oString.Section(_n1_, _n2_)

	def BetweenIB(pSubStrOrPos1, pSubStrOrPos2)
		return This.BetweenCSIB(pSubStrOrPos1, pSubStrOrPos2, 1)

	  #===============================#
	 #     SECTION BOUNDS            #
	#===============================#

	def FindSectionBoundsZZ(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)

		if CheckingParams()
			if NOT @BothAreNumbers(_n1_, _n2_)
				StzRaise("Incorrect params types! Both n1 and n2 must be numbers.")
			ok
			if NOT @BothAreNumbers(_nCharsBefore_, _nCharsAfter_)
				StzRaise("Incorrect params types! Both nCharsBefore and nCharsAfter must be numbers.")
			ok
		ok

		if _nCharsBefore_ > _n1_
			_nCharsBefore_ = _n1_ - 1
		ok

		_nLen_ = @oString.NumberOfChars()
		if _nCharsAfter_ > _nLen_ - _n2_
			_nCharsAfter_ = _nLen_ - _n2_
		ok

		_anSectionBefore_ = [0, 0]
		if _nCharsBefore_ != 0
			_anSectionBefore_[1] = (_n1_ - _nCharsBefore_)
			_anSectionBefore_[2] = (_n1_ - 1)
		ok

		_anSectionAfter_ = [0, 0]
		if _nCharsAfter_ != 0
			_anSectionAfter_[1] = (_n2_ + 1)
			_anSectionAfter_[2] = (_n2_ + _nCharsAfter_)
		ok

		return [ _anSectionBefore_, _anSectionAfter_ ]

	def FindSectionBoundsIBZZ(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		_aSections_ = This.FindSectionBoundsZZ(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		_aSections_[1][1]++
		_aSections_[1][2]++
		_aSections_[2][1]--
		_aSections_[2][2]--
		return _aSections_

	def SectionBounds(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		_aSections_ = This.FindSectionBoundsZZ(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		return @oString.Sections(_aSections_)

	def SectionBoundsIB(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		_aSections_ = This.FindSectionBoundsIBZZ(_n1_, _n2_, _nCharsBefore_, _nCharsAfter_)
		return @oString.Sections(_aSections_)

	  #===============================#
	 #     IS BOUNDED BY             #
	#===============================#

	def IsBoundedByCS(pacBounds, pCaseSensitive)

		if isList(pacBounds) and IsPair(pacBounds) and
		   isList(pacBounds[2]) and IsPair(pacBounds[2])

			_oParam_ = new stzList(pacBounds[2])
			if _oParam_.IsInNamedParam()
				return This.IsBoundedByInCS(pacBounds[1], pacBounds[2], pCaseSensitive)
			but _oParam_.IsAndNamedParam()
				pacBounds[2] = pacBounds[2][2]
			ok
		ok

		if isString(pacBounds)
			_cBound1_ = pacBounds
			_cBound2_ = pacBounds

		but isList(pacBounds) and IsPairOfStrings(pacBounds)
			_cBound1_ = pacBounds[1]
			_cBound2_ = pacBounds[2]

		else
			StzRaise("Incorrect param type! pacBounds must be a string or a pair of strings.")
		ok

		_oFinder_ = new stzStringFinder(@oString)

		if _oFinder_.StartsWithCS(_cBound1_, pCaseSensitive) and
		   _oFinder_.EndsWithCS(_cBound2_, pCaseSensitive)
			return 1
		else
			return 0
		ok

	def IsBoundedBy(pacBounds)
		return This.IsBoundedByCS(pacBounds, 1)

	  #============================================#
	 #     IS BOUNDED BY -- INSIDE A STRING       #
	#============================================#

	def IsBoundedByInCS(pacBounds, pIn, pCaseSensitive)

		if isString(pacBounds)
			_aTemp_ = []
			_aTemp_ + pacBounds + pacBounds
			pacBounds = _aTemp_
		ok

		if NOT ( isList(pacBounds) and IsPairOfStrings(pacBounds) )
			StzRaise("Incorrect param type! pacBounds must be a pair of strings.")
		ok

		if isList(pIn) and IsInOrInsideNamedParamList(pIn)
			pIn = pIn[2]
		ok

		if NOT isString(pIn)
			StzRaise("Incorrect param type! pIn must be a string.")
		ok

		_oStr_ = new stzStringBounder(pIn)
		_bResult_ = _oStr_.SubStringIsBoundedByCS(@oString.Content(), pacBounds, pCaseSensitive)

		return _bResult_

	def IsBoundedByIn(pacBounds, pIn)
		return This.IsBoundedByInCS(pacBounds, pIn, 1)

	  #============================================#
	 #     SUBSTRING IS BOUNDED BY               #
	#============================================#

	def SubStringIsBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		if isString(pacBounds)
			_cBound1_ = pacBounds
			_cBound2_ = pacBounds
		but isList(pacBounds) and IsPairOfStrings(pacBounds)
			_cBound1_ = pacBounds[1]
			_cBound2_ = pacBounds[2]
		else
			StzRaise("Incorrect param type!")
		ok

		_cBounded_ = _cBound1_ + pcSubStr + _cBound2_
		_oFinder_ = new stzStringFinder(@oString)
		return _oFinder_.ContainsCS(_cBounded_, pCaseSensitive)

	def SubStringIsBoundedBy(pcSubStr, pacBounds)
		return This.SubStringIsBoundedByCS(pcSubStr, pacBounds, 1)

	  #============================================#
	 #     SUBSTRING IS BETWEEN                   #
	#============================================#

	def SubStringIsBetweenCS(pcSubStr, p1, p2, pCaseSensitive)

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param! pcSubStr must be a string.")
		ok

		if @BothAreNumbers(p1, p2)
			return This.SubStringIsBetweenPositionsCS(pcSubStr, p1, p2, pCaseSensitive)

		but @BothAreStrings(p1, p2)
			return This.SubStringIsBetweenSubStringsCS(pcSubStr, p1, p2, pCaseSensitive)

		else
			StzRaise("Incorrect params types! p1 and p2 must be both numbers or both strings.")
		ok

	def SubStringIsBetween(pcSubStr, p1, p2)
		return This.SubStringIsBetweenCS(pcSubStr, p1, p2, 1)

	  #============================================#
	 #     SUBSTRING IS BETWEEN POSITIONS         #
	#============================================#

	def SubStringIsBetweenPositionsCS(pcSubStr, _n1_, _n2_, pCaseSensitive)
		_cSection_ = @oString.Section(_n1_, _n2_)
		_oFinder_ = new stzStringFinder(_cSection_)
		return _oFinder_.ContainsCS(pcSubStr, pCaseSensitive)

	def SubStringIsBetweenPositions(pcSubStr, _n1_, _n2_)
		return This.SubStringIsBetweenPositionsCS(pcSubStr, _n1_, _n2_, 1)

	  #============================================#
	 #     SUBSTRING IS BETWEEN SUBSTRINGS        #
	#============================================#

	def SubStringIsBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		if CheckingParams()
			if isList(pcSubStr1) and IsSubStringsNamedParamList(pcSubStr1)
				pcSubStr1 = pcSubStr1[2]
			ok
			if isList(pcSubStr2) and IsAndNamedParamList(pcSubStr2)
				pcSubStr2 = pcSubStr2[2]
			ok
		ok

		_oFinder_ = new stzStringFinder(@oString)

		_n1_ = _oFinder_.FindFirstCS(pcSubStr1, pCaseSensitive)
		_n2_ = _oFinder_.FindLastCS(pcSubStr2, pCaseSensitive)
		_bOk1_ = This.SubStringIsBetweenPositionsCS(pcSubStr, _n1_, _n2_, pCaseSensitive)

		_n1_ = _oFinder_.FindFirstCS(pcSubStr2, pCaseSensitive)
		_n2_ = _oFinder_.FindLastCS(pcSubStr1, pCaseSensitive)
		_bOk2_ = This.SubStringIsBetweenPositionsCS(pcSubStr, _n1_, _n2_, pCaseSensitive)

		return _bOk1_ or _bOk2_

	def SubStringIsBetweenSubStrings(pcSubStr, pcSubStr1, pcSubStr2)
		return This.SubStringIsBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, 1)

	  #===============================#
	 #     IS BOUND OF              #
	#===============================#

	def IsBoundOfCS(pcSubStr, pcInStr, pCaseSensitive)

		if CheckingParams()
			if isList(pcInStr) and IsInNamedParamList(pcInStr)
				pcInStr = pcInStr[2]
			ok
			if NOT isString(pcInStr)
				StzRaise("Incorrect param type! pcInStr must be a string.")
			ok
		ok

		_cBounded_ = @oString.Content() + pcSubStr + @oString.Content()
		_oFinder_ = new stzStringFinder(pcInStr)
		return _oFinder_.ContainsCS(_cBounded_, pCaseSensitive)

	def IsBoundOf(pcSubStr, pcInStr)
		return This.IsBoundOfCS(pcSubStr, pcInStr, 1)

	  #===============================#
	 #     CHAR AT                   #
	#===============================#

	def Char(n)
		if n < 1 or n > @oString.NumberOfChars()
			StzRaise("Index out of range!")
		ok
		return @oString.NthChar(n)

	def FirstChar()
		return This.Char(1)

	def LastChar()
		return This.Char(@oString.NumberOfChars())
