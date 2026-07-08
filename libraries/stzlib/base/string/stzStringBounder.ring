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

	def SectionCS(n1, n2, pCaseSensitive)

		nLen = @oString.NumberOfChars()

		if CheckingParams()

			if isList(n1)
				oN1 = Q(n1)
				if IsOneOfTheseNamedParamsList(n1, [
					:From, :FromPosition, :Start, :FromStart,
					:StartingAt, :StartingAtPosition,
					:Between, :BetweenPosition ])
					n1 = n1[2]
				ok
			ok

			if isList(n2)
				oN2 = Q(n2)
				if IsOneOfTheseNamedParamsList(n2, [
					:To, :ToPosition, :End, :ToEnd,
					:Until, :UntilPosition, :UpTo, :UpToPosition, :And ])
					n2 = n2[2]
				ok
			ok

			if isString(n1)
				if n1 = :First or n1 = :FirstChar
					n1 = 1
				but n1 = :Last or n1 = :LastChar
					n1 = nLen
				else
					oFinder = new stzStringFinder(@oString)
					n1 = oFinder.FindFirstCS(n1, pCaseSensitive)
				ok
			ok

			if isString(n2)
				if n2 = :End or n2 = :Last or n2 = :LastChar
					n2 = nLen
				but n2 = :First or n2 = :FirstChar
					n2 = 1
				else
					nLen2 = StzLen(n2)
					oFinder = new stzStringFinder(@oString)
					n2 = oFinder.FindLastCS(n2, pCaseSensitive) + nLen2 - 1
				ok
			ok

			if NOT @BothAreNumbers(n1, n2)
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		if n1 > n2
			nSwap = n1
			n1 = n2
			n2 = nSwap
		ok

		if NOT ( n1 >= 1 and n1 <= nLen and n2 >= 1 and n2 <= nLen )
			StzRaise("Indexes out of range! n1 and n2 must be inside the string.")
		ok

		return @oString.Section(n1, n2)

		def SectionCSQ(n1, n2, pCaseSensitive)
			return new stzStringBounder( This.SectionCS(n1, n2, pCaseSensitive) )

	def Section(n1, n2)
		return This.SectionCS(n1, n2, 1)

		def SectionQ(n1, n2)
			return new stzStringBounder(This.Section(n1, n2))

	  #===============================#
	 #     MULTIPLE SECTIONS         #
	#===============================#

	def Sections(aSections)
		return @oString.Sections(aSections)

	  #===============================#
	 #     ANTI-SECTION              #
	#===============================#

	def AntiSection(n1, n2)
		nLen = @oString.NumberOfChars()
		acResult = []

		if n1 > 1
			acResult + @oString.Section(1, n1 - 1)
		ok
		if n2 < nLen
			acResult + @oString.Section(n2 + 1, nLen)
		ok

		return acResult

	  #===============================#
	 #     RANGE                     #
	#===============================#

	def RangeCS(nStartPos, nRange, pCaseSensitive)

		if CheckingParams()
			if NOT isNumber(nRange)
				StzRaise("Incorrect param type! nRange must be a number.")
			ok

			if isNumber(nStartPos)
				if nStartPos < 0
					nStartPos = @oString.NumberOfChars() + nStartPos + 1
				ok
				if nStartPos = 0 or nRange = 0
					return ""
				ok
			ok
		ok

		cResult = ""

		if nRange > 0
			if CheckingParams() and isString(nStartPos)
				oFinder = new stzStringFinder(@oString)
				nStartPos = oFinder.FindFirstCS(nStartPos, pCaseSensitive)
			ok
			cResult = This.SectionCS(nStartPos, nStartPos + nRange - 1, pCaseSensitive)
		else
			n1 = nStartPos + nRange + 1
			if n1 > 0
				cResult = This.SectionCS(n1, nStartPos, pCaseSensitive)
			ok
		ok

		return cResult

		def RangeCSQ(nStartPos, nRange, pCaseSensitive)
			return new stzStringBounder( This.RangeCS(nStartPos, nRange, pCaseSensitive) )

	def Range(nStartPos, nRange)
		return This.RangeCS(nStartPos, nRange, 1)

		def RangeQ(nStartPos, nRange)
			return new stzStringBounder( This.Range(nStartPos, nRange) )

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
			n1 = pSubStrOrPos1 + 1
			n2 = pSubStrOrPos2 - 1
			_cBtwnResult_ = @oString.Section(n1, n2)
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
			n1 = pSubStrOrPos1 + 1
			n2 = pSubStrOrPos2 - 1
			return @oString.Section(n1, n2)
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
			n1 = pSubStrOrPos1 + 1
			n2 = pSubStrOrPos2 - 1
			return @oString.Section(n1, n2)
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
			n1 = pSubStrOrPos1 + 1
			n2 = pSubStrOrPos2 - 1
			return @oString.Section(n1, n2)
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

		oFinder = new stzStringFinder(@oString)
		n1 = oFinder.FindFirstCS(pSubStrOrPos1, pCaseSensitive)
		n2 = oFinder.FindLastCS(pSubStrOrPos2, pCaseSensitive) + StzLen(pSubStrOrPos2) - 1
		return @oString.Section(n1, n2)

	def BetweenIB(pSubStrOrPos1, pSubStrOrPos2)
		return This.BetweenCSIB(pSubStrOrPos1, pSubStrOrPos2, 1)

	  #===============================#
	 #     SECTION BOUNDS            #
	#===============================#

	def FindSectionBoundsZZ(n1, n2, nCharsBefore, nCharsAfter)

		if CheckingParams()
			if NOT @BothAreNumbers(n1, n2)
				StzRaise("Incorrect params types! Both n1 and n2 must be numbers.")
			ok
			if NOT @BothAreNumbers(nCharsBefore, nCharsAfter)
				StzRaise("Incorrect params types! Both nCharsBefore and nCharsAfter must be numbers.")
			ok
		ok

		if nCharsBefore > n1
			nCharsBefore = n1 - 1
		ok

		nLen = @oString.NumberOfChars()
		if nCharsAfter > nLen - n2
			nCharsAfter = nLen - n2
		ok

		anSectionBefore = [0, 0]
		if nCharsBefore != 0
			anSectionBefore[1] = (n1 - nCharsBefore)
			anSectionBefore[2] = (n1 - 1)
		ok

		anSectionAfter = [0, 0]
		if nCharsAfter != 0
			anSectionAfter[1] = (n2 + 1)
			anSectionAfter[2] = (n2 + nCharsAfter)
		ok

		return [ anSectionBefore, anSectionAfter ]

	def FindSectionBoundsIBZZ(n1, n2, nCharsBefore, nCharsAfter)
		aSections = This.FindSectionBoundsZZ(n1, n2, nCharsBefore, nCharsAfter)
		aSections[1][1]++
		aSections[1][2]++
		aSections[2][1]--
		aSections[2][2]--
		return aSections

	def SectionBounds(n1, n2, nCharsBefore, nCharsAfter)
		aSections = This.FindSectionBoundsZZ(n1, n2, nCharsBefore, nCharsAfter)
		return @oString.Sections(aSections)

	def SectionBoundsIB(n1, n2, nCharsBefore, nCharsAfter)
		aSections = This.FindSectionBoundsIBZZ(n1, n2, nCharsBefore, nCharsAfter)
		return @oString.Sections(aSections)

	  #===============================#
	 #     IS BOUNDED BY             #
	#===============================#

	def IsBoundedByCS(pacBounds, pCaseSensitive)

		if isList(pacBounds) and IsPair(pacBounds) and
		   isList(pacBounds[2]) and IsPair(pacBounds[2])

			oParam = new stzList(pacBounds[2])
			if oParam.IsInNamedParam()
				return This.IsBoundedByInCS(pacBounds[1], pacBounds[2], pCaseSensitive)
			but oParam.IsAndNamedParam()
				pacBounds[2] = pacBounds[2][2]
			ok
		ok

		if isString(pacBounds)
			cBound1 = pacBounds
			cBound2 = pacBounds

		but isList(pacBounds) and IsPairOfStrings(pacBounds)
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]

		else
			StzRaise("Incorrect param type! pacBounds must be a string or a pair of strings.")
		ok

		oFinder = new stzStringFinder(@oString)

		if oFinder.StartsWithCS(cBound1, pCaseSensitive) and
		   oFinder.EndsWithCS(cBound2, pCaseSensitive)
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
			aTemp = []
			aTemp + pacBounds + pacBounds
			pacBounds = aTemp
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

		oStr = new stzStringBounder(pIn)
		bResult = oStr.SubStringIsBoundedByCS(@oString.Content(), pacBounds, pCaseSensitive)

		return bResult

	def IsBoundedByIn(pacBounds, pIn)
		return This.IsBoundedByInCS(pacBounds, pIn, 1)

	  #============================================#
	 #     SUBSTRING IS BOUNDED BY               #
	#============================================#

	def SubStringIsBoundedByCS(pcSubStr, pacBounds, pCaseSensitive)

		if isString(pacBounds)
			cBound1 = pacBounds
			cBound2 = pacBounds
		but isList(pacBounds) and IsPairOfStrings(pacBounds)
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]
		else
			StzRaise("Incorrect param type!")
		ok

		cBounded = cBound1 + pcSubStr + cBound2
		oFinder = new stzStringFinder(@oString)
		return oFinder.ContainsCS(cBounded, pCaseSensitive)

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

	def SubStringIsBetweenPositionsCS(pcSubStr, n1, n2, pCaseSensitive)
		cSection = @oString.Section(n1, n2)
		oFinder = new stzStringFinder(cSection)
		return oFinder.ContainsCS(pcSubStr, pCaseSensitive)

	def SubStringIsBetweenPositions(pcSubStr, n1, n2)
		return This.SubStringIsBetweenPositionsCS(pcSubStr, n1, n2, 1)

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

		oFinder = new stzStringFinder(@oString)

		n1 = oFinder.FindFirstCS(pcSubStr1, pCaseSensitive)
		n2 = oFinder.FindLastCS(pcSubStr2, pCaseSensitive)
		bOk1 = This.SubStringIsBetweenPositionsCS(pcSubStr, n1, n2, pCaseSensitive)

		n1 = oFinder.FindFirstCS(pcSubStr2, pCaseSensitive)
		n2 = oFinder.FindLastCS(pcSubStr1, pCaseSensitive)
		bOk2 = This.SubStringIsBetweenPositionsCS(pcSubStr, n1, n2, pCaseSensitive)

		return bOk1 or bOk2

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

		cBounded = @oString.Content() + pcSubStr + @oString.Content()
		oFinder = new stzStringFinder(pcInStr)
		return oFinder.ContainsCS(cBounded, pCaseSensitive)

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
