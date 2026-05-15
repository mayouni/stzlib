#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSTRINGALIGNERXT          #
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

class stzStringAlignerXT from stzStringAligner

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
			[ "JustifyLeft",	"AlignLeft" ],

			# --- AlignRight aliases ---

			[ "RightAlign",		"AlignRight" ],
			[ "JustifyRight",	"AlignRight" ],

			# --- AlignCenter aliases ---

			[ "CenterAlign",	"AlignCenter" ],
			[ "JustifyCenter",	"AlignCenter" ],

			# --- PadLeft aliases ---

			[ "PadStart",		"PadLeft" ],

			# --- PadRight aliases ---

			[ "PadEnd",		"PadRight" ]
		]

		nLen = len(_aAliases_)
		for i = 1 to nLen
			addmethod(This, _aAliases_[i][1], _aAliases_[i][2])
		next
