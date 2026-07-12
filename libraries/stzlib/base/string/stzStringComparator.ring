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


class stzStringComparator from stzObject

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
		_nResult_ = StzEngineStringEqualsCS(pH, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return _nResult_

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
		_nLen_ = len(pacOtherStr)
		for i = 1 to _nLen_
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

	# TRUE if the string sorts AFTER the given one.
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
		_nResult_ = StzEngineStringCompareCS(pH, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return _nResult_

	def Compare(pcOtherStr)
		return This.CompareCS(pcOtherStr, 1)

	  #======================================================#
	 #   DIFF                                               #
	#======================================================#

	def DiffWith(pcOtherStr)
		_aResult_ = []
		_nLen_ = @oString.NumberOfChars()
		_oOther_ = new stzString(pcOtherStr)
		_nOtherLen_ = _oOther_.NumberOfChars()
		_nMax_ = _nLen_
		if _nOtherLen_ > _nMax_
			_nMax_ = _nOtherLen_
		ok
		_acThisChars_ = @oString.Chars()
		_acOtherChars_ = _oOther_.Chars()
		for i = 1 to _nMax_
			if i > _nLen_ or i > _nOtherLen_
				_aResult_ + i
			but _acThisChars_[i] != _acOtherChars_[i]
				_aResult_ + i
			ok
		next
		return _aResult_

	  #======================================================#
	 #   CONTAINS CHECKS                                    #
	#======================================================#

	def ContainsCS(pcSubStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		return StzEngineStringContainsCS(@oString.Engine(), pcSubStr, _bCase_)

	def Contains(pcSubStr)
		return This.ContainsCS(pcSubStr, 1)

	def ContainsOneOfTheseCS(pacSubStr, pCaseSensitive)
		_nLen_ = len(pacSubStr)
		for i = 1 to _nLen_
			if This.ContainsCS(pacSubStr[i], pCaseSensitive)
				return 1
			ok
		next
		return 0

	def ContainsOneOfThese(pacSubStr)
		return This.ContainsOneOfTheseCS(pacSubStr, 1)

	def ContainsAllOfTheseCS(pacSubStr, pCaseSensitive)
		_nLen_ = len(pacSubStr)
		for i = 1 to _nLen_
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
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return _c_

	def CommonPrefixWith(pcOtherStr)
		return This.CommonPrefixWithCS(pcOtherStr, 1)

	def CommonSuffixWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		pR = StzEngineStringCommonSuffixCS(pH, pH2, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return _c_

	def CommonSuffixWith(pcOtherStr)
		return This.CommonSuffixWithCS(pcOtherStr, 1)

	def CommonCharsWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		pR = StzEngineStringCommonCharsCS(pH, pH2, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return _c_

	def CommonCharsWith(pcOtherStr)
		return This.CommonCharsWithCS(pcOtherStr, 1)

	def CommonalityWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_n_ = StzEngineStringCommonalityCS(pH, pH2, _bCase_)
		StzEngineStringFree(pH2)
		return _n_

	def CommonalityWith(pcOtherStr)
		return This.CommonalityWithCS(pcOtherStr, 1)

	def DiffCharsWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		pR = StzEngineStringDiffCharsCS(pH, pH2, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return _c_

	def DiffCharsWith(pcOtherStr)
		return This.DiffCharsWithCS(pcOtherStr, 1)

	  #======================================================#
	 #   LEVENSHTEIN DISTANCE                               #
	#======================================================#

	def LevenshteinDistanceWith(pcOtherStr)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_n_ = StzEngineStringLevenshteinDistance(pH, pH2)
		StzEngineStringFree(pH2)
		return _n_

		def EditDistanceWith(pcOtherStr)
			return This.LevenshteinDistanceWith(pcOtherStr)

	  #======================================================#
	 #   PREFIX / SUFFIX COUNT                              #
	#======================================================#

	def PrefixCountWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		_n_ = StzEngineStringPrefixCountCS(pH, pcOtherStr, _bCase_)
		return _n_

	def PrefixCountWith(pcOtherStr)
		return This.PrefixCountWithCS(pcOtherStr, 1)

	def SuffixCountWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		_n_ = StzEngineStringSuffixCountCS(pH, pcOtherStr, _bCase_)
		return _n_

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
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return _c_

	def LongestCommonPrefixWith(pcOtherStr)
		return This.LongestCommonPrefixWithCS(pcOtherStr, 1)

	def LongestCommonSuffixWithCS(pcOtherStr, pCaseSensitive)
		_bCase_ = @CaseSensitive(pCaseSensitive)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		pR = StzEngineStringLongestCommonSuffixCS(pH, pH2, _bCase_)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH2)
		return _c_

	def LongestCommonSuffixWith(pcOtherStr)
		return This.LongestCommonSuffixWithCS(pcOtherStr, 1)

	  #======================================================#
	 #   SOUNDEX / METAPHONE                                #
	#======================================================#

	def Soundex()
		pH = @oString.Engine()
		pR = StzEngineStringSoundex(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	# The Metaphone phonetic code of the string.
	def Metaphone()
		pH = @oString.Engine()
		pR = StzEngineStringMetaphone(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #======================================================#
	 #   JARO / JARO-WINKLER SIMILARITY                     #
	#======================================================#

	def JaroSimilarityWith(pcOtherStr)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_n_ = StzEngineStringJaro(pH, pH2)
		StzEngineStringFree(pH2)
		return _n_

		def JaroDistanceWith(pcOtherStr)
			return This.JaroSimilarityWith(pcOtherStr)

	def JaroWinklerSimilarityWith(pcOtherStr)
		pH = @oString.Engine()
		pH2 = StzEngineString(pcOtherStr)
		_n_ = StzEngineStringJaroWinkler(pH, pH2)
		StzEngineStringFree(pH2)
		return _n_

		def JaroWinklerDistanceWith(pcOtherStr)
			return This.JaroWinklerSimilarityWith(pcOtherStr)
