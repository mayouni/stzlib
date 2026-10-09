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


# Turns a text into another representation of itself and back: hexadecimal, binary, octal, code points, URL and HTML escapes, regex escapes and Unicode normal forms.
#
# It is the encoding helper behind the encoding methods of stzString (ToHex, UrlEncoded,
# HtmlDecoded, NormalizedNFC...), which builds one over itself and writes the result back; reach for
# it directly with new stzStringEncoder(cText) or StzStringEncoderQ(cText) when you only need the
# encoding. The past-tense forms (UrlEncoded, HtmlDecoded, NormalizedNFC...) return the new text and
# leave the encoder alone, and the verbs (UrlEncode, FromHex, Reverse...) change the held text in
# place and return nothing, the Q form returning the encoder so calls chain. Read the result with
# Content. Note what each form counts: ToHex gives the UTF-8 bytes, ToCharCodes and ToOctal give
# Unicode code points, and ToBinary gives one group of eight digits per character, which is cut to
# its low eight bits above code point 255, so it is exact for Latin-1 text only. FromHex does not
# join UTF-8 bytes back into characters, so it round-trips ASCII only. Pass a plain text, not a
# stzString object: an edit through an encoder empties the stzString that was passed in.
#
#   receiver   o1 = new stzStringEncoder("Hi é")
#   example    ? o1.ToHex()
#              #--> 486920c3a9
#              ? o1.UrlEncoded()
#              #--> Hi%20%C3%A9
#              ? o1.ToCharCodes()
#              #--> 72 105 32 233
#              o2 = new stzStringEncoder("שלום")
#              ? o2.UrlEncoded()
#              #--> %D7%A9%D7%9C%D7%95%D7%9D
#              ? o2.ToCharCodes()
#              #--> 1513 1500 1493 1501
#              o3 = new stzStringEncoder("a😀")
#              ? o3.ToHex()
#              #--> 61f09f9880
#              ? o3.ToCharCodes()
#              #--> 97 128512
#   see        stzString, stzStringFormatter, stzListOfBytes
class stzStringEncoder from stzObject

	@oString

	# Builds an encoder over a text, given as a string or as a stzString object.
	#
	#   pStrOrStzStrObj   the text to encode or decode, or a stzString whose content is used, any
	#                     other value raises an error
	#   returns           nothing; the object is built
	#   note              pass a plain text and read the result with Content; stzString does it
	#                     safely by writing the encoder result back with Update
	#   warning           with a stzString argument, the first in-place edit (UrlEncode, HtmlDecode,
	#                     FromHex, Reverse, NormalizeNFC...) leaves the stzString you passed reading
	#                     as an empty text; the encoder itself keeps the right text
	#   see               Content, ToHex
	def init(pStrOrStzStrObj)
		if isString(pStrOrStzStrObj)
			@oString = new stzString(pStrOrStzStrObj)
		but isObject(pStrOrStzStrObj)
			@oString = pStrOrStzStrObj
		else
			StzRaise("Can't create stzStringEncoder! Parameter must be a string or stzString object.")
		ok

	# Returns the text as it stands now, after the in-place edits made so far.
	#
	#   returns    a text
	#   see        NumberOfChars, ToHex
	def Content()
		return @oString.Content()

	# Returns how many characters the text holds, counting an emoji or a Hebrew letter as one.
	#
	#   returns    a number
	#   see        Content, IsEmpty
	def NumberOfChars()
		return @oString.NumberOfChars()

	# TRUE if the text holds no character at all.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        NumberOfChars, Content
	def IsEmpty()
		return @oString.IsEmpty()

	  #===============================#
	 #     HEX                       #
	#===============================#

	# Returns the UTF-8 bytes of the text as lower-case hexadecimal digits, two per byte, with no separator.
	#
	#   returns    a text; empty for an empty text
	#   note       a Hebrew letter is two bytes and an emoji four, so the result is longer than
	#              twice the character count; ToHexQ returns a new encoder over the result
	#   see        ToHexWithPrefix, FromHex, ToBinary
	#@ aka  The string's bytes in hexadecimal form.
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

	# Returns the same hexadecimal digits as ToHex, preceded by 0x.
	#
	#   returns    a text
	#   note       the prefix is always added, even for an empty text
	#   see        ToHex
	def ToHexWithPrefix()
		return "0x" + This.ToHex()

	# Replaces the held text by the text that hexadecimal digits spell, in place, taking each pair of digits as one character.
	#
	#   cHex       the hexadecimal digits, two per character, a trailing odd digit is dropped
	#   returns    nothing; the text changes. FromHexQ returns the encoder for chaining
	#   note       for ASCII text it round-trips with ToHex
	#   warning    each byte becomes its own character, so only pairs below 80 give the expected
	#              text: FromHex("c3a9") answers the two characters that spell Ã© and
	#              FromHex("d7a9d795") answers four, where ToHex of é and of a Hebrew word gave
	#              those digits; the UTF-8 bytes are not joined back into characters, so ToHex and
	#              FromHex do not round-trip for text outside ASCII
	#   see        ToHex, FromBinary
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

	# Returns the text percent-encoded for a URL, each byte of a non-ASCII character as %XX in upper case.
	#
	#   returns    a text
	#   note       a space becomes %20 and an ampersand %26
	#   see        UrlEncode, UrlDecoded, HtmlEncoded
	#@ aka  The string URL-encoded.
	def UrlEncoded()
		pHandle = StzEngineString(@oString.Content())
		pEnc = StzEngineStringURLEncode(pHandle)
		_cResult_ = StzEngineStringData(pEnc)
		StzEngineStringFree(pEnc)
		StzEngineStringFree(pHandle)
		return _cResult_

		# Replaces the held text by its percent-encoded form, in place.
		#
		#   returns    nothing; the text changes
		#   see        UrlEncoded, UrlDecode
		def UrlEncode()
			@oString.Update(This.UrlEncoded())

	# Returns the text with every %XX sequence turned back into its character, reading the bytes as UTF-8.
	#
	#   returns    a text
	#   note       decoded Hebrew, Arabic and emoji come back whole
	#   see        UrlDecode, UrlEncoded
	#@ aka  The string URL-decoded.
	def UrlDecoded()
		pHandle = StzEngineString(@oString.Content())
		pDec = StzEngineStringURLDecode(pHandle)
		_cResult_ = StzEngineStringData(pDec)
		StzEngineStringFree(pDec)
		StzEngineStringFree(pHandle)
		return _cResult_

		# Replaces the held text by its percent-decoded form, in place.
		#
		#   returns    nothing; the text changes
		#   see        UrlDecoded, UrlEncode
		def UrlDecode()
			@oString.Update(This.UrlDecoded())

	  #===============================#
	 #     CHAR CODES                #
	#===============================#

	# Returns the Unicode code point of each character, in order.
	#
	#   returns    a list of numbers; a list of one number per character
	#   note       despite its name it gives code points, not only ASCII codes: a Hebrew letter
	#              answers 1513 and an emoji 128512; Unicodes is the same call
	#   see        Unicodes, ToCharCodes
	def AsciiCodes()
		# Returns Unicode codepoints for each char (engine-backed)
		_pH_ = @oString.Engine()
		_nLen_ = @oString.NumberOfChars()
		_acResult_ = []
		for _i_ = 1 to _nLen_
			_acResult_ + StzEngineStringCharAt(_pH_, _i_)
		next
		return _acResult_

	# Returns the Unicode code point of each character, in order.
	#
	#   returns    a list of numbers; a list of one number per character
	#   see        AsciiCodes, ToCharCodes
	def Unicodes()
		# Same as AsciiCodes -- returns Unicode codepoints
		return This.AsciiCodes()

		return _acResult_

	  #===============================#
	 #     BINARY                    #
	#===============================#

	# Returns the text as one group of eight binary digits per character, groups separated by a space.
	#
	#   returns    a text such as 01001000 01101001 for Hi
	#   note       exact for Latin-1 text, so use ToHex for the bytes of other scripts
	#   warning    a character whose code point is above 255 is cut to its low eight bits: the
	#              Hebrew shin (1513) answers 11101001, which is also what the code point 233
	#              answers, and an emoji (128512) answers 00000000; ToBinary is not the UTF-8 bytes
	#              either, which ToHex gives
	#   see        FromBinary, ToOctal, ToCharCodes
	#@ aka  The string's bytes in binary form.
	def ToBinary()
		_pH_ = @oString.Engine()
		_nLen_ = @oString.NumberOfChars()
		_cResult_ = ""

		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cResult_ += " "
			ok
			_n_ = StzEngineStringCharAt(_pH_, _i_)
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

	# Replaces the held text by the characters that groups of binary digits spell, in place, one character per group.
	#
	#   _cBin_     the groups of binary digits, separated by a single space
	#   returns    nothing; the text changes. FromBinaryQ returns the encoder for chaining
	#   note       a group may be longer than eight digits and then gives a larger code point
	#   see        ToBinary, FromCharCodes
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

	# Returns the code point of each character in octal, at least three digits, separated by a space.
	#
	#   returns    a text such as 110 151 for Hi
	#   note       unlike ToBinary it is not cut to eight bits: the Hebrew shin answers 2751
	#   see        ToBinary, ToCharCodes
	#@ aka  The string's bytes in octal form.
	def ToOctal()
		_pH_ = @oString.Engine()
		_nLen_ = @oString.NumberOfChars()
		_cResult_ = ""

		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cResult_ += " "
			ok
			_n_ = StzEngineStringCharAt(_pH_, _i_)
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

	# Returns the code point of each character as decimal numbers in one text, separated by a space.
	#
	#   returns    a text such as 72 105 for Hi
	#   note       AsciiCodes gives the same numbers as a list
	#   see        FromCharCodes, AsciiCodes
	def ToCharCodes()
		_pH_ = @oString.Engine()
		_nLen_ = @oString.NumberOfChars()
		_cResult_ = ""

		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cResult_ += " "
			ok
			_cResult_ += ("" + StzEngineStringCharAt(_pH_, _i_))
		next

		return _cResult_

	# Replaces the held text by the characters whose code points are given, in place.
	#
	#   cCodes     the code points as decimal numbers separated by a single space
	#   returns    nothing; the text changes. FromCharCodesQ returns the encoder for chaining
	#   note       any code point works, so 128512 gives an emoji
	#   see        ToCharCodes, FromBinary
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

	# Returns the text with the HTML special characters replaced by entities.
	#
	#   returns    a text
	#   note       the five characters done are & < > " and ' (the last as &#39;), other text is
	#              left as it is
	#   see        HtmlEncode, HtmlDecoded, UrlEncoded
	#@ aka  The string with the HTML-special chars encoded as entities. Engine-backed. This built a per-character LIST of the whole string and concatenated onto a growing result -- the wrap-to-scan shape, quadratic in the string length. The engine does the same five substitutions (& < > " and ' -> &#39;) in one pass, and the bridge now sizes its buffer to fit rather than silently returning "" past 64 KB.
	def HtmlEncoded()
		return StzEngineHtmlEncode(@oString.Content())

		# Replaces the held text by its HTML-encoded form, in place.
		#
		#   returns    nothing; the text changes. HtmlEncodeQ returns the encoder for chaining
		#   see        HtmlEncoded, HtmlDecode
		def HtmlEncode()
			@oString.Update(This.HtmlEncoded())

		def HtmlEncodeQ()
			This.HtmlEncode()
			return This

	# Returns the text with its HTML entities turned back into characters, in a single pass.
	#
	#   returns    a text
	#   note       named entities (&lt; &quot; &nbsp;...) and numeric ones (&#39; &#x41;) are
	#              decoded, and a double-encoded &amp;lt; comes back as &lt;, not as <
	#   see        HtmlDecode, HtmlEncoded
	#@ aka  The string with the HTML entities decoded. Engine-backed, and it HAS to be, because the old Ring version was wrong.
	def HtmlDecoded()
		return StzEngineHtmlDecode(@oString.Content())

		# Replaces the held text by its HTML-decoded form, in place.
		#
		#   returns    nothing; the text changes. HtmlDecodeQ returns the encoder for chaining
		#   see        HtmlDecoded, HtmlEncode
		def HtmlDecode()
			@oString.Update(This.HtmlDecoded())

		def HtmlDecodeQ()
			This.HtmlDecode()
			return This

	  #===============================#
	 #     REGEX ESCAPING            #
	#===============================#

	# Returns the text with a backslash before every character that has a meaning in a regular expression.
	#
	#   returns    a text
	#   note       a.b*c(d) becomes a\.b\*c\(d\); plain letters and non-ASCII text are untouched
	#   see        EscapeForRegex
	#@ aka  The string with the regex special chars escaped. One engine pass. This used to build a per-character LIST of the whole string (@oString.Chars()) and scan the metacharacter set for each one, which allocates a Ring object per character to answer a question about 14 ASCII bytes. Same set, same result.
	def EscapedForRegex()
		return StzRegexEscape(@oString.Content())

		# Replaces the held text by its regex-escaped form, in place.
		#
		#   returns    nothing; the text changes. EscapeForRegexQ returns the encoder for chaining
		#   see        EscapedForRegex
		def EscapeForRegex()
			@oString.Update(This.EscapedForRegex())

		def EscapeForRegexQ()
			This.EscapeForRegex()
			return This

	  #===============================#
	 #     REVERSE                   #
	#===============================#

	# Reverses the order of the characters of the held text, in place.
	#
	#   returns    nothing; the text changes. ReverseQ returns the encoder for chaining
	#   note       characters are reversed, not bytes, so an emoji or a Hebrew word stays whole
	#   see        Reversed
	def Reverse()
		# Engine-backed Unicode-aware reverse
		@oString.Update(StzReverse(@oString.Content()))

		def ReverseQ()
			This.Reverse()
			return This

	# Returns the characters in reverse order and leaves the encoder unchanged.
	#
	#   returns    a text
	#   see        Reverse
	def Reversed()
		_oCopy_ = new stzStringEncoder(@oString.Content())
		_oCopy_.Reverse()
		return _oCopy_.Content()

	  #===============================#
	 #     UNICODE NORMALIZATION     #
	#===============================#

	# Recomposes the held text to Unicode form C, in place: a letter and its combining accent become one character.
	#
	#   returns    nothing; the text changes. NormalizeNFCQ returns the encoder for chaining
	#   see        NormalizedNFC, NormalizeNFD, Normalize
	def NormalizeNFC()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringNormalize(_pH_, 0)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def NormalizeNFCQ()
			This.NormalizeNFC()
			return This

	# Returns the text recomposed to Unicode form C: a letter and its combining accent become one character.
	#
	#   returns    a text
	#   note       e followed by a combining acute accent gives the one character é
	#   see        NormalizeNFC, NormalizedNFD
	#@ aka  The string in Unicode NFC normal form.
	def NormalizedNFC()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringNormalize(_pH_, 0)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Decomposes the held text to Unicode form D, in place: an accented letter becomes the letter and its combining accent.
	#
	#   returns    nothing; the text changes. NormalizeNFDQ returns the encoder for chaining
	#   see        NormalizedNFD, NormalizeNFC
	def NormalizeNFD()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringNormalize(_pH_, 1)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def NormalizeNFDQ()
			This.NormalizeNFD()
			return This

	# Returns the text decomposed to Unicode form D: an accented letter becomes the letter and its combining accent.
	#
	#   returns    a text
	#   note       é gives two characters, so NumberOfChars grows
	#   see        NormalizeNFD, NormalizedNFC
	#@ aka  The string in Unicode NFD normal form.
	def NormalizedNFD()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringNormalize(_pH_, 1)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Normalizes the held text to compatibility form C, in place: ligatures and look-alikes become plain letters.
	#
	#   returns    nothing; the text changes. NormalizeNFKCQ returns the encoder for chaining
	#   see        NormalizedNFKC, NormalizeNFC
	def NormalizeNFKC()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringNormalize(_pH_, 2)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def NormalizeNFKCQ()
			This.NormalizeNFKC()
			return This

	# Returns the text in compatibility form C: ligatures and look-alikes become plain letters, then are recomposed.
	#
	#   returns    a text
	#   note       the ligature fi gives the two letters fi, and a superscript 2 gives 2
	#   see        NormalizeNFKC, NormalizedNFC
	#@ aka  The string in Unicode NFKC normal form.
	def NormalizedNFKC()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringNormalize(_pH_, 2)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Normalizes the held text to compatibility form D, in place: ligatures become plain letters and accents are split off.
	#
	#   returns    nothing; the text changes. NormalizeNFKDQ returns the encoder for chaining
	#   see        NormalizedNFKD, NormalizeNFD
	def NormalizeNFKD()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringNormalize(_pH_, 3)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		@oString.Update(_c_)

		def NormalizeNFKDQ()
			This.NormalizeNFKD()
			return This

	# Returns the text in compatibility form D: ligatures become plain letters and accents are split off.
	#
	#   returns    a text
	#   see        NormalizeNFKD, NormalizedNFD
	#@ aka  The string in Unicode NFKD normal form.
	def NormalizedNFKD()
		_pH_ = @oString.Engine()
		_pR_ = StzEngineStringNormalize(_pH_, 3)
		_c_ = StzEngineStringData(_pR_)
		StzEngineStringFree(_pR_)
		return _c_

	# Normalizes the held text to Unicode form C, in place; the plain default of the four forms.
	#
	#   returns    nothing; the text changes. NormalizeQ returns the encoder for chaining
	#   see        NormalizeNFC, Normalized
	def Normalize()
		This.NormalizeNFC()

		def NormalizeQ()
			This.Normalize()
			return This

	def Normalized()
		return This.NormalizedNFC()
