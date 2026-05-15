#--------------------------------------------------------------#
#           SOFTANZA LIBRARY (V0.9) - STZSTRINGIO              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String IO subclass -- import/export,         #
#                  file reading/writing, URL operations.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringIO from stzString

	  #===============================#
	 #     FILE OPERATIONS           #
	#===============================#

	def FromFile(pcFilePath)
		if NOT fexists(pcFilePath)
			StzRaise("File not found! " + pcFilePath)
		ok

		cContent = read(pcFilePath)
		This.Update(cContent)

		def FromFileQ(pcFilePath)
			This.FromFile(pcFilePath)
			return This

		def LoadFrom(pcFilePath)
			This.FromFile(pcFilePath)

	def ToFile(pcFilePath)
		write(pcFilePath, This.Content())

		def SaveTo(pcFilePath)
			This.ToFile(pcFilePath)

		def ExportTo(pcFilePath)
			This.ToFile(pcFilePath)

	def AppendToFile(pcFilePath)
		cExisting = ""
		if fexists(pcFilePath)
			cExisting = read(pcFilePath)
		ok
		write(pcFilePath, cExisting + This.Content())

	def PrependToFile(pcFilePath)
		cExisting = ""
		if fexists(pcFilePath)
			cExisting = read(pcFilePath)
		ok
		write(pcFilePath, This.Content() + cExisting)

	def FileExists(pcFilePath)
		return fexists(pcFilePath)

	def IsFilePath()
		cContent = This.Content()
		nLen = len(cContent)
		if nLen = 0
			return 0
		ok

		bHasSep = 0
		bHasDot = 0

		for i = 1 to nLen
			c = substr(cContent, i, 1)
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
		cContent = lower(This.Content())
		if left(cContent, 7) = "http://" or
		   left(cContent, 8) = "https://" or
		   left(cContent, 6) = "ftp://"
			return 1
		else
			return 0
		ok

	def IsEmail()
		oFinder = StzStringFinderQ(This.Content())
		if oFinder.Contains("@") and oFinder.Contains(".")
			return 1
		else
			return 0
		ok

	  #===============================#
	 #     FORMAT CONVERSION         #
	#===============================#

	def ToJSON()
		cContent = This.Content()
		cResult = '"'
		nLen = len(cContent)
		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if c = '"'
				cResult += '\"'
			but c = "\"
				cResult += "\\"
			but c = char(10)
				cResult += "\n"
			but c = char(13)
				cResult += "\r"
			but c = char(9)
				cResult += "\t"
			else
				cResult += c
			ok
		next
		cResult += '"'
		return cResult

	def ToCSV()
		cContent = This.Content()
		oFinder = StzStringFinderQ(cContent)
		if oFinder.Contains(",") or oFinder.Contains('"') or oFinder.Contains(NL)
			cContent = @ReplaceCS(cContent, '"', '""', 1)
			return '"' + cContent + '"'
		else
			return cContent
		ok

	def ToXML()
		cContent = This.Content()
		cResult = ""
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
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
		cContent = This.Content()
		nLen = len(cContent)
		if nLen = 0
			return 0
		ok

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)
			if (n >= 65 and n <= 90) or
			   (n >= 97 and n <= 122) or
			   (n >= 48 and n <= 57) or
			   c = "+" or c = "/" or c = "="
				# valid base64 character
			else
				return 0
			ok
		next

		return 1
