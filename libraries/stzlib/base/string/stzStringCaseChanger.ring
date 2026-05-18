#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCASECHANGER        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String case changer -- case                 #
#                  transformations (upper, lower, toggle).      #
#                  Wraps stzString via composition.             #
#                  For aliases, use stzStringCaseChangerXT.     #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCaseChanger

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringCaseChanger! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   UPPERCASE                                          #
	#======================================================#

	def Uppercase()
		pHandle = StzEngineString(@oString.Content())
		pUpper = StzEngineStringToUpper(pHandle)
		@oString.Update(StzEngineStringData(pUpper))
		StzEngineStringFree(pUpper)
		StzEngineStringFree(pHandle)

		def UppercaseQ()
			This.Uppercase()
			return This

	def Uppercased()
		pHandle = StzEngineString(@oString.Content())
		pUpper = StzEngineStringToUpper(pHandle)
		cResult = StzEngineStringData(pUpper)
		StzEngineStringFree(pUpper)
		StzEngineStringFree(pHandle)
		return cResult

	  #======================================================#
	 #   LOWERCASE                                          #
	#======================================================#

	def Lowercase()
		pHandle = StzEngineString(@oString.Content())
		pLower = StzEngineStringToLower(pHandle)
		@oString.Update(StzEngineStringData(pLower))
		StzEngineStringFree(pLower)
		StzEngineStringFree(pHandle)

		def LowercaseQ()
			This.Lowercase()
			return This

	def Lowercased()
		pHandle = StzEngineString(@oString.Content())
		pLower = StzEngineStringToLower(pHandle)
		cResult = StzEngineStringData(pLower)
		StzEngineStringFree(pLower)
		StzEngineStringFree(pHandle)
		return cResult

	  #======================================================#
	 #   CAPITALIZE                                         #
	#======================================================#

	def Capitalize()
		cStr = This.Lowercased()
		if len(cStr) > 0
			cStr[1] = upper(cStr[1])
		ok
		@oString.Update(cStr)

		def CapitalizeQ()
			This.Capitalize()
			return This

	def Capitalized()
		oCopy = new stzStringCaseChanger(@oString.Content())
		oCopy.Capitalize()
		return oCopy.Content()

	  #======================================================#
	 #   CAPITALIZE EACH WORD                               #
	#======================================================#

	def CapitalizeEachWord()
		cStr = This.Lowercased()
		nLen = len(cStr)
		if nLen = 0
			return
		ok
		cResult = upper(cStr[1])
		for i = 2 to nLen
			if i > 1 and cStr[i-1] = " "
				cResult += upper(cStr[i])
			else
				cResult += cStr[i]
			ok
		next
		@oString.Update(cResult)

		def CapitalizeEachWordQ()
			This.CapitalizeEachWord()
			return This

	def EachWordCapitalized()
		oCopy = new stzStringCaseChanger(@oString.Content())
		oCopy.CapitalizeEachWord()
		return oCopy.Content()

	  #======================================================#
	 #   CASE CHECKING                                      #
	#======================================================#

	def IsUppercase()
		pHandle = StzEngineString(@oString.Content())
		nResult = StzEngineStringIsUppercase(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def IsLowercase()
		pHandle = StzEngineString(@oString.Content())
		nResult = StzEngineStringIsLowercase(pHandle)
		StzEngineStringFree(pHandle)
		return nResult

	def IsCapitalized()
		cStr = @oString.Content()
		if len(cStr) = 0
			return 0
		ok
		return cStr[1] = upper(cStr[1])

	  #======================================================#
	 #   TOGGLE CASE                                        #
	#======================================================#

	def ToggleCase()
		cStr = @oString.Content()
		nLen = @oString.NumberOfChars()
		cResult = ""
		for i = 1 to nLen
			c = cStr[i]
			if c = upper(c)
				cResult += lower(c)
			else
				cResult += upper(c)
			ok
		next
		@oString.Update(cResult)

		def ToggleCaseQ()
			This.ToggleCase()
			return This

	def CaseToggled()
		oCopy = new stzStringCaseChanger(@oString.Content())
		oCopy.ToggleCase()
		return oCopy.Content()

	  #======================================================#
	 #   FORCE CASE                                         #
	#======================================================#

	def SetCase(pcCase)
		if pcCase = :Upper or pcCase = :Uppercase
			This.Uppercase()
		but pcCase = :Lower or pcCase = :Lowercase
			This.Lowercase()
		but pcCase = :Capitalized or pcCase = :Capital
			This.Capitalize()
		ok

		def SetCaseQ(pcCase)
			This.SetCase(pcCase)
			return This
