#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCASECHANGER        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String case changer -- case                 #
#                  transformations (upper, lower, toggle).     #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringCaseChangerXT     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


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
		@oString.Update(StzUpper(@oString.Content()))

		def UppercaseQ()
			This.Uppercase()
			return This

	def Uppercased()
		return StzUpper(@oString.Content())

	  #======================================================#
	 #   LOWERCASE                                          #
	#======================================================#

	def Lowercase()
		@oString.Update(StzLower(@oString.Content()))

		def LowercaseQ()
			This.Lowercase()
			return This

	def Lowercased()
		return StzLower(@oString.Content())

	  #======================================================#
	 #   CAPITALIZE                                         #
	#======================================================#

	def Capitalize()
		cStr = @oString.Content()
		if StzLen(cStr) > 0
			# Engine-backed: first char uppercase, rest lowercase
			cFirst = StzUpper(StzLeft(cStr, 1))
			if StzLen(cStr) > 1
				pH = StzEngineString(cStr)
				pRest = StzEngineStringSlice(pH, 2, StzLen(cStr) - 1)
				cRest = StzLower(StzEngineStringData(pRest))
				StzEngineStringFree(pRest)
				StzEngineStringFree(pH)
				@oString.Update(cFirst + cRest)
			else
				@oString.Update(cFirst)
			ok
		ok

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
		# Engine-backed: use StzTitle for Unicode-aware title case
		@oString.Update(StzTitle(@oString.Content()))

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
		return StzIsUpper(@oString.Content())

	def IsLowercase()
		return StzIsLower(@oString.Content())

	def IsCapitalized()
		cStr = @oString.Content()
		if StzLen(cStr) = 0
			return 0
		ok
		cFirst = StzLeft(cStr, 1)
		return cFirst = StzUpper(cFirst)

	  #======================================================#
	 #   TOGGLE CASE                                        #
	#======================================================#

	def ToggleCase()
		pH = StzEngineString(@oString.Content())
		pR = StzEngineStringSwapCase(pH)
		@oString.Update(StzEngineStringData(pR))
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)

		def ToggleCaseQ()
			This.ToggleCase()
			return This

	def CaseToggled()
		pH = StzEngineString(@oString.Content())
		pR = StzEngineStringSwapCase(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)
		return c

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

	  #======================================================#
	 #   DECAPITALIZE FIRST                                 #
	#======================================================#

	def DecapitalizeFirst()
		pH = @oString.Engine()
		pR = StzEngineStringDecapitalizeFirst(pH)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def DecapitalizeFirstQ()
			This.DecapitalizeFirst()
			return This

	def FirstDecapitalized()
		oCopy = new stzStringCaseChanger(@oString.Content())
		oCopy.DecapitalizeFirst()
		return oCopy.Content()
