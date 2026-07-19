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


class stzStringEncoder from stzObject

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

	# The string's bytes in hexadecimal form.
	def ToHex()
		pHandle = StzEngineString(@oString.Content())
		pHex = StzEngineStringToHex(pHandle)
		_cResult_ = StzEngineStringData(pHex)
		StzEngineStringFree(pHex)
		StzEngineStringFree(pHandle)
		return _cResult_

		def ToHexQ()
			return new stzStringEncoder(This.ToHex())

		def Hexcodes()
			return This.ToHex()

	def ToHexWithPrefix()
		return "0x" + This.ToHex()

	def FromHex(cHex)
		_cResult_ = ""
		_oHex_ = new stzString(cHex)
		_acChars_ = _oHex_.Chars()
		_nLen_ = len(_acChars_)
		_i_ = 1

		while _i_ <= _nLen_ - 1
			_cByte_ = _acChars_[_i_] + _acChars_[_i_ + 1]
			_cResult_ += StzChar(dec(_cByte_))
			_i_ += 2
		end

		@oString.Update(_cResult_)

		def FromHexQ(cHex)
			This.FromHex(cHex)
			return This

	  #===============================#
	 #     URL ENCODING              #
	#===============================#

	# The string URL-encoded.
	def UrlEncoded()
		pHandle = StzEngineString(@oString.Content())
		pEnc = StzEngineStringURLEncode(pHandle)
		_cResult_ = StzEngineStringData(pEnc)
		StzEngineStringFree(pEnc)
		StzEngineStringFree(pHandle)
		return _cResult_

		def UrlEncode()
			@oString.Update(This.UrlEncoded())

	# The string URL-decoded.
	def UrlDecoded()
		pHandle = StzEngineString(@oString.Content())
		pDec = StzEngineStringURLDecode(pHandle)
		_cResult_ = StzEngineStringData(pDec)
		StzEngineStringFree(pDec)
		StzEngineStringFree(pHandle)
		return _cResult_

		def UrlDecode()
			@oString.Update(This.UrlDecoded())

	  #===============================#
	 #     CHAR CODES                #
	#===============================#

	def AsciiCodes()
		# Returns Unicode codepoints for each char (engine-backed)
		pH = @oString.Engine()
		_nLen_ = @oString.NumberOfChars()
		_acResult_ = []
		for _i_ = 1 to _nLen_
			_acResult_ + StzEngineStringCharAt(pH, _i_)
		next
		return _acResult_

	def Unicodes()
		# Same as AsciiCodes -- returns Unicode codepoints
		return This.AsciiCodes()

		return _acResult_

	  #===============================#
	 #     BINARY                    #
	#===============================#

	# The string's bytes in binary form.
	def ToBinary()
		pH = @oString.Engine()
		_nLen_ = @oString.NumberOfChars()
		_cResult_ = ""

		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cResult_ += " "
			ok
			_n_ = StzEngineStringCharAt(pH, _i_)
			_cBin_ = ""
			for b = 7 to 0 step -1
				if _n_ & pow(2, b)
					_cBin_ += "1"
				else
					_cBin_ += "0"
				ok
			next
			_cResult_ += _cBin_
		next

		return _cResult_

	def FromBinary(_cBin_)
		_acParts_ = @Split(_cBin_, " ")
		_cResult_ = ""
		_nLen_ = len(_acParts_)

		for _i_ = 1 to _nLen_
			_cByte_ = _acParts_[_i_]
			_nVal_ = 0
			_nByteLen_ = StzLen(_cByte_)
			_oTmp_ = new stzString(_cByte_)
			_acBits_ = _oTmp_.Chars()
			for j = 1 to _nByteLen_
				if _acBits_[j] = "1"
					_nVal_ += pow(2, _nByteLen_ - j)
				ok
			next
			_cResult_ += StzChar(_nVal_)
		next

		@oString.Update(_cResult_)

		def FromBinaryQ(_cBin_)
			This.FromBinary(_cBin_)
			return This

	  #===============================#
	 #     OCTAL                     #
	#===============================#

	# The string's bytes in octal form.
	def ToOctal()
		pH = @oString.Engine()
		_nLen_ = @oString.NumberOfChars()
		_cResult_ = ""

		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cResult_ += " "
			ok
			_n_ = StzEngineStringCharAt(pH, _i_)
			_cOct_ = ""
			_nTemp_ = _n_
			if _nTemp_ = 0
				_cOct_ = "0"
			else
				while _nTemp_ > 0
					_cOct_ = ("" + (_nTemp_ % 8)) + _cOct_
					_nTemp_ = floor(_nTemp_ / 8)
				end
			ok
			# Pad to at least 3 digits
			while StzLen(_cOct_) < 3
				_cOct_ = "0" + _cOct_
			end
			_cResult_ += _cOct_
		next

		return _cResult_

	  #===============================#
	 #     CHAR CODES (STRING)       #
	#===============================#

	def ToCharCodes()
		pH = @oString.Engine()
		_nLen_ = @oString.NumberOfChars()
		_cResult_ = ""

		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cResult_ += " "
			ok
			_cResult_ += ("" + StzEngineStringCharAt(pH, _i_))
		next

		return _cResult_

	def FromCharCodes(cCodes)
		_acParts_ = @Split(cCodes, " ")
		_cResult_ = ""
		_nLen_ = len(_acParts_)

		for _i_ = 1 to _nLen_
			_cResult_ += StzChar(0 + _acParts_[_i_])
		next

		@oString.Update(_cResult_)

		def FromCharCodesQ(cCodes)
			This.FromCharCodes(cCodes)
			return This

	  #===============================#
	 #     HTML ENCODING             #
	#===============================#

	# The string with the HTML-special chars encoded as entities.
	# Engine-backed. This built a per-character LIST of the whole string and
	# concatenated onto a growing result -- the wrap-to-scan shape, quadratic
	# in the string length. The engine does the same five substitutions
	# (& < > " and ' -> &#39;) in one pass, and the bridge now sizes its
	# buffer to fit rather than silently returning "" past 64 KB.
	def HtmlEncoded()
		return StzEngineHtmlEncode(@oString.Content())

		def HtmlEncode()
			@oString.Update(This.HtmlEncoded())

		def HtmlEncodeQ()
			This.HtmlEncode()
			return This

	# The string with the HTML entities decoded. Engine-backed, and it HAS to
	# be, because the old Ring version was wrong.
	#
	# It ran StzReplace("&amp;", "&") FIRST, then the others -- so the '&'
	# produced by decoding &amp; was fed straight into the next rules:
	#
	#   "&amp;lt;"  ->  "&lt;"  ->  "<"      WRONG, should stay "&lt;"
	#   "&amp;gt;"  ->  "&gt;"  ->  ">"      WRONG, should stay "&gt;"
	#
	# i.e. anything that was DOUBLE-encoded came back single-decoded. The
	# encode/decode pair was not a round trip whenever the source text itself
	# contained an entity.
	#
	# The engine makes ONE left-to-right pass, consuming each entity whole and
	# advancing past it, so a decoded '&' can never re-trigger a match. It
	# also covers &apos; &nbsp; and numeric entities (&#NN; / &#xHH;), which
	# the five-replace version silently left intact -- a widening, not a
	# behaviour change for anything the old code handled.
	def HtmlDecoded()
		return StzEngineHtmlDecode(@oString.Content())

		def HtmlDecode()
			@oString.Update(This.HtmlDecoded())

		def HtmlDecodeQ()
			This.HtmlDecode()
			return This

	  #===============================#
	 #     REGEX ESCAPING            #
	#===============================#

	# The string with the regex special chars escaped.
	# One engine pass. This used to build a per-character LIST of the whole
	# string (@oString.Chars()) and scan the metacharacter set for each one,
	# which allocates a Ring object per character to answer a question about
	# 14 ASCII bytes. Same set, same result.
	def EscapedForRegex()
		return StzRegexEscape(@oString.Content())

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
		_oCopy_ = new stzStringEncoder(@oString.Content())
		_oCopy_.Reverse()
		return _oCopy_.Content()

	  #===============================#
	 #     UNICODE NORMALIZATION     #
	#===============================#

	def NormalizeNFC()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 0)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def NormalizeNFCQ()
			This.NormalizeNFC()
			return This

	# The string in Unicode NFC normal form.
	def NormalizedNFC()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 0)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def NormalizeNFD()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 1)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def NormalizeNFDQ()
			This.NormalizeNFD()
			return This

	# The string in Unicode NFD normal form.
	def NormalizedNFD()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 1)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def NormalizeNFKC()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 2)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def NormalizeNFKCQ()
			This.NormalizeNFKC()
			return This

	# The string in Unicode NFKC normal form.
	def NormalizedNFKC()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 2)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def NormalizeNFKD()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 3)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		@oString.Update(_c_)

		def NormalizeNFKDQ()
			This.NormalizeNFKD()
			return This

	# The string in Unicode NFKD normal form.
	def NormalizedNFKD()
		pH = @oString.Engine()
		pR = StzEngineStringNormalize(pH, 3)
		_c_ = StzEngineStringData(pR)
		StzEngineStringFree(pR)
		return _c_

	def Normalize()
		This.NormalizeNFC()

		def NormalizeQ()
			This.Normalize()
			return This

	def Normalized()
		return This.NormalizedNFC()
