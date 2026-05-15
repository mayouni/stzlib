#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZSTRINGREPLACERXT           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Extended string replacer -- adds all        #
#                  Softanza method aliases to stzStringReplacer #
#                  via addmethod() for full fluency.            #
#                  Use stzStringReplacer for lean canonical API.#
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzStringReplacerXT from stzStringReplacer

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

			# --- ReplaceCS aliases ---

			[ "ReplaceAllCS",               "ReplaceCS" ],
			[ "ReplaceSubStringCS",         "ReplaceCS" ],

			# --- Replace aliases ---

			[ "ReplaceAll",                 "Replace" ],
			[ "ReplaceSubString",           "Replace" ],

			# --- ReplaceNthCS aliases ---

			[ "ReplaceNthOccurrenceCS",     "ReplaceNthCS" ],

			# --- ReplaceNth aliases ---

			[ "ReplaceNthOccurrence",       "ReplaceNth" ],

			# --- ReplaceFirstCS aliases ---

			[ "ReplaceFirstOccurrenceCS",   "ReplaceFirstCS" ],

			# --- ReplaceFirst aliases ---

			[ "ReplaceFirstOccurrence",     "ReplaceFirst" ],

			# --- ReplaceLastCS aliases ---

			[ "ReplaceLastOccurrenceCS",    "ReplaceLastCS" ],

			# --- ReplaceLast aliases ---

			[ "ReplaceLastOccurrence",      "ReplaceLast" ],

			# --- RemoveCS aliases ---

			[ "RemoveAllCS",                "RemoveCS" ],
			[ "RemoveSubStringCS",          "RemoveCS" ],

			# --- Remove aliases ---

			[ "RemoveAll",                  "Remove" ],
			[ "RemoveSubString",            "Remove" ],

			# --- RemoveNthCS aliases ---

			[ "RemoveNthOccurrenceCS",      "RemoveNthCS" ],

			# --- RemoveNth aliases ---

			[ "RemoveNthOccurrence",        "RemoveNth" ],

			# --- RemoveFirstCS aliases ---

			[ "RemoveFirstOccurrenceCS",    "RemoveFirstCS" ],

			# --- RemoveFirst aliases ---

			[ "RemoveFirstOccurrence",      "RemoveFirst" ],

			# --- RemoveLastCS aliases ---

			[ "RemoveLastOccurrenceCS",     "RemoveLastCS" ],

			# --- RemoveLast aliases ---

			[ "RemoveLastOccurrence",       "RemoveLast" ],

			# --- InsertBefore aliases ---

			[ "InsertAt",                   "InsertBefore" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
