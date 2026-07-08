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

		cContent = read(pcFilePath)
		@oString.Update(cContent)

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
		cExisting = ""
		if fexists(pcFilePath)
			cExisting = read(pcFilePath)
		ok
		write(pcFilePath, cExisting + @oString.Content())

	def PrependToFile(pcFilePath)
		cExisting = ""
		if fexists(pcFilePath)
			cExisting = read(pcFilePath)
		ok
		write(pcFilePath, @oString.Content() + cExisting)

	def FileExists(pcFilePath)
		return fexists(pcFilePath)

	def IsFilePath()
		cContent = @oString.Content()
		nLen = StzLen(cContent)
		if nLen = 0
			return 0
		ok

		acChars = @oString.Chars()
		bHasSep = 0
		bHasDot = 0

		for i = 1 to nLen
			c = acChars[i]
			if c = "\" or c = "/"
				bHasSep = 1
			ok
			if c = "."
				bHasDot = 1
			ok
		next

		if bHasSep and bHasDot
			return 1
		else
			return 0
		ok

	  #===============================#
	 #     URL DETECTION             #
	#===============================#

	def IsURL()
		cContent = StzCaseFold(@oString.Content())
		if StzLeft(cContent, 7) = "http://" or
		   StzLeft(cContent, 8) = "https://" or
		   StzLeft(cContent, 6) = "ftp://"
			return 1
		else
			return 0
		ok

	def IsEmail()
		oFinder = new stzStringFinder(@oString)
		if oFinder.Contains("@") and oFinder.Contains(".")
			return 1
		else
			return 0
		ok

	  #===============================#
	 #     FORMAT CONVERSION         #
	#===============================#

	def ToJSON()
		acChars = @oString.Chars()
		nLen = len(acChars)
		cResult = '"'
		for i = 1 to nLen
			c = acChars[i]
			if c = '"'
				cResult += '\"'
			but c = "\"
				cResult += "\\"
			but c = StzChar(10)
				cResult += "\n"
			but c = StzChar(13)
				cResult += "\r"
			but c = StzChar(9)
				cResult += "\t"
			else
				cResult += c
			ok
		next
		cResult += '"'
		return cResult

	def ToCSV()
		cContent = @oString.Content()
		oFinder = new stzStringFinder(cContent)
		if oFinder.Contains(",") or oFinder.Contains('"') or oFinder.Contains(NL)
			cContent = @ReplaceCS(cContent, '"', '""', 1)
			return '"' + cContent + '"'
		else
			return cContent
		ok

	def ToXML()
		acChars = @oString.Chars()
		nLen = len(acChars)
		cResult = ""

		for i = 1 to nLen
			c = acChars[i]
			if c = "&"
				cResult += "&amp;"
			but c = "<"
				cResult += "&lt;"
			but c = ">"
				cResult += "&gt;"
			but c = '"'
				cResult += "&quot;"
			but c = "'"
				cResult += "&apos;"
			else
				cResult += c
			ok
		next

		return cResult

	def ToHTML()
		return "<span>" + This.ToXML() + "</span>"

	def FromClipboard()
		StzRaise("Clipboard access is not supported in this environment!")

	def IsBase64()
		acChars = @oString.Chars()
		nLen = len(acChars)
		if nLen = 0
			return 0
		ok

		for i = 1 to nLen
			c = acChars[i]
			if isAlpha(c) or isDigit(c) or
			   c = "+" or c = "/" or c = "="
				# valid base64 character
			else
				return 0
			ok
		next

		return 1
