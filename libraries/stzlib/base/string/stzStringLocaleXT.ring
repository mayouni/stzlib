#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGLOCALEXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String locale extended class -- aliases     #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringLocaleXT from stzStringLocale

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

			# --- Locale case aliases ---

			[ "LowercasedInLocale",		"InLocaleLowercased" ],
			[ "UppercasedInLocale",		"InLocaleUppercased" ],

			# --- Script detection aliases ---

			[ "IsLatinScript",		"IsLatin" ],
			[ "ContainsLatinLetters",	"HasLatinLetters" ],
			[ "ContainsArabicLetters",	"HasArabicLetters" ],

			# --- Content type aliases ---

			[ "ContainsDigits",		"HasDigits" ],
			[ "ContainsOnlyDigits",		"IsNumeric" ],
			[ "ContainsOnlyLetters",	"IsAlphabetic" ],
			[ "ContainsOnlyLatinLetters",	"IsOnlyLatin" ],

			# --- ASCII aliases ---

			[ "IsAscii",			"IsAsciiString" ],

			# --- Punctuation/Whitespace aliases ---

			[ "ContainsPunctuation",	"HasPunctuation" ],
			[ "ContainsWhitespace",		"HasWhitespace" ],
			[ "ContainsOnlyWhitespace",	"IsOnlyWhitespace" ],

			# --- Multi-script aliases ---

			[ "IsMixedScript",		"IsMultiScript" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
