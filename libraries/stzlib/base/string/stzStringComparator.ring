#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCOMPARATOR         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String comparator -- Wraps stzString via    #
#                 composition. Comparing strings for equality, #
#                 order, and diff.                             #
#                 For aliases, use stzStringComparatorXT.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringComparator

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringComparator! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   EQUALITY                                           #
	#======================================================#

	def IsEqualToCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		nResult = StzEngineStringEqualsCS(pH, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return nResult

	def IsEqualTo(pcOtherStr)
		return This.IsEqualToCS(pcOtherStr, 1)

	def IsNotEqualToCS(pcOtherStr, pCaseSensitive)
		return NOT This.IsEqualToCS(pcOtherStr, pCaseSensitive)

	def IsNotEqualTo(pcOtherStr)
		return NOT This.IsEqualTo(pcOtherStr)

	  #======================================================#
	 #   EQUALITY WITH MULTIPLE STRINGS                     #
	#======================================================#

	def IsEqualToOneOfTheseCS(pacOtherStr, pCaseSensitive)
		nLen = len(pacOtherStr)
		for i = 1 to nLen
			if This.IsEqualToCS(pacOtherStr[i], pCaseSensitive)
				return 1
			ok
		next
		return 0

	def IsEqualToOneOfThese(pacOtherStr)
		return This.IsEqualToOneOfTheseCS(pacOtherStr, 1)

	  #======================================================#
	 #   ORDERING                                           #
	#======================================================#

	def IsLessThan(pcOtherStr)
		return This.CompareCS(pcOtherStr, 1) < 0

	def IsGreaterThan(pcOtherStr)
		return This.CompareCS(pcOtherStr, 1) > 0

	def IsBetweenCS(pcStr1, pcStr2, pCaseSensitive)
		return This.CompareCS(pcStr1, pCaseSensitive) >= 0 and
		       This.CompareCS(pcStr2, pCaseSensitive) <= 0

	def IsBetween(pcStr1, pcStr2)
		return This.IsBetweenCS(pcStr1, pcStr2, 1)

	  #======================================================#
	 #   COMPARE (RETURNS -1, 0, 1)                         #
	#======================================================#

	def CompareCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		nResult = StzEngineStringCompareCS(pH, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return nResult

	def Compare(pcOtherStr)
		return This.CompareCS(pcOtherStr, 1)

	  #======================================================#
	 #   DIFF                                               #
	#======================================================#

	def DiffWith(pcOtherStr)
		aResult = []
		nLen = @oString.NumberOfChars()
		oOther = new stzString(pcOtherStr)
		nOtherLen = oOther.NumberOfChars()
		nMax = nLen
		if nOtherLen > nMax
			nMax = nOtherLen
		ok
		acThisChars = @oString.Chars()
		acOtherChars = oOther.Chars()
		for i = 1 to nMax
			if i > nLen or i > nOtherLen
				aResult + i
			but acThisChars[i] != acOtherChars[i]
				aResult + i
			ok
		next
		return aResult

	  #======================================================#
	 #   CONTAINS CHECKS                                    #
	#======================================================#

	def ContainsCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringContainsCS(@oString.Engine(), pcSubStr, _bCase_)

	def Contains(pcSubStr)
		return This.ContainsCS(pcSubStr, 1)

	def ContainsOneOfTheseCS(pacSubStr, pCaseSensitive)
		nLen = len(pacSubStr)
		for i = 1 to nLen
			if This.ContainsCS(pacSubStr[i], pCaseSensitive)
				return 1
			ok
		next
		return 0

	def ContainsOneOfThese(pacSubStr)
		return This.ContainsOneOfTheseCS(pacSubStr, 1)

	def ContainsAllOfTheseCS(pacSubStr, pCaseSensitive)
		nLen = len(pacSubStr)
		for i = 1 to nLen
			if NOT This.ContainsCS(pacSubStr[i], pCaseSensitive)
				return 0
			ok
		next
		return 1

	def ContainsAllOfThese(pacSubStr)
		return This.ContainsAllOfTheseCS(pacSubStr, 1)

	  #======================================================#
	 #   COMMON PREFIX / SUFFIX                             #
	#======================================================#

	def CommonPrefixWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		pR = StzEngineStringCommonPrefixCS(pH, pH2, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return c

	def CommonPrefixWith(pcOtherStr)
		return This.CommonPrefixWithCS(pcOtherStr, 1)

	def CommonSuffixWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		pR = StzEngineStringCommonSuffixCS(pH, pH2, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return c

	def CommonSuffixWith(pcOtherStr)
		return This.CommonSuffixWithCS(pcOtherStr, 1)

	def CommonCharsWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		pR = StzEngineStringCommonCharsCS(pH, pH2, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return c

	def CommonCharsWith(pcOtherStr)
		return This.CommonCharsWithCS(pcOtherStr, 1)

	def CommonalityWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		n = StzEngineStringCommonalityCS(pH, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return n

	def CommonalityWith(pcOtherStr)
		return This.CommonalityWithCS(pcOtherStr, 1)

	def DiffCharsWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		pR = StzEngineStringDiffCharsCS(pH, pH2, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return c

	def DiffCharsWith(pcOtherStr)
		return This.DiffCharsWithCS(pcOtherStr, 1)

	  #======================================================#
	 #   LEVENSHTEIN DISTANCE                               #
	#======================================================#

	def LevenshteinDistanceWith(pcOtherStr)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		n = StzEngineStringLevenshteinDistance(pH, pH2)
		StzEngineStringFree(pH2)
		return n

		def EditDistanceWith(pcOtherStr)
			return This.LevenshteinDistanceWith(pcOtherStr)

	  #======================================================#
	 #   PREFIX / SUFFIX COUNT                              #
	#======================================================#

	def PrefixCountWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		n = StzEngineStringPrefixCountCS(pH, pcOtherStr, _bCase_)
		return n

	def PrefixCountWith(pcOtherStr)
		return This.PrefixCountWithCS(pcOtherStr, 1)

	def SuffixCountWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		n = StzEngineStringSuffixCountCS(pH, pcOtherStr, _bCase_)
		return n

	def SuffixCountWith(pcOtherStr)
		return This.SuffixCountWithCS(pcOtherStr, 1)

	  #======================================================#
	 #   LONGEST COMMON PREFIX / SUFFIX                     #
	#======================================================#

	def LongestCommonPrefixWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		pR = StzEngineStringLongestCommonPrefixCS(pH, pH2, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return c

	def LongestCommonPrefixWith(pcOtherStr)
		return This.LongestCommonPrefixWithCS(pcOtherStr, 1)

	def LongestCommonSuffixWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		pR = StzEngineStringLongestCommonSuffixCS(pH, pH2, _bCase_)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return c

	def LongestCommonSuffixWith(pcOtherStr)
		return This.LongestCommonSuffixWithCS(pcOtherStr, 1)

	  #======================================================#
	 #   SOUNDEX / METAPHONE                                #
	#======================================================#

	def Soundex()
		pH = @oString.Engine()
		pR = StzEngineStringSoundex(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def Metaphone()
		pH = @oString.Engine()
		pR = StzEngineStringMetaphone(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c
