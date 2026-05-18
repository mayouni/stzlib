#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STXSTRINGALIGNER          #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : String aligner extended class -- aliases    #
#                  registered via addmethod() for full fluency. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stxStringAligner from stzStringAligner

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

			# --- AlignLeft aliases ---

			[ "LeftAlign",		"AlignLeft" ],
			[ "LeftAlignQ",		"AlignLeftQ" ],
			[ "JustifyLeft",	"AlignLeft" ],

			# --- AlignRight aliases ---

			[ "RightAlign",		"AlignRight" ],
			[ "RightAlignQ",	"AlignRightQ" ],
			[ "JustifyRight",	"AlignRight" ],

			# --- AlignCenter aliases ---

			[ "CenterAlign",	"AlignCenter" ],
			[ "CenterAlignQ",	"AlignCenterQ" ],
			[ "JustifyCenter",	"AlignCenter" ],

			# --- PadLeft aliases ---

			[ "PadStart",		"PadLeft" ],
			[ "PadStartQ",		"PadLeftQ" ],

			# --- PadRight aliases ---

			[ "PadEnd",		"PadRight" ],
			[ "PadEndQ",		"PadRightQ" ],

			# --- PadBoth aliases ---

			[ "PadAll",		"PadBoth" ],
			[ "PadAllQ",		"PadBothQ" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
