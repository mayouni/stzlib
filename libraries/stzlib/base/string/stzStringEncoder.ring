#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGENCODER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String encoder subclass -- hex, base64,     #
#                  URL encoding/decoding, unicode operations.   #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringEncoder from stzString

	  #===============================#
	 #     HEX                       #
	#===============================#

	def ToHex()
		cContent = This.Content()
		cResult = ""
		nLen = len(cContent)

		for i = 1 to nLen
			cHex = hex(ascii(substr(cContent, i, 1)))
			if len(cHex) = 1
				cHex = "0" + cHex
			ok
			cResult += cHex
		next

		return cResult

		def ToHexQ()
			return new stzStringEncoder(This.ToHex())

		def Hexcodes()
			return This.ToHex()

	def ToHexWithPrefix()
		return "0x" + This.ToHex()

	def FromHex(cHex)
		cResult = ""
		nLen = len(cHex)
		i = 1

		while i <= nLen - 1
			cByte = substr(cHex, i, 2)
			cResult += char(dec(cByte))
			i += 2
		end

		This.Update(cResult)

		def FromHexQ(cHex)
			This.FromHex(cHex)
			return This

	  #===============================#
	 #     URL ENCODING              #
	#===============================#

	def UrlEncoded()
		cContent = This.Content()
		cResult = ""
		nLen = len(cContent)

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			n = ascii(c)

			if (n >= 65 and n <= 90) or
			   (n >= 97 and n <= 122) or
			   (n >= 48 and n <= 57) or
			   c = "-" or c = "_" or c = "." or c = "~"
				cResult += c
			else
				cHex = hex(n)
				if len(cHex) = 1
					cHex = "0" + cHex
				ok
				cResult += "%" + upper(cHex)
			ok
		next

		return cResult

		def UrlEncode()
			This.Update(This.UrlEncoded())

	def UrlDecoded()
		cContent = This.Content()
		cResult = ""
		nLen = len(cContent)
		i = 1

		while i <= nLen
			c = substr(cContent, i, 1)
			if c = "%" and i + 2 <= nLen
				cHex = substr(cContent, i + 1, 2)
				cResult += char(dec(cHex))
				i += 3
			but c = "+"
				cResult += " "
				i++
			else
				cResult += c
				i++
			ok
		end

		return cResult

		def UrlDecode()
			This.Update(This.UrlDecoded())

	  #===============================#
	 #     CHAR CODES                #
	#===============================#

	def AsciiCodes()
		acResult = []
		cContent = This.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			acResult + ascii(substr(cContent, i, 1))
		next

		return acResult

	def Unicodes()
		acResult = []
		cContent = This.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			acResult + ascii(substr(cContent, i, 1))
		next

		return acResult

