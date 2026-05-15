#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGCASECHANGERXT      #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String case changer extended class --       #
#                  aliases registered via addmethod() for full  #
#                  fluency.                                     #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCaseChangerXT from stzStringCaseChanger

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

			# --- Uppercase aliases ---

			[ "ToUpper",		"Uppercase" ],
			[ "ToUpperQ",		"UppercaseQ" ],
			[ "ToUppercase",	"Uppercase" ],

			# --- Lowercase aliases ---

			[ "ToLower",		"Lowercase" ],
			[ "ToLowerQ",		"LowercaseQ" ],
			[ "ToLowercase",	"Lowercase" ],

			# --- Capitalize aliases ---

			[ "TitleCase",		"Capitalize" ],
			[ "TitleCaseQ",		"CapitalizeQ" ],

			# --- Capitalized aliases ---

			[ "Titled",		"Capitalized" ],

			# --- CapitalizeEachWord aliases ---

			[ "TitleCaseWords",	"CapitalizeEachWord" ],
			[ "TitleCaseWordsQ",	"CapitalizeEachWordQ" ],

			# --- ToggleCase aliases ---

			[ "SwapCase",		"ToggleCase" ],
			[ "SwapCaseQ",		"ToggleCaseQ" ],
			[ "InvertCase",		"ToggleCase" ],

			# --- SetCase aliases ---

			[ "ApplyCase",		"SetCase" ],
			[ "ApplyCaseQ",		"SetCaseQ" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
