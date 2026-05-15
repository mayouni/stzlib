#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STZSTRINGCHECKERXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Extended string checker -- adds all         #
#                  Softanza method aliases to stzStringChecker  #
#                  via addmethod() for full fluency.            #
#                  Use stzStringChecker for lean canonical API. #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringCheckerXT from stzStringChecker

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

			# --- IsPalindromeCS aliases ---

			[ "IsMirroredCS",               "IsPalindromeCS" ],

			# --- IsPalindrome aliases ---

			[ "IsMirrored",                 "IsPalindrome" ],

			# --- IsHybridcase aliases ---

			[ "IsMixedcase",                "IsHybridcase" ],

			# --- ContainsOnlySpaces aliases ---

			[ "IsMadeOfSpaces",             "ContainsOnlySpaces" ],
			[ "IsBlank",                    "ContainsOnlySpaces" ],

			# --- ContainsOnlyLetters aliases ---

			[ "IsAlpha",                    "ContainsOnlyLetters" ],
			[ "IsAlphabetic",               "ContainsOnlyLetters" ],
			[ "IsMadeOfLetters",            "ContainsOnlyLetters" ],

			# --- ContainsOnlyNumbers aliases ---

			[ "IsMadeOfNumbers",            "ContainsOnlyNumbers" ],
			[ "IsNumeric",                  "ContainsOnlyNumbers" ],

			# --- ContainsOnlyDigits aliases ---

			[ "IsDigit",                    "ContainsOnlyDigits" ],
			[ "IsMadeOfDigits",             "ContainsOnlyDigits" ],

			# --- ContainsOnlyLettersAndNumbers aliases ---

			[ "IsAlphaNum",                 "ContainsOnlyLettersAndNumbers" ],
			[ "IsAlphaNumeric",             "ContainsOnlyLettersAndNumbers" ],
			[ "IsAlNum",                    "ContainsOnlyLettersAndNumbers" ],
			[ "IsMadeOfLettersAndNumbers",  "ContainsOnlyLettersAndNumbers" ],

			# --- IsMadeOfCS aliases ---

			[ "IsMadeOfTheseCS",            "IsMadeOfCS" ],

			# --- IsMadeOf aliases ---

			[ "IsMadeOfThese",              "IsMadeOf" ],

			# --- IsMadeOfSomeCS aliases ---

			[ "IsMadeOfSomeOfTheseCS",      "IsMadeOfSomeCS" ],

			# --- IsMadeOfSome aliases ---

			[ "IsMadeOfSomeOfThese",        "IsMadeOfSome" ],

			# --- RepresentsInteger aliases ---

			[ "IsInteger",                  "RepresentsInteger" ],
			[ "IsAnInteger",                "RepresentsInteger" ],

			# --- RepresentsSignedInteger aliases ---

			[ "IsSignedInteger",            "RepresentsSignedInteger" ],

			# --- RepresentsUnsignedInteger aliases ---

			[ "IsUnsignedInteger",          "RepresentsUnsignedInteger" ],

			# --- RepresentsNumber aliases ---

			[ "IsANumber",                  "RepresentsNumber" ],
			[ "IsNumberInString",           "RepresentsNumber" ],

			# --- RepresentsDecimalNumber aliases ---

			[ "IsDecimalNumber",            "RepresentsDecimalNumber" ],

			# --- RepresentsBinaryNumber aliases ---

			[ "IsBinaryNumber",             "RepresentsBinaryNumber" ],

			# --- RepresentsHexNumber aliases ---

			[ "IsHexNumber",                "RepresentsHexNumber" ],

			# --- IsChar aliases ---

			[ "IsAChar",                    "IsChar" ],

			# --- IsLetter aliases ---

			[ "IsALetter",                  "IsLetter" ],

			# --- IsWord aliases ---

			[ "IsAWord",                    "IsWord" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
