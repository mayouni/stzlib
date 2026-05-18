#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGENCODER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String encoder -- Wraps stzString via        #
#                  composition. Hex, base64, URL encoding/       #
#                  decoding, unicode operations.                 #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringEncoder

	@oString

	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringEncoder! Parameter must be a string or stzString object.")
		ok

	def Content()
		return @oString.Content()

	def NumberOfChars()
		return @oString.NumberOfChars()

	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     HEX                       #
	#===============================#

	def ToHex()
		pHandle = StzEngineString(@oString.Content())
		pHex = StzEngineStringToHex(pHandle)
		cResult = StzEngineStringData(pHex)
		StzEngineStringFree(pHex)
		StzEngineStringFree(pHandle)
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

		@oString.Update(cResult)

		def FromHexQ(cHex)
			This.FromHex(cHex)
			return This

	  #===============================#
	 #     URL ENCODING              #
	#===============================#

	def UrlEncoded()
		pHandle = StzEngineString(@oString.Content())
		pEnc = StzEngineStringURLEncode(pHandle)
		cResult = StzEngineStringData(pEnc)
		StzEngineStringFree(pEnc)
		StzEngineStringFree(pHandle)
		return cResult

		def UrlEncode()
			@oString.Update(This.UrlEncoded())

	def UrlDecoded()
		pHandle = StzEngineString(@oString.Content())
		pDec = StzEngineStringURLDecode(pHandle)
		cResult = StzEngineStringData(pDec)
		StzEngineStringFree(pDec)
		StzEngineStringFree(pHandle)
		return cResult

		def UrlDecode()
			@oString.Update(This.UrlDecoded())

	  #===============================#
	 #     CHAR CODES                #
	#===============================#

	def AsciiCodes()
		acResult = []
		cContent = @oString.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			acResult + ascii(substr(cContent, i, 1))
		next

		return acResult

	def Unicodes()
		acResult = []
		cContent = @oString.Content()
		nLen = len(cContent)

		for i = 1 to nLen
			acResult + ascii(substr(cContent, i, 1))
		next

		return acResult

	  #===============================#
	 #     BINARY                    #
	#===============================#

	def ToBinary()
		cContent = @oString.Content()
		nLen = len(cContent)
		cResult = ""

		for i = 1 to nLen
			if i > 1
				cResult += " "
			ok
			n = ascii(substr(cContent, i, 1))
			cBin = ""
			for b = 7 to 0 step -1
				if n & pow(2, b)
					cBin += "1"
				else
					cBin += "0"
				ok
			next
			cResult += cBin
		next

		return cResult

	def FromBinary(cBin)
		acParts = @Split(cBin, " ")
		cResult = ""
		nLen = len(acParts)

		for i = 1 to nLen
			cByte = acParts[i]
			nVal = 0
			nByteLen = len(cByte)
			for j = 1 to nByteLen
				c = substr(cByte, j, 1)
				if c = "1"
					nVal += pow(2, nByteLen - j)
				ok
			next
			cResult += char(nVal)
		next

		@oString.Update(cResult)

		def FromBinaryQ(cBin)
			This.FromBinary(cBin)
			return This

	  #===============================#
	 #     OCTAL                     #
	#===============================#

	def ToOctal()
		cContent = @oString.Content()
		nLen = len(cContent)
		cResult = ""

		for i = 1 to nLen
			if i > 1
				cResult += " "
			ok
			n = ascii(substr(cContent, i, 1))
			cOct = ""
			nTemp = n
			if nTemp = 0
				cOct = "0"
			else
				while nTemp > 0
					cOct = ("" + (nTemp % 8)) + cOct
					nTemp = floor(nTemp / 8)
				end
			ok
			# Pad to at least 3 digits
			while len(cOct) < 3
				cOct = "0" + cOct
			end
			cResult += cOct
		next

		return cResult

	  #===============================#
	 #     CHAR CODES (STRING)       #
	#===============================#

	def ToCharCodes()
		cContent = @oString.Content()
		nLen = len(cContent)
		cResult = ""

		for i = 1 to nLen
			if i > 1
				cResult += " "
			ok
			cResult += ("" + ascii(substr(cContent, i, 1)))
		next

		return cResult

	def FromCharCodes(cCodes)
		acParts = @Split(cCodes, " ")
		cResult = ""
		nLen = len(acParts)

		for i = 1 to nLen
			cResult += char(0 + acParts[i])
		next

		@oString.Update(cResult)

		def FromCharCodesQ(cCodes)
			This.FromCharCodes(cCodes)
			return This

	  #===============================#
	 #     HTML ENCODING             #
	#===============================#

	def HtmlEncoded()
		cContent = @oString.Content()
		nLen = len(cContent)
		cResult = ""

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
				cResult += "&#39;"
			else
				cResult += c
			ok
		next

		return cResult

		def HtmlEncode()
			@oString.Update(This.HtmlEncoded())

		def HtmlEncodeQ()
			This.HtmlEncode()
			return This

	def HtmlDecoded()
		cContent = @oString.Content()
		cResult = cContent

		cResult = ring_substr2(cResult, "&amp;", "&")
		cResult = ring_substr2(cResult, "&lt;", "<")
		cResult = ring_substr2(cResult, "&gt;", ">")
		cResult = ring_substr2(cResult, "&quot;", '"')
		cResult = ring_substr2(cResult, "&#39;", "'")

		return cResult

		def HtmlDecode()
			@oString.Update(This.HtmlDecoded())

		def HtmlDecodeQ()
			This.HtmlDecode()
			return This

	  #===============================#
	 #     REGEX ESCAPING            #
	#===============================#

	def EscapedForRegex()
		cContent = @oString.Content()
		nLen = len(cContent)
		cResult = ""
		cSpecial = ".*+?^${}[]()|\\"

		for i = 1 to nLen
			c = substr(cContent, i, 1)
			if ring_find(cSpecial, c) > 0
				cResult += "\" + c
			else
				cResult += c
			ok
		next

		return cResult

		def EscapeForRegex()
			@oString.Update(This.EscapedForRegex())

		def EscapeForRegexQ()
			This.EscapeForRegex()
			return This

	  #===============================#
	 #     REVERSE                   #
	#===============================#

	def Reverse()
		cContent = @oString.Content()
		nLen = len(cContent)
		cResult = ""

		for i = nLen to 1 step -1
			cResult += substr(cContent, i, 1)
		next

		@oString.Update(cResult)

		def ReverseQ()
			This.Reverse()
			return This

	def Reversed()
		oCopy = new stzStringEncoder(@oString.Content())
		oCopy.Reverse()
		return oCopy.Content()
