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


# Moves a text in and out: saves it to a file, loads it from one, and renders it as a JSON, CSV, XML or HTML value.
#
# Build one with new stzStringIO("text"). ToFile (also SaveTo, ExportTo), AppendToFile and
# PrependToFile write the text held; FromFile (also LoadFrom) replaces it with a file's content,
# read as UTF-8, and raises when the file is missing. ToJSON, ToCSV, ToXML and ToHTML only return a
# rendering. IsFilePath, IsURL, IsEmail and IsBase64 are quick shape tests, not validations.
# FromClipboard is a placeholder that always raises. Use an invented path of your own when you try
# the file methods.
#
#   receiver   o1 = new stzStringIO("say " + char(34) + "hi" + char(34) + ", שלום")
#   example    ? o1.ToJSON()
#              #--> "say \"hi\", שלום"
#              ? o1.ToCSV()
#              #--> "say ""hi"", שלום"
#              ? o1.ToXML()
#              #--> say &quot;hi&quot;, שלום
#              ? o1.IsURL()
#              #--> 0
#   see        stzString, stzFile, stzStringCode
class stzStringIO from stzObject

	@oString

	# Builds an input-output helper over a text or over a stzString object, to save it, load it or convert it to another format.
	#
	#   pStrOrStzStrObj   a text, or a stzString object, to write out or to fill from a file
	#   returns           nothing; the object is built
	#   warning           any other kind of value raises "Can't create stzStringIO! Parameter must
	#                     be a string or stzString object."; Given a stzString object, FromFile and
	#                     LoadFrom leave that stzString EMPTY while the helper holds the file
	#                     content; the writing methods do not touch it. Pass the text, os.Content(),
	#                     to be safe
	#   see               ToFile, FromFile
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringIO! Parameter must be a string or stzString object.")
		ok

	# Returns the text the helper holds, after a FromFile if one was made.
	#
	#   returns    a text
	#   see        FromFile
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting letters and not bytes.
	#
	#   returns    a number
	#   see        Content
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text is empty.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfChars
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     FILE OPERATIONS           #
	#===============================#

	# Replaces the text held by the whole content of a file.
	#
	#   pcFilePath   the path of the file to read
	#   returns      nothing; use FromFileQ to chain
	#   note         LoadFrom is the same method; the file is read as UTF-8 bytes, so Hebrew and
	#                emoji come back intact
	#   warning      a file that does not exist raises "File not found!" and the text is kept
	#   see          ToFile, FileExists
	def FromFile(pcFilePath)
		if NOT fexists(pcFilePath)
			StzRaise("File not found! " + pcFilePath)
		ok

		_cContent_ = read(pcFilePath)
		@oString.Update(_cContent_)

		def FromFileQ(pcFilePath)
			This.FromFile(pcFilePath)
			return This

		# Replaces the text held by the whole content of a file, exactly as FromFile does.
		#
		#   pcFilePath   the path of the file to read
		#   returns      nothing
		#   see          FromFile
		def LoadFrom(pcFilePath)
			This.FromFile(pcFilePath)

	# Writes the text held to a file, replacing what the file held.
	#
	#   pcFilePath   the path of the file to write
	#   returns      nothing
	#   note         SaveTo and ExportTo are the same method; a path in a folder that does not exist
	#                is not created and is not run here
	#   see          AppendToFile, FromFile
	def ToFile(pcFilePath)
		write(pcFilePath, @oString.Content())

		# Writes the text held to a file, replacing what the file held, exactly as ToFile does.
		#
		#   pcFilePath   the path of the file to write
		#   returns      nothing
		#   see          ToFile
		def SaveTo(pcFilePath)
			This.ToFile(pcFilePath)

		# Writes the text held to a file, replacing what the file held, exactly as ToFile does.
		#
		#   pcFilePath   the path of the file to write
		#   returns      nothing
		#   see          ToFile
		def ExportTo(pcFilePath)
			This.ToFile(pcFilePath)

	# Adds the text held at the end of a file, creating the file when it does not exist.
	#
	#   pcFilePath   the path of the file to extend
	#   returns      nothing
	#   note         the file is read whole and rewritten, so it is not for large files
	#   see          PrependToFile, ToFile
	def AppendToFile(pcFilePath)
		_cExisting_ = ""
		if fexists(pcFilePath)
			_cExisting_ = read(pcFilePath)
		ok
		write(pcFilePath, _cExisting_ + @oString.Content())

	# Adds the text held at the start of a file, creating the file when it does not exist.
	#
	#   pcFilePath   the path of the file to extend
	#   returns      nothing
	#   note         the file is read whole and rewritten
	#   see          AppendToFile
	def PrependToFile(pcFilePath)
		_cExisting_ = ""
		if fexists(pcFilePath)
			_cExisting_ = read(pcFilePath)
		ok
		write(pcFilePath, @oString.Content() + _cExisting_)

	# TRUE if a file exists at the given path.
	#
	#   pcFilePath   the path to test
	#   returns      TRUE or FALSE
	#   note         it tests a path, not the text held
	#   see          FromFile
	def FileExists(pcFilePath)
		return fexists(pcFilePath)

	# TRUE if the text looks like a file path: it contains a slash or backslash and also a dot.
	#
	#   returns    TRUE or FALSE
	#   note       it never looks at the disk
	#   warning    A shape test only: "http://x.org/a.b" and the number "1.5/2" answer TRUE, and a
	#              path without a dot, "dir/file", answers FALSE
	#   see        IsURL, FileExists
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

	# TRUE if the text begins with http://, https:// or ftp://, in any case.
	#
	#   returns    TRUE or FALSE
	#   note       "www.example.org" is FALSE: the scheme is required
	#   see        IsFilePath, IsEmail
	def IsURL()
		_cContent_ = StzCaseFold(@oString.Content())
		if StzLeft(_cContent_, 7) = "http://" or
		   StzLeft(_cContent_, 8) = "https://" or
		   StzLeft(_cContent_, 6) = "ftp://"
			return 1
		else
			return 0
		ok

	# TRUE if the text contains both an @ and a dot, anywhere.
	#
	#   returns    TRUE or FALSE
	#   note       the Hebrew "שלום@דוא.com" answers TRUE
	#   warning    A loose check: "@." and "x.y@z" answer TRUE, and "a@b" answers FALSE; it does not
	#              validate an address
	#   see        IsURL
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

	# Returns the text as a JSON string literal: in double quotes, with quote, backslash, newline, return and tab escaped.
	#
	#   returns    a text starting and ending with a double quote
	#   note       Hebrew, Arabic and emoji are kept as they are, not written as \u escapes
	#   see        ToCSV, ToXML
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

	# Returns the text as one CSV field: in double quotes, with quotes doubled, when it holds a comma, a quote or a newline; unchanged otherwise.
	#
	#   returns    a text
	#   note       a comma, a quote or a newline triggers the quoting; plain text stays as it is
	#   see        ToJSON
	def ToCSV()
		_cContent_ = @oString.Content()
		_oFinder_ = new stzStringFinder(_cContent_)
		if _oFinder_.Contains(",") or _oFinder_.Contains('"') or _oFinder_.Contains(char(10))
			_cContent_ = @ReplaceCS(_cContent_, '"', '""', 1)
			return '"' + _cContent_ + '"'
		else
			return _cContent_
		ok

	# Returns the text with the five XML special characters replaced by their entities: & < > " and the apostrophe.
	#
	#   returns    a text
	#   note       it makes content safe to place inside an XML element, not a whole document
	#   see        ToHTML
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

	# Returns the text made safe for HTML and wrapped in a span element.
	#
	#   returns    a text such as "<span>a&amp;b</span>"
	#   see        ToXML
	def ToHTML()
		return "<span>" + This.ToXML() + "</span>"

	# Raises the error "Clipboard access is not supported in this environment!" today.
	#
	#   returns    nothing: it always raises
	#   note       no clipboard is read
	#   warning    Always raises, it is a placeholder
	#   see        FromFile
	def FromClipboard()
		StzRaise("Clipboard access is not supported in this environment!")

	# TRUE if the text is not empty and made only of letters, digits, +, / and =.
	#
	#   returns    TRUE or FALSE
	#   note       it checks neither the length nor the padding
	#   warning    A character test only: "abc" and "====" answer TRUE although neither is valid
	#              base64, and a text with a space or a Hebrew letter answers FALSE
	#   see        ToJSON
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
