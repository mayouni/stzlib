

class stzStringNeg

	#-------------------------------#
	#  NEGATIVE FORM OF Contains()  #
	#-------------------------------#

	def ContainsNoCS(cSubStr, pCaseSensitive)
		if isList(cSubStr)
			return This.ContainsNoneOfTheseCS(cSubStr, pCaseSensitive)
		ok

		return NOT This.ContainsCS(cSubStr, pCaseSensitive)

	def ContainsNoneOfTheseCS(pacSubStr, pCaseSensitive)
		bResult = TRUE
		nLen = len(pacSubStr)
		for i = 1 to nLen
			if This.ContainsCS(pacSubStr[i], pCaseSensitive)
				bResult = FALSE
				exit
			ok
		next
		return bRersult

		def ContainsNoneOfTheseSubStringsCS(pacSubStr, pCaseSensitive)
			return This.ContainsNoneOfTheseCS(pacSubStr, pCaseSensitive)
	
		def ContainsNoneOfCS(pacSubStr, pCaseSensitive)
			return This.ContainsNoneOfTheseCS(pacSubStr, pCaseSensitive)
	
	def ContainsNeitherCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		if isList(pcSubStr2) and Q(pcSubStr2).IsNorNamedParam()
			pcSubStr2 = pcSubStr2[2]
		ok

		return This.ContainsNoneOfTheseCS([pcSubStr1, pcSubStr2], pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsNo(cSubStr)
		return This.ContainsNoCS(cSubStr, TRUE)

	def ContainsNoneOfThese(pacSubStr)
		return This.ContainsNoneOfTheseCS(pacSubStr, TRUE)

		def ContainsNoneOfTheseSubStrings(pacSubStr)
			return This.ContainsNoneOfTheseCS(pacSubStr, TRUE)
	
		def ContainsNoneOf(pacSubStr)
			return This.ContainsNoneOfTheseCS(pacSubStr, TRUE)
	
	def ContainsNeither(pcSubStr1, pcSubStr2)
		return This.ContainsNeitherCS(pcSubStr1, pcSubStr2, TRUE)
	
