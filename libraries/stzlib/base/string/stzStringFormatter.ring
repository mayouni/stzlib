#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGFORMATTER         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String formatter -- case conversion,        #
#                  alignment, padding, spacing, simplification #
#                  and repeating.                              #
#                  Wraps stzString via composition.            #
#                  For aliases, use stzStringFormatterXT.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringFormatter from stzObject

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
			StzRaise("Can't create stzStringFormatter! Parameter must be a string or stzString object.")
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
	 #     LOWERCASE                 #
	#===============================#

	def ApplyLowercase()
		pHandle = StzEngineString(@oString.Content())
		pLower = StzEngineStringToLower(pHandle)
		@oString.Update(StzEngineStringData(pLower))
		StzEngineStringFree(pLower)
		StzEngineStringFree(pHandle)

		def ApplyLowercaseQ()
			This.ApplyLowercase()
			return This

	def Lowercased()
		pHandle = StzEngineString(@oString.Content())
		pLower = StzEngineStringToLower(pHandle)
		_cResult_ = StzEngineStringData(pLower)
		StzEngineStringFree(pLower)
		StzEngineStringFree(pHandle)
		return _cResult_

		def LowercasedQ()
			return new stzStringFormatter(This.Lowercased())

	  #===============================#
	 #     UPPERCASE                 #
	#===============================#

	def ApplyUppercase()
		pHandle = StzEngineString(@oString.Content())
		pUpper = StzEngineStringToUpper(pHandle)
		@oString.Update(StzEngineStringData(pUpper))
		StzEngineStringFree(pUpper)
		StzEngineStringFree(pHandle)

		def ApplyUppercaseQ()
			This.ApplyUppercase()
			return This

	def Uppercased()
		pHandle = StzEngineString(@oString.Content())
		pUpper = StzEngineStringToUpper(pHandle)
		_cResult_ = StzEngineStringData(pUpper)
		StzEngineStringFree(pUpper)
		StzEngineStringFree(pHandle)
		return _cResult_

		def UppercasedQ()
			return new stzStringFormatter(This.Uppercased())

	  #===============================#
	 #     CAPITALIZE                #
	#===============================#

	def ApplyCapitalcase()
		_cContent_ = @oString.Content()
		if StzLen(_cContent_) = 0
			return
		ok

		_cFirst_ = StzUpper(StzLeft(_cContent_, 1))
		if StzLen(_cContent_) > 1
			_pH_ = StzEngineString(_cContent_)
			pRest = StzEngineStringSlice(_pH_, 2, StzLen(_cContent_) - 1)
			_cRest_ = StzLower(StzEngineStringData(pRest))
			StzEngineStringFree(pRest)
			StzEngineStringFree(_pH_)
			@oString.Update(_cFirst_ + _cRest_)
		else
			@oString.Update(_cFirst_)
		ok

		def ApplyCapitalcaseQ()
			This.ApplyCapitalcase()
			return This

	def Capitalized()
		_cContent_ = @oString.Content()
		if StzLen(_cContent_) = 0
			return ""
		ok

		_cFirst_ = StzUpper(StzLeft(_cContent_, 1))
		if StzLen(_cContent_) > 1
			_pH_ = StzEngineString(_cContent_)
			pRest = StzEngineStringSlice(_pH_, 2, StzLen(_cContent_) - 1)
			_cRest_ = StzLower(StzEngineStringData(pRest))
			StzEngineStringFree(pRest)
			StzEngineStringFree(_pH_)
			return _cFirst_ + _cRest_
		else
			return _cFirst_
		ok

		def CapitalizedQ()
			return new stzStringFormatter(This.Capitalized())

	  #===============================#
	 #     TITLECASE                 #
	#===============================#

	def ApplyTitlecase()
		@oString.Update(StzTitle(@oString.Content()))

		def ApplyTitlecaseQ()
			This.ApplyTitlecase()
			return This

	# The string in Title Case (each word capitalized).
	def Titlecased()
		_oCopy_ = new stzStringFormatter(@oString.Content())
		_oCopy_.ApplyTitlecase()
		return _oCopy_.Content()

		def TitlecasedQ()
			return new stzStringFormatter(This.Titlecased())

	  #===============================#
	 #     CASE FOLD                 #
	#===============================#

	def ApplyCaseFold()
		@oString.Update(StzCaseFold(@oString.Content()))

	# The string case-folded (aggressive lowercasing, for caseless
	# comparison).
	def CaseFolded()
		return StzCaseFold(@oString.Content())

	  #===============================#
	 #     REVERSED                  #
	#===============================#

	def ApplyReverse()
		@oString.Update(StzReverse(@oString.Content()))

		def ApplyReverseQ()
			This.ApplyReverse()
			return This

	def Reversed()
		return StzReverse(@oString.Content())

		def ReversedQ()
			return new stzStringFormatter(This.Reversed())

	  #===============================#
	 #     LEFT ALIGN                #
	#===============================#

	def LeftAlign(nWidth)
		This.LeftAlignXT(nWidth, " ")

		def LeftAlignQ(nWidth)
			This.LeftAlign(nWidth)
			return This

	def LeftAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and StzLen(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringLjust(_pH_, nWidth, cChar)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def LeftAlignXTQ(nWidth, cChar)
			This.LeftAlignXT(nWidth, cChar)
			return This

	def LeftAligned(nWidth)
		_oCopy_ = new stzStringFormatter(@oString.Content())
		_oCopy_.LeftAlign(nWidth)
		return _oCopy_.Content()

	  #===============================#
	 #     RIGHT ALIGN               #
	#===============================#

	def RightAlign(nWidth)
		This.RightAlignXT(nWidth, " ")

		def RightAlignQ(nWidth)
			This.RightAlign(nWidth)
			return This

	def RightAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and StzLen(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRjust(_pH_, nWidth, cChar)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RightAlignXTQ(nWidth, cChar)
			This.RightAlignXT(nWidth, cChar)
			return This

	def RightAligned(nWidth)
		_oCopy_ = new stzStringFormatter(@oString.Content())
		_oCopy_.RightAlign(nWidth)
		return _oCopy_.Content()

	  #===============================#
	 #     CENTER ALIGN              #
	#===============================#

	def CenterAlign(nWidth)
		This.CenterAlignXT(nWidth, " ")

		def CenterAlignQ(nWidth)
			This.CenterAlign(nWidth)
			return This

	def CenterAlignXT(nWidth, cChar)
		if CheckingParams()
			if NOT isNumber(nWidth)
				StzRaise("Incorrect param type! nWidth must be a number.")
			ok
			if NOT ( isString(cChar) and StzLen(cChar) = 1 )
				StzRaise("Incorrect param type! cChar must be a char.")
			ok
		ok
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringCenterPad(_pH_, nWidth, cChar)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def CenterAlignXTQ(nWidth, cChar)
			This.CenterAlignXT(nWidth, cChar)
			return This

	def CenterAligned(nWidth)
		_oCopy_ = new stzStringFormatter(@oString.Content())
		_oCopy_.CenterAlign(nWidth)
		return _oCopy_.Content()

	  #===============================#
	 #     PADDING                   #
	#===============================#

	def PadLeft(nWidth, cChar)
		This.RightAlignXT(nWidth, cChar)

		def PadLeftQ(nWidth, cChar)
			This.PadLeft(nWidth, cChar)
			return This

	def PaddedLeft(nWidth, cChar)
		return This.RightAligned(nWidth)

	def PadRight(nWidth, cChar)
		This.LeftAlignXT(nWidth, cChar)

		def PadRightQ(nWidth, cChar)
			This.PadRight(nWidth, cChar)
			return This

	def PaddedRight(nWidth, cChar)
		return This.LeftAligned(nWidth)

	  #===============================#
	 #     SIMPLIFICATION            #
	#===============================#

	def Simplify()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringSimplify(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def SimplifyQ()
			This.Simplify()
			return This

	def Simplified()
		_oCopy_ = new stzStringFormatter(@oString.Content())
		_oCopy_.Simplify()
		return _oCopy_.Content()

		def SimplifiedQ()
			return new stzStringFormatter(This.Simplified())

	  #===============================#
	 #     TRIMMING                  #
	#===============================#

	def Trim()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrim(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimmed(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	def TrimLeft()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimLeft(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def TrimLeftQ()
			This.TrimLeft()
			return This

	def TrimmedLeft()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimLeft(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	def TrimRight()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimRight(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def TrimRightQ()
			This.TrimRight()
			return This

	def TrimmedRight()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringTrimRight(_pH_)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	  #===============================#
	 #     REPEATING                 #
	#===============================#

	def RepeatNTimes(n)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRepeat(_pH_, n)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def RepeatNTimesQ(n)
			This.RepeatNTimes(n)
			return This

	def RepeatedNTimes(n)
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringRepeat(_pH_, n)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_
