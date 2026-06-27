#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGENCODER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String encoder -- Wraps stzString via       #
#                  composition. Hex, base64, URL encoding/     #
#                  decoding, unicode operations.               #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


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
		oHex = new stzString(cHex)
		acChars = oHex.Chars()
		nLen = len(acChars)
		i = 1

		while i <= nLen - 1
			cByte = acChars[i] + acChars[i + 1]
			cResult += StzChar(dec(cByte))
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
		# Returns Unicode codepoints for each char (engine-backed)
		pH = @oString.Engine()
		nLen = @oString.NumberOfChars()
		acResult = []
		for i = 1 to nLen
			acResult + StzEngineStringCharAt(pH, i)
		next
		return acResult

	def Unicodes()
		# Same as AsciiCodes â€” returns Unicode codepoints
		return This.AsciiCodes()

		return acResult

	  #===============================#
	 #     BINARY                    #
	#===============================#

	def ToBinary()
		pH = @oString.Engine()
		nLen = @oString.NumberOfChars()
		cResult = ""

		for i = 1 to nLen
			if i > 1
				cResult += " "
			ok
			n = StzEngineStringCharAt(pH, i)
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
			nByteLen = StzLen(cByte)
			oTmp = new stzString(cByte)
			acBits = oTmp.Chars()
			for j = 1 to nByteLen
				if acBits[j] = "1"
					nVal += pow(2, nByteLen - j)
				ok
			next
			cResult += StzChar(nVal)
		next

		@oString.Update(cResult)

		def FromBinaryQ(cBin)
			This.FromBinary(cBin)
			return This

	  #===============================#
	 #     OCTAL                     #
	#===============================#

	def ToOctal()
		pH = @oString.Engine()
		nLen = @oString.NumberOfChars()
		cResult = ""

		for i = 1 to nLen
			if i > 1
				cResult += " "
			ok
			n = StzEngineStringCharAt(pH, i)
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
			while StzLen(cOct) < 3
				cOct = "0" + cOct
			end
			cResult += cOct
		next

		return cResult

	  #===============================#
	 #     CHAR CODES (STRING)       #
	#===============================#

	def ToCharCodes()
		pH = @oString.Engine()
		nLen = @oString.NumberOfChars()
		cResult = ""

		for i = 1 to nLen
			if i > 1
				cResult += " "
			ok
			cResult += ("" + StzEngineStringCharAt(pH, i))
		next

		return cResult

	def FromCharCodes(cCodes)
		acParts = @Split(cCodes, " ")
		cResult = ""
		nLen = len(acParts)

		for i = 1 to nLen
			cResult += StzChar(0 + acParts[i])
		next

		@oString.Update(cResult)

		def FromCharCodesQ(cCodes)
			This.FromCharCodes(cCodes)
			return This

	  #===============================#
	 #     HTML ENCODING             #
	#===============================#

	def HtmlEncoded()
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

		cResult = StzReplace(cResult, "&amp;", "&")
		cResult = StzReplace(cResult, "&lt;", "<")
		cResult = StzReplace(cResult, "&gt;", ">")
		cResult = StzReplace(cResult, "&quot;", '"')
		cResult = StzReplace(cResult, "&#39;", "'")

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
		acChars = @oString.Chars()
		nLen = len(acChars)
		cResult = ""
		cSpecial = ".*+?^${}[]()|\\"

		for i = 1 to nLen
			c = acChars[i]
			if StzFindFirst(cSpecial, c) > 0
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
		# Engine-backed Unicode-aware reverse
		@oString.Update(StzReverse(@oString.Content()))

		def ReverseQ()
			This.Reverse()
			return This

	def Reversed()
		oCopy = new stzStringEncoder(@oString.Content())
		oCopy.Reverse()
		return oCopy.Content()

	  #===============================#
	 #     UNICODE NORMALIZATION     #
	#===============================#

	def NormalizeNFC()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 0)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def NormalizeNFCQ()
			This.NormalizeNFC()
			return This

	def NormalizedNFC()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 0)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def NormalizeNFD()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 1)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def NormalizeNFDQ()
			This.NormalizeNFD()
			return This

	def NormalizedNFD()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 1)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def NormalizeNFKC()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 2)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def NormalizeNFKCQ()
			This.NormalizeNFKC()
			return This

	def NormalizedNFKC()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 2)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def NormalizeNFKD()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 3)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(c)

		def NormalizeNFKDQ()
			This.NormalizeNFKD()
			return This

	def NormalizedNFKD()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 3)
		c = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return c

	def Normalize()
		This.NormalizeNFC()

		def NormalizeQ()
			This.Normalize()
			return This

	def Normalized()
		return This.NormalizedNFC()
