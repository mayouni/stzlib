#--------------------------------------------------------------#
#       SOFTANZA LIBRARY (V0.9) - STXSTRINGBOUNDER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Extended string bounder -- adds all         #
#                  Softanza method aliases to stzStringBounder  #
#                  via addmethod() for full fluency.            #
#                  Use stzStringBounder for lean canonical API. #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringBounder from stzStringBounder

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

			# --- SectionCS aliases ---

			[ "SliceCS",                            "SectionCS" ],

			# --- Section aliases ---

			[ "Slice",                              "Section" ],

			# --- BetweenCS aliases ---

			[ "SubStringBetweenCS",                 "BetweenCS" ],

			# --- Between aliases ---

			[ "SubStringBetween",                   "Between" ],

			# --- BetweenCSIB aliases ---

			[ "BetweenIBCS",                        "BetweenCSIB" ],

			# --- FindSectionBoundsZZ aliases ---

			[ "FindSectionBoundsAsSections",        "FindSectionBoundsZZ" ],

			# --- IsBoundedByInCS aliases ---

			[ "IsBoundedByCSIB",                    "IsBoundedByInCS" ],

			# --- IsBoundedByIn aliases ---

			[ "IsBoundedByIB",                      "IsBoundedByIn" ],

			# --- SubStringIsBetweenCS aliases ---

			[ "SubStringComesBetweenCS",            "SubStringIsBetweenCS" ],

			# --- SubStringIsBetween aliases ---

			[ "SubStringComesBetween",              "SubStringIsBetween" ],

			# --- SubStringIsBetweenPositionsCS aliases ---

			[ "SubStringComesBetweenPositionsCS",   "SubStringIsBetweenPositionsCS" ],

			# --- SubStringIsBetweenPositions aliases ---

			[ "SubStringComesBetweenPositions",     "SubStringIsBetweenPositions" ],

			# --- SubStringIsBetweenSubStringsCS aliases ---

			[ "SubStringComesBetweenSubStringsCS",  "SubStringIsBetweenSubStringsCS" ],

			# --- SubStringIsBetweenSubStrings aliases ---

			[ "SubStringComesBetweenSubStrings",    "SubStringIsBetweenSubStrings" ],

			# --- IsBoundOfCS aliases ---

			[ "IsBoundOfInCS",                      "IsBoundOfCS" ],

			# --- IsBoundOf aliases ---

			[ "IsBoundOfIn",                        "IsBoundOf" ],

			# --- Char aliases ---

			[ "CharAt",                             "Char" ],
			[ "NthChar",                            "Char" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
