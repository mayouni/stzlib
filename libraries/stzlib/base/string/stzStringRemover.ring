#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGREMOVER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String remover subclass -- removing         #
#                  substrings by value, position, or section.  #
#                  For aliases, use stzStringRemoverXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringRemover from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringRemover! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   REMOVING ALL OCCURRENCES OF A GIVEN SUBSTRING      #
	#======================================================#

	def RemoveCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringRemoveCS(pH, pcSubStr, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveCSQ(pcSubStr, pCaseSensitive)
			This.RemoveCS(pcSubStr, pCaseSensitive)
			return This

		def RemoveAllCS(pcSubStr, pCaseSensitive)
			This.RemoveCS(pcSubStr, pCaseSensitive)

			def RemoveAllCSQ(pcSubStr, pCaseSensitive)
				return This.RemoveCSQ(pcSubStr, pCaseSensitive)

	def Remove(pcSubStr)
		This.RemoveCS(pcSubStr, 1)

		def RemoveQ(pcSubStr)
			This.Remove(pcSubStr)
			return This

		def RemoveAll(pcSubStr)
			This.Remove(pcSubStr)

			def RemoveAllQ(pcSubStr)
				return This.RemoveQ(pcSubStr)

	def RemovedCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def Removed(pcSubStr)
		return This.RemovedCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING NTH OCCURRENCE OF A GIVEN SUBSTRING       #
	#======================================================#

	def RemoveNthCS(_n_, pcSubStr, pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringRemoveNth(pH, pcSubStr, _n_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveNthCSQ(_n_, pcSubStr, pCaseSensitive)
			This.RemoveNthCS(_n_, pcSubStr, pCaseSensitive)
			return This

	def RemoveNth(_n_, pcSubStr)
		This.RemoveNthCS(_n_, pcSubStr, 1)

		def RemoveNthQ(_n_, pcSubStr)
			This.RemoveNth(_n_, pcSubStr)
			return This

	def NthRemovedCS(_n_, pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveNthCSQ(_n_, pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def NthRemoved(_n_, pcSubStr)
		return This.NthRemovedCS(_n_, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING FIRST / LAST OCCURRENCE                   #
	#======================================================#

	def RemoveFirstCS(pcSubStr, pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringRemoveFirst(pH, pcSubStr)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveFirstCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFirstCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveFirst(pcSubStr)
		This.RemoveFirstCS(pcSubStr, 1)

		def RemoveFirstQ(pcSubStr)
			This.RemoveFirst(pcSubStr)
			return This

	def FirstRemovedCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFirstCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def FirstRemoved(pcSubStr)
		return This.FirstRemovedCS(pcSubStr, 1)

	#--

	def RemoveLastCS(pcSubStr, pCaseSensitive)
		pH = @oString.Engine()
		pR = StzEngineStringRemoveLast(pH, pcSubStr)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveLastCSQ(pcSubStr, pCaseSensitive)
			This.RemoveLastCS(pcSubStr, pCaseSensitive)
			return This

	def RemoveLast(pcSubStr)
		This.RemoveLastCS(pcSubStr, 1)

		def RemoveLastQ(pcSubStr)
			This.RemoveLast(pcSubStr)
			return This

	def LastRemovedCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveLastCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	def LastRemoved(pcSubStr)
		return This.LastRemovedCS(pcSubStr, 1)

	  #======================================================#
	 #   REMOVING AT A GIVEN POSITION                       #
	#======================================================#

	def RemoveAtPositionCS(_n_, pcSubStr, pCaseSensitive)
		_nLen_ = StzLen(pcSubStr)
		This.RemoveSection(_n_, _n_ + _nLen_ - 1)

	def RemoveAtPosition(_n_, pcSubStr)
		This.RemoveAtPositionCS(_n_, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING A SECTION                                 #
	#======================================================#

	def RemoveSection(n1, n2)
		pH = @oString.Engine()
		pR = StzEngineStringRemoveRange(pH, n1, n2 - n1 + 1)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveSectionQ(n1, n2)
			This.RemoveSection(n1, n2)
			return This

	def SectionRemoved(n1, n2)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveSectionQ(n1, n2)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING A RANGE (POSITION + N CHARS)              #
	#======================================================#

	def RemoveRange(nStart, nRange)
		This.RemoveSection(nStart, nStart + nRange - 1)

		def RemoveRangeQ(nStart, nRange)
			This.RemoveRange(nStart, nRange)
			return This

	def RangeRemoved(nStart, nRange)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveRangeQ(nStart, nRange)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING WITH CONDITION                            #
	#======================================================#

	def RemoveW(pcCondition)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindW(pcCondition)
		for i = len(_anPos_) to 1 step -1
			This.RemoveSection(_anPos_[i], _anPos_[i])
		next

		def RemoveWQ(pcCondition)
			This.RemoveW(pcCondition)
			return This

	def RemovedW(pcCondition)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveWQ(pcCondition)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING MANY SUBSTRINGS AT ONCE                   #
	#======================================================#

	def RemoveManyCS(pacSubStr, pCaseSensitive)
		if CheckParams()
			if NOT (isList(pacSubStr) and @IsListOfStrings(pacSubStr))
				StzRaise("Incorrect param type! pacSubStr must be a list of strings.")
			ok
		ok

		_acSubStr_ = U(pacSubStr)
		_nLen_ = len(_acSubStr_)
		_oCopy_ = new stzStringRemover(@oString.Content())

		for @i = 1 to _nLen_
			_oCopy_.RemoveAllCS(_acSubstr_[@i], pCaseSensitive)
		next

		This.UpdateWith(_oCopy_.Content())

		def RemoveManyCSQ(pacSubStr, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)
			return This

		def RemoveAllOfTheseCS(pacSubStr, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)

		def RemoveTheseCS(pacSubStr, pCaseSensitive)
			This.RemoveManyCS(pacSubStr, pCaseSensitive)

	def ManyRemovedCS(pacSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveManyCSQ(pacSubStr, pCaseSensitive)
		return _oCopy_.Content()

	#--

	def RemoveMany(pacSubStr)
		_nPacSubstr1Len_ = len(pacSubstr)
		for _iLoopPacSubstr1_ = 1 to _nPacSubstr1Len_
			_cSubstr_ = pacSubstr[_iLoopPacSubstr1_]
			This.RemoveAll(_cSubstr_)
		next

		def RemoveManyQ(pacSubStr)
			This.RemoveMany(pacSubStr)
			return This

		def RemoveAllOfThese(pacSubStr)
			This.RemoveMany(pacSubStr)

		def RemoveThese(pacSubStr)
			This.RemoveMany(pacSubStr)

	def ManyRemoved(pacSubStr)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveManyQ(pacSubStr)
		return _oCopy_.Content()

		def TheseRemoved(pacSubStr)
			return This.ManyRemoved(pacSubStr)

	  #===========================================================#
	 #   REMOVING ALL SUBSTRINGS EXCEPT THOSE PROVIDED           #
	#===========================================================#

	def RemoveSubStringsExceptCS(pacSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_acAll_ = _oFinder_.SubStringsCS(pCaseSensitive)
		_nLen_ = len(_acAll_)

		for @i = 1 to _nLen_
			_bFound_ = 0
			for @j = 1 to len(pacSubStr)
				if BothStringsAreEqualCS(_acAll_[@i], pacSubStr[@j], pCaseSensitive)
					_bFound_ = 1
					exit
				ok
			next
			if NOT _bFound_
				This.RemoveCS(_acAll_[@i], pCaseSensitive)
			ok
		next

		def RemoveAllExceptCS(pacSubStr, pCaseSensitive)
			This.RemoveSubStringsExceptCS(pacSubStr, pCaseSensitive)

		def RemoveAllButCS(pacSubStr, pCaseSensitive)
			This.RemoveSubStringsExceptCS(pacSubStr, pCaseSensitive)

	def RemoveSubStringsExcept(pacSubStr)
		This.RemoveSubStringsExceptCS(pacSubStr, 1)

		def RemoveAllExcept(pacSubStr)
			This.RemoveSubStringsExcept(pacSubStr)

		def RemoveAllBut(pacSubStr)
			This.RemoveSubStringsExcept(pacSubStr)

	  #======================================================#
	 #   REMOVING BETWEEN TWO SUBSTRINGS                    #
	#======================================================#

	def RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)
		# Softanza semantics: removes ALL open...close pairs (engine-backed)
		pH = @oString.Engine()
		pR = StzEngineStringRemoveBetween(pH, pcBound1, pcBound2)
		_cRabResult_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_cRabResult_)

		def RemoveAnyBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			return This

		def RemoveBetweenCS(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCS(pcBound1, pcBound2, pCaseSensitive)

	def AnyBetweenRemovedCS(pcBound1, pcBound2, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveAnyBetweenCSQ(pcBound1, pcBound2, pCaseSensitive)
		return _oCopy_.Content()

	#--

	def RemoveAnyBetween(pcBound1, pcBound2)
		This.RemoveAnyBetweenCS(pcBound1, pcBound2, 1)

		def RemoveAnyBetweenQ(pcBound1, pcBound2)
			This.RemoveAnyBetween(pcBound1, pcBound2)
			return This

		def RemoveBetween(pcBound1, pcBound2)
			This.RemoveAnyBetween(pcBound1, pcBound2)

	def AnyBetweenRemoved(pcBound1, pcBound2)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveAnyBetweenQ(pcBound1, pcBound2)
		return _oCopy_.Content()

		def BetweenRemoved(pcBound1, pcBound2)
			return This.AnyBetweenRemoved(pcBound1, pcBound2)

	  #=======================================#
	 #     REMOVE FIRST BETWEEN MARKERS      #
	#=======================================#

	def RemoveFirstBetween(pcBound1, pcBound2)
		# Removes only the FIRST open...close pair
		pH = @oString.Engine()
		pR = StzEngineStringRemoveFirstBetween(pH, pcBound1, pcBound2)
		_cRfbResult_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_cRfbResult_)

		def RemoveFirstBetweenQ(pcBound1, pcBound2)
			This.RemoveFirstBetween(pcBound1, pcBound2)
			return This

	def FirstBetweenRemoved(pcBound1, pcBound2)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFirstBetween(pcBound1, pcBound2)
		return _oCopy_.Content()

	  #-----------------------------------------------------------#
	 #   REMOVING BETWEEN TWO SUBSTRINGS -- INCLUDING BOUNDS     #
	#-----------------------------------------------------------#

	def RemoveAnyBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_aSection_ = _oFinder_.FindAnyBetweenAsSectionCS(pcBound1, pcBound2, pCaseSensitive)

		if isList(pcBound2) and IsAndNamedParamList(pcBound2)
			pcBound2 = pcBound2[2]
		ok

		_nLen1_ = StzLen(pcBound1)
		_nLen2_ = StzLen(pcBound2)

		_aSection_[1] = _aSection_[1] - _nLen1_
		_aSection_[2] = _aSection_[2] + _nLen2_

		This.RemoveSection(_aSection_[1], _aSection_[2])

		def RemoveAnyBetweenCSIBQ(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)
			return This

		def RemoveBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)
			This.RemoveAnyBetweenCSIB(pcBound1, pcBound2, pCaseSensitive)

	def AnyBetweenRemovedCSIB(pcBound1, pcBound2, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveAnyBetweenCSIBQ(pcBound1, pcBound2, pCaseSensitive)
		return _oCopy_.Content()

	#--

	def RemoveAnyBetweenIB(pcBound1, pcBound2)
		This.RemoveAnyBetweenCSIB(pcBound1, pcBound2, 1)

		def RemoveAnyBetweenIBQ(pcBound1, pcBound2)
			This.RemoveAnyBetweenIB(pcBound1, pcBound2)
			return This

		def RemoveBetweenIB(pcBound1, pcBound2)
			This.RemoveAnyBetweenIB(pcBound1, pcBound2)

	def AnyBetweenRemovedIB(pcBound1, pcBound2)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveAnyBetweenIBQ(pcBound1, pcBound2)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING DUPLICATES                                #
	#======================================================#

	def RemoveDuplicatesCS(pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_aSections_ = _oFinder_.FindDuplicatesAsSectionsCS(pCaseSensitive)
		if len(_aSections_) > 0
			@oString.RemoveSections(_aSections_)
		ok
		This.UpdateWith(_cResult_)

		def RemoveDuplicatesCSQ(pCaseSensitive)
			This.RemoveDuplicatesCS(pCaseSensitive)
			return This

	def DuplicatesRemovedCS(pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveDuplicatesCSQ(pCaseSensitive)
		return _oCopy_.Content()

		def WithoutDuplicatesCS(pCaseSensitive)
			return This.DuplicatesRemovedCS(pCaseSensitive)

	#--

	def RemoveDuplicates()
		This.RemoveDuplicatesCS(1)

		def RemoveDuplicatesQ()
			This.RemoveDuplicates()
			return This

	def DuplicatesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveDuplicatesQ()
		return _oCopy_.Content()

		def WithoutDuplicates()
			return This.DuplicatesRemoved()

	  #======================================================#
	 #   REMOVING SUBSTRING FROM LEFT / RIGHT               #
	#======================================================#

	def RemoveFromLeftCS(pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		pH = @oString.Engine()
		pR = StzEngineStringRemovePrefix(pH, pcSubStr)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveFromLeftCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromLeftCS(pcSubStr, pCaseSensitive)
			return This

	def RemovedFromLeftCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFromLeftCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	#--

	def RemoveFromLeft(pcSubStr)
		This.RemoveFromLeftCS(pcSubStr, 1)

		def RemoveFromLeftQ(pcSubStr)
			This.RemoveFromLeft(pcSubStr)
			return This

	def RemovedFromLeft(pcSubStr)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFromLeftQ(pcSubStr)
		return _oCopy_.Content()

	#--

	def RemoveFromRightCS(pcSubStr, pCaseSensitive)
		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		pH = @oString.Engine()
		pR = StzEngineStringRemoveSuffix(pH, pcSubStr)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveFromRightCSQ(pcSubStr, pCaseSensitive)
			This.RemoveFromRightCS(pcSubStr, pCaseSensitive)
			return This

	def RemovedFromRightCS(pcSubStr, pCaseSensitive)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFromRightCSQ(pcSubStr, pCaseSensitive)
		return _oCopy_.Content()

	#--

	def RemoveFromRight(pcSubStr)
		This.RemoveFromRightCS(pcSubStr, 1)

		def RemoveFromRightQ(pcSubStr)
			This.RemoveFromRight(pcSubStr)
			return This

	def RemovedFromRight(pcSubStr)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveFromRightQ(pcSubStr)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING SPACES                                    #
	#======================================================#

	def RemoveSpaces()
		This.RemoveAll(" ")

		def RemoveSpacesQ()
			This.RemoveSpaces()
			return This

		def RemoveAllSpaces()
			This.RemoveSpaces()

	def SpacesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveSpacesQ()
		return _oCopy_.Content()

	#--

	def RemoveLeadingSpaces()
		@oString.TrimStart()

		def RemoveLeadingSpacesQ()
			This.RemoveLeadingSpaces()
			return This

	def LeadingSpacesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveLeadingSpacesQ()
		return _oCopy_.Content()

	#--

	def RemoveTrailingSpaces()
		@oString.TrimEnd()

		def RemoveTrailingSpacesQ()
			This.RemoveTrailingSpaces()
			return This

	def TrailingSpacesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveTrailingSpacesQ()
		return _oCopy_.Content()

	#--

	def RemoveLeftSpaces()
		@oString.TrimLeft()

		def RemoveLeftSpacesQ()
			This.RemoveLeftSpaces()
			return This

	def LeftSpacesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveLeftSpacesQ()
		return _oCopy_.Content()

	#--

	def RemoveRightSpaces()
		@oString.TrimRight()

		def RemoveRightSpacesQ()
			This.RemoveRightSpaces()
			return This

	def RightSpacesRemoved()
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveRightSpacesQ()
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING N-FIRST / N-LAST OCCURRENCES              #
	#======================================================#

	def RemoveNFirstOccurrencesCS(_n_, pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(pcSubStr, pCaseSensitive)
		if len(_anPos_) < _n_
			_n_ = len(_anPos_)
		ok
		_nLenSubStr_ = StzLen(pcSubStr)
		for i = _n_ to 1 step -1
			This.RemoveSection(_anPos_[i], _anPos_[i] + _nLenSubStr_ - 1)
		next

		def RemoveNFirstOccurrencesCSQ(_n_, pcSubStr, pCaseSensitive)
			This.RemoveNFirstOccurrencesCS(_n_, pcSubStr, pCaseSensitive)
			return This

	def RemoveNFirstOccurrences(_n_, pcSubStr)
		This.RemoveNFirstOccurrencesCS(_n_, pcSubStr, 1)

	#--

	def RemoveNLastOccurrencesCS(_n_, pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		_anPos_ = _oFinder_.FindCS(pcSubStr, pCaseSensitive)
		_nLen_ = len(_anPos_)
		if _nLen_ < _n_
			_n_ = _nLen_
		ok
		_nLenSubStr_ = StzLen(pcSubStr)
		for i = _nLen_ to _nLen_ - _n_ + 1 step -1
			This.RemoveSection(_anPos_[i], _anPos_[i] + _nLenSubStr_ - 1)
		next

		def RemoveNLastOccurrencesCSQ(_n_, pcSubStr, pCaseSensitive)
			This.RemoveNLastOccurrencesCS(_n_, pcSubStr, pCaseSensitive)
			return This

	def RemoveNLastOccurrences(_n_, pcSubStr)
		This.RemoveNLastOccurrencesCS(_n_, pcSubStr, 1)

	  #======================================================#
	 #   REMOVING CHAR AT POSITION                          #
	#======================================================#

	def RemoveCharAt(_n_)
		pH = @oString.Engine()
		pR = StzEngineStringRemoveCharAt(pH, _n_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def RemoveCharAtQ(_n_)
			This.RemoveCharAt(_n_)
			return This

	def CharRemovedAt(_n_)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveCharAtQ(_n_)
		return _oCopy_.Content()

	  #======================================================#
	 #   REMOVING CHARS AT MULTIPLE POSITIONS               #
	#======================================================#

	def RemoveCharsAtPositions(panPos)
		_aSorted_ = sort(panPos)
		for i = len(_aSorted_) to 1 step -1
			This.RemoveCharAt(_aSorted_[i])
		next

		def RemoveCharsAtPositionsQ(panPos)
			This.RemoveCharsAtPositions(panPos)
			return This

	def CharsRemovedAtPositions(panPos)
		_oCopy_ = new stzStringRemover(@oString.Content())
		_oCopy_.RemoveCharsAtPositionsQ(panPos)
		return _oCopy_.Content()
