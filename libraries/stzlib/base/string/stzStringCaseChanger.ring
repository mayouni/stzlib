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


class stzStringCaseChanger from stzObject

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
		_cStr_ = @oString.Content()
		if StzLen(_cStr_) > 0
			# Engine-backed: first char uppercase, rest lowercase
			_cFirst_ = StzUpper(StzLeft(_cStr_, 1))
			if StzLen(_cStr_) > 1
				pH = StzEngineString(_cStr_)
				pRest = StzEngineStringSlice(pH, 2, StzLen(_cStr_) - 1)
				_cRest_ = StzLower(StzEngineStringData(pRest))
				StzEngineStringFree(pRest)
				StzEngineStringFree(pH)
				@oString.Update(_cFirst_ + _cRest_)
			else
				@oString.Update(_cFirst_)
			ok
		ok

		def CapitalizeQ()
			This.Capitalize()
			return This

	def Capitalized()
		_oCopy_ = new stzStringCaseChanger(@oString.Content())
		_oCopy_.Capitalize()
		return _oCopy_.Content()

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
		_oCopy_ = new stzStringCaseChanger(@oString.Content())
		_oCopy_.CapitalizeEachWord()
		return _oCopy_.Content()

	  #======================================================#
	 #   CASE CHECKING                                      #
	#======================================================#

	def IsUppercase()
		return StzIsUpper(@oString.Content())

	def IsLowercase()
		return StzIsLower(@oString.Content())

	def IsCapitalized()
		_cStr_ = @oString.Content()
		if StzLen(_cStr_) = 0
			return 0
		ok
		_cFirst_ = StzLeft(_cStr_, 1)
		return _cFirst_ = StzUpper(_cFirst_)

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
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		StzEngineStringFree(pH)
		return _c_

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
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def DecapitalizeFirstQ()
			This.DecapitalizeFirst()
			return This

	def FirstDecapitalized()
		_oCopy_ = new stzStringCaseChanger(@oString.Content())
		_oCopy_.DecapitalizeFirst()
		return _oCopy_.Content()
