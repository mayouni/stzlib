#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STXSTRINGSPLITTER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Extended string splitter -- adds all        #
#                  Softanza method aliases to stzStringSplitter #
#                  via addmethod() for full fluency.            #
#                  Use stzStringSplitter for lean canonical API.#
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringSplitter from stzStringSplitter

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

			# --- SplitCS aliases ---

			[ "SplitsCS",                   "SplitCS" ],

			# --- Split aliases ---

			[ "Splits",                     "Split" ],

			# --- SplitAtCS aliases ---

			[ "SplitsAtCS",                 "SplitAtCS" ],
			[ "SeparatedByCS",              "SplitAtCS" ],

			# --- SplitAt aliases ---

			[ "SplitsAt",                   "SplitAt" ],
			[ "SeparatedBy",                "SplitAt" ],

			# --- SplitAtSubStringCS aliases ---

			[ "SplitsAtSubStringCS",        "SplitAtSubStringCS" ],

			# --- SplitAtSubString aliases ---

			[ "SplitsAtSubString",          "SplitAtSubString" ],

			# --- SplitAtSubStringsCS aliases ---

			[ "SplitsAtSubStringsCS",       "SplitAtSubStringsCS" ],

			# --- SplitAtSubStrings aliases ---

			[ "SplitsAtSubStrings",         "SplitAtSubStrings" ],

			# --- SplitAtPosition aliases ---

			[ "SplitAtThisPosition",        "SplitAtPosition" ],

			# --- SplitAtPositions aliases ---

			[ "SplitAtThesePositions",      "SplitAtPositions" ],

			# --- SplitBeforeCS aliases ---

			[ "SplitsBeforeCS",             "SplitBeforeCS" ],

			# --- SplitBefore aliases ---

			[ "SplitsBefore",               "SplitBefore" ],

			# --- SplitAfterCS aliases ---

			[ "SplitsAfterCS",              "SplitAfterCS" ],

			# --- SplitAfter aliases ---

			[ "SplitsAfter",                "SplitAfter" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
