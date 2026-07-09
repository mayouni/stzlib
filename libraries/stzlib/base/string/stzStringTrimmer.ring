#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGTRIMMER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String trimmer -- Wraps stzString via       #
#                  composition. Trimming whitespace and chars  #
#                  from strings.                               #
#                  For aliases, use stzStringTrimmerXT.        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringTrimmer from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringTrimmer! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #======================================================#
	 #   TRIMMING BOTH SIDES                                #
	#======================================================#

	def Trim()
		pH = @oString.Engine()
		pR = StzEngineStringTrim(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def TrimQ()
			This.Trim()
			return This

	def Trimmed()
		pH = @oString.Engine()
		pR = StzEngineStringTrimmed(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #======================================================#
	 #   TRIMMING LEFT / RIGHT                              #
	#======================================================#

	def TrimLeft()
		pH = @oString.Engine()
		pR = StzEngineStringTrimLeft(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def TrimLeftQ()
			This.TrimLeft()
			return This

	def TrimmedLeft()
		pH = @oString.Engine()
		pR = StzEngineStringTrimLeft(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def TrimRight()
		pH = @oString.Engine()
		pR = StzEngineStringTrimRight(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def TrimRightQ()
			This.TrimRight()
			return This

	def TrimmedRight()
		pH = @oString.Engine()
		pR = StzEngineStringTrimRight(pH)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	  #======================================================#
	 #   TRIMMING START / END                               #
	#======================================================#

	def TrimStart()
		This.TrimLeft()

		def TrimStartQ()
			This.TrimStart()
			return This

	def TrimmedFromStart()
		return This.TrimmedLeft()

	def TrimEnd()
		This.TrimRight()

		def TrimEndQ()
			This.TrimEnd()
			return This

	def TrimmedFromEnd()
		return This.TrimmedRight()

	  #======================================================#
	 #   TRIMMING A SPECIFIC CHAR                           #
	#======================================================#

	def TrimCharCS(_c_, pCaseSensitive)
		This.TrimCharFromStartCS(_c_, pCaseSensitive)
		This.TrimCharFromEndCS(_c_, pCaseSensitive)

		def TrimCharCSQ(_c_, pCaseSensitive)
			This.TrimCharCS(_c_, pCaseSensitive)
			return This

	def CharTrimmedCS(_c_, pCaseSensitive)
		_oCopy_ = new stzStringTrimmer(@oString.Content())
		_oCopy_.TrimCharCS(_c_, pCaseSensitive)
		return _oCopy_.Content()

	def TrimChar(_c_)
		This.TrimCharCS(_c_, 1)

		def TrimCharQ(_c_)
			This.TrimChar(_c_)
			return This

	def CharTrimmed(_c_)
		return This.CharTrimmedCS(_c_, 1)

	  #======================================================#
	 #   TRIMMING CHAR FROM START / END                     #
	#======================================================#

	def TrimCharFromStartCS(_c_, pCaseSensitive)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_nStart_ = 1
		for i = 1 to _nLen_
			if BothStringsAreEqualCS(_acChars_[i], _c_, pCaseSensitive)
				_nStart_ = i + 1
			else
				exit
			ok
		next
		if _nStart_ > _nLen_
			@oString.Update("")
		else
			@oString.Update(@oString.Section(_nStart_, _nLen_))
		ok

		def TrimCharFromStartCSQ(_c_, pCaseSensitive)
			This.TrimCharFromStartCS(_c_, pCaseSensitive)
			return This

		def RemoveThisCharFromStartCS(_c_, pCaseSensitive)
			This.TrimCharFromStartCS(_c_, pCaseSensitive)

	def TrimCharFromStart(_c_)
		This.TrimCharFromStartCS(_c_, 1)

		def RemoveThisCharFromStart(_c_)
			This.TrimCharFromStart(_c_)

	#--

	def TrimCharFromEndCS(_c_, pCaseSensitive)
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_nEnd_ = _nLen_
		for i = _nLen_ to 1 step -1
			if BothStringsAreEqualCS(_acChars_[i], _c_, pCaseSensitive)
				_nEnd_ = i - 1
			else
				exit
			ok
		next
		if _nEnd_ < 1
			@oString.Update("")
		else
			@oString.Update(@oString.Section(1, _nEnd_))
		ok

		def TrimCharFromEndCSQ(_c_, pCaseSensitive)
			This.TrimCharFromEndCS(_c_, pCaseSensitive)
			return This

		def RemoveThisCharFromEndCS(_c_, pCaseSensitive)
			This.TrimCharFromEndCS(_c_, pCaseSensitive)

	def TrimCharFromEnd(_c_)
		This.TrimCharFromEndCS(_c_, 1)

		def RemoveThisCharFromEnd(_c_)
			This.TrimCharFromEnd(_c_)

	  #======================================================#
	 #   TRIMMING CHAR FROM LEFT / RIGHT                    #
	#======================================================#

	def TrimCharFromLeftCS(_c_, pCaseSensitive)
		if @oString.IsLeftToRight()
			This.TrimCharFromStartCS(_c_, pCaseSensitive)
		else
			This.TrimCharFromEndCS(_c_, pCaseSensitive)
		ok

	def TrimCharFromLeft(_c_)
		This.TrimCharFromLeftCS(_c_, 1)

	def TrimCharFromRightCS(_c_, pCaseSensitive)
		if @oString.IsLeftToRight()
			This.TrimCharFromEndCS(_c_, pCaseSensitive)
		else
			This.TrimCharFromStartCS(_c_, pCaseSensitive)
		ok

	def TrimCharFromRight(_c_)
		This.TrimCharFromRightCS(_c_, 1)
