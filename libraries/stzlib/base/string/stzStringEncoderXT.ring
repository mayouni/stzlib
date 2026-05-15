#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZSTRINGENCODERXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String encoder extended class -- aliases    #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringEncoderXT from stzStringEncoder

	_bAliasesLoaded = FALSE

	def init(pcStr)
		super.init(pcStr)
		This._RegisterAliases()

	def _RegisterAliases()

		if _bAliasesLoaded
			return
		ok

		_bAliasesLoaded = TRUE

		_aAliases_ = [

			# --- Hex aliases ---

			[ "HexEncoded",			"ToHex" ],
			[ "HexEncode",			"ToHex" ],
			[ "HexDecode",			"FromHex" ],
			[ "HexDecodeQ",			"FromHexQ" ],
			[ "HexWithPrefix",		"ToHexWithPrefix" ],

			# --- Binary aliases ---

			[ "BinaryEncoded",		"ToBinary" ],
			[ "BinaryDecode",		"FromBinary" ],
			[ "BinaryDecodeQ",		"FromBinaryQ" ],

			# --- Octal aliases ---

			[ "OctalEncoded",		"ToOctal" ],

			# --- CharCodes aliases ---

			[ "CharCodes",			"ToCharCodes" ],
			[ "DecodeCharCodes",		"FromCharCodes" ],
			[ "DecodeCharCodesQ",		"FromCharCodesQ" ],

			# --- URL aliases ---

			[ "EncodeUrl",			"UrlEncode" ],
			[ "DecodeUrl",			"UrlDecode" ],
			[ "UrlEncodedString",		"UrlEncoded" ],
			[ "UrlDecodedString",		"UrlDecoded" ],

			# --- Regex aliases ---

			[ "EscapeRegex",		"EscapeForRegex" ],
			[ "EscapeRegexQ",		"EscapeForRegexQ" ],
			[ "RegexEscaped",		"EscapedForRegex" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
