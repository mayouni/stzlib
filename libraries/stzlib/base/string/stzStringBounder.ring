#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGBOUNDER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String bounder subclass -- sections,        #
#                  ranges, between, bounding, and bounds        #
#                  checking operations.                          #
#                  Canonical methods only. For full Softanza    #
#                  fluency (aliases), use stzStringBounderXT.   #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringBounder from stzString

	  #===============================#
	 #     SECTION (SLICE)           #
	#===============================#

	def SectionCS(n1, n2, pCaseSensitive)

		nLen = This.NumberOfChars()

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
					n1 = StzStringFinderQ(This.Content()).FindFirstCS(n1, pCaseSensitive)
				ok
			ok

			if isString(n2)
				if n2 = :End or n2 = :Last or n2 = :LastChar
					n2 = nLen
				but n2 = :First or n2 = :FirstChar
					n2 = 1
				else
					nLen2 = Q(n2).NumberOfChars()
					n2 = StzStringFinderQ(This.Content()).FindLastCS(n2, pCaseSensitive) + nLen2 - 1
				ok
			ok

			if NOT @BothAreNumbers(n1, n2)
				StzRaise("Incorrect params! n1 and n2 must be numbers.")
			ok
		ok

		anTemp = ring_sort([ n1, n2 ])
		n1 = anTemp[1]
		n2 = anTemp[2]

		if NOT ( n1 >= 1 and n1 <= nLen and n2 >= 1 and n2 <= nLen )
			StzRaise("Indexes out of range! n1 and n2 must be inside the string.")
		ok

		cResult = substr(This.Content(), n1, n2 - n1 + 1)
		return cResult

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
		acResult = []
		cContent = This.Content()
		nLen = len(aSections)
		for i = 1 to nLen
			n1 = aSections[i][1]
			n2 = aSections[i][2]
			if n1 >= 1 and n2 >= n1 and n2 <= len(cContent)
				acResult + substr(cContent, n1, n2 - n1 + 1)
			ok
		next
		return acResult

	  #===============================#
	 #     ANTI-SECTION              #
	#===============================#

	def AntiSection(n1, n2)
		nLen = This.NumberOfChars()
		acResult = []

		if n1 > 1
			acResult + substr(This.Content(), 1, n1 - 1)
		ok
		if n2 < nLen
			acResult + substr(This.Content(), n2 + 1, nLen - n2)
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
					nStartPos = This.NumberOfChars() + nStartPos + 1
				ok
				if nStartPos = 0 or nRange = 0
					return ""
				ok
			ok
		ok

		cResult = ""

		if nRange > 0
			if CheckingParams() and isString(nStartPos)
				nStartPos = StzStringFinderQ(This.Content()).FindFirstCS(nStartPos, pCaseSensitive)
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

		if CheckingParams()
			if isList(pSubStrOrPos2) and IsAndNamedParamList(pSubStrOrPos2)
				pSubStrOrPos2 = pSubStrOrPos2[2]
			ok
		ok

		if NOT ( @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2) or @BothAreNumbers(pSubStrOrPos1, pSubStrOrPos2) )
			StzRaise("Incorrect params types! pSubStrOrPos1 and pSubStrOrPos2 must be both strings or numbers.")
		ok

		oFinder = StzStringFinderQ(This.Content())

		if @BothAreStrings(pSubStrOrPos1, pSubStrOrPos2)
			n1 = oFinder.FindFirstCS(pSubStrOrPos1, pCaseSensitive)
			if n1 = 0
				return ""
			else
				n1 += Q(pSubStrOrPos1).NumberOfChars()
			ok

			n2 = oFinder.FindLastCS(pSubStrOrPos2, pCaseSensitive)
			if n2 = 0
				return ""
			else
				n2--
			ok
		else
			n1 = pSubStrOrPos1 + 1
			n2 = pSubStrOrPos2 - 1
		ok

		cResult = This.Section(n1, n2)
		return cResult

	def Between(pSubStrOrPos1, pSubStrOrPos2)
		return This.BetweenCS(pSubStrOrPos1, pSubStrOrPos2, 1)

	  #=======================================#
	 #     BETWEEN -- INCLUDING BOUNDS       #
	#=======================================#

	def BetweenCSIB(pSubStrOrPos1, pSubStrOrPos2, pCaseSensitive)
		if isNumber(pSubStrOrPos1) and isNumber(pSubStrOrPos2)
			return This.Section(pSubStrOrPos1, pSubStrOrPos2)
		ok

		oFinder = StzStringFinderQ(This.Content())
		n1 = oFinder.FindFirstCS(pSubStrOrPos1, pCaseSensitive)
		n2 = oFinder.FindLastCS(pSubStrOrPos2, pCaseSensitive) + Q(pSubStrOrPos2).NumberOfChars() - 1
		return This.Section(n1, n2)

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

		nLen = This.NumberOfChars()
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
		return This.Sections(aSections)

	def SectionBoundsIB(n1, n2, nCharsBefore, nCharsAfter)
		aSections = This.FindSectionBoundsIBZZ(n1, n2, nCharsBefore, nCharsAfter)
		return This.Sections(aSections)

	  #===============================#
	 #     IS BOUNDED BY             #
	#===============================#

	def IsBoundedByCS(pacBounds, pCaseSensitive)

		if isList(pacBounds) and StzListQ(pacBounds).IsPair() and
		   isList(pacBounds[2]) and StzListQ(pacBounds[2]).IsPair()

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

		but isList(pacBounds) and StzListQ(pacBounds).IsPairOfStrings()
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]

		else
			StzRaise("Incorrect param type! pacBounds must be a string or a pair of strings.")
		ok

		oFinder = StzStringFinderQ(This.Content())

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

		if NOT ( isList(pacBounds) and StzListQ(pacBounds).IsPairOfStrings() )
			StzRaise("Incorrect param type! pacBounds must be a pair of strings.")
		ok

		if isList(pIn) and StzListQ(pIn).IsInOrInsideNamedParam()
			pIn = pIn[2]
		ok

		if NOT isString(pIn)
			StzRaise("Incorrect param type! pIn must be a string.")
		ok

		oStr = new stzStringBounder(pIn)
		bResult = oStr.SubStringIsBoundedByCS(This.Content(), pacBounds, pCaseSensitive)

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
		but isList(pacBounds) and StzListQ(pacBounds).IsPairOfStrings()
			cBound1 = pacBounds[1]
			cBound2 = pacBounds[2]
		else
			StzRaise("Incorrect param type!")
		ok

		cBounded = cBound1 + pcSubStr + cBound2
		oFinder = StzStringFinderQ(This.Content())
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
		cSection = This.Section(n1, n2)
		oFinder = StzStringFinderQ(cSection)
		return oFinder.ContainsCS(pcSubStr, pCaseSensitive)

	def SubStringIsBetweenPositions(pcSubStr, n1, n2)
		return This.SubStringIsBetweenPositionsCS(pcSubStr, n1, n2, 1)

	  #============================================#
	 #     SUBSTRING IS BETWEEN SUBSTRINGS        #
	#============================================#

	def SubStringIsBetweenSubStringsCS(pcSubStr, pcSubStr1, pcSubStr2, pCaseSensitive)

		if CheckingParams()
			if isList(pcSubStr1) and StzListQ(pcSubStr1).IsSubStringsNamedParam()
				pcSubStr1 = pcSubStr1[2]
			ok
			if isList(pcSubStr2) and IsAndNamedParamList(pcSubStr2)
				pcSubStr2 = pcSubStr2[2]
			ok
		ok

		oFinder = StzStringFinderQ(This.Content())

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
			if isList(pcInStr) and StzListQ(pcInStr).IsInNamedParam()
				pcInStr = pcInStr[2]
			ok
			if NOT isString(pcInStr)
				StzRaise("Incorrect param type! pcInStr must be a string.")
			ok
		ok

		cBounded = This.Content() + pcSubStr + This.Content()
		oFinder = StzStringFinderQ(pcInStr)
		return oFinder.ContainsCS(cBounded, pCaseSensitive)

	def IsBoundOf(pcSubStr, pcInStr)
		return This.IsBoundOfCS(pcSubStr, pcInStr, 1)

	  #===============================#
	 #     CHAR AT                   #
	#===============================#

	def Char(n)
		if n < 1 or n > This.NumberOfChars()
			StzRaise("Index out of range!")
		ok
		return substr(This.Content(), n, 1)

	def FirstChar()
		return This.Char(1)

	def LastChar()
		return This.Char(This.NumberOfChars())
