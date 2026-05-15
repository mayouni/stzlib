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

