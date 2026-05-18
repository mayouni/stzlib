#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STXSTRINGTRIMMER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String trimmer extended class -- aliases    #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringTrimmer from stzStringTrimmer

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

			# --- Trim aliases ---

			[ "Strip",		"Trim" ],
			[ "StripQ",		"TrimQ" ],

			# --- TrimLeft aliases ---

			[ "StripLeft",		"TrimLeft" ],
			[ "StripLeftQ",		"TrimLeftQ" ],

			# --- TrimRight aliases ---

			[ "StripRight",		"TrimRight" ],
			[ "StripRightQ",	"TrimRightQ" ],

			# --- TrimStart aliases ---

			[ "StripStart",		"TrimStart" ],
			[ "StripStartQ",	"TrimStartQ" ],

			# --- TrimEnd aliases ---

			[ "StripEnd",		"TrimEnd" ],
			[ "StripEndQ",		"TrimEndQ" ],

			# --- TrimChar aliases ---

			[ "StripChar",		"TrimChar" ],
			[ "StripCharQ",		"TrimCharQ" ],
			[ "StripCharCS",	"TrimCharCS" ],

			# --- TrimCharFromStart aliases ---

			[ "StripCharFromStart",		"TrimCharFromStart" ],
			[ "StripCharFromStartCS",	"TrimCharFromStartCS" ],

			# --- TrimCharFromEnd aliases ---

			[ "StripCharFromEnd",		"TrimCharFromEnd" ],
			[ "StripCharFromEndCS",		"TrimCharFromEndCS" ],

			# --- TrimCharFromLeft aliases ---

			[ "StripCharFromLeft",		"TrimCharFromLeft" ],
			[ "StripCharFromLeftCS",	"TrimCharFromLeftCS" ],

			# --- TrimCharFromRight aliases ---

			[ "StripCharFromRight",		"TrimCharFromRight" ],
			[ "StripCharFromRightCS",	"TrimCharFromRightCS" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
