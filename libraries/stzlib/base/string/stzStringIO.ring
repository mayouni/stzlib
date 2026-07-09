#--------------------------------------------------------------#
#           SOFTANZA LIBRARY (V0.9) - STZSTRINGIO              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String IO -- Wraps stzString via            #
#                  composition. Import/export, file reading/   #
#                  writing, URL operations.                    #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


class stzStringIO from stzObject

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringIO! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     FILE OPERATIONS           #
	#===============================#

	def FromFile(pcFilePath)
		if NOT fexists(pcFilePath)
			StzRaise("File not found! " + pcFilePath)
		ok

		_cContent_ = read(pcFilePath)
		@oString.Update(_cContent_)

		def FromFileQ(pcFilePath)
			This.FromFile(pcFilePath)
			return This

		def LoadFrom(pcFilePath)
			This.FromFile(pcFilePath)

	def ToFile(pcFilePath)
		write(pcFilePath, @oString.Content())

		def SaveTo(pcFilePath)
			This.ToFile(pcFilePath)

		def ExportTo(pcFilePath)
			This.ToFile(pcFilePath)

	def AppendToFile(pcFilePath)
		_cExisting_ = ""
		if fexists(pcFilePath)
			_cExisting_ = read(pcFilePath)
		ok
		write(pcFilePath, _cExisting_ + @oString.Content())

	def PrependToFile(pcFilePath)
		_cExisting_ = ""
		if fexists(pcFilePath)
			_cExisting_ = read(pcFilePath)
		ok
		write(pcFilePath, @oString.Content() + _cExisting_)

	def FileExists(pcFilePath)
		return fexists(pcFilePath)

	def IsFilePath()
		_cContent_ = @oString.Content()
		_nLen_ = StzLen(_cContent_)
		if _nLen_ = 0
			return 0
		ok

		_acChars_ = @oString.Chars()
		_bHasSep_ = 0
		_bHasDot_ = 0

		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if _c_ = "\" or _c_ = "/"
				_bHasSep_ = 1
			ok
			if _c_ = "."
				_bHasDot_ = 1
			ok
		next

		if _bHasSep_ and _bHasDot_
			return 1
		else
			return 0
		ok

	  #===============================#
	 #     URL DETECTION             #
	#===============================#

	def IsURL()
		_cContent_ = StzCaseFold(@oString.Content())
		if StzLeft(_cContent_, 7) = "http://" or
		   StzLeft(_cContent_, 8) = "https://" or
		   StzLeft(_cContent_, 6) = "ftp://"
			return 1
		else
			return 0
		ok

	def IsEmail()
		_oFinder_ = new stzStringFinder(@oString)
		if _oFinder_.Contains("@") and _oFinder_.Contains(".")
			return 1
		else
			return 0
		ok

	  #===============================#
	 #     FORMAT CONVERSION         #
	#===============================#

	def ToJSON()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_cResult_ = '"'
		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if _c_ = '"'
				_cResult_ += '\"'
			but _c_ = "\"
				_cResult_ += "\\"
			but _c_ = StzChar(10)
				_cResult_ += "\n"
			but _c_ = StzChar(13)
				_cResult_ += "\r"
			but _c_ = StzChar(9)
				_cResult_ += "\t"
			else
				_cResult_ += _c_
			ok
		next
		_cResult_ += '"'
		return _cResult_

	def ToCSV()
		_cContent_ = @oString.Content()
		_oFinder_ = new stzStringFinder(_cContent_)
		if _oFinder_.Contains(",") or _oFinder_.Contains('"') or _oFinder_.Contains(NL)
			_cContent_ = @ReplaceCS(_cContent_, '"', '""', 1)
			return '"' + _cContent_ + '"'
		else
			return _cContent_
		ok

	def ToXML()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		_cResult_ = ""

		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if _c_ = "&"
				_cResult_ += "&amp;"
			but _c_ = "<"
				_cResult_ += "&lt;"
			but _c_ = ">"
				_cResult_ += "&gt;"
			but _c_ = '"'
				_cResult_ += "&quot;"
			but _c_ = "'"
				_cResult_ += "&apos;"
			else
				_cResult_ += _c_
			ok
		next

		return _cResult_

	def ToHTML()
		return "<span>" + This.ToXML() + "</span>"

	def FromClipboard()
		StzRaise("Clipboard access is not supported in this environment!")

	def IsBase64()
		_acChars_ = @oString.Chars()
		_nLen_ = len(_acChars_)
		if _nLen_ = 0
			return 0
		ok

		for i = 1 to _nLen_
			_c_ = _acChars_[i]
			if isAlpha(_c_) or isDigit(_c_) or
			   _c_ = "+" or _c_ = "/" or _c_ = "="
				# valid base64 character
			else
				return 0
			ok
		next

		return 1
