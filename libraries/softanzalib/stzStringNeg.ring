

class stzStringNeg

	#-------------------------------#
	#  NEGATIVE FORM OF Contains()  #
	#-------------------------------#

	def ContainsNoCS(cSubStr, pCaseSensitive)
		if isList(cSubStr)
			return This.ContainsNoneOfTheseCS(cSubStr, pCaseSensitive)
		ok

		return NOT This.ContainsCS(cSubStr, pCaseSensitive)

	def ContainsNoneOfTheseCS(pacSubStrings, pCaseSensitive)
		bResult = TRUE
		nLen = len(pacSubStrings)
		for i = 1 to nLen
			if This.ContainsCS(pacSubStrings[i], pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next
		return bRersult

		def ContainsNoneOfTheseSubStringsCS(pacSubStrings, pCaseSensitive)
			return This.ContainsNoneOfTheseCS(pacSubStrings, pCaseSensitive)
	
		def ContainsNoneOfCS(pacSubStrings, pCaseSensitive)
			return This.ContainsNoneOfTheseCS(pacSubStrings, pCaseSensitive)
	
	def ContainsNeitherCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		if isList(pcSubStr2) and Q(pcSubStr2).IsNorNamedParam()
			pcSubStr2 = pcSubStr2[2]
		ok

		return This.ContainsNoneOfTheseCS([pcSubStr1, pcSubStr2], pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsNo(cSubStr)
		return This.ContainsNoCS(cSubStr, TRUE)

	def ContainsNoneOfThese(pacSubStrings)
		return This.ContainsNoneOfTheseCS(pacSubStrings, TRUE)

		def ContainsNoneOfTheseSubStrings(pacSubStrings)
			return This.ContainsNoneOfTheseCS(pacSubStrings, TRUE)
	
		def ContainsNoneOf(pacSubStrings)
			return This.ContainsNoneOfTheseCS(pacSubStrings, TRUE)
	
	def ContainsNeither(pcSubStr1, pcSubStr2)
		return This.ContainsNeitherCS(pcSubStr1, pcSubStr2, TRUE)
	
