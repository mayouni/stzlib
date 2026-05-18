#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCOMPARATOR         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String comparator -- Wraps stzString via    #
#                  composition. Comparing strings for equality, #
#                  order, and diff.                             #
#                  For aliases, use stzStringComparatorXT.      #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

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
		if pCaseSensitive = 1
			return @oString.Content() = pcOtherStr
		else
			return lower(@oString.Content()) = lower(pcOtherStr)
		ok

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
		return strcmp(@oString.Content(), pcOtherStr) < 0

	def IsGreaterThan(pcOtherStr)
		return strcmp(@oString.Content(), pcOtherStr) > 0

	def IsBetweenCS(pcStr1, pcStr2, pCaseSensitive)
		if pCaseSensitive = 1
			cSelf = @oString.Content()
		else
			cSelf = lower(@oString.Content())
			pcStr1 = lower(pcStr1)
			pcStr2 = lower(pcStr2)
		ok
		return strcmp(cSelf, pcStr1) >= 0 and strcmp(cSelf, pcStr2) <= 0

	def IsBetween(pcStr1, pcStr2)
		return This.IsBetweenCS(pcStr1, pcStr2, 1)

	  #======================================================#
	 #   COMPARE (RETURNS -1, 0, 1)                         #
	#======================================================#

	def CompareCS(pcOtherStr, pCaseSensitive)
		if pCaseSensitive = 0
			n = strcmp(lower(@oString.Content()), lower(pcOtherStr))
		else
			n = strcmp(@oString.Content(), pcOtherStr)
		ok

		if n < 0
			return -1
		but n > 0
			return 1
		else
			return 0
		ok

	def Compare(pcOtherStr)
		return This.CompareCS(pcOtherStr, 1)

	  #======================================================#
	 #   DIFF                                               #
	#======================================================#

	def DiffWith(pcOtherStr)
		aResult = []
		nLen = @oString.NumberOfChars()
		nOtherLen = len(pcOtherStr)
		nMax = nLen
		if nOtherLen > nMax
			nMax = nOtherLen
		ok
		for i = 1 to nMax
			if i > nLen or i > nOtherLen
				aResult + i
			but @oString.Content()[i] != pcOtherStr[i]
				aResult + i
			ok
		next
		return aResult

	  #======================================================#
	 #   CONTAINS CHECKS                                    #
	#======================================================#

	def ContainsCS(pcSubStr, pCaseSensitive)
		_oFinder_ = new stzStringFinder(@oString)
		return _oFinder_.FindNthCS(1, pcSubStr, pCaseSensitive) > 0

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
