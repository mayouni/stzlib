#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSTRINGCODE              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String code -- Wraps stzString via          #
#                  composition. Detecting and working with     #
#                  code snippets in strings (Ring code,        #
#                  functions, classes).                        #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringCode from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringCode! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     RING CODE DETECTION       #
	#===============================#

	def IsRingCode()
		_cContent_ = StzCaseFold(@oString.Content())
		_acKeywords_ = [
			"func", "class", "def", "if", "but", "else", "ok",
			"for", "next", "while", "end", "switch", "off",
			"return", "load", "see", "give", "new", "try",
			"catch", "done"
		]

		_nLen_ = len(_acKeywords_)
		for i = 1 to _nLen_
			_oFinder_ = new stzStringFinder(_cContent_)
			if _oFinder_.Contains(_acKeywords_[i])
				return 1
			ok
		next
		return 0

	def IsRingFunction()
		_cTrimmed_ = trim(@oString.Content())
		return StzLeft(StzCaseFold(_cTrimmed_), 5) = "func "

	def IsRingClass()
		_cTrimmed_ = trim(@oString.Content())
		return StzLeft(StzCaseFold(_cTrimmed_), 6) = "class "

	  #===============================#
	 #     CODE EXECUTION            #
	#===============================#

	def Execute()
		eval(@oString.Content())

	def ExecuteAndReturn()
		_cCode_ = "_result_ = " + @oString.Content()
		eval(_cCode_)
		return _result_

	  #===============================#
	 #     CODE STRUCTURE            #
	#===============================#

	def ContainsFunctions()
		_oFinder_ = new stzStringFinder(StzCaseFold(@oString.Content()))
		return _oFinder_.Contains("func ")

	def ContainsClasses()
		_oFinder_ = new stzStringFinder(StzCaseFold(@oString.Content()))
		return _oFinder_.Contains("class ")

	def NumberOfFunctions()
		_cContent_ = StzCaseFold(@oString.Content())
		_acLines_ = split(_cContent_, nl)
		_nCount_ = 0
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if StzLeft(_cLine_, 5) = "func "
				_nCount_++
			ok
		next

		return _nCount_

	def NumberOfClasses()
		_cContent_ = StzCaseFold(@oString.Content())
		_acLines_ = split(_cContent_, nl)
		_nCount_ = 0
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			if StzLeft(_cLine_, 6) = "class "
				_nCount_++
			ok
		next

		return _nCount_

	def FunctionNames()
		_cContent_ = @oString.Content()
		_acLines_ = split(_cContent_, nl)
		_acNames_ = []
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			_cLineLow_ = StzCaseFold(_cLine_)
			if StzLeft(_cLineLow_, 5) = "func "
				_oLine_ = new stzString(_cLine_)
				_cRest_ = _oLine_.Section(6, StzLen(_cLine_))
				_cRest_ = trim(_cRest_)
				# Extract the function name (first word)
				_cName_ = ""
				_oRest_ = new stzString(_cRest_)
				_acRestChars_ = _oRest_.Chars()
				_nRestLen_ = len(_acRestChars_)
				for j = 1 to _nRestLen_
					_c_ = _acRestChars_[j]
					if _c_ = " " or _c_ = "(" or _c_ = nl
						exit
					ok
					_cName_ += _c_
				next
				if StzLen(_cName_) > 0
					_acNames_ + _cName_
				ok
			ok
		next

		return _acNames_

	def ClassNames()
		_cContent_ = @oString.Content()
		_acLines_ = split(_cContent_, nl)
		_acNames_ = []
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			_cLineLow_ = StzCaseFold(_cLine_)
			if StzLeft(_cLineLow_, 6) = "class "
				_oLine_ = new stzString(_cLine_)
				_cRest_ = _oLine_.Section(7, StzLen(_cLine_))
				_cRest_ = trim(_cRest_)
				# Extract the class name (first word)
				_cName_ = ""
				_oRest_ = new stzString(_cRest_)
				_acRestChars_ = _oRest_.Chars()
				_nRestLen_ = len(_acRestChars_)
				for j = 1 to _nRestLen_
					_c_ = _acRestChars_[j]
					if _c_ = " " or _c_ = nl
						exit
					ok
					_cName_ += _c_
				next
				if StzLen(_cName_) > 0
					_acNames_ + _cName_
				ok
			ok
		next

		return _acNames_

	  #===============================#
	 #     LINE ANALYSIS             #
	#===============================#

	def IsComment()
		_cTrimmed_ = trim(@oString.Content())
		if StzLeft(_cTrimmed_, 1) = "#"
			return 1
		ok
		if StzLeft(_cTrimmed_, 2) = "//"
			return 1
		ok
		return 0

	def IsBlankLine()
		_cTrimmed_ = trim(@oString.Content())
		return StzLen(_cTrimmed_) = 0

	def ContainsComments()
		_oFinder_ = new stzStringFinder(@oString)
		if _oFinder_.Contains("#")
			return 1
		ok
		if _oFinder_.Contains("//")
			return 1
		ok
		return 0

	def LinesOfCode()
		_cContent_ = @oString.Content()
		_acLines_ = split(_cContent_, nl)
		_nCount_ = 0
		_nLen_ = len(_acLines_)

		for i = 1 to _nLen_
			_cLine_ = trim(_acLines_[i])
			# Skip blank lines
			if StzLen(_cLine_) = 0
				loop
			ok
			# Skip comment lines
			if StzLeft(_cLine_, 1) = "#"
				loop
			ok
			if StzLeft(_cLine_, 2) = "//"
				loop
			ok
			_nCount_++
		next

		return _nCount_
